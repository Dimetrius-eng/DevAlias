cmake_minimum_required(VERSION 3.22)

project(devalias_game_core LANGUAGES CXX)

set(DEVALIAS_GAME_CORE_SOURCES
    src/game_engine.cpp
    src/game_types.cpp
    src/word_deck.cpp
)

if(ANDROID)
  add_library(devalias_game_core SHARED ${DEVALIAS_GAME_CORE_SOURCES})
else()
  add_library(devalias_game_core STATIC ${DEVALIAS_GAME_CORE_SOURCES})
endif()

target_include_directories(devalias_game_core
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_features(devalias_game_core PUBLIC cxx_std_20)

if(MSVC)
  target_compile_options(devalias_game_core PRIVATE /W4 /WX)
else()
  target_compile_options(devalias_game_core PRIVATE -Wall -Wextra -Werror)
endif()

option(DEVALIAS_BUILD_TESTS "Build native game-core tests" ON)

if(DEVALIAS_BUILD_TESTS AND NOT ANDROID)
  enable_testing()

  function(add_game_core_test target_name source_file)
    add_executable(${target_name} ${source_file})
    target_link_libraries(${target_name} PRIVATE devalias_game_core)
    add_test(NAME ${target_name} COMMAND ${target_name})
  endfunction()

  add_game_core_test(game_types_test tests/game_types_test.cpp)
  add_game_core_test(word_deck_test tests/word_deck_test.cpp)
  add_game_core_test(game_engine_test tests/game_engine_test.cpp)
endif()