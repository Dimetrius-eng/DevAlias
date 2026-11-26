import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/game_settings.dart';
import '../domain/game_word.dart';

class AssetWordRepository {
  const AssetWordRepository();

  static const _assetPath = 'assets/data/words_uk.json';

  Future<List<GameWord>> loadWords() async {
    final source = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(source);

    if (decoded is! List) {
      throw const FormatException('The word dictionary must be a JSON list.');
    }

    return decoded
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Every dictionary entry must be an object.',
            );
          }

          return GameWord.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  Future<List<GameWord>> loadForSettings(GameSettings settings) async {
    final words = await loadWords();

    return words
        .where(
          (word) =>
              word.difficulty == settings.difficulty &&
              settings.categories.contains(word.category),
        )
        .toList(growable: false);
  }
}
