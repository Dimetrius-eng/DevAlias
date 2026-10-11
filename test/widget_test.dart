import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/game_settings.dart';
import 'package:devalias/domain/game_word.dart';
import 'package:devalias/domain/team.dart';
import 'package:devalias/domain/word_category.dart';
import 'package:devalias/main.dart';
import 'package:devalias/screens/game_page.dart';
import 'package:devalias/theme/app_theme.dart';

void main() {
  testWidgets('DevAlias start screen displays its menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());
    await tester.pumpAndSettle();

    expect(find.text('DevAlias'), findsOneWidget);
    expect(find.text('Нова гра'), findsOneWidget);
    expect(find.text('Як грати'), findsOneWidget);
    expect(find.byIcon(Icons.terminal_rounded), findsOneWidget);
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .theme
          ?.colorScheme
          .primary,
      AppTheme.primary,
    );
  });

  testWidgets('New game page lets a player choose round duration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нова гра'));
    await tester.pumpAndSettle();

    expect(find.text('Налаштування гри'), findsOneWidget);

    await tester.tap(find.text('90 с'));
    await tester.pump();

    final durationSelector = find
        .byWidgetPredicate((widget) => widget is SegmentedButton<int>)
        .first;
    expect(tester.widget<SegmentedButton<int>>(durationSelector).selected, {
      90,
    });
  });

  testWidgets('Game controls advance cards and count guessed terms', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нова гра'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Почати гру'));
    await tester.pumpAndSettle();

    expect(find.text('Раунд 1 із 3'), findsOneWidget);
    expect(find.text('Команда 1 пояснює'), findsOneWidget);
    expect(find.text('Алгоритм'), findsOneWidget);
    expect(find.text('Команда 1: 0  •  Команда 2: 0'), findsOneWidget);

    await tester.tap(find.text('Вгадано'));
    await tester.pump();

    expect(find.text('Команда 1: 1  •  Команда 2: 0'), findsOneWidget);
    expect(find.text('Компілятор'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('game-card')),
      const Offset(-500, 0),
      1000,
    );
    await tester.pump();

    expect(find.text('Команда 1: 1  •  Команда 2: 0'), findsOneWidget);
    expect(find.text('Репозиторій'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('game-card')),
      const Offset(500, 0),
      1000,
    );
    await tester.pump();

    expect(find.text('Команда 1: 2  •  Команда 2: 0'), findsOneWidget);
    expect(find.text('Алгоритм'), findsOneWidget);
  });

  testWidgets('Round timer pauses and finishes with the last word', (
    WidgetTester tester,
  ) async {
    final settings = GameSettings(
      firstTeam: const Team(name: 'Команда 1'),
      secondTeam: const Team(name: 'Команда 2'),
      roundDuration: const Duration(seconds: 2),
      roundCount: 1,
      difficulty: Difficulty.medium,
      categories: {WordCategory.generalIt},
    );
    const words = [
      GameWord(
        id: 'test-word',
        term: 'Тестовий термін',
        difficulty: Difficulty.medium,
        category: WordCategory.generalIt,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(settings: settings, words: words),
      ),
    );

    expect(find.text('00:02'), findsOneWidget);

    await tester.tap(find.byTooltip('Пауза'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Гра на паузі'), findsOneWidget);
    expect(find.text('00:02'), findsOneWidget);

    await tester.tap(find.byTooltip('Продовжити'));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Час вийшов'), findsOneWidget);
    expect(find.text('Останній термін: Тестовий термін'), findsOneWidget);
  });

  testWidgets('Next round changes the active team and keeps the score', (
    WidgetTester tester,
  ) async {
    final settings = GameSettings(
      firstTeam: const Team(name: 'Команда 1'),
      secondTeam: const Team(name: 'Команда 2'),
      roundDuration: const Duration(seconds: 1),
      roundCount: 2,
      difficulty: Difficulty.medium,
      categories: {WordCategory.generalIt},
    );
    const words = [
      GameWord(
        id: 'test-word',
        term: 'Тестовий термін',
        difficulty: Difficulty.medium,
        category: WordCategory.generalIt,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(settings: settings, words: words),
      ),
    );
    await tester.tap(find.text('Вгадано'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Наступний раунд'));
    await tester.pump();

    expect(find.text('Раунд 2 із 2'), findsOneWidget);
    expect(find.text('Команда 2 пояснює'), findsOneWidget);
    expect(find.text('Команда 1: 1  •  Команда 2: 0'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Показати підсумок партії'));
    await tester.pump();

    expect(find.text('Партію завершено'), findsOneWidget);
    expect(find.text('Команда 1 перемагає'), findsOneWidget);
  });

  testWidgets('How to play button opens the rules page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Як грати'));
    await tester.pumpAndSettle();

    expect(find.text('Правила DevAlias'), findsOneWidget);
  });
}
