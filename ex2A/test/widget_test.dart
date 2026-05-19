import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ex2a_app/main.dart';

void main() {
  testWidgets('can open and close the item editor panel', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('ex2A: Dual List Lab'), findsOneWidget);
    expect(find.text('Lower list: Gupta Empire Board'), findsOneWidget);

    await tester.tap(find.text('Kalidasa works draft'));
    await tester.pumpAndSettle();

    expect(find.text('Item editor panel'), findsOneWidget);
    expect(find.text('Save and close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Item editor panel'), findsNothing);
    expect(find.text('Kalidasa works draft'), findsOneWidget);
  });

  testWidgets('selecting upper list item switches lower list content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Kalidasa works draft'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('board-tile-maurya')));
    await tester.pumpAndSettle();

    expect(find.text('Lower list: Maurya Empire Board'), findsOneWidget);
    expect(find.text('Arthashastra summary'), findsOneWidget);
    expect(find.text('Kalidasa works draft'), findsNothing);
  });
}
