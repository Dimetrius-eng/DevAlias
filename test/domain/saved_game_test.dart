import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_settings.dart';
import 'package:devalias/domain/game_word.dart';
import 'package:devalias/domain/round_word_result.dart';
import 'package:devalias/domain/saved_game.dart';
import 'package:devalias/domain/team.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  test('saved game restores its full unfinished-game snapshot', () {
    const word = GameWord(
      id: 'medium-general-1',
      term: 'Алгоритм',
      difficulty: Difficulty.medium,
      category: WordCategory.generalIt,
    );
    final settings = GameSettings(
      firstTeam: const Team(name: 'Frontend'),
      secondTeam: const Team(name: 'Backend'),
      roundDuration: const Duration(seconds: 60),
      roundCount: 3,
      difficulty: Difficulty.medium,
      categories: {WordCategory.generalIt},
    );
    final savedGame = SavedGame(
      settings: settings,
      words: const [word],
      currentWordId: word.id,
      roundIndex: 2,
      firstTeamScore: 4,
      secondTeamScore: 2,
      secondsRemaining: 37,
      isPaused: true,
      isRoundFinished: false,
      roundHistory: const [
        RoundWordResult(
          word: word,
          teamName: 'Frontend',
          outcome: WordOutcome.guessed,
        ),
      ],
      gameHistory: const [
        RoundWordResult(
          word: word,
          teamName: 'Frontend',
          outcome: WordOutcome.guessed,
        ),
      ],
    );

    final restored = SavedGame.fromJson(savedGame.toJson());

    expect(restored.settings.firstTeam.name, 'Frontend');
    expect(restored.settings.secondTeam.name, 'Backend');
    expect(restored.currentWordId, word.id);
    expect(restored.roundIndex, 2);
    expect(restored.firstTeamScore, 4);
    expect(restored.secondTeamScore, 2);
    expect(restored.secondsRemaining, 37);
    expect(restored.isPaused, isTrue);
    expect(restored.gameHistory.single.word.term, 'Алгоритм');
    expect(restored.gameHistory.single.wasGuessed, isTrue);
  });
}
