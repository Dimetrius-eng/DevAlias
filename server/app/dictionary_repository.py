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
