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

  random_engine_.seed(shuffle_seed);
  std::shuffle(words_.begin(), words_.end(), random_engine_);
}

const Word* WordDeck::Next() {
  if (IsEmpty()) {
    return nullptr;
  }

  if (next_index_ == words_.size()) {
    std::shuffle(words_.begin(), words_.end(), random_engine_);
    if (words_.size() > 1 && has_last_word_ &&
        words_.front().id == last_word_id_) {
      std::swap(words_.front(), words_.back());
    }
    next_index_ = 0;
  }

  last_word_id_ = words_[next_index_].id;
  has_last_word_ = true;
  return &words_[next_index_++];
}

std::size_t WordDeck::RemainingCount() const {
  return words_.size() - next_index_;
}

bool WordDeck::IsEmpty() const {
  return words_.empty();
}

}  // namespace devalias
