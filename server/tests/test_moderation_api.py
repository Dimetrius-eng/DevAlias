from contextlib import contextmanager

import pytest
from fastapi import HTTPException

import app.main as api


@contextmanager
def _fake_database():
    yield object()


def _word(*, approved: bool) -> dict[str, object]:
    return {
        "source_id": "lesson29-test",
        "term": "Тестовий термін",
        "difficulty": "easy",
        "categories": ["general_it"],
        "is_approved": approved,
    }


def test_create_word_starts_pending_moderation(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(api, "open_database", _fake_database)
    monkeypatch.setattr(api, "create_word", lambda connection, **kwargs: _word(approved=False))

    word = api.create_dictionary_word(
        api.WordCreateRequest(
            source_id="lesson29-test",
            term="Тестовий термін",
            difficulty=api.Difficulty.easy,
            categories=["general_it"],
        )
    )

    assert word.is_approved is False
    assert word.source_id == "lesson29-test"


def test_moderation_publishes_word(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(api, "open_database", _fake_database)
    monkeypatch.setattr(
        api,
        "set_word_approval",
        lambda connection, *, source_id, approved: _word(approved=approved),
    )

    word = api.moderate_dictionary_word(
        "lesson29-test",
        api.ModerationRequest(approved=True),
    )

    assert word.is_approved is True


def test_editing_missing_word_returns_404(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(api, "open_database", _fake_database)
    monkeypatch.setattr(api, "update_word", lambda connection, **kwargs: None)

    with pytest.raises(HTTPException, match="Word was not found") as error:
        api.edit_dictionary_word(
            "missing",
            api.WordUpdateRequest(term="Оновлений термін"),
        )

    assert error.value.status_code == 404


def test_moderation_list_is_pending_by_default(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(api, "open_database", _fake_database)
    captured_arguments: dict[str, object] = {}

    def fake_list(connection, *, approved, limit):
        captured_arguments.update(approved=approved, limit=limit)
        return [_word(approved=False)]

    monkeypatch.setattr(api, "list_words_for_moderation", fake_list)

    words = api.read_words_for_moderation()

    assert captured_arguments == {"approved": False, "limit": 50}
    assert words[0].is_approved is False
