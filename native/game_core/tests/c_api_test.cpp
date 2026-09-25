#include <cassert>

#include "devalias/c_api.h"

int main() {
  assert(devalias_game_core_api_version() == 1);
  return 0;
}