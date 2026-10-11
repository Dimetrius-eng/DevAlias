#include <cassert>
#include <string>
#include <vector>

#include "devalias/word_deck.hpp"

namespace {

devalias::GameSettings CreateSettings() {
  return {
      .team_names = {"Frontend", "Backend"},
      .round_duration_seconds = 60,
      .round_count = 3,
      .difficulty = devalias::Difficulty::kMedium,
      .categories = {devalias::WordCategory::kGeneralIt},
  };
}

std::vector<devalias::Word> CreateWords() {
  return {
      {"medium-general-1", "Алгоритм", devalias::Difficulty::kMedium,
       devalias::WordCategory::kGeneralIt},
      {"medium-general-2", "Компілятор", devalias::Difficulty::kMedium,
       devalias::WordCategory::kGeneralIt},
      {"medium-web-1", "REST API", devalias::Difficulty::kMedium,
       devalias::WordCategory::kWebDevelopment},
      {"easy-general-1", "Браузер", devalias::Difficulty::kEasy,
       devalias::WordCategory::kGeneralIt},
  };
}

}  // namespace

int main() {
  const devalias::GameSettings settings = CreateSettings();

  devalias::WordDeck deck(CreateWords(), settings, 42);
  assert(deck.RemainingCount() == 2);

  const devalias::Word* first = deck.Next();
  const devalias::Word* second = deck.Next();
  assert(first != nullptr);
  assert(second != nullptr);
  assert(first->id != second->id);
  assert(first->difficulty == devalias::Difficulty::kMedium);
  assert(second->category == devalias::WordCategory::kGeneralIt);
  assert(deck.RemainingCount() == 0);
  assert(deck.IsEmpty());
  assert(deck.Next() == nullptr);

  devalias::WordDeck first_deck(CreateWords(), settings, 2026);
  devalias::WordDeck second_deck(CreateWords(), settings, 2026);
  assert(first_deck.Next()->id == second_deck.Next()->id);
  assert(first_deck.Next()->id == second_deck.Next()->id);

  devalias::GameSettings no_matching_words = settings;
  no_matching_words.difficulty = devalias::Difficulty::kHard;
  devalias::WordDeck empty_deck(CreateWords(), no_matching_words, 42);
  assert(empty_deck.IsEmpty());

  return 0;
}