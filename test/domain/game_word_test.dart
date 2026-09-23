import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_word.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  test('GameWord reads a valid JSON dictionary entry', () {
    final word = GameWord.fromJson({
      'id': 'medium-general-1',
      'term': 'Алгоритм',
      'difficulty': 'medium',
      'category': 'general_it',
    });

    expect(word.id, 'medium-general-1');
    expect(word.term, 'Алгоритм');
    expect(word.difficulty, Difficulty.medium);
    expect(word.category, WordCategory.generalIt);
  });

  test('GameWord rejects an incomplete JSON dictionary entry', () {
    expect(() => GameWord.fromJson({'id': 'broken'}), throwsFormatException);
  });
}
