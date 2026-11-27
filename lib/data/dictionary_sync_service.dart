import '../domain/game_settings.dart';
import '../domain/game_word.dart';
import 'asset_word_repository.dart';
import 'dictionary_cache.dart';
import 'remote_dictionary_api.dart';

class DictionarySyncResult {
  const DictionarySyncResult({required this.wordCount});

  final int wordCount;
}

class DictionarySyncService {
  const DictionarySyncService({
    required this.remoteSource,
    required this.cache,
  });

  final DictionaryRemoteSource remoteSource;
  final DictionaryCache cache;

  Future<DictionarySyncResult> synchronize() async {
    final words = await remoteSource.fetchDictionary();
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
