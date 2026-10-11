#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace devalias {

enum class Difficulty {
  kEasy,
  kMedium,
  kHard,
};

enum class WordCategory {
  kGeneralIt,
  kProgrammingLanguages,
  kWebDevelopment,
  kDatabases,
};

struct Word {
  std::string id;
  std::string term;
  Difficulty difficulty;
  WordCategory category;
};

struct Team {
  std::string name;
  std::int32_t score = 0;
};

struct GameSettings {
  std::vector<std::string> team_names;
  std::int32_t round_duration_seconds = 60;
  std::int32_t round_count = 3;
  Difficulty difficulty = Difficulty::kMedium;
  std::vector<WordCategory> categories;

  [[nodiscard]] bool IsValid() const;
};

}  // namespace devalias