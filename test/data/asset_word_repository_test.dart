import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/data/asset_word_repository.dart';
import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_settings.dart';
import 'package:devalias/domain/team.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repository = AssetWordRepository();

  test('asset repository loads the offline word dictionary', () async {
    final words = await repository.loadWords();

    expect(words, hasLength(36));
    expect(words.first.term, 'Браузер');
  });

  test('asset repository filters words by game settings', () async {
    final settings = GameSettings(
      firstTeam: Team(name: 'Frontend'),
      secondTeam: Team(name: 'Backend'),
      roundDuration: const Duration(seconds: 60),
      roundCount: 3,
      difficulty: Difficulty.medium,
      categories: {WordCategory.generalIt},
    );

    final words = await repository.loadForSettings(settings);

    expect(words.map((word) => word.term), [
      'Алгоритм',
      'Компілятор',
      'Репозиторій',
    ]);
  });
}
