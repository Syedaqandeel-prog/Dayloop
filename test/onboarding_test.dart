import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayloop/data/app_store.dart';
import 'package:dayloop/screens/onboarding_screen.dart';

void main() {
  testWidgets('requires a name before continuing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    await tester.pumpWidget(
      StoreScope(
        store: store,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What should we call you?'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What should we call you?'), findsOneWidget);
    expect(
        find.text('Please enter your name before continuing.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Aisha');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a few habits'), findsOneWidget);
  });
}
