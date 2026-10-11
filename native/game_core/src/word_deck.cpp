#include "devalias/word_deck.hpp"

#include <algorithm>
#include <random>

namespace devalias {

WordDeck::WordDeck(std::vector<Word> words, const GameSettings& settings,
                   std::uint32_t shuffle_seed) {
  for (Word& word : words) {
    const bool matches_difficulty = word.difficulty == settings.difficulty;
    const bool matches_category = std::find(settings.categories.begin(),
                                            settings.categories.end(),
                                            word.category) != settings.categories.end();

    if (matches_difficulty && matches_category) {
      words_.push_back(std::move(word));
    }
  }

  std::mt19937 random_engine(shuffle_seed);
  std::shuffle(words_.begin(), words_.end(), random_engine);
}

const Word* WordDeck::Next() {
  if (IsEmpty()) {
    return nullptr;
  }

  return &words_[next_index_++];
}

std::size_t WordDeck::RemainingCount() const {
  return words_.size() - next_index_;
}

bool WordDeck::IsEmpty() const {
  return next_index_ == words_.size();
}

}  // namespace devalias