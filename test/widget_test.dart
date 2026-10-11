import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/main.dart';
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
    expect(find.text('Рахунок: 0'), findsOneWidget);

    await tester.tap(find.text('Вгадано'));
    await tester.pump();

    expect(find.text('Рахунок: 1'), findsOneWidget);
    expect(find.text('Компілятор'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('game-card')),
      const Offset(-500, 0),
      1000,
    );
    await tester.pump();

    expect(find.text('Рахунок: 1'), findsOneWidget);
    expect(find.text('Репозиторій'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('game-card')),
      const Offset(500, 0),
      1000,
    );
    await tester.pump();

    expect(find.text('Рахунок: 2'), findsOneWidget);
    expect(find.text('Алгоритм'), findsOneWidget);
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
