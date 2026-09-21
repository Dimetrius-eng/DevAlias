import 'package:flutter_test/flutter_test.dart';

import 'package:devalias/main.dart';

void main() {
  testWidgets('DevAlias start screen displays the title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DevAliasApp());

    expect(find.text('DevAlias'), findsOneWidget);
  });
}
