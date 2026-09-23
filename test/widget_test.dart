import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/main.dart';
import 'package:devalias/theme/app_theme.dart';

void main() {
  testWidgets('DevAlias start screen displays the title and theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());

    expect(find.text('DevAlias'), findsOneWidget);
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .theme
          ?.colorScheme
          .primary,
      AppTheme.primary,
    );
  });
}
