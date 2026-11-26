#include <cassert>

#include "devalias/c_api.h"

int main() {
  assert(devalias_game_core_api_version() == 2);

  const devalias_word_input words[] = {{"first"}, {"second"}};
  devalias_game_session* session =
      devalias_game_session_create(1, words, 2, 42);
  assert(session != nullptr);
  assert(devalias_game_session_start_turn(session) == 1);
  assert(devalias_game_session_current_team_index(session) == 0);
  assert(devalias_game_session_current_round(session) == 1);
  assert(devalias_game_session_guess_word(session) == 1);
  assert(devalias_game_session_team_score(session, 0) == 1);
  assert(devalias_game_session_finish_turn(session) == 1);
  assert(devalias_game_session_start_turn(session) == 1);
  assert(devalias_game_session_current_team_index(session) == 1);
  assert(devalias_game_session_skip_word(session) == 1);
  assert(devalias_game_session_finish_turn(session) == 1);
  assert(devalias_game_session_is_finished(session) == 1);
  devalias_game_session_destroy(session);
  return 0;
}
