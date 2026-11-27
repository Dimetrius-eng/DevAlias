import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/data/dictionary_cache.dart';
import 'package:devalias/data/dictionary_sync_service.dart';
import 'package:devalias/data/remote_dictionary_api.dart';
import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_settings.dart';
import 'package:devalias/domain/game_word.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  test('sync replaces the offline cache with the server dictionary', () async {
    final cache = _FakeCache();
    final service = DictionarySyncService(
      remoteSource: _FakeRemoteSource([
        const GameWord(
          id: 'server-word',
          term: 'Контейнер',
          difficulty: Difficulty.medium,
          category: WordCategory.generalIt,
        ),
      ]),
      cache: cache,
    );

    final result = await service.synchronize();

    expect(result.wordCount, 1);
    expect(cache.words.single.id, 'server-word');
  });

  test(
    'sync keeps the existing cache when the server sends no words',
    () async {
      final cache = _FakeCache()
        ..words = const [
          GameWord(
            id: 'old-word',
            term: 'Старе слово',
            difficulty: Difficulty.easy,
            category: WordCategory.generalIt,
          ),
        ];
      final service = DictionarySyncService(
        remoteSource: _FakeRemoteSource(const []),
        cache: cache,
      );

      await expectLater(service.synchronize(), throwsA(isA<FormatException>()));

      expect(cache.words.single.id, 'old-word');
    },
  );
}

class _FakeRemoteSource implements DictionaryRemoteSource {
  const _FakeRemoteSource(this.words);

  final List<GameWord> words;

  @override
  Future<List<GameWord>> fetchDictionary() async => words;
}

class _FakeCache implements DictionaryCache {
  List<GameWord> words = const [];

  @override
  Future<List<GameWord>> loadForSettings(GameSettings settings) async => words
      .where(
        (word) =>
            word.difficulty == settings.difficulty &&
            settings.categories.contains(word.category),
      )
      .toList(growable: false);

  @override
  Future<DictionaryCacheInfo?> readInfo() async => words.isEmpty
      ? null
      : DictionaryCacheInfo(
          synchronizedAt: DateTime(2026),
          wordCount: words.length,
        );

  @override
  Future<void> replaceAll(List<GameWord> nextWords) async {
    words = List.unmodifiable(nextWords);
  }
}
