import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Opens the one local database used by the game.
///
/// Keeping the schema in one place prevents independent features from trying
/// to open the same SQLite file with incompatible version numbers.
class GameDatabase {
  GameDatabase._();

  static const _databaseName = 'devalias.db';
  static const version = 4;
  static Future<Database>? _database;

  static Future<Database> get instance async {
    return _database ??= openDatabase(
      path.join(await getDatabasesPath(), _databaseName),
      version: version,
      onCreate: (database, _) async {
        await _createUnfinishedGameTable(database);
        await _createCompletedGameTable(database);
        await _createLocalProfileTable(database);
      },
      onUpgrade: (database, oldVersion, _) async {
        if (oldVersion < 2) {
          // Version 1 lacked the actions needed for an exact resume.
          await database.delete(
            'unfinished_game',
            where: 'id = ?',
            whereArgs: [1],
          );
        }
        if (oldVersion < 3) {
          await _createCompletedGameTable(database);
        }
        if (oldVersion < 4) {
          await _createLocalProfileTable(database);
        }
      },
    );
  }

  static Future<void> _createUnfinishedGameTable(DatabaseExecutor database) {
    return database.execute('''
      CREATE TABLE unfinished_game (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        payload TEXT NOT NULL,
        saved_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createCompletedGameTable(DatabaseExecutor database) {
    return database.execute('''
      CREATE TABLE completed_game (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payload TEXT NOT NULL,
        completed_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createLocalProfileTable(DatabaseExecutor database) {
    return database.execute('''
      CREATE TABLE local_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        display_name TEXT NOT NULL,
        avatar_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
}
