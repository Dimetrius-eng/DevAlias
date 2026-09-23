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

  testWidgets('Game settings show a summary after starting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нова гра'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Почати гру'));
    await tester.pump();

    expect(find.textContaining('Партія готова:'), findsOneWidget);
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
