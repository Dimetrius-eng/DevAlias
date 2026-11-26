# DevAlias portable game core

This folder contains C++ rules and state that stay independent from Flutter and Android.

- `include/` exposes the C++ API.
- `src/` implements that API.
- `tests/` verifies the core with native executables.
- `CMakeLists.txt` builds a static library and tests on desktop, or the
  `libdevalias_game_core.so` shared library for Android.

The Android app includes this library through Gradle external native build.
Dart FFI calls are added in a later lesson.