#include "devalias/game_types.hpp"

#include <cstddef>

namespace devalias {

bool GameSettings::IsValid() const {
  if (team_names.size() < 2 || round_duration_seconds <= 0 || round_count <= 0 ||
      categories.empty()) {
    return false;
  }

  for (std::size_t first = 0; first < team_names.size(); ++first) {
    if (team_names[first].empty()) {
      return false;
    }

    for (std::size_t second = first + 1; second < team_names.size(); ++second) {
      if (team_names[first] == team_names[second]) {
        return false;
      }
    }
  }

  return true;
}

}  // namespace devalias