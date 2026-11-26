import 'dart:convert';
import 'dart:io' show Platform;

import '../domain/completed_game.dart';
import 'game_database.dart';

abstract interface class CompletedGameStore {
  Future<void> save(CompletedGame game);
  Future<List<CompletedGame>> loadAll();
}

CompletedGameStore createCompletedGameStore() {
  return Platform.isAndroid || Platform.isIOS
      ? SqliteCompletedGameStore()
      : const _NoOpCompletedGameStore();
}

class SqliteCompletedGameStore implements CompletedGameStore {
  static const _tableName = 'completed_game';

  @override
  Future<void> save(CompletedGame game) async {
    final database = await GameDatabase.instance;
    await database.insert(_tableName, {
      'payload': jsonEncode(game.toJson()),
      'completed_at': game.completedAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<CompletedGame>> loadAll() async {
    final database = await GameDatabase.instance;
    final rows = await database.query(_tableName, orderBy: 'completed_at DESC');
    return rows.map(_gameFromRow).toList(growable: false);
  }

  CompletedGame _gameFromRow(Map<String, Object?> row) {
    final payload = row['payload'];
    final id = row['id'];
    if (payload is! String || id is! int) {
      throw const FormatException('Completed game record is invalid.');
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map) {
      throw const FormatException('Completed game record is invalid.');
    }
    return CompletedGame.fromJson(Map<String, Object?>.from(decoded), id: id);
  }
}

class _NoOpCompletedGameStore implements CompletedGameStore {
  const _NoOpCompletedGameStore();

  @override
  Future<List<CompletedGame>> loadAll() async => const [];

  @override
  Future<void> save(CompletedGame game) async {}
}
