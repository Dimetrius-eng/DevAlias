"""SQL queries for the published DevAlias dictionary."""

from typing import Any

import psycopg


def list_categories(connection: psycopg.Connection[Any]) -> list[dict[str, Any]]:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                categories.slug,
                categories.display_name_uk,
                COUNT(word_categories.word_id) FILTER (WHERE words.is_approved)
                    AS word_count
            FROM categories
            LEFT JOIN word_categories ON word_categories.category_id = categories.id
            LEFT JOIN words ON words.id = word_categories.word_id
            GROUP BY categories.id
            ORDER BY categories.display_name_uk
            """
        )
        return list(cursor.fetchall())


def category_exists(connection: psycopg.Connection[Any], slug: str) -> bool:
    with connection.cursor() as cursor:
        cursor.execute("SELECT EXISTS(SELECT 1 FROM categories WHERE slug = %s)", (slug,))
        return cursor.fetchone()["exists"]


def random_word(
    connection: psycopg.Connection[Any],
    *,
    difficulty: str | None,
    category: str | None,
) -> dict[str, Any] | None:
    conditions = ["words.is_approved = TRUE"]
    parameters: list[str] = []
    if difficulty is not None:
        conditions.append("words.difficulty = %s")
        parameters.append(difficulty)
    if category is not None:
        conditions.append(
            """
            EXISTS (
                SELECT 1
                FROM word_categories selected_categories
                JOIN categories selected_category
                    ON selected_category.id = selected_categories.category_id
                WHERE selected_categories.word_id = words.id
                  AND selected_category.slug = %s
            )
            """
        )
        parameters.append(category)

    where_clause = " AND ".join(conditions)
    with connection.cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                words.source_id,
                words.term,
                words.difficulty,
                ARRAY_AGG(categories.slug ORDER BY categories.slug) AS categories
            FROM words
            JOIN word_categories ON word_categories.word_id = words.id
            JOIN categories ON categories.id = word_categories.category_id
            WHERE {where_clause}
            GROUP BY words.id
            ORDER BY RANDOM()
            LIMIT 1
            """,
            parameters,
        )
        return cursor.fetchone()


def get_word(connection: psycopg.Connection[Any], source_id: str) -> dict[str, Any] | None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                words.source_id,
                words.term,
                words.difficulty,
                words.is_approved,
                ARRAY_AGG(categories.slug ORDER BY categories.slug) AS categories
            FROM words
            JOIN word_categories ON word_categories.word_id = words.id
            JOIN categories ON categories.id = word_categories.category_id
            WHERE words.source_id = %s
            GROUP BY words.id
            """,
            (source_id,),
        )
        return cursor.fetchone()


def list_words_for_moderation(
    connection: psycopg.Connection[Any], *, approved: bool, limit: int
) -> list[dict[str, Any]]:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                words.source_id,
                words.term,
                words.difficulty,
                words.is_approved,
                ARRAY_AGG(categories.slug ORDER BY categories.slug) AS categories
            FROM words
            JOIN word_categories ON word_categories.word_id = words.id
            JOIN categories ON categories.id = word_categories.category_id
            WHERE words.is_approved = %s
            GROUP BY words.id
            ORDER BY words.created_at DESC
            LIMIT %s
            """,
            (approved, limit),
        )
        return list(cursor.fetchall())


def create_word(
    connection: psycopg.Connection[Any], *, source_id: str, term: str, difficulty: str, categories: list[str]
) -> dict[str, Any]:
    category_ids = _category_ids(connection, categories)
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO words (source_id, term, difficulty, is_approved)
            VALUES (%s, %s, %s, FALSE)
            """,
            (source_id, term, difficulty),
        )
        cursor.execute("SELECT id FROM words WHERE source_id = %s", (source_id,))
        word_id = cursor.fetchone()["id"]
        _replace_categories(cursor, word_id, category_ids)
    connection.commit()
    return get_word(connection, source_id)


def update_word(
    connection: psycopg.Connection[Any], *, source_id: str, changes: dict[str, Any]
) -> dict[str, Any] | None:
    existing_word = get_word(connection, source_id)
    if existing_word is None:
        return None

    categories = changes.pop("categories", None)
    category_ids = _category_ids(connection, categories) if categories is not None else None
    with connection.cursor() as cursor:
        fields = []
        parameters: list[Any] = []
        for field in ("term", "difficulty"):
            if field in changes:
                fields.append(f"{field} = %s")
                parameters.append(changes[field])
        if fields:
            fields.append("updated_at = NOW()")
            parameters.append(source_id)
            cursor.execute(
                f"UPDATE words SET {', '.join(fields)} WHERE source_id = %s",
                parameters,
            )
        if category_ids is not None:
            cursor.execute("SELECT id FROM words WHERE source_id = %s", (source_id,))
            _replace_categories(cursor, cursor.fetchone()["id"], category_ids)
    connection.commit()
    return get_word(connection, source_id)


def set_word_approval(
    connection: psycopg.Connection[Any], *, source_id: str, approved: bool
) -> dict[str, Any] | None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            UPDATE words
            SET is_approved = %s, updated_at = NOW()
            WHERE source_id = %s
            """,
            (approved, source_id),
        )
        if cursor.rowcount == 0:
            return None
    connection.commit()
    return get_word(connection, source_id)


def _category_ids(connection: psycopg.Connection[Any], slugs: list[str]) -> list[int]:
    with connection.cursor() as cursor:
        cursor.execute("SELECT id, slug FROM categories WHERE slug = ANY(%s)", (slugs,))
        identifiers_by_slug = {row["slug"]: row["id"] for row in cursor.fetchall()}
    missing_slugs = sorted(set(slugs) - identifiers_by_slug.keys())
    if missing_slugs:
        raise ValueError(f"Unknown categories: {', '.join(missing_slugs)}")
    return [identifiers_by_slug[slug] for slug in slugs]


def _replace_categories(cursor: Any, word_id: int, category_ids: list[int]) -> None:
    cursor.execute("DELETE FROM word_categories WHERE word_id = %s", (word_id,))
    cursor.executemany(
        "INSERT INTO word_categories (word_id, category_id) VALUES (%s, %s)",
        [(word_id, category_id) for category_id in category_ids],
    )
