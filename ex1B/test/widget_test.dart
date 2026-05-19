import 'package:flutter_test/flutter_test.dart';

import 'package:ex1b_app/main.dart';

void main() {
  testWidgets('can submit form input', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('English input'), 'Alice');
    await tester.enterText(find.bySemanticsLabel('Japanese input'), 'あいこ');
    await tester.enterText(
      find.bySemanticsLabel('Email input'),
      'alice@example.com',
    );

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Status: form submitted'), findsOneWidget);
    expect(find.text('English: alice'), findsOneWidget);
    expect(find.text('Japanese: あいこ'), findsOneWidget);
    expect(find.text('Email: alice@example.com'), findsOneWidget);
  });

  testWidgets('clear resets input and submitted results', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.bySemanticsLabel('English input'), 'Bob');
    await tester.enterText(find.bySemanticsLabel('Japanese input'), 'ぼぶ');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('Status: cleared input'), findsOneWidget);
    expect(find.text('English: '), findsOneWidget);
    expect(find.text('Japanese: '), findsOneWidget);
    expect(find.text('Email: '), findsOneWidget);
  });
}
