import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/platform/native_game_core.dart';

void main() {
  test('native core is optional outside Android', () {
    expect(NativeGameCore.instance.apiVersion, isNull);
  });
}
