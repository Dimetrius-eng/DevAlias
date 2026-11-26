#include <cassert>
#include <vector>

#include "devalias/game_engine.hpp"

namespace {

devalias::GameSettings CreateSettings(std::int32_t round_count = 1) {
  return {
      .team_names = {"Frontend", "Backend"},
      .round_duration_seconds = 60,
      .round_count = round_count,
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
      {"medium-general-3", "Репозиторій", devalias::Difficulty::kMedium,
       devalias::WordCategory::kGeneralIt},
      {"medium-general-4", "Коміт", devalias::Difficulty::kMedium,
       devalias::WordCategory::kGeneralIt},
  };
}

}  // namespace

int main() {
  devalias::GameEngine game(CreateSettings(), CreateWords(), 42);
  assert(!game.IsFinished());
  assert(game.CurrentRound() == 0);
  assert(game.StartNextTurn());
  assert(game.IsTurnActive());
  assert(game.CurrentRound() == 1);
  assert(game.CurrentTeam()->name == "Frontend");
  assert(game.CurrentWord() != nullptr);

  assert(game.GuessCurrentWord());
  assert(game.Teams()[0].score == 1);
  assert(game.CurrentWord() != nullptr);
  assert(game.SkipCurrentWord());
  assert(game.Teams()[0].score == 1);
  assert(game.FinishCurrentTurn());

  assert(!game.IsFinished());
  assert(game.CurrentTeam()->name == "Backend");
  assert(game.StartNextTurn());
  assert(game.CurrentWord() != nullptr);
  assert(game.GuessCurrentWord());
  assert(game.Teams()[1].score == 1);
  assert(game.FinishCurrentTurn());
  assert(game.IsFinished());
  assert(game.CurrentTeam() == nullptr);
  assert(!game.StartNextTurn());

  devalias::GameSettings invalid_settings = CreateSettings();
  invalid_settings.team_names[1] = "Frontend";
  devalias::GameEngine invalid_game(invalid_settings, CreateWords(), 42);
  assert(invalid_game.IsFinished());
  assert(!invalid_game.StartNextTurn());

  return 0;
}