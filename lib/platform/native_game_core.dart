import 'dart:ffi';
import 'dart:io' show Platform;

class NativeGameCore {
  NativeGameCore._();

  static final instance = NativeGameCore._();

  int? get apiVersion {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final library = DynamicLibrary.open('libdevalias_game_core.so');
      final readVersion = library
          .lookupFunction<Int32 Function(), int Function()>(
            'devalias_game_core_api_version',
          );
      return readVersion();
    } on ArgumentError {
      return null;
    }
  }
}
