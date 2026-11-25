/// Plain data models with JSON support. No Flutter imports here, so the
/// whole core layer can be unit-tested with plain Dart.
library;

enum DaySlot { morning, afternoon, evening }

extension DaySlotLabel on DaySlot {
  String get label => switch (this) {
    DaySlot.morning => 'Morning',
    DaySlot.afternoon => 'Afternoon',
    DaySlot.evening => 'Evening',
  };
}

enum RoutineMode { full, lite, rescue }

extension RoutineModeLabel on RoutineMode {
  String get label => switch (this) {
    RoutineMode.full => 'Full',
    RoutineMode.lite => 'Lite',
    RoutineMode.rescue => 'Rescue',
  };
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

int _int(Object? v, int fallback) => v is num ? v.toInt() : fallback;
String _str(Object? v, String fallback) => v is String ? v : fallback;
bool _bool(Object? v, bool fallback) => v is bool ? v : fallback;

class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.minutes,
    required this.liteMinutes,
    required this.slot,
    required this.icon,
  });

  final String id;
  String title;

  /// Duration of the full version.
  int minutes;

  /// Duration of the lite version (never more than [minutes]).
  int liteMinutes;
  DaySlot slot;

  /// Key into the icon map in the UI layer.
  String icon;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'minutes': minutes,
    'liteMinutes': liteMinutes,
    'slot': slot.name,
    'icon': icon,
  };

  static Habit? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final title = json['title'];
    if (id is! String || title is! String) return null;
    final minutes = _int(json['minutes'], 10).clamp(1, 240);
    return Habit(
      id: id,
      title: title,
      minutes: minutes,
      liteMinutes: _int(json['liteMinutes'], 5).clamp(1, minutes),
      slot: _enumByName(DaySlot.values, json['slot'], DaySlot.morning),
      icon: _str(json['icon'], 'star'),
    );
  }
}

/// Starter habits offered during onboarding.
class HabitTemplate {
  const HabitTemplate(this.title, this.minutes, this.liteMinutes, this.slot, this.icon);
  final String title;
  final int minutes;
  final int liteMinutes;
  final DaySlot slot;
  final String icon;
}

const List<HabitTemplate> kHabitTemplates = [
  HabitTemplate('Drink a glass of water', 1, 1, DaySlot.morning, 'water'),
  HabitTemplate('Morning stretch', 10, 3, DaySlot.morning, 'stretch'),
  HabitTemplate('Meditate', 10, 3, DaySlot.morning, 'meditate'),
  HabitTemplate('Deep work block', 60, 25, DaySlot.afternoon, 'focus'),
  HabitTemplate('Healthy lunch', 20, 10, DaySlot.afternoon, 'food'),
  HabitTemplate('Evening walk', 20, 10, DaySlot.evening, 'walk'),
  HabitTemplate('Read 10 pages', 15, 5, DaySlot.evening, 'book'),
  HabitTemplate('Phone off before bed', 30, 10, DaySlot.evening, 'sleep'),
];

enum ItemStatus { pending, done, skipped }

class SelfCareItem {
  SelfCareItem({
    required this.id,
    required this.category,
    required this.title,
    required this.note,
    required this.when,
    required this.minutes,
    this.status = ItemStatus.pending,
  });

  final String id;
  String category;
  String title;
  String note;
  final String when;
  int minutes;
  ItemStatus status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'title': title,
    'note': note,
    'when': when,
    'minutes': minutes,
    'status': status.name,
  };

  static SelfCareItem? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final title = json['title'];
    if (id is! String || title is! String) return null;
    return SelfCareItem(
      id: id,
      category: _str(json['category'], 'rest'),
      title: title,
      note: _str(json['note'], ''),
      when: _str(json['when'], ''),
      minutes: _int(json['minutes'], 10),
      status: _enumByName(ItemStatus.values, json['status'], ItemStatus.pending),
    );
  }
}

class SelfCareSettings {
  SelfCareSettings({
    this.enabled = true,
    this.weekday = DateTime.sunday,
    Set<String>? categories,
    this.pauseStreaks = true,
  }) : categories = categories ?? {'reading', 'meditation', 'rest', 'relaxation'};

  bool enabled;

  /// 1 = Monday ... 7 = Sunday (same as [DateTime.weekday]).
  int weekday;
  Set<String> categories;
  bool pauseStreaks;

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'weekday': weekday,
    'categories': categories.toList(),
    'pauseStreaks': pauseStreaks,
  };

  static SelfCareSettings fromJson(Object? json) {
    if (json is! Map) return SelfCareSettings();
    final cats = json['categories'];
    final set = <String>{
      if (cats is List)
        for (final c in cats)
          if (c is String) c,
    };
    return SelfCareSettings(
      enabled: _bool(json['enabled'], true),
      weekday: _int(json['weekday'], DateTime.sunday).clamp(1, 7),
      categories: set.isEmpty ? null : set,
      pauseStreaks: _bool(json['pauseStreaks'], true),
    );
  }
}

class ActiveChallenge {
  ActiveChallenge({required this.id, required this.startKey, this.graceUsed = false});

  final String id;
  final String startKey;
  bool graceUsed;

  Map<String, dynamic> toJson() => {'id': id, 'startKey': startKey, 'graceUsed': graceUsed};

  static ActiveChallenge? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final start = json['startKey'];
    if (id is! String || start is! String) return null;
    return ActiveChallenge(id: id, startKey: start, graceUsed: _bool(json['graceUsed'], false));
  }
}

class CompletedChallenge {
  CompletedChallenge({required this.id, required this.completedKey});

  final String id;
  final String completedKey;

  Map<String, dynamic> toJson() => {'id': id, 'completedKey': completedKey};

  static CompletedChallenge? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final key = json['completedKey'];
    if (id is! String || key is! String) return null;
    return CompletedChallenge(id: id, completedKey: key);
  }
}
