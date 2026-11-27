import 'package:sqflite/sqflite.dart';

import '../domain/difficulty.dart';
import '../domain/game_settings.dart';
import '../domain/game_word.dart';
import '../domain/word_category.dart';
import 'game_database.dart';

class DictionaryCacheInfo {
  const DictionaryCacheInfo({
    required this.synchronizedAt,
    required this.wordCount,
  });

  final DateTime synchronizedAt;
  final int wordCount;
}

abstract class DictionaryCache {
  Future<void> replaceAll(List<GameWord> words);
  Future<List<GameWord>> loadForSettings(GameSettings settings);
  Future<DictionaryCacheInfo?> readInfo();
}

class SqliteDictionaryCache implements DictionaryCache {
  const SqliteDictionaryCache();

  static const _wordsTable = 'dictionary_word';
  static const _infoTable = 'dictionary_cache_info';

  @override
  Future<void> replaceAll(List<GameWord> words) async {
    final database = await GameDatabase.instance;
    final synchronizedAt = DateTime.now().millisecondsSinceEpoch;
    await database.transaction((transaction) async {
      await transaction.delete(_wordsTable);
      final batch = transaction.batch();
      for (final word in words) {
        batch.insert(_wordsTable, {
          'source_id': word.id,
          'term': word.term,
          'difficulty': word.difficulty.name,
          'category': word.category.storageValue,
        });
      }
      batch.insert(_infoTable, {
        'id': 1,
        'synchronized_at': synchronizedAt,
        'word_count': words.length,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<List<GameWord>> loadForSettings(GameSettings settings) async {
    final database = await GameDatabase.instance;
    final rows = await database.query(
      _wordsTable,
      where:
          'difficulty = ? AND category IN (${_placeholders(settings.categories.length)})',
      whereArgs: [
        settings.difficulty.name,
        ...settings.categories.map((category) => category.storageValue),
      ],
      orderBy: 'source_id',
    );
    return rows
        .map(
          (row) => GameWord(
            id: row['source_id']! as String,
            term: row['term']! as String,
            difficulty: Difficulty.fromStorageValue(
              row['difficulty']! as String,
            ),
            category: WordCategory.fromStorageValue(row['category']! as String),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<DictionaryCacheInfo?> readInfo() async {
    final database = await GameDatabase.instance;
    final rows = await database.query(
      _infoTable,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.single;
    return DictionaryCacheInfo(
      synchronizedAt: DateTime.fromMillisecondsSinceEpoch(
        row['synchronized_at']! as int,
      ),
      wordCount: row['word_count']! as int,
    );
  }

  String _placeholders(int count) => List.filled(count, '?').join(', ');
}
