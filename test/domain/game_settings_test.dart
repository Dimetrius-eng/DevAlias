import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_settings.dart';
import 'package:devalias/domain/team.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  GameSettings createSettings({
    String firstTeamName = 'Frontend',
    String secondTeamName = 'Backend',
    int roundCount = 3,
    Set<WordCategory> categories = const {WordCategory.generalIt},
  }) {
    return GameSettings(
      firstTeam: Team(name: firstTeamName),
      secondTeam: Team(name: secondTeamName),
      roundDuration: const Duration(seconds: 60),
      roundCount: roundCount,
      difficulty: Difficulty.medium,
      categories: categories,
    );
  }

  test('complete game settings can start a game', () {
    final settings = createSettings();

    expect(settings.canStart, isTrue);
    expect(settings.roundDuration.inSeconds, 60);
    expect(settings.difficulty.label, 'Середня');
  });

  test('game settings cannot start with invalid team names or categories', () {
    expect(createSettings(firstTeamName: '').canStart, isFalse);
    expect(
      createSettings(
        firstTeamName: 'Одна команда',
        secondTeamName: 'Одна команда',
      ).canStart,
      isFalse,
    );
    expect(createSettings(categories: {}).canStart, isFalse);
  });

  test('game settings protect their category set from external changes', () {
    final selected = <WordCategory>{WordCategory.generalIt};
    final settings = createSettings(categories: selected);
    selected.add(WordCategory.databases);

    expect(settings.categories, {WordCategory.generalIt});
  });
}
