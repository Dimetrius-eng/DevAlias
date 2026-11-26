import 'completed_game.dart';

enum AchievementId { firstGame, tenTerms, threeGames, perfectRound, fiftyTerms }

class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final AchievementId id;
  final String title;
  final String description;
  final bool isUnlocked;
}

/// A snapshot calculated from all locally completed parties.
class GameStatistics {
  const GameStatistics({
    required this.gamesPlayed,
    required this.guessedWords,
    required this.skippedWords,
    required this.bestSingleGameScore,
    required this.bestTeamName,
    required this.achievements,
  });

  final int gamesPlayed;
  final int guessedWords;
  final int skippedWords;
  final int bestSingleGameScore;
  final String? bestTeamName;
  final List<AchievementProgress> achievements;

  int get evaluatedWords => guessedWords + skippedWords;
  int get accuracyPercent =>
      evaluatedWords == 0 ? 0 : (guessedWords * 100 / evaluatedWords).round();
  int get unlockedAchievementCount =>
      achievements.where((achievement) => achievement.isUnlocked).length;
}

class GameStatisticsCalculator {
  const GameStatisticsCalculator._();

  static GameStatistics calculate(List<CompletedGame> games) {
    var guessedWords = 0;
    var skippedWords = 0;
    var bestSingleGameScore = 0;
    var hasPerfectGame = false;
    final teamScores = <String, int>{};

    for (final game in games) {
      guessedWords += game.history.where((result) => result.wasGuessed).length;
      skippedWords += game.history.where((result) => !result.wasGuessed).length;
      bestSingleGameScore = _max(
        bestSingleGameScore,
        _max(game.firstTeamScore, game.secondTeamScore),
      );
      if (game.history.isNotEmpty &&
          game.history.every((result) => result.wasGuessed)) {
        hasPerfectGame = true;
      }
      teamScores.update(
        game.firstTeamName,
        (score) => score + game.firstTeamScore,
        ifAbsent: () => game.firstTeamScore,
      );
      teamScores.update(
        game.secondTeamName,
        (score) => score + game.secondTeamScore,
        ifAbsent: () => game.secondTeamScore,
      );
    }

    String? bestTeamName;
    var bestTeamScore = -1;
    for (final entry in teamScores.entries) {
      if (entry.value > bestTeamScore) {
        bestTeamName = entry.key;
        bestTeamScore = entry.value;
      }
    }

    return GameStatistics(
      gamesPlayed: games.length,
      guessedWords: guessedWords,
      skippedWords: skippedWords,
      bestSingleGameScore: bestSingleGameScore,
      bestTeamName: bestTeamName,
      achievements: [
        AchievementProgress(
          id: AchievementId.firstGame,
          title: 'Перший реліз',
          description: 'Завершіть першу партію.',
          isUnlocked: games.isNotEmpty,
        ),
        AchievementProgress(
          id: AchievementId.tenTerms,
          title: 'Термінатор',
          description: 'Вгадайте 10 термінів у всіх партіях.',
          isUnlocked: guessedWords >= 10,
        ),
        AchievementProgress(
          id: AchievementId.threeGames,
          title: 'Командний гравець',
          description: 'Завершіть 3 партії.',
          isUnlocked: games.length >= 3,
        ),
        AchievementProgress(
          id: AchievementId.perfectRound,
          title: 'Без пропусків',
          description: 'Завершіть партію без пропущених слів.',
          isUnlocked: hasPerfectGame,
        ),
        AchievementProgress(
          id: AchievementId.fiftyTerms,
          title: 'Словниковий запас',
          description: 'Вгадайте 50 термінів у всіх партіях.',
          isUnlocked: guessedWords >= 50,
        ),
      ],
    );
  }

  static int _max(int first, int second) => first > second ? first : second;
}
