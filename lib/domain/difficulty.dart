enum Difficulty {
  easy('Легка'),
  medium('Середня'),
  hard('Важка');

  const Difficulty(this.label);

  final String label;

  static Difficulty fromStorageValue(String value) {
    return switch (value) {
      'easy' => Difficulty.easy,
      'medium' => Difficulty.medium,
      'hard' => Difficulty.hard,
      _ => throw FormatException('Unknown difficulty: $value'),
    };
  }
}
