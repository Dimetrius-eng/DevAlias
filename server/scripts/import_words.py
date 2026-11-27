"""Import the offline Flutter dictionary into local PostgreSQL."""

import json
import os
from pathlib import Path
from typing import Any

import psycopg


PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DICTIONARY_PATH = PROJECT_ROOT / "assets" / "data" / "words_uk.json"
DEFAULT_DATABASE_URL = (
    "postgresql://devalias:devalias_local_password@localhost:5432/devalias"
)
VALID_DIFFICULTIES = {"easy", "medium", "hard"}


def load_words(dictionary_path: Path = DEFAULT_DICTIONARY_PATH) -> list[dict[str, str]]:
    """Load and validate the JSON dictionary shared with the Flutter MVP."""
    raw_data: Any = json.loads(dictionary_path.read_text(encoding="utf-8"))
    if not isinstance(raw_data, list):
        raise ValueError("Dictionary root must be a JSON list.")

    words: list[dict[str, str]] = []
    source_ids: set[str] = set()
    for index, item in enumerate(raw_data):
        if not isinstance(item, dict):
            raise ValueError(f"Dictionary entry {index} must be an object.")
        required_values = {
            field: item.get(field) for field in ("id", "term", "difficulty", "category")
        }
        if not all(isinstance(value, str) and value.strip() for value in required_values.values()):
            raise ValueError(f"Dictionary entry {index} is incomplete.")

        source_id = required_values["id"]
        difficulty = required_values["difficulty"]
        if difficulty not in VALID_DIFFICULTIES:
            raise ValueError(f"Dictionary entry {index} has an invalid difficulty.")
        if source_id in source_ids:
            raise ValueError(f"Dictionary contains duplicate id: {source_id}")
        source_ids.add(source_id)
        words.append({key: value.strip() for key, value in required_values.items()})

    return words


def import_words(connection: psycopg.Connection[Any], words: list[dict[str, str]]) -> int:
    """Upsert words and replace each word's category relation atomically."""
    with connection.cursor() as cursor:
        cursor.execute("SELECT id, slug FROM categories")
        category_ids = {slug: identifier for identifier, slug in cursor.fetchall()}

        for word in words:
            category_id = category_ids.get(word["category"])
            if category_id is None:
                raise ValueError(f"Database has no category: {word['category']}")

            cursor.execute(
                """
                INSERT INTO words (source_id, term, difficulty)
                VALUES (%(source_id)s, %(term)s, %(difficulty)s)
                ON CONFLICT (source_id) DO UPDATE
                SET term = EXCLUDED.term,
                    difficulty = EXCLUDED.difficulty,
                    updated_at = NOW()
                RETURNING id
                """,
                {
                    "source_id": word["id"],
                    "term": word["term"],
                    "difficulty": word["difficulty"],
                },
            )
            word_id = cursor.fetchone()[0]
            cursor.execute("DELETE FROM word_categories WHERE word_id = %s", (word_id,))
            cursor.execute(
                """
                INSERT INTO word_categories (word_id, category_id)
                VALUES (%s, %s)
                """,
                (word_id, category_id),
            )
    connection.commit()
    return len(words)


def main() -> None:
    words = load_words()
    database_url = os.getenv("DATABASE_URL", DEFAULT_DATABASE_URL)
    with psycopg.connect(database_url) as connection:
        imported_count = import_words(connection, words)
    print(f"Imported {imported_count} words into PostgreSQL.")


if __name__ == "__main__":
    main()
