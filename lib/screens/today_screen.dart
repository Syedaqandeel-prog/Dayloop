import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/dates.dart';
import '../core/models.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'focus_screen.dart';
import 'self_care_day_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.onOpenHabits});

  final VoidCallback onOpenHabits;

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final d = store.data;
    final today = store.today;
    final now = DateTime.now();
    final name = d.name.isEmpty ? '' : ', ${d.name}';
    final planned = d.plannedHabits(today);
    final mode = d.modeFor(today);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(prettyDate(today), style: AppText.body(13, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text('${_greeting(now)}$name', style: AppText.display(28)),
          const SizedBox(height: 18),
          if (d.isSelfCareDay(today)) ...[_SelfCareBanner(day: today), const SizedBox(height: 14)],
          _StatsRow(data: d, today: today, planned: planned.length),
          const SizedBox(height: 14),
          _MoodCard(data: d, today: today),
          const SizedBox(height: 8),
          SectionLabel(
            "Today's routine",
            trailing: Text(
              '${mode.label} mode',
              style: AppText.body(12, weight: FontWeight.w700, color: AppColors.accent),
            ),
          ),
          if (planned.isEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No habits yet', style: AppText.body(16, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Add your first habit to build today\'s routine.',
                    style: AppText.body(14, color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: onOpenHabits, child: const Text('Add a habit')),
                ],
              ),
            )
          else
            for (final slot in DaySlot.values) ..._slotSection(context, d, today, mode, slot, planned),
          const SizedBox(height: 8),
          _WaterCard(data: d, today: today),
          const SizedBox(height: 14),
          _JournalCard(key: ValueKey(dayKey(today)), day: today, initial: d.journalOn(today)),
        ],
      ),
    );
  }

  List<Widget> _slotSection(
    BuildContext context,
    AppData d,
    DateTime today,
    RoutineMode mode,
    DaySlot slot,
    List<Habit> planned,
  ) {
    final habits = planned.where((h) => h.slot == slot).toList();
    if (habits.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(
          slot.label,
          style: AppText.body(14, weight: FontWeight.w700, color: AppColors.muted),
        ),
      ),
      for (final h in habits)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _HabitTile(habit: h, minutes: d.minutesFor(h, mode), done: d.isDone(today, h.id), day: today),
        ),
    ];
  }
}

class _SelfCareBanner extends StatelessWidget {
  const _SelfCareBanner({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.night,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SelfCareDayScreen(day: day))),
      child: Row(
        children: [
          const IconBubble(icon: Icons.spa_outlined, background: AppColors.whiteFaint, foreground: AppColors.peach),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today is your Self-Care Day',
                  style: AppText.body(15, weight: FontWeight.w700, color: AppColors.white),
                ),
                Text('Your plan is ready. Streaks are paused.', style: AppText.body(13, color: AppColors.nightSoft)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.white),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data, required this.today, required this.planned});

  final AppData data;
  final DateTime today;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final streak = data.currentStreak(today);
    final done = data.doneCount(today);
    return Row(
      children: [
        Expanded(
          child: AppCard(
            color: AppColors.ink,
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_outlined, color: AppColors.peach, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak',
                        style: AppText.body(26, weight: FontWeight.w800, color: AppColors.peach, height: 1.1),
                      ),
                      Text('day streak', style: AppText.body(12, color: AppColors.sandDeep)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$done/$planned', style: AppText.body(26, weight: FontWeight.w800, height: 1.1)),
                const SizedBox(height: 2),
                Text('done today', style: AppText.body(12, color: AppColors.muted)),
                const SizedBox(height: 8),
                SoftProgressBar(value: planned == 0 ? 0 : done / planned),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.data, required this.today});

  final AppData data;
  final DateTime today;

  static const List<(IconData, String)> _moods = [
    (Icons.sentiment_very_dissatisfied, 'Drained'),
    (Icons.sentiment_dissatisfied, 'Low'),
    (Icons.sentiment_neutral, 'Okay'),
    (Icons.sentiment_satisfied, 'Good'),
    (Icons.sentiment_very_satisfied, 'Charged'),
  ];

  @override
  Widget build(BuildContext context) {
    final mood = data.moods[dayKey(today)];
    final mode = data.modeFor(today);
    final store = StoreScope.read(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How's your energy?", style: AppText.body(16, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _moods.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == _moods.length - 1 ? 0 : 6),
                    child: _MoodButton(
                      icon: _moods[i].$1,
                      label: _moods[i].$2,
                      selected: mood == i + 1,
                      onTap: () => store.update((d) => d.setMood(today, i + 1)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Routine size', style: AppText.body(13, color: AppColors.muted)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final m in RoutineMode.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: m == RoutineMode.rescue ? 0 : 6),
                    child: ChoicePill(
                      label: m.label,
                      selected: mode == m,
                      expand: true,
                      onTap: () => store.update((d) => d.setMode(today, m)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(switch (mode) {
            RoutineMode.full => 'Full routine with normal durations.',
            RoutineMode.lite => 'Shorter versions of every habit. Lite days still count toward your streak.',
            RoutineMode.rescue => 'Just 3 tiny habits, 2 minutes each. One is enough to keep your streak.',
          }, style: AppText.body(13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Energy: $label',
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.warnSoft : AppColors.sand,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? AppColors.warn : AppColors.line, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(icon, color: selected ? AppColors.warn : AppColors.muted),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, style: AppText.body(11, weight: selected ? FontWeight.w700 : FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.habit, required this.minutes, required this.done, required this.day});

  final Habit habit;
  final int minutes;
  final bool done;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.read(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      onTap: () => store.update((d) => d.toggleHabit(day, habit.id)),
      child: Row(
        children: [
          IconBubble(
            icon: appIcon(habit.icon),
            background: done ? AppColors.successSoft : AppColors.accentSoft,
            foreground: done ? AppColors.success : AppColors.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: AppText.body(
                    15,
                    weight: FontWeight.w700,
                    color: done ? AppColors.muted : AppColors.ink,
                  ).copyWith(decoration: done ? TextDecoration.lineThrough : TextDecoration.none),
                ),
                Text('$minutes min', style: AppText.body(12, color: AppColors.muted)),
              ],
            ),
          ),
          if (!done)
            CircleIconButton(
              icon: Icons.play_arrow_rounded,
              tooltip: 'Start ${habit.title}',
              borderColor: null,
              background: AppColors.accentSoft,
              foreground: AppColors.accent,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FocusScreen(
                    title: habit.title,
                    minutes: minutes,
                    onFinished: (s) => s.update((d) {
                      if (!d.isDone(day, habit.id)) d.toggleHabit(day, habit.id);
                    }),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 4),
          Semantics(
            label: done ? 'Done. Tap to undo.' : 'Mark as done',
            child: Checkbox(
              value: done,
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (_) => store.update((d) => d.toggleHabit(day, habit.id)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({required this.data, required this.today});

  final AppData data;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.read(context);
    final glasses = data.waterOn(today);
    final goal = data.waterGoal;
    return AppCard(
      color: const Color(0xFFE4EEF6),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined, color: Color(0xFF2D5B80), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Water', style: AppText.body(13, color: const Color(0xFF24426E))),
                Text(
                  '$glasses of $goal glasses',
                  style: AppText.body(17, weight: FontWeight.w800, color: const Color(0xFF14284A)),
                ),
                const SizedBox(height: 6),
                SoftProgressBar(value: glasses / goal, color: const Color(0xFF2A5DA8), track: const Color(0xFFB9CCE6)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'Remove a glass',
            onPressed: glasses == 0 ? null : () => store.update((d) => d.addWater(today, -1)),
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Add a glass',
            background: const Color(0xFF2A5DA8),
            foreground: AppColors.white,
            borderColor: null,
            onPressed: () => store.update((d) => d.addWater(today, 1)),
          ),
        ],
      ),
    );
  }
}

/// Keyed by date so a new day starts with an empty field.
class _JournalCard extends StatefulWidget {
  const _JournalCard({super.key, required this.day, required this.initial});

  final DateTime day;
  final String initial;

  @override
  State<_JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends State<_JournalCard> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Saved on every change, so nothing is lost if the user leaves the screen.
  void _save(String text) {
    StoreScope.read(context).update((d) => d.setJournal(widget.day, text));
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ONE LINE FOR TODAY', style: AppText.label.copyWith(color: AppColors.accent)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLength: 280,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: _save,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              hintText: 'What made today lighter?',
              counterText: '',
              fillColor: AppColors.sand,
            ),
          ),
        ],
      ),
    );
  }
}
