import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/local_player_profile.dart';

void main() {
  test('local profile trims its display name and preserves creation date', () {
    final createdAt = DateTime(2026, 11, 26);
    final profile = LocalPlayerProfile(
      displayName: '  Dima  ',
      avatar: ProfileAvatar.rocket,
      createdAt: createdAt,
    );

    final updated = profile.copyWith(displayName: 'Dev Dima');

    expect(profile.displayName, 'Dima');
    expect(updated.displayName, 'Dev Dima');
    expect(updated.avatar, ProfileAvatar.rocket);
    expect(updated.createdAt, createdAt);
  });

  test('local profile rejects an empty or too long display name', () {
    expect(
      () => LocalPlayerProfile(
        displayName: '   ',
        avatar: ProfileAvatar.terminal,
        createdAt: DateTime(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => LocalPlayerProfile(
        displayName: 'a' * 25,
        avatar: ProfileAvatar.terminal,
        createdAt: DateTime(2026),
      ),
      throwsArgumentError,
    );
  });
}
