import 'difficulty.dart';
import 'word_category.dart';

class GameWord {
  const GameWord({
    required this.id,
    required this.term,
    required this.difficulty,
    required this.category,
  });

  factory GameWord.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final term = json['term'];
    final difficulty = json['difficulty'];
    final category = json['category'];

    if (id is! String ||
        term is! String ||
        difficulty is! String ||
        category is! String) {
      throw const FormatException(
        'A word must have valid id, term, difficulty, and category.',
      );
    }

    return GameWord(
      id: id,
      term: term,
      difficulty: Difficulty.fromStorageValue(difficulty),
      category: WordCategory.fromStorageValue(category),
    );
  }

  final String id;
  final String term;
  final Difficulty difficulty;
  final WordCategory category;
}
