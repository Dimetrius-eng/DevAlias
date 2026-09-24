#pragma once

#include <cstddef>
#include <cstdint>
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
  std::size_t next_index_ = 0;
};

}  // namespace devalias