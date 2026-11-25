/// Badge and challenge definitions. Each badge reads its progress from
/// [AppData], so the rules live in one place.
library;

import 'app_data.dart';

class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tone,
    required this.target,
    required this.progress,
  });

  final String id;
  final String title;
  final String description;
  final String icon;

  /// Colour family name used by the UI (`peach`, `gold`, `blue`, `pink`, `indigo`, `green`).
  final String tone;
  final int target;
  final int Function(AppData data, DateTime today) progress;
}

final List<BadgeDef> kBadges = [
  BadgeDef(
    id: 'first_step',
    title: 'First Step',
    description: 'Complete your very first habit.',
    icon: 'star',
    tone: 'green',
    target: 1,
    progress: (d, t) => d.totalCompletions,
  ),
  BadgeDef(
    id: 'streak_7',
    title: '7-Day Streak',
    description: 'Keep your routine going for 7 days in a row.',
    icon: 'flame',
    tone: 'peach',
    target: 7,
    progress: (d, t) => d.bestStreak(t),
  ),
  BadgeDef(
    id: 'early_riser',
    title: 'Early Riser',
    description: 'Finish a morning habit on 10 different days.',
    icon: 'sun',
    tone: 'gold',
    target: 10,
    progress: (d, t) => d.morningDays,
  ),
  BadgeDef(
    id: 'hydrated',
    title: 'Hydrated',
    description: 'Reach your water goal on 7 days.',
    icon: 'water',
    tone: 'blue',
    target: 7,
    progress: (d, t) => d.waterGoalDays,
  ),
  BadgeDef(
    id: 'journaler',
    title: 'Journaler',
    description: 'Write your one line on 7 days.',
    icon: 'journal',
    tone: 'pink',
    target: 7,
    progress: (d, t) => d.journalDays,
  ),
  BadgeDef(
    id: 'calm_mind',
    title: 'Calm Mind',
    description: 'Finish 10 focus or meditation sessions.',
    icon: 'meditate',
    tone: 'indigo',
    target: 10,
    progress: (d, t) => d.focusTotal,
  ),
  BadgeDef(
    id: 'bookworm',
    title: 'Bookworm',
    description: 'Finish 5 reading suggestions on Self-Care Days.',
    icon: 'book',
    tone: 'peach',
    target: 5,
    progress: (d, t) => d.selfCareReadingDone,
  ),
  BadgeDef(
    id: 'self_care_pro',
    title: 'Self-Care Pro',
    description: 'Complete 4 Self-Care Days (3 or more suggestions each).',
    icon: 'heart',
    tone: 'pink',
    target: 4,
    progress: (d, t) => d.selfCareDaysCompleted,
  ),
  BadgeDef(
    id: 'challenger',
    title: 'Challenger',
    description: 'Complete your first challenge.',
    icon: 'flag',
    tone: 'green',
    target: 1,
    progress: (d, t) => d.completedChallenges.length,
  ),
  BadgeDef(
    id: 'streak_30',
    title: '30-Day Streak',
    description: 'Keep your routine going for 30 days in a row.',
    icon: 'flame',
    tone: 'gold',
    target: 30,
    progress: (d, t) => d.bestStreak(t),
  ),
  BadgeDef(
    id: 'champion',
    title: 'Champion',
    description: 'Complete 5 challenges.',
    icon: 'trophy',
    tone: 'gold',
    target: 5,
    progress: (d, t) => d.completedChallenges.length,
  ),
];

BadgeDef? badgeById(String id) {
  for (final b in kBadges) {
    if (b.id == id) return b;
  }
  return null;
}

class ChallengeDef {
  const ChallengeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.days,
    required this.icon,
    required this.check,
  });

  final String id;
  final String title;
  final String description;
  final int days;
  final String icon;

  /// True when the challenge's goal was met on [day].
  final bool Function(AppData data, DateTime day) check;
}

final List<ChallengeDef> kChallenges = [
  ChallengeDef(
    id: 'hydration_7',
    title: 'Hydration Week',
    description: 'Reach your water goal every day for 7 days.',
    days: 7,
    icon: 'water',
    check: (d, day) => d.waterGoalMet(day),
  ),
  ChallengeDef(
    id: 'journal_7',
    title: 'One Line a Day',
    description: 'Write your one-line journal for 7 days.',
    days: 7,
    icon: 'journal',
    check: (d, day) => d.hasJournal(day),
  ),
  ChallengeDef(
    id: 'focus_5',
    title: 'Focus Five',
    description: 'Finish at least one focus session on 5 days.',
    days: 5,
    icon: 'focus',
    check: (d, day) => d.focusOn(day) > 0,
  ),
  ChallengeDef(
    id: 'routine_14',
    title: '14 Days of Routine',
    description: 'Complete your daily routine for 14 days.',
    days: 14,
    icon: 'calendar',
    check: (d, day) => d.daySuccess(day),
  ),
  ChallengeDef(
    id: 'early_riser_21',
    title: '21-Day Early Riser',
    description: 'Finish a morning habit every day for 21 days.',
    days: 21,
    icon: 'sun',
    check: (d, day) => d.morningDone(day),
  ),
];

ChallengeDef? challengeById(String id) {
  for (final c in kChallenges) {
    if (c.id == id) return c;
  }
  return null;
}

/// Live state of an active challenge.
class ChallengeStatus {
  const ChallengeStatus({
    required this.doneDays,
    required this.totalDays,
    required this.graceUsed,
    required this.failed,
    required this.completed,
    required this.dayResults,
  });

  final int doneDays;
  final int totalDays;
  final bool graceUsed;
  final bool failed;
  final bool completed;

  /// One entry per day since the start: true = goal met, false = missed,
  /// null = today and not done yet.
  final List<bool?> dayResults;

  int get daysLeft => (totalDays - doneDays).clamp(0, totalDays);
}

/// Maximum challenges a user can run at the same time.
const int kMaxActiveChallenges = 3;
