import 'dart:convert';
import 'dart:io' show Platform;

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../domain/saved_game.dart';

abstract interface class UnfinishedGameStore {
  Future<void> save(SavedGame game);
  Future<SavedGame?> load();
  Future<void> delete();
}

UnfinishedGameStore createUnfinishedGameStore() {
  return Platform.isAndroid || Platform.isIOS
      ? SqliteUnfinishedGameStore()
      : const _NoOpUnfinishedGameStore();
}

class SqliteUnfinishedGameStore implements UnfinishedGameStore {
  static const _databaseName = 'devalias.db';
  static const _tableName = 'unfinished_game';
  Future<Database>? _database;
  Future<void> _writeQueue = Future.value();

  Future<Database> get _openDatabase async {
    return _database ??= openDatabase(
      path.join(await getDatabasesPath(), _databaseName),
      version: 2,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            payload TEXT NOT NULL,
            saved_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Version 1 did not retain every past turn, so it cannot recreate
          // the deterministic C++ deck exactly. Discard that incomplete save.
          await database.delete(_tableName, where: 'id = ?', whereArgs: [1]);
        }
      },
    );
  }

  @override
  Future<void> save(SavedGame game) {
    return _enqueue(() async {
      final database = await _openDatabase;
      await database.insert(_tableName, {
        'id': 1,
        'payload': jsonEncode(game.toJson()),
        'saved_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  @override
  Future<SavedGame?> load() async {
    final database = await _openDatabase;
    final rows = await database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (rows.isEmpty) {
      return null;
    }

    final payload = rows.single['payload'];
    if (payload is! String) {
      throw const FormatException('Saved game payload is invalid.');
    }

    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved game payload is invalid.');
    }
    return SavedGame.fromJson(decoded);
  }

  @override
  Future<void> delete() {
    return _enqueue(() async {
      final database = await _openDatabase;
      await database.delete(_tableName, where: 'id = ?', whereArgs: [1]);
    });
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _writeQueue = _writeQueue.then((_) => action());
    return _writeQueue;
  }
}

class _NoOpUnfinishedGameStore implements UnfinishedGameStore {
  const _NoOpUnfinishedGameStore();

  @override
  Future<void> delete() async {}

  @override
  Future<SavedGame?> load() async => null;

  @override
  Future<void> save(SavedGame game) async {}
}
