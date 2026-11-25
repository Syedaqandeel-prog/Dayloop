/// Suggestions used to build the weekly Self-Care Day plan.
library;

import 'dart:math';

import 'models.dart';

class SelfCareSuggestion {
  const SelfCareSuggestion(this.title, this.note, this.minutes);
  final String title;
  final String note;
  final int minutes;
}

class SelfCareCategory {
  const SelfCareCategory(this.id, this.label, this.icon);
  final String id;
  final String label;
  final String icon;
}

const List<SelfCareCategory> kSelfCareCategories = [
  SelfCareCategory('reading', 'Reading', 'book'),
  SelfCareCategory('meditation', 'Meditation', 'meditate'),
  SelfCareCategory('rest', 'Rest', 'sleep'),
  SelfCareCategory('relaxation', 'Relaxation', 'waves'),
];

String selfCareCategoryLabel(String id) {
  if (id == 'reflection') return 'Reflection';
  for (final c in kSelfCareCategories) {
    if (c.id == id) return c.label;
  }
  return id;
}

const Map<String, List<SelfCareSuggestion>> kSelfCareLibrary = {
  'reading': [
    SelfCareSuggestion('Read 20 pages', 'Continue a book you already started', 25),
    SelfCareSuggestion('Read in the sun', 'Take your book near a window or outside', 20),
    SelfCareSuggestion('Read something light', 'Short stories, poetry or a magazine', 15),
    SelfCareSuggestion('Re-read a favourite chapter', 'Comfort reading counts too', 15),
  ],
  'meditation': [
    SelfCareSuggestion('Body-scan meditation', 'Lie down and relax one body part at a time', 10),
    SelfCareSuggestion('Box breathing', 'In 4, hold 4, out 4, hold 4', 5),
    SelfCareSuggestion('Gratitude meditation', 'Think of three people you are thankful for', 10),
    SelfCareSuggestion('Silent sitting', 'Just sit quietly with your eyes closed', 10),
  ],
  'rest': [
    SelfCareSuggestion('Screen-free nap', 'Phone in another room, set a gentle alarm', 25),
    SelfCareSuggestion('Lie down and listen', 'Soft sounds or silence, no scrolling', 15),
    SelfCareSuggestion('Early night', 'Lights out 30 minutes earlier than usual', 30),
    SelfCareSuggestion('Slow morning', 'No alarm and no rush today', 30),
  ],
  'relaxation': [
    SelfCareSuggestion('Slow walk and chai', 'No goal, no step count, just a walk', 30),
    SelfCareSuggestion('Warm shower and fresh clothes', 'A small reset for body and mind', 15),
    SelfCareSuggestion('Call someone you love', 'A relaxed chat, nothing urgent', 20),
    SelfCareSuggestion('Tidy one small corner', 'A calm space for a calm mind', 15),
    SelfCareSuggestion('Listen to a full album', 'Something you have not heard in a while', 40),
  ],
};

const SelfCareSuggestion kReflection = SelfCareSuggestion(
  'Write 3 good things',
  'Close your week with what went well',
  5,
);

const List<String> kSelfCareSlots = ['Morning', 'Late morning', 'Afternoon', 'Evening'];

/// Which category fits each slot best, when the user selected it.
const List<String> _preferredBySlot = ['meditation', 'reading', 'rest', 'relaxation'];

/// Builds a 5-item plan: four suggestions from the selected categories plus
/// a closing reflection at night. Never repeats a suggestion in one plan.
List<SelfCareItem> generateSelfCarePlan(Set<String> categories, Random rnd) {
  final selected = [
    for (final c in kSelfCareCategories)
      if (categories.contains(c.id)) c.id,
  ];
  if (selected.isEmpty) selected.add('rest');

  final used = <String>{};
  final items = <SelfCareItem>[];
  for (var i = 0; i < kSelfCareSlots.length; i++) {
    final preferred = _preferredBySlot[i];
    final category = selected.contains(preferred) ? preferred : selected[i % selected.length];
    final pick = _pick(category, used, rnd);
    used.add(pick.title);
    items.add(
      SelfCareItem(
        id: 's$i',
        category: category,
        title: pick.title,
        note: pick.note,
        when: kSelfCareSlots[i],
        minutes: pick.minutes,
      ),
    );
  }
  items.add(
    SelfCareItem(
      id: 's${kSelfCareSlots.length}',
      category: 'reflection',
      title: kReflection.title,
      note: kReflection.note,
      when: 'Night',
      minutes: kReflection.minutes,
    ),
  );
  return items;
}

SelfCareSuggestion _pick(String category, Set<String> usedTitles, Random rnd) {
  final list = kSelfCareLibrary[category] ?? kSelfCareLibrary['rest']!;
  final fresh = [
    for (final s in list)
      if (!usedTitles.contains(s.title)) s,
  ];
  final pool = fresh.isEmpty ? list : fresh;
  return pool[rnd.nextInt(pool.length)];
}

/// A replacement suggestion for [item] from the same category that is not
/// already in [plan]. Returns null when nothing else is available.
SelfCareSuggestion? swapSuggestion(SelfCareItem item, List<SelfCareItem> plan, Random rnd) {
  if (item.category == 'reflection') return null;
  final list = kSelfCareLibrary[item.category];
  if (list == null) return null;
  final inPlan = {for (final p in plan) p.title};
  final options = [
    for (final s in list)
      if (!inPlan.contains(s.title)) s,
  ];
  if (options.isEmpty) return null;
  return options[rnd.nextInt(options.length)];
}
