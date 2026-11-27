import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:dayloop/core/achievements.dart';
import 'package:dayloop/core/app_data.dart';
import 'package:dayloop/core/dates.dart';
import 'package:dayloop/core/models.dart';

/// Monday 2 Nov 2026, with Sunday as the Self-Care Day.
AppData _setup() {
  final start = DateTime(2026, 11, 2);
  final d = AppData.fresh(start)..onboarded = true;
  d.selfCare.weekday = DateTime.sunday;
  for (final t in kHabitTemplates.take(4)) {
    d.addHabit(
      Habit(
        id: d.newId('h'),
        title: t.title,
        minutes: t.minutes,
        liteMinutes: t.liteMinutes,
        slot: t.slot,
        icon: t.icon,
      ),
    );
  }
  return d;
}

void main() {
  final start = DateTime(2026, 11, 2);
  final sat = addDays(start, 5);
  final sun = addDays(start, 6);
  final mon = addDays(start, 7);

  group('streaks', () {
    late AppData d;
    late List<String> ids;
    setUp(() {
      d = _setup();
      ids = d.sortedHabits.map((h) => h.id).toList();
      for (var i = 0; i < 6; i++) {
        d.toggleHabit(addDays(start, i), ids[0]);
        d.toggleHabit(addDays(start, i), ids[1]);
      }
    });

    test('counts consecutive days', () => expect(d.currentStreak(sat), 6));
    test('today never breaks the streak', () => expect(d.currentStreak(sun), 6));
    test('paused Self-Care Day does not break the streak', () => expect(d.currentStreak(mon), 6));
    test('without pause a missed day breaks it', () {
      d.selfCare.pauseStreaks = false;
      expect(d.currentStreak(mon), 0);
      expect(d.bestStreak(mon), 6);
    });
    test('toggling twice clears the day', () {
      d.toggleHabit(mon, ids[2]);
      d.toggleHabit(mon, ids[2]);
      expect(d.completions.containsKey(dayKey(mon)), isFalse);
    });
  });

  group('mood-adaptive routine', () {
    test('drained mood gives Rescue with 3 habits, one is enough', () {
      final d = _setup();
      final ids = d.sortedHabits.map((h) => h.id).toList();
      d.setMood(mon, 1);
      expect(d.modeFor(mon), RoutineMode.rescue);
      expect(d.plannedHabits(mon).length, 3);
      d.toggleHabit(mon, ids[0]);
      expect(d.daySuccess(mon), isTrue);
      d.setMode(mon, RoutineMode.full);
      expect(d.daySuccess(mon), isFalse);
    });
  });

  group('badges', () {
    test('awarded once only', () {
      final d = _setup();
      d.toggleHabit(mon, d.habits.first.id);
      expect(d.evaluateAchievements(mon).newBadges.map((b) => b.id), contains('first_step'));
      expect(d.evaluateAchievements(mon).newBadges, isEmpty);
    });
  });

  group('challenges', () {
    test('one grace day, second miss fails', () {
      final d = _setup();
      expect(d.joinChallenge('hydration_7', start), isNull);
      expect(d.joinChallenge('hydration_7', start), isNotNull);
      for (var i = 0; i < 3; i++) {
        d.addWater(addDays(start, i), 8);
      }
      var st = d.challengeStatus(d.activeChallenges.first, addDays(start, 3));
      expect(st.doneDays, 3);
      expect(st.graceUsed, isFalse);
      st = d.challengeStatus(d.activeChallenges.first, addDays(start, 4));
      expect(st.graceUsed, isTrue);
      expect(st.failed, isFalse);
      final update = d.evaluateAchievements(addDays(start, 5));
      expect(update.failedChallenges.length, 1);
      expect(d.activeChallenges, isEmpty);
    });

    test('completing a challenge unlocks Challenger', () {
      final d = _setup();
      d.joinChallenge('focus_5', start);
      for (var i = 0; i < 5; i++) {
        d.addFocusSession(addDays(start, i));
      }
      final update = d.evaluateAchievements(addDays(start, 4));
      expect(update.completedChallenges.length, 1);
      expect(update.newBadges.map((b) => b.id), contains('challenger'));
    });

    test('at most $kMaxActiveChallenges at a time', () {
      final d = _setup();
      for (var i = 0; i < kMaxActiveChallenges; i++) {
        expect(d.joinChallenge(kChallenges[i].id, mon), isNull);
      }
      expect(d.joinChallenge(kChallenges[kMaxActiveChallenges].id, mon), isNotNull);
    });
  });

  group('Self-Care Day', () {
    test('preview plan is stable and has no repeats', () {
      final d = _setup();
      final a = d.selfCarePlanFor(sun).map((e) => e.title).toList();
      final b = d.selfCarePlanFor(sun).map((e) => e.title).toList();
      expect(a, b);
      expect(a.toSet().length, 5);
    });

    test('swap, surprise keeps done items, reflection cannot swap', () {
      final d = _setup();
      final rnd = Random(1);
      final before = d.selfCarePlanFor(sun)[1].title;
      expect(d.swapSelfCareItem(sun, 's1', rnd), isTrue);
      expect(d.selfCarePlanFor(sun)[1].title, isNot(before));
      expect(d.swapSelfCareItem(sun, 's4', rnd), isFalse);
      d.setSelfCareStatus(sun, 's0', ItemStatus.done);
      d.surpriseSelfCare(sun, rnd);
      expect(d.selfCarePlanFor(sun)[0].status, ItemStatus.done);
    });
  });

  group('saving', () {
    test('JSON round trip is identical', () {
      final d = _setup();
      d.toggleHabit(mon, d.habits.first.id);
      d.setJournal(mon, 'Good day');
      d.joinChallenge('journal_7', mon);
      final json = jsonEncode(d.toJson());
      expect(jsonEncode(AppData.fromJson(jsonDecode(json), mon).toJson()), json);
    });

    test('broken data never crashes', () {
      expect(AppData.fromJson('garbage', mon).habits, isEmpty);
      final broken = AppData.fromJson({
        'habits': [
          1,
          {'id': 3},
        ],
        'moods': 'x',
        'completions': {
          'a': [1],
        },
      }, mon);
      expect(broken.habits, isEmpty);
      expect(broken.onboarded, isFalse);
    });
  });
}
