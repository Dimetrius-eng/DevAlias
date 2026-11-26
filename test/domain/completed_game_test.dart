import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/completed_game.dart';
import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_word.dart';
import 'package:devalias/domain/round_word_result.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  test('completed game preserves result and word history', () {
    const word = GameWord(
      id: 'api',
      term: 'API',
      difficulty: Difficulty.medium,
      category: WordCategory.generalIt,
    );
    final game = CompletedGame(
      id: 7,
      completedAt: DateTime(2026, 11, 26, 18, 30),
      firstTeamName: 'Frontend',
      secondTeamName: 'Backend',
      firstTeamScore: 3,
      secondTeamScore: 2,
      history: const [
        RoundWordResult(
          word: word,
          teamName: 'Frontend',
          outcome: WordOutcome.guessed,
        ),
      ],
    );

    final restored = CompletedGame.fromJson(game.toJson(), id: 7);

    expect(restored.id, 7);
    expect(restored.winnerName, 'Frontend');
    expect(restored.firstTeamScore, 3);
    expect(restored.history.single.word.term, 'API');
    expect(restored.history.single.wasGuessed, isTrue);
  });

  test('completed game calls equal scores a draw', () {
    final game = CompletedGame(
      completedAt: DateTime(2026, 11, 26),
      firstTeamName: 'A',
      secondTeamName: 'B',
      firstTeamScore: 4,
      secondTeamScore: 4,
      history: const [],
    );

    expect(game.winnerName, 'Нічия');
  });
}
