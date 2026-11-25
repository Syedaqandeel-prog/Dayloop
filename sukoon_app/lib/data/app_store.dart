import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_data.dart';
import '../core/dates.dart';

/// Holds [AppData], saves it on every change and tells the UI to rebuild.
/// Data stays on the device (no account or server needed).
class AppStore extends ChangeNotifier {
  AppStore._(this._prefs, this._data);

  static const String _storageKey = 'sukoon_app_data_v1';

  final SharedPreferences _prefs;
  AppData _data;
  final Random random = Random();
  final List<String> _notices = [];

  AppData get data => _data;

  DateTime get today => dateOnly(DateTime.now());

  static Future<AppStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    AppData data;
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      data = AppData.fresh(now);
    } else {
      try {
        data = AppData.fromJson(jsonDecode(raw), now);
      } catch (e) {
        debugPrint('Saved data could not be read, starting fresh: $e');
        data = AppData.fresh(now);
      }
    }
    final store = AppStore._(prefs, data);
    // Settle challenges that ended while the app was closed.
    store._evaluate();
    return store;
  }

  /// Runs [change] on the data, re-checks achievements, saves and rebuilds.
  void update(void Function(AppData data) change) {
    change(_data);
    _evaluate();
    _save();
    notifyListeners();
  }

  /// Messages for badges won and challenges finished since the last call.
  List<String> takeNotices() {
    final list = List<String>.of(_notices);
    _notices.clear();
    return list;
  }

  /// Deletes everything and returns to onboarding.
  Future<void> resetAll() async {
    _data = AppData.fresh(DateTime.now());
    _notices.clear();
    await _prefs.remove(_storageKey);
    notifyListeners();
  }

  void _evaluate() {
    // Twice, because finishing a challenge can unlock a badge.
    for (var i = 0; i < 2; i++) {
      final result = _data.evaluateAchievements(today);
      for (final b in result.newBadges) {
        _notices.add('New badge: ${b.title}');
      }
      for (final c in result.completedChallenges) {
        _notices.add('Challenge complete: ${c.title}');
      }
      for (final c in result.failedChallenges) {
        _notices.add('${c.title} ended after two missed days. You can start it again anytime.');
      }
      if (result.isEmpty) break;
    }
  }

  void _save() {
    _prefs.setString(_storageKey, jsonEncode(_data.toJson())).catchError((Object e) {
      debugPrint('Saving failed: $e');
      return false;
    });
  }
}

/// Makes the [AppStore] available to every screen.
class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child}) : super(notifier: store);

  /// Use inside `build`: the widget rebuilds when data changes.
  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'StoreScope is missing above this widget.');
    return scope!.notifier!;
  }

  /// Use in callbacks (onPressed etc.): no rebuild subscription.
  static AppStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'StoreScope is missing above this widget.');
    return scope!.notifier!;
  }
}
