import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayloop/data/app_store.dart';
import 'package:dayloop/screens/achievements_screen.dart';

void main() {
  testWidgets('Challenges selector opens challenge content', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    await tester.pumpWidget(
      StoreScope(
        store: store,
        child: const MaterialApp(home: AchievementsScreen()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('achievement-tab-challenges')));
    await tester.pumpAndSettle();

    expect(find.textContaining('IN PROGRESS'), findsOneWidget);
  });
}
