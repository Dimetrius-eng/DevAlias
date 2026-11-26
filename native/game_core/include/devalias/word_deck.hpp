#pragma once

#include <cstddef>
#include <cstdint>
#include <random>
#include <string>
#include <vector>

#include "devalias/game_types.hpp"

namespace devalias {

class WordDeck {
 public:
  WordDeck(std::vector<Word> words, const GameSettings& settings,
           std::uint32_t shuffle_seed);

  [[nodiscard]] const Word* Next();
  [[nodiscard]] std::size_t RemainingCount() const;
  [[nodiscard]] bool IsEmpty() const;

 private:
  std::vector<Word> words_;
  std::mt19937 random_engine_;
  std::size_t next_index_ = 0;
  std::string last_word_id_;
  bool has_last_word_ = false;
};

}  // namespace devalias
