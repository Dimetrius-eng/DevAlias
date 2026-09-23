# DevAlias portable game core

This folder contains C++ rules and state that must stay independent from Flutter and Android.

- `include/` exposes the C++ API.
- `src/` implements that API.
- `tests/` verifies the core with a native executable.

CMake, Android NDK packaging, and Dart FFI are added in later lessons.