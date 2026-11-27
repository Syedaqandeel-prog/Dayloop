/// All app data and the rules that act on it. Pure Dart (no Flutter), so
/// every rule here is covered by unit tests in `test/core_test.dart`.
library;

import 'dart:math';

import 'achievements.dart';
import 'dates.dart';
import 'models.dart';
import 'self_care_library.dart';

/// Result of re-checking achievements after a change.
class AchievementUpdate {
  AchievementUpdate();
  final List<BadgeDef> newBadges = [];
  final List<ChallengeDef> completedChallenges = [];
  final List<ChallengeDef> failedChallenges = [];

  bool get isEmpty => newBadges.isEmpty && completedChallenges.isEmpty && failedChallenges.isEmpty;
}

class AppData {
  AppData({required this.firstUseKey});

  factory AppData.fresh(DateTime now) => AppData(firstUseKey: dayKey(now));

  static const int schemaVersion = 1;

  bool onboarded = false;
  String name = '';

  /// 'system', 'light' or 'dark'.
  String themeMode = 'dark';

  /// Id of the colour scheme chosen in Settings.
  String schemeId = 'p1';

  /// Profile photo as base64 JPEG (small, resized on pick), or empty.
  String photoBase64 = '';
  String firstUseKey;
  int waterGoal = 8;

  final List<Habit> habits = [];

  /// day key -> ids of habits completed that day.
  final Map<String, Set<String>> completions = {};

  /// day key -> energy 1..5.
  final Map<String, int> moods = {};

  /// day key -> mode the user picked by hand (overrides the mood suggestion).
  final Map<String, RoutineMode> modeOverrides = {};

  final Map<String, int> water = {};
  final Map<String, String> journal = {};
  final Map<String, int> focusSessions = {};

  SelfCareSettings selfCare = SelfCareSettings();
  final Map<String, List<SelfCareItem>> selfCarePlans = {};

  /// day key -> how rested the user felt (1..5).
  final Map<String, int> restRatings = {};

  /// badge id -> day key it was earned. A badge is only ever earned once.
  final Map<String, String> earnedBadges = {};

  final List<ActiveChallenge> activeChallenges = [];
  final List<CompletedChallenge> completedChallenges = [];

  int _idCounter = 0;

  DateTime get firstUse => parseDayKey(firstUseKey);

  String newId(String prefix) {
    _idCounter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  // ---------------------------------------------------------------------------
  // Habits & routine
  // ---------------------------------------------------------------------------

  List<Habit> get sortedHabits {
    final list = [...habits];
    list.sort((a, b) => a.slot.index.compareTo(b.slot.index));
    return list;
  }

  Habit? habitById(String id) {
    for (final h in habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  /// Mood 1 = drained -> Rescue, 2 = low -> Lite, otherwise Full.
  RoutineMode suggestedMode(int? mood) {
    if (mood == null) return RoutineMode.full;
    if (mood <= 1) return RoutineMode.rescue;
    if (mood == 2) return RoutineMode.lite;
    return RoutineMode.full;
  }

  RoutineMode modeFor(DateTime day) {
    final key = dayKey(day);
    return modeOverrides[key] ?? suggestedMode(moods[key]);
  }

  /// Rescue mode keeps only the first 3 habits of the day.
  List<Habit> plannedHabits(DateTime day) {
    final list = sortedHabits;
    if (modeFor(day) == RoutineMode.rescue) return list.take(3).toList();
    return list;
  }

  int minutesFor(Habit h, RoutineMode mode) => switch (mode) {
    RoutineMode.full => h.minutes,
    RoutineMode.lite => h.liteMinutes,
    RoutineMode.rescue => min(2, h.liteMinutes),
  };

  bool isDone(DateTime day, String habitId) => completions[dayKey(day)]?.contains(habitId) ?? false;

  int doneCount(DateTime day) {
    final done = completions[dayKey(day)];
    if (done == null) return 0;
    return plannedHabits(day).where((h) => done.contains(h.id)).length;
  }

  /// A day counts when half of the planned routine is done (Rescue: 1 habit).
  bool daySuccess(DateTime day) {
    final planned = plannedHabits(day);
    if (planned.isEmpty) return false;
    final done = doneCount(day);
    if (modeFor(day) == RoutineMode.rescue) return done >= 1;
    return done >= (planned.length / 2).ceil();
  }

  /// 0 = nothing, 1 = started, 2 = most, 3 = everything.
  int dayLevel(DateTime day) {
    final planned = plannedHabits(day).length;
    if (planned == 0) return 0;
    final done = doneCount(day);
    if (done == 0) return 0;
    if (done >= planned) return 3;
    return done * 2 >= planned ? 2 : 1;
  }

  void toggleHabit(DateTime day, String habitId) {
    final key = dayKey(day);
    final set = completions.putIfAbsent(key, () => <String>{});
    if (!set.remove(habitId)) set.add(habitId);
    if (set.isEmpty) completions.remove(key);
  }

  void setMood(DateTime day, int mood) {
    final key = dayKey(day);
    moods[key] = mood.clamp(1, 5);
    // A new check-in replaces a manual choice so the routine follows the mood.
    modeOverrides.remove(key);
  }

  void setMode(DateTime day, RoutineMode mode) => modeOverrides[dayKey(day)] = mode;

  void addHabit(Habit h) => habits.add(h);

  void updateHabit(Habit updated) {
    final i = habits.indexWhere((h) => h.id == updated.id);
    if (i >= 0) habits[i] = updated;
  }

  void deleteHabit(String id) => habits.removeWhere((h) => h.id == id);

  // ---------------------------------------------------------------------------
  // Water, journal, focus
  // ---------------------------------------------------------------------------

  int waterOn(DateTime day) => water[dayKey(day)] ?? 0;

  void addWater(DateTime day, int delta) {
    final key = dayKey(day);
    final next = (waterOn(day) + delta).clamp(0, 30);
    if (next == 0) {
      water.remove(key);
    } else {
      water[key] = next;
    }
  }

  bool waterGoalMet(DateTime day) => waterOn(day) >= waterGoal;

  String journalOn(DateTime day) => journal[dayKey(day)] ?? '';

  bool hasJournal(DateTime day) => journalOn(day).trim().isNotEmpty;

  void setJournal(DateTime day, String text) {
    final key = dayKey(day);
    final clean = text.length > 280 ? text.substring(0, 280) : text;
    if (clean.trim().isEmpty) {
      journal.remove(key);
    } else {
      journal[key] = clean;
    }
  }

  int focusOn(DateTime day) => focusSessions[dayKey(day)] ?? 0;

  void addFocusSession(DateTime day) {
    final key = dayKey(day);
    focusSessions[key] = focusOn(day) + 1;
  }

  // ---------------------------------------------------------------------------
  // Streaks
  // ---------------------------------------------------------------------------

  bool isSelfCareDay(DateTime day) => selfCare.enabled && day.weekday == selfCare.weekday;

  /// On a Self-Care Day with paused streaks, a missed routine never breaks the streak.
  bool isPausedDay(DateTime day) => isSelfCareDay(day) && selfCare.pauseStreaks;

  /// Today never breaks the streak because the day is not over yet.
  int currentStreak(DateTime today) {
    final start = firstUse;
    var day = dateOnly(today);
    var streak = 0;
    if (daySuccess(day)) streak++;
    day = addDays(day, -1);
    for (var i = 0; i < 3660; i++) {
      if (day.isBefore(start)) break;
      if (daySuccess(day)) {
        streak++;
      } else if (!isPausedDay(day)) {
        break;
      }
      day = addDays(day, -1);
    }
    return streak;
  }

  int bestStreak(DateTime today) {
    final end = dateOnly(today);
    var day = firstUse;
    if (day.isAfter(end)) return 0;
    var run = 0;
    var best = 0;
    for (var i = 0; i < 3660 && !day.isAfter(end); i++) {
      if (daySuccess(day)) {
        run++;
        if (run > best) best = run;
      } else if (!isPausedDay(day) && !isSameDay(day, end)) {
        run = 0;
      }
      day = addDays(day, 1);
    }
    return best;
  }

  // ---------------------------------------------------------------------------
  // Stats used by badges
  // ---------------------------------------------------------------------------

  int get totalCompletions => completions.values.fold(0, (sum, s) => sum + s.length);

  bool morningDone(DateTime day) {
    final done = completions[dayKey(day)];
    if (done == null) return false;
    return habits.any((h) => h.slot == DaySlot.morning && done.contains(h.id));
  }

  int get morningDays {
    final morningIds = {
      for (final h in habits)
        if (h.slot == DaySlot.morning) h.id,
    };
    return completions.values.where((s) => s.any(morningIds.contains)).length;
  }

  int get waterGoalDays => water.values.where((v) => v >= waterGoal).length;

  int get journalDays => journal.values.where((t) => t.trim().isNotEmpty).length;

  int get focusTotal => focusSessions.values.fold(0, (sum, v) => sum + v);

  int get selfCareReadingDone =>
      selfCarePlans.values.expand((p) => p).where((i) => i.category == 'reading' && i.status == ItemStatus.done).length;

  int get selfCareDaysCompleted =>
      selfCarePlans.values.where((p) => p.where((i) => i.status == ItemStatus.done).length >= 3).length;

  // ---------------------------------------------------------------------------
  // Self-Care Day
  // ---------------------------------------------------------------------------

  /// Suggests the weekday with the lowest completion over the last 4 weeks.
  int suggestedSelfCareWeekday(DateTime today) {
    final totals = List<int>.filled(7, 0);
    final counts = List<int>.filled(7, 0);
    for (var i = 1; i <= 28; i++) {
      final day = addDays(today, -i);
      if (day.isBefore(firstUse)) break;
      counts[day.weekday - 1]++;
      totals[day.weekday - 1] += dayLevel(day);
    }
    if (counts.every((c) => c == 0)) return DateTime.sunday;
    var bestDay = DateTime.sunday;
    var bestScore = double.infinity;
    for (var w = 7; w >= 1; w--) {
      final c = counts[w - 1];
      if (c == 0) continue;
      final score = totals[w - 1] / c;
      if (score < bestScore) {
        bestScore = score;
        bestDay = w;
      }
    }
    return bestDay;
  }

  /// The stored plan for [day], or a preview built from a fixed seed so it
  /// looks the same every time until the user acts on it.
  List<SelfCareItem> selfCarePlanFor(DateTime day) {
    final stored = selfCarePlans[dayKey(day)];
    if (stored != null) return stored;
    return generateSelfCarePlan(selfCare.categories, Random(_seedFor(day)));
  }

  bool hasStoredPlan(DateTime day) => selfCarePlans.containsKey(dayKey(day));

  int _seedFor(DateTime day) => day.year * 10000 + day.month * 100 + day.day;

  List<SelfCareItem> _materializePlan(DateTime day) =>
      selfCarePlans.putIfAbsent(dayKey(day), () => selfCarePlanFor(day));

  void setSelfCareStatus(DateTime day, String itemId, ItemStatus status) {
    for (final item in _materializePlan(day)) {
      if (item.id == itemId) item.status = status;
    }
  }

  /// Returns false when no other suggestion is available.
  bool swapSelfCareItem(DateTime day, String itemId, Random rnd) {
    final plan = _materializePlan(day);
    for (final item in plan) {
      if (item.id != itemId) continue;
      final next = swapSuggestion(item, plan, rnd);
      if (next == null) return false;
      item
        ..title = next.title
        ..note = next.note
        ..minutes = next.minutes
        ..status = ItemStatus.pending;
      return true;
    }
    return false;
  }

  /// Builds a brand-new plan, keeping suggestions that were already done.
  void surpriseSelfCare(DateTime day, Random rnd) {
    final old = selfCarePlanFor(day);
    final fresh = generateSelfCarePlan(selfCare.categories, rnd);
    for (var i = 0; i < fresh.length && i < old.length; i++) {
      if (old[i].status == ItemStatus.done) fresh[i] = old[i];
    }
    selfCarePlans[dayKey(day)] = fresh;
  }

  void rateRest(DateTime day, int rating) => restRatings[dayKey(day)] = rating.clamp(1, 5);

  // ---------------------------------------------------------------------------
  // Achievements & challenges
  // ---------------------------------------------------------------------------

  bool isEarned(String badgeId) => earnedBadges.containsKey(badgeId);

  bool isChallengeActive(String id) => activeChallenges.any((c) => c.id == id);

  int timesCompleted(String id) => completedChallenges.where((c) => c.id == id).length;

  /// Returns an error message, or null when the user joined.
  String? joinChallenge(String id, DateTime today) {
    if (challengeById(id) == null) return 'This challenge no longer exists.';
    if (isChallengeActive(id)) return 'You are already in this challenge.';
    if (activeChallenges.length >= kMaxActiveChallenges) {
      return 'You can run up to $kMaxActiveChallenges challenges at a time.';
    }
    activeChallenges.add(ActiveChallenge(id: id, startKey: dayKey(today)));
    return null;
  }

  void leaveChallenge(String id) => activeChallenges.removeWhere((c) => c.id == id);

  /// One missed day is forgiven (grace day); a second miss fails the challenge.
  ChallengeStatus challengeStatus(ActiveChallenge active, DateTime today) {
    final def = challengeById(active.id);
    final end = dateOnly(today);
    final results = <bool?>[];
    if (def == null) {
      return const ChallengeStatus(
        doneDays: 0,
        totalDays: 1,
        graceUsed: false,
        failed: true,
        completed: false,
        dayResults: [],
      );
    }
    var day = parseDayKey(active.startKey);
    var done = 0;
    var grace = false;
    var failed = false;
    for (var i = 0; i < 400 && !day.isAfter(end) && done < def.days; i++) {
      final ok = def.check(this, day);
      if (ok) {
        done++;
        results.add(true);
      } else if (isSameDay(day, end)) {
        results.add(null);
      } else if (!grace) {
        grace = true;
        results.add(false);
      } else {
        failed = true;
        results.add(false);
        break;
      }
      day = addDays(day, 1);
    }
    return ChallengeStatus(
      doneDays: done,
      totalDays: def.days,
      graceUsed: grace,
      failed: failed,
      completed: !failed && done >= def.days,
      dayResults: results,
    );
  }

  /// Awards new badges and settles finished or failed challenges.
  AchievementUpdate evaluateAchievements(DateTime today) {
    final update = AchievementUpdate();
    final todayKey = dayKey(today);

    for (final active in [...activeChallenges]) {
      final def = challengeById(active.id);
      final status = challengeStatus(active, today);
      if (def == null) {
        activeChallenges.remove(active);
      } else if (status.failed) {
        activeChallenges.remove(active);
        update.failedChallenges.add(def);
      } else if (status.completed) {
        activeChallenges.remove(active);
        completedChallenges.add(CompletedChallenge(id: def.id, completedKey: todayKey));
        update.completedChallenges.add(def);
      } else {
        active.graceUsed = status.graceUsed;
      }
    }

    for (final badge in kBadges) {
      if (earnedBadges.containsKey(badge.id)) continue;
      if (badge.progress(this, today) >= badge.target) {
        earnedBadges[badge.id] = todayKey;
        update.newBadges.add(badge);
      }
    }
    return update;
  }

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
    'schema': schemaVersion,
    'onboarded': onboarded,
    'name': name,
    'firstUseKey': firstUseKey,
    'waterGoal': waterGoal,
    'habits': [for (final h in habits) h.toJson()],
    'completions': {for (final e in completions.entries) e.key: e.value.toList()},
    'moods': moods,
    'modeOverrides': {for (final e in modeOverrides.entries) e.key: e.value.name},
    'water': water,
    'journal': journal,
    'focusSessions': focusSessions,
    'selfCare': selfCare.toJson(),
    'selfCarePlans': {
      for (final e in selfCarePlans.entries) e.key: [for (final i in e.value) i.toJson()],
    },
    'restRatings': restRatings,
    'earnedBadges': earnedBadges,
    'activeChallenges': [for (final c in activeChallenges) c.toJson()],
    'completedChallenges': [for (final c in completedChallenges) c.toJson()],
  };

  /// Tolerant parser: anything malformed is skipped instead of crashing.
  static AppData fromJson(Object? json, DateTime now) {
    if (json is! Map) return AppData.fresh(now);
    final firstUse = json['firstUseKey'];
    final data = AppData(firstUseKey: firstUse is String && tryParseDayKey(firstUse) != null ? firstUse : dayKey(now));
    data.onboarded = json['onboarded'] == true;
    data.name = json['name'] is String ? json['name'] as String : '';
    final mode = json['themeMode'];
    data.themeMode = mode == 'light' || mode == 'system' ? mode as String : 'dark';
    final scheme = json['schemeId'];
    data.schemeId = scheme is String && scheme.isNotEmpty ? scheme : 'p1';
    final photo = json['photo'];
    data.photoBase64 = photo is String ? photo : '';
    final goal = json['waterGoal'];
    data.waterGoal = goal is num ? goal.toInt().clamp(1, 20) : 8;

    final habits = json['habits'];
    if (habits is List) {
      for (final h in habits) {
        final parsed = Habit.fromJson(h);
        if (parsed != null) data.habits.add(parsed);
      }
    }

    final comps = json['completions'];
    if (comps is Map) {
      comps.forEach((k, v) {
        if (k is String && v is List) {
          final set = {
            for (final id in v)
              if (id is String) id,
          };
          if (set.isNotEmpty) data.completions[k] = set;
        }
      });
    }

    _readIntMap(json['moods'], data.moods);
    _readIntMap(json['water'], data.water);
    _readIntMap(json['focusSessions'], data.focusSessions);
    _readIntMap(json['restRatings'], data.restRatings);

    final modes = json['modeOverrides'];
    if (modes is Map) {
      modes.forEach((k, v) {
        if (k is! String) return;
        for (final m in RoutineMode.values) {
          if (m.name == v) data.modeOverrides[k] = m;
        }
      });
    }

    _readStringMap(json['journal'], data.journal);
    _readStringMap(json['earnedBadges'], data.earnedBadges);

    data.selfCare = SelfCareSettings.fromJson(json['selfCare']);

    final plans = json['selfCarePlans'];
    if (plans is Map) {
      plans.forEach((k, v) {
        if (k is String && v is List) {
          final items = [for (final i in v) SelfCareItem.fromJson(i)].whereType<SelfCareItem>().toList();
          if (items.isNotEmpty) data.selfCarePlans[k] = items;
        }
      });
    }

    final active = json['activeChallenges'];
    if (active is List) {
      for (final c in active) {
        final parsed = ActiveChallenge.fromJson(c);
        if (parsed != null && !data.isChallengeActive(parsed.id)) data.activeChallenges.add(parsed);
      }
    }
    final completed = json['completedChallenges'];
    if (completed is List) {
      for (final c in completed) {
        final parsed = CompletedChallenge.fromJson(c);
        if (parsed != null) data.completedChallenges.add(parsed);
      }
    }
    return data;
  }

  static void _readIntMap(Object? src, Map<String, int> into) {
    if (src is! Map) return;
    src.forEach((k, v) {
      if (k is String && v is num) into[k] = v.toInt();
    });
  }

  static void _readStringMap(Object? src, Map<String, String> into) {
    if (src is! Map) return;
    src.forEach((k, v) {
      if (k is String && v is String) into[k] = v;
    });
  }
}
