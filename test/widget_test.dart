import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/main.dart';

void main() {
  testWidgets('DevAlias start screen displays its main content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());

    expect(find.text('DevAlias'), findsOneWidget);
    expect(
      find.text('Створюйте зрозумілі імена для складного коду.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);
  });
}
