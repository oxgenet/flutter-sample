import 'package:ex3_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign in with "pass" proceeds to India History Explorer', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).first, 'Sora');
    await tester.enterText(find.byType(TextField).last, 'pass');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Sora'), findsOneWidget);
  });

  testWidgets('sign up with "pass" proceeds to India History Explorer', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).first, 'Aoi');
    await tester.enterText(find.byType(TextField).last, 'pass');
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Aoi'), findsOneWidget);
  });

  testWidgets('wrong password calls SystemNavigator.pop', (WidgetTester tester) async {
    var exitRequested = false;
    appExitHandler = () {
      exitRequested = true;
    };

    final methodCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          methodCalls.add(call);
          return null;
        });

    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).first, 'Sora');
    await tester.enterText(find.byType(TextField).last, 'wrong-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      methodCalls.any((call) => call.method == 'SystemNavigator.pop'),
      isTrue,
    );
    expect(exitRequested, isTrue);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    appExitHandler = defaultAppExitHandler;
  });
}
