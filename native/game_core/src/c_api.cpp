#include "devalias/c_api.h"

#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "devalias/game_engine.hpp"

struct devalias_game_session {
  explicit devalias_game_session(std::unique_ptr<devalias::GameEngine> value)
      : engine(std::move(value)) {}

  std::unique_ptr<devalias::GameEngine> engine;
};

namespace {

std::vector<devalias::Word> CreateWords(const devalias_word_input* words,
                                        int32_t word_count) {
  std::vector<devalias::Word> game_words;
  if (words == nullptr || word_count <= 0) {
    return game_words;
  }

  game_words.reserve(static_cast<std::size_t>(word_count));
  for (int32_t index = 0; index < word_count; ++index) {
    if (words[index].id == nullptr || words[index].id[0] == '\0') {
      continue;
    }

    const std::string id(words[index].id);
    game_words.push_back({id, id, devalias::Difficulty::kMedium,
                          devalias::WordCategory::kGeneralIt});
  }
  return game_words;
}

bool IsUsable(const devalias_game_session* session) {
  return session != nullptr && session->engine != nullptr;
}

}  // namespace

int32_t devalias_game_core_api_version(void) {
  return 2;
}

devalias_game_session* devalias_game_session_create(
    int32_t rounds_per_team, const devalias_word_input* words,
    int32_t word_count, uint32_t shuffle_seed) {
  devalias::GameSettings settings{
      .team_names = {"first", "second"},
      .round_duration_seconds = 60,
      .round_count = rounds_per_team,
      .difficulty = devalias::Difficulty::kMedium,
      .categories = {devalias::WordCategory::kGeneralIt},
  };

  auto engine = std::make_unique<devalias::GameEngine>(
      std::move(settings), CreateWords(words, word_count), shuffle_seed);
  return new devalias_game_session(std::move(engine));
}

void devalias_game_session_destroy(devalias_game_session* session) {
  delete session;
}

int32_t devalias_game_session_start_turn(devalias_game_session* session) {
  return IsUsable(session) && session->engine->StartNextTurn() ? 1 : 0;
}

int32_t devalias_game_session_guess_word(devalias_game_session* session) {
  return IsUsable(session) && session->engine->GuessCurrentWord() ? 1 : 0;
}

int32_t devalias_game_session_skip_word(devalias_game_session* session) {
  return IsUsable(session) && session->engine->SkipCurrentWord() ? 1 : 0;
}

int32_t devalias_game_session_finish_turn(devalias_game_session* session) {
  return IsUsable(session) && session->engine->FinishCurrentTurn() ? 1 : 0;
}

int32_t devalias_game_session_current_team_index(
    const devalias_game_session* session) {
  if (!IsUsable(session) || session->engine->CurrentTeam() == nullptr) {
    return -1;
  }

  const auto& teams = session->engine->Teams();
  const auto* current_team = session->engine->CurrentTeam();
  for (std::size_t index = 0; index < teams.size(); ++index) {
    if (&teams[index] == current_team) {
      return static_cast<int32_t>(index);
    }
  }
  return -1;
}

int32_t devalias_game_session_current_round(
    const devalias_game_session* session) {
  return IsUsable(session) ? session->engine->CurrentRound() : 0;
}

int32_t devalias_game_session_team_score(const devalias_game_session* session,
                                         int32_t team_index) {
  if (!IsUsable(session) || team_index < 0) {
    return 0;
  }

  const auto& teams = session->engine->Teams();
  const auto index = static_cast<std::size_t>(team_index);
  return index < teams.size() ? teams[index].score : 0;
}

int32_t devalias_game_session_is_finished(
    const devalias_game_session* session) {
  return IsUsable(session) && session->engine->IsFinished() ? 1 : 0;
}

const char* devalias_game_session_current_word_id(
    const devalias_game_session* session) {
  if (!IsUsable(session)) {
    return nullptr;
  }

  const auto* word = session->engine->CurrentWord();
  return word == nullptr ? nullptr : word->id.c_str();
}
