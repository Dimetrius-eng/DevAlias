import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

abstract final class GameFeedback {
  static final _player = AudioPlayer();

  static Future<void> guessed() async {
    await HapticFeedback.heavyImpact();
    await _play('audio/guessed.wav');
  }

  static Future<void> skipped() async {
    await HapticFeedback.mediumImpact();
    await _play('audio/skipped.wav');
  }

  static Future<void> roundFinished() async {
    await HapticFeedback.vibrate();
    await _play('audio/round_finished.wav');
  }

  static Future<void> _play(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } on Object {
      // Feedback is optional on platforms without an audio implementation.
    }
  }
}
