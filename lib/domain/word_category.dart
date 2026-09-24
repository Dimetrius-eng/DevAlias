enum WordCategory {
  generalIt('Загальні IT'),
  programmingLanguages('Мови програмування'),
  webDevelopment('Веброзробка'),
  databases('Бази даних');

  const WordCategory(this.label);

  final String label;

  static WordCategory fromStorageValue(String value) {
    return switch (value) {
      'general_it' => WordCategory.generalIt,
      'programming_languages' => WordCategory.programmingLanguages,
      'web_development' => WordCategory.webDevelopment,
      'databases' => WordCategory.databases,
      _ => throw FormatException('Unknown word category: $value'),
    };
  }
}
