from scripts.import_words import DEFAULT_DICTIONARY_PATH, load_words


def test_flutter_dictionary_is_valid_for_postgresql_import() -> None:
    words = load_words(DEFAULT_DICTIONARY_PATH)

    assert len(words) == 36
    assert words[0] == {
        "id": "easy-general-1",
        "term": "Браузер",
        "difficulty": "easy",
        "category": "general_it",
    }
    assert len({word["id"] for word in words}) == len(words)
