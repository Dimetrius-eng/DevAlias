import 'dart:io' show Platform;

import 'package:sqflite/sqflite.dart';

import '../domain/local_player_profile.dart';
import 'game_database.dart';

abstract interface class LocalProfileStore {
  Future<LocalPlayerProfile> load();
  Future<void> save(LocalPlayerProfile profile);
}

LocalProfileStore createLocalProfileStore() {
  return Platform.isAndroid || Platform.isIOS
      ? SqliteLocalProfileStore()
      : _MemoryLocalProfileStore.instance;
}

class SqliteLocalProfileStore implements LocalProfileStore {
  static const _tableName = 'local_profile';

  @override
  Future<LocalPlayerProfile> load() async {
    final database = await GameDatabase.instance;
    final rows = await database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (rows.isEmpty) {
      return LocalPlayerProfile.defaultProfile();
    }

    final row = rows.single;
    final displayName = row['display_name'];
    final avatarId = row['avatar_id'];
    final createdAt = row['created_at'];
    if (displayName is! String || avatarId is! String || createdAt is! int) {
      throw const FormatException('Local profile is invalid.');
    }
    return LocalPlayerProfile(
      displayName: displayName,
      avatar: ProfileAvatar.values.byName(avatarId),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }

  @override
  Future<void> save(LocalPlayerProfile profile) async {
    final database = await GameDatabase.instance;
    await database.insert(_tableName, {
      'id': 1,
      'display_name': profile.displayName,
      'avatar_id': profile.avatar.name,
      'created_at': profile.createdAt.millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

class _MemoryLocalProfileStore implements LocalProfileStore {
  _MemoryLocalProfileStore._();

  static final instance = _MemoryLocalProfileStore._();
  LocalPlayerProfile? _profile;

  @override
  Future<LocalPlayerProfile> load() async =>
      _profile ?? LocalPlayerProfile.defaultProfile();

  @override
  Future<void> save(LocalPlayerProfile profile) async {
    _profile = profile;
  }
}
