enum ProfileAvatar { terminal, code, lightbulb, rocket }

/// Player identity stored only on this device; it is not an online account.
class LocalPlayerProfile {
  LocalPlayerProfile({
    required String displayName,
    required this.avatar,
    required this.createdAt,
  }) : displayName = _validatedName(displayName);

  final String displayName;
  final ProfileAvatar avatar;
  final DateTime createdAt;

  factory LocalPlayerProfile.defaultProfile() {
    return LocalPlayerProfile(
      displayName: 'Гравець',
      avatar: ProfileAvatar.terminal,
      createdAt: DateTime.now(),
    );
  }

  LocalPlayerProfile copyWith({String? displayName, ProfileAvatar? avatar}) {
    return LocalPlayerProfile(
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
    );
  }

  static String _validatedName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 24) {
      throw ArgumentError.value(
        value,
        'displayName',
        'Name must contain 1–24 characters.',
      );
    }
    return trimmed;
  }
}
