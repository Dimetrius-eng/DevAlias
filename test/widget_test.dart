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

  testWidgets('Start menu explains that navigation is coming later', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нова гра'));
    await tester.pump();

    expect(
      find.text('Цей розділ з’явиться в наступних уроках.'),
      findsOneWidget,
    );
  });
}
