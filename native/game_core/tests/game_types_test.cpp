#include <cassert>

#include "devalias/game_types.hpp"

int main() {
  devalias::GameSettings settings{
      .team_names = {"Frontend", "Backend"},
      .round_duration_seconds = 60,
      .round_count = 3,
      .difficulty = devalias::Difficulty::kMedium,
      .categories = {devalias::WordCategory::kGeneralIt},
  };

  assert(settings.IsValid());

  settings.team_names[1] = "Frontend";
  assert(!settings.IsValid());

  settings.team_names[1] = "Backend";
  settings.categories.clear();
  assert(!settings.IsValid());

  const devalias::Team team{.name = "Frontend"};
  assert(team.score == 0);

  return 0;
}