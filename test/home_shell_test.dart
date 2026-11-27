import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayloop/data/app_store.dart';
import 'package:dayloop/screens/home_shell.dart';
import 'package:dayloop/screens/profile_screen.dart';
import 'package:dayloop/screens/self_care_day_screen.dart';

void main() {
  testWidgets('profile tab opens and Self-Care Day plan remains accessible',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    store.update((data) {
      data.selfCare.enabled = true;
      data.selfCare.weekday = store.today.weekday;
    });
    await tester.pumpWidget(
      StoreScope(
        store: store,
        child: const MaterialApp(home: HomeShell()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('bottom-tab-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bottom-tab-today')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today is your Self-Care Day'));
    await tester.pumpAndSettle();
    expect(find.byType(SelfCareDayScreen), findsOneWidget);
  });
}
