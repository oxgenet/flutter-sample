import 'package:ex2_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Controls summary reflects user choices', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Aiko');
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Timeline focus'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Increase confidence'));
    await tester.tap(find.text('Increase confidence'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Timeline focus'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply settings'));
    await tester.pumpAndSettle();

    expect(
      find.text('Applied status: Aiko | Beginner | Quiz | 60'),
      findsOneWidget,
    );
  });
}
