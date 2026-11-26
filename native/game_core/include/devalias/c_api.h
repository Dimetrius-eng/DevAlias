#pragma once

#include <stdint.h>

#if defined(_WIN32)
#define DEVALIAS_API __declspec(dllexport)
#else
#define DEVALIAS_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

DEVALIAS_API int32_t devalias_game_core_api_version(void);

typedef struct devalias_game_session devalias_game_session;

typedef struct devalias_word_input {
  const char* id;
} devalias_word_input;

DEVALIAS_API devalias_game_session* devalias_game_session_create(
    int32_t rounds_per_team, const devalias_word_input* words,
    int32_t word_count, uint32_t shuffle_seed);
DEVALIAS_API void devalias_game_session_destroy(devalias_game_session* session);
DEVALIAS_API int32_t devalias_game_session_start_turn(
    devalias_game_session* session);
DEVALIAS_API int32_t devalias_game_session_guess_word(
    devalias_game_session* session);
DEVALIAS_API int32_t devalias_game_session_skip_word(
    devalias_game_session* session);
DEVALIAS_API int32_t devalias_game_session_finish_turn(
    devalias_game_session* session);
DEVALIAS_API int32_t devalias_game_session_current_team_index(
    const devalias_game_session* session);
DEVALIAS_API int32_t devalias_game_session_current_round(
    const devalias_game_session* session);
DEVALIAS_API int32_t devalias_game_session_team_score(
    const devalias_game_session* session, int32_t team_index);
DEVALIAS_API int32_t devalias_game_session_is_finished(
    const devalias_game_session* session);
DEVALIAS_API const char* devalias_game_session_current_word_id(
    const devalias_game_session* session);

#ifdef __cplusplus
}
#endif
