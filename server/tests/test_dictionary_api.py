from contextlib import contextmanager

import pytest
from fastapi import HTTPException

import app.main as api


@contextmanager
def _fake_database():
    yield object()


def test_categories_endpoint_returns_repository_rows(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(api, "open_database", _fake_database)
    monkeypatch.setattr(
        api,
        "list_categories",
        lambda connection: [
            {
                "slug": "databases",
                "display_name_uk": "Бази даних",
                "word_count": 9,
            }
        ],
    )

    categories = api.read_categories()

    assert categories[0].slug == "databases"
    assert categories[0].word_count == 9


def test_random_word_passes_filters_to_repository(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(api, "open_database", _fake_database)
    monkeypatch.setattr(api, "category_exists", lambda connection, slug: True)
    captured_filters: dict[str, str | None] = {}

    def fake_random_word(connection, *, difficulty, category):
        captured_filters.update(difficulty=difficulty, category=category)
        return {
            "source_id": "hard-database-3",
            "term": "Реплікація",
            "difficulty": "hard",
            "categories": ["databases"],
        }

    monkeypatch.setattr(api, "random_word", fake_random_word)

    word = api.read_random_word(api.Difficulty.hard, "databases")

    assert captured_filters == {"difficulty": "hard", "category": "databases"}
    assert word.term == "Реплікація"


def test_random_word_rejects_an_unknown_category(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(api, "open_database", _fake_database)
    monkeypatch.setattr(api, "category_exists", lambda connection, slug: False)

    with pytest.raises(HTTPException, match="Category was not found") as error:
        api.read_random_word(None, "missing")

    assert error.value.status_code == 404
