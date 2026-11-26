import 'difficulty.dart';
import 'team.dart';
import 'word_category.dart';

class GameSettings {
  GameSettings({
    required this.firstTeam,
    required this.secondTeam,
    required this.roundDuration,
    required this.roundCount,
    required this.difficulty,
    required Set<WordCategory> categories,
  }) : categories = Set.unmodifiable(categories);

  final Team firstTeam;
  final Team secondTeam;
  final Duration roundDuration;
  final int roundCount;
  final Difficulty difficulty;
  final Set<WordCategory> categories;

  bool get canStart {
    return firstTeam.hasName &&
        secondTeam.hasName &&
        firstTeam.name != secondTeam.name &&
        roundDuration > Duration.zero &&
        roundCount > 0 &&
        categories.isNotEmpty;
  }
}
