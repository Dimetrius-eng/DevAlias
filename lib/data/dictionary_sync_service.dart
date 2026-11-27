import 'dart:async';

import '../domain/game_settings.dart';
import '../domain/game_word.dart';
import 'asset_word_repository.dart';
import 'dictionary_cache.dart';
import 'remote_dictionary_api.dart';

class DictionarySyncResult {
  const DictionarySyncResult({required this.wordCount});

  final int wordCount;
}

class DictionarySyncUnavailableException implements Exception {
  const DictionarySyncUnavailableException(this.cause);

  final Object cause;

  @override
  String toString() => 'Server sync is unavailable: $cause';
}

class DictionarySyncService {
  const DictionarySyncService({
    required this.remoteSource,
    required this.cache,
  });

  final DictionaryRemoteSource remoteSource;
  final DictionaryCache cache;

  Future<DictionarySyncResult> synchronize() async {
    final List<GameWord> words;
    try {
      words = await remoteSource.fetchDictionary().timeout(
        const Duration(seconds: 10),
      );
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw DictionarySyncUnavailableException(error);
    }
    if (words.isEmpty) {
      throw const FormatException('The server dictionary cannot be empty.');
    }
    await cache.replaceAll(words);
    return DictionarySyncResult(wordCount: words.length);
  }
}

class OfflineFirstWordRepository {
  const OfflineFirstWordRepository({
    required this.cache,
    this.assetRepository = const AssetWordRepository(),
  });

  final DictionaryCache cache;
  final AssetWordRepository assetRepository;

  Future<List<GameWord>> loadForSettings(GameSettings settings) async {
    try {
      final cacheInfo = await cache.readInfo();
      if (cacheInfo != null) {
        return await cache.loadForSettings(settings);
      }
    } on Object {
      // The bundled dictionary is a safe fallback if SQLite is unavailable.
    }
    return assetRepository.loadForSettings(settings);
  }
}
