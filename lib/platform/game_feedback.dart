import 'package:flutter/services.dart';

abstract final class GameFeedback {
  static Future<void> guessed() async {
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> skipped() async {
    await HapticFeedback.selectionClick();
    await SystemSound.play(SystemSoundType.click);
  }
}
