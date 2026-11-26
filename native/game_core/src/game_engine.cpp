#include "devalias/game_engine.hpp"

#include <utility>

namespace devalias {

GameEngine::GameEngine(GameSettings settings, std::vector<Word> words,
                       std::uint32_t shuffle_seed)
    : settings_(std::move(settings)),
      deck_(std::move(words), settings_, shuffle_seed) {
  for (const std::string& team_name : settings_.team_names) {
    teams_.push_back({.name = team_name});
  }

  finished_ = !settings_.IsValid() || deck_.IsEmpty();
}

bool GameEngine::StartNextTurn() {
  if (turn_active_ || finished_) {
    return false;
  }

  if (current_round_ == 0) {
    current_round_ = 1;
  }

  AdvanceToNextWord();
  if (current_word_ == nullptr) {
    finished_ = true;
    return false;
  }

  turn_active_ = true;
  return true;
}

bool GameEngine::GuessCurrentWord() {
  if (!turn_active_ || current_word_ == nullptr) {
    return false;
  }

  ++teams_[current_team_index_].score;
  AdvanceToNextWord();
  return true;
}

bool GameEngine::SkipCurrentWord() {
  if (!turn_active_ || current_word_ == nullptr) {
    return false;
  }

  AdvanceToNextWord();
  return true;
}

bool GameEngine::FinishCurrentTurn() {
  if (!turn_active_) {
    return false;
  }

  turn_active_ = false;
  current_word_ = nullptr;
  ++current_team_index_;

  if (current_team_index_ == teams_.size()) {
    current_team_index_ = 0;
    ++current_round_;
  }

  if (current_round_ > settings_.round_count) {
    finished_ = true;
  }

  return true;
}

const std::vector<Team>& GameEngine::Teams() const {
  return teams_;
}

const Team* GameEngine::CurrentTeam() const {
  if (finished_ || teams_.empty()) {
    return nullptr;
  }

  return &teams_[current_team_index_];
}

const Word* GameEngine::CurrentWord() const {
  return current_word_;
}

std::int32_t GameEngine::CurrentRound() const {
  return current_round_;
}

bool GameEngine::IsTurnActive() const {
  return turn_active_;
}

bool GameEngine::IsFinished() const {
  return finished_;
}

void GameEngine::AdvanceToNextWord() {
  current_word_ = deck_.Next();
}

}  // namespace devalias