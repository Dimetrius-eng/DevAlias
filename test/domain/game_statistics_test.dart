import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/completed_game.dart';
import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_statistics.dart';
import 'package:devalias/domain/game_word.dart';
import 'package:devalias/domain/round_word_result.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  const api = GameWord(
    id: 'api',
    term: 'API',
    difficulty: Difficulty.medium,
    category: WordCategory.generalIt,
  );
  const cache = GameWord(
    id: 'cache',
    term: 'Кеш',
    difficulty: Difficulty.medium,
    category: WordCategory.generalIt,
  );

  test('statistics aggregate completed games and unlock achievements', () {
    final games = [
      CompletedGame(
        completedAt: DateTime(2026, 11, 26),
        firstTeamName: 'Frontend',
        secondTeamName: 'Backend',
        firstTeamScore: 2,
        secondTeamScore: 1,
        history: const [
          RoundWordResult(
            word: api,
            teamName: 'Frontend',
            outcome: WordOutcome.guessed,
          ),
          RoundWordResult(
            word: cache,
            teamName: 'Frontend',
            outcome: WordOutcome.guessed,
          ),
          RoundWordResult(
            word: api,
            teamName: 'Backend',
            outcome: WordOutcome.guessed,
          ),
        ],
      ),
      CompletedGame(
        completedAt: DateTime(2026, 11, 25),
        firstTeamName: 'Frontend',
        secondTeamName: 'Backend',
        firstTeamScore: 1,
        secondTeamScore: 0,
        history: const [
          RoundWordResult(
            word: cache,
            teamName: 'Frontend',
            outcome: WordOutcome.guessed,
          ),
          RoundWordResult(
            word: api,
            teamName: 'Backend',
            outcome: WordOutcome.skipped,
          ),
        ],
      ),
    ];

    final statistics = GameStatisticsCalculator.calculate(games);

    expect(statistics.gamesPlayed, 2);
    expect(statistics.guessedWords, 4);
    expect(statistics.skippedWords, 1);
    expect(statistics.accuracyPercent, 80);
    expect(statistics.bestSingleGameScore, 2);
    expect(statistics.bestTeamName, 'Frontend');
    expect(
      statistics.achievements
          .firstWhere(
            (achievement) => achievement.id == AchievementId.firstGame,
          )
          .isUnlocked,
      isTrue,
    );
    expect(
      statistics.achievements
          .firstWhere(
            (achievement) => achievement.id == AchievementId.perfectRound,
          )
          .isUnlocked,
      isTrue,
    );
  });

  test('empty history has zero statistics and no unlocked achievements', () {
    final statistics = GameStatisticsCalculator.calculate(const []);

    expect(statistics.gamesPlayed, 0);
    expect(statistics.accuracyPercent, 0);
    expect(statistics.bestTeamName, isNull);
    expect(statistics.unlockedAchievementCount, 0);
  });
}
