#pragma once

#include <cstddef>
#include <cstdint>
#include <vector>

#include "devalias/game_types.hpp"
#include "devalias/word_deck.hpp"

namespace devalias {

class GameEngine {
 public:
  GameEngine(GameSettings settings, std::vector<Word> words,
             std::uint32_t shuffle_seed);

  [[nodiscard]] bool StartNextTurn();
  [[nodiscard]] bool GuessCurrentWord();
  [[nodiscard]] bool SkipCurrentWord();
  [[nodiscard]] bool FinishCurrentTurn();

  [[nodiscard]] const std::vector<Team>& Teams() const;
  [[nodiscard]] const Team* CurrentTeam() const;
  [[nodiscard]] const Word* CurrentWord() const;
  [[nodiscard]] std::int32_t CurrentRound() const;
  [[nodiscard]] bool IsTurnActive() const;
  [[nodiscard]] bool IsFinished() const;

 private:
  void AdvanceToNextWord();

  GameSettings settings_;
  std::vector<Team> teams_;
  WordDeck deck_;
  std::size_t current_team_index_ = 0;
  std::int32_t current_round_ = 0;
  const Word* current_word_ = nullptr;
  bool turn_active_ = false;
  bool finished_ = false;
};

}  // namespace devalias