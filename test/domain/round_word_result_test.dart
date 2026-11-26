import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_word.dart';
import 'package:devalias/domain/round_word_result.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  const word = GameWord(
    id: 'test-word',
    term: 'Алгоритм',
    difficulty: Difficulty.medium,
    category: WordCategory.generalIt,
  );

  test('round word result identifies a guessed word', () {
    const result = RoundWordResult(
      word: word,
      teamName: 'Команда 1',
      outcome: WordOutcome.guessed,
    );

    expect(result.wasGuessed, isTrue);
  });

  test('round word result identifies a skipped word', () {
    const result = RoundWordResult(
      word: word,
      teamName: 'Команда 1',
      outcome: WordOutcome.skipped,
    );

    expect(result.wasGuessed, isFalse);
  });
}
