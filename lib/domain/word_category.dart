enum WordCategory {
  generalIt('Загальні IT'),
  programmingLanguages('Мови програмування'),
  webDevelopment('Веброзробка'),
  databases('Бази даних');

  const WordCategory(this.label);

  final String label;

  String get storageValue => switch (this) {
    WordCategory.generalIt => 'general_it',
    WordCategory.programmingLanguages => 'programming_languages',
    WordCategory.webDevelopment => 'web_development',
    WordCategory.databases => 'databases',
  };

  static WordCategory fromStorageValue(String value) {
    return WordCategory.values.firstWhere(
      (category) => category.storageValue == value,
      orElse: () => throw FormatException('Unknown word category: $value'),
    );
  }
}
