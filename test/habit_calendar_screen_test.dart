import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayloop/core/dates.dart';
import 'package:dayloop/core/models.dart';
import 'package:dayloop/data/app_store.dart';
import 'package:dayloop/screens/habit_calendar_screen.dart';

void main() {
  testWidgets(
      'shows selected habits as completed today and missed on past days',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    final today = store.today;
    final yesterday = addDays(today, -1);
    final habit = Habit(
      id: 'daily_reading',
      title: 'Daily reading',
      minutes: 10,
      liteMinutes: 5,
      slot: DaySlot.morning,
      icon: 'book',
    );
    final otherHabit = Habit(
      id: 'morning_walk',
      title: 'Morning walk',
      minutes: 10,
      liteMinutes: 5,
      slot: DaySlot.afternoon,
      icon: 'walk',
    );
    store.update((data) {
      data.firstUseKey = dayKey(yesterday);
      data.addHabit(habit);
      data.addHabit(otherHabit);
      data.toggleHabit(today, habit.id);
    });

    await tester.pumpWidget(
      StoreScope(
        store: store,
        child: const MaterialApp(home: HabitCalendarScreen()),
      ),
    );

    expect(find.text('Daily reading'), findsOneWidget);
    expect(find.text('Morning walk'), findsOneWidget);
    expect(find.text('Completed'), findsNWidgets(2));

    await tester.tap(
      find.bySemanticsLabel(
          '${kWeekdayNames[yesterday.weekday - 1]}, ${yesterday.day}'),
    );
    await tester.pumpAndSettle();

    expect(find.text(prettyDate(yesterday)), findsOneWidget);
    expect(find.text('Daily reading'), findsOneWidget);
    expect(find.text('Morning walk'), findsOneWidget);
    expect(find.text('Missed'), findsNWidgets(3));
  });
}
