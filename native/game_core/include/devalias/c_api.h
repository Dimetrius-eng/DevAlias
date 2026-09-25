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

#ifdef __cplusplus
}
#endif