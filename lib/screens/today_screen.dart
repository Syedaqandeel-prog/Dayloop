import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/dates.dart';
import '../core/models.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'focus_screen.dart';
import 'profile_card.dart';
import 'self_care_day_screen.dart';

/// Space kept free at the bottom of every tab for the floating navigation bar.
const double kFloatingNavSpace = 112;

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.onOpenHabits, required this.onOpenProfile});

  final VoidCallback onOpenHabits;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final d = store.data;
    final today = store.today;
    final planned = d.plannedHabits(today);
    final mode = d.modeFor(today);

    return ListView(
      padding: const EdgeInsets.only(bottom: kFloatingNavSpace),
      children: [
        _HeroWithMood(data: d, today: today, onOpenProfile: onOpenProfile),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (d.isSelfCareDay(today)) ...[_SelfCareBanner(day: today), const SizedBox(height: 16)],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: Text('Today’s rituals', style: AppText.display(20))),
                    Text(
                      '${planned.length} · ${mode.label}',
                      style: AppText.body(13, weight: FontWeight.w600, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (planned.isEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No rituals yet', style: AppText.body(16, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        'Add your first habit to build today’s routine.',
                        style: AppText.body(14, color: AppColors.muted),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: onOpenHabits, child: const Text('Add a habit')),
                    ],
                  ),
                )
              else
                for (final h in planned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HabitTile(
                      habit: h,
                      minutes: d.minutesFor(h, mode),
                      done: d.isDone(today, h.id),
                      day: today,
                    ),
                  ),
              const SizedBox(height: 10),
              if (planned.isNotEmpty) ...[
                Text('Today’s tracker', style: AppText.body(15, weight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final h in planned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RitualCounterCard(
                      habit: h,
                      done: d.isDone(today, h.id),
                      day: today,
                    ),
                  ),
                const SizedBox(height: 4),
              ],
              _JournalCard(key: ValueKey(dayKey(today)), day: today, initial: d.journalOn(today)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Deep "hero" header (greeting, streak, progress) with the mood card
/// floating over its bottom edge.
class _HeroWithMood extends StatelessWidget {
  const _HeroWithMood({required this.data, required this.today, required this.onOpenProfile});

  final AppData data;
  final DateTime today;
  final VoidCallback onOpenProfile;

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final name = data.name.trim();
    final planned = data.plannedHabits(today).length;
    final done = data.doneCount(today);
    final left = planned - done;
    final streak = data.currentStreak(today);
    final subline = planned == 0
        ? 'Let’s set up your first ritual'
        : left == 0
        ? 'All rituals done. Beautiful day.'
        : '$left ${left == 1 ? 'ritual' : 'rituals'} left · keep the rhythm';

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 66,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.night,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(right: -70, top: -70, child: _Ring(size: 230, alpha: 0x38)),
                Positioned(right: -38, top: -38, child: _Ring(size: 166, alpha: 0x52)),
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: 102,
                    height: 102,
                    decoration: BoxDecoration(color: AppColors.peach.withAlpha(0x29), shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, topInset + 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prettyDate(today),
                      style: AppText.body(13, weight: FontWeight.w600, color: AppColors.nightSoft),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Open profile',
                    child: GestureDetector(onTap: onOpenProfile, child: const ProfileAvatar(size: 44)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name.isEmpty ? _greeting(DateTime.now()) : '${_greeting(DateTime.now())}, $name',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.display(30, color: AppColors.nightInk),
              ),
              const SizedBox(height: 4),
              Text(
                subline,
                style: AppText.body(14, weight: FontWeight.w500, color: AppColors.nightSoft),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _HeroChip(leading: const Emoji3D('flame', size: 32), value: '$streak', label: 'day streak'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroChip(
                      leading: SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                          value: planned == 0 ? 0 : done / planned,
                          strokeWidth: 5,
                          strokeCap: StrokeCap.round,
                          color: AppColors.peach,
                          backgroundColor: AppColors.whiteFaint,
                        ),
                      ),
                      value: '$done/$planned',
                      label: 'done today',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _MoodCard(data: data, today: today),
            ],
          ),
        ),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.alpha});

  final double size;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.peach.withAlpha(alpha), width: 2),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.leading, required this.value, required this.label});

  final Widget leading;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x17FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppText.body(24, weight: FontWeight.w800, color: AppColors.nightInk, height: 1.05),
                ),
                Text(
                  label,
                  style: AppText.body(12, weight: FontWeight.w600, color: AppColors.nightSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelfCareBanner extends StatelessWidget {
  const _SelfCareBanner({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.accentSoft,
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SelfCareDayScreen(day: day))),
      child: Row(
        children: [
          const EmojiTile('spa', size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today is your Self-Care Day',
                  style: AppText.body(15, weight: FontWeight.w800, color: AppColors.accentSoftInk),
                ),
                Text('Your plan is ready. Streaks are paused.', style: AppText.body(13, color: AppColors.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.accentSoftInk),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.data, required this.today});

  final AppData data;
  final DateTime today;

  static const List<String> _labels = ['Drained', 'Low', 'Okay', 'Good', 'Great'];
  static const List<String> _emojis = ['😩', '😔', '😐', '🙂', '😁'];

  @override
  Widget build(BuildContext context) {
    final mood = data.moods[dayKey(today)];
    final mode = data.modeFor(today);
    final store = StoreScope.read(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 28, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('How’s your energy?', style: AppText.body(16, weight: FontWeight.w800)),
              ),
              Semantics(
                button: true,
                label: 'Routine size: ${mode.label}. Tap to change.',
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _pickMode(context, store, mode),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${mode.label} routine',
                          style: AppText.body(13, weight: FontWeight.w700, color: AppColors.peach),
                        ),
                        Icon(Icons.expand_more, size: 18, color: AppColors.peach),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: _MoodButton(
                    emoji: _emojis[i],
                    label: _labels[i],
                    selected: mood == i + 1,
                    anySelected: mood != null,
                    onTap: () => store.update((d) => d.setMood(today, i + 1)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickMode(BuildContext context, AppStore store, RoutineMode current) {
    const info = {
      RoutineMode.full: 'Every habit at its normal length.',
      RoutineMode.lite: 'Shorter versions. Still counts toward your streak.',
      RoutineMode.rescue: 'Just 3 tiny habits, 2 minutes each. One keeps your streak.',
    };
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Routine size', style: AppText.display(22)),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Choose your routine for today',
                    style: AppText.body(13, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 12),
                for (final m in RoutineMode.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      color: AppColors.sand,
                      borderColor: AppColors.line,
                      onTap: () {
                        store.update((d) => d.setMode(today, m));
                        Navigator.of(sheet).pop();
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.label, style: AppText.body(16, weight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(info[m]!, style: AppText.body(13, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.anySelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final bool anySelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Energy: $label',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.peach.withAlpha(0x38) : Colors.transparent,
                  border: Border.all(color: selected ? AppColors.peach : Colors.transparent, width: 2),
                ),
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: selected || !anySelected ? 1 : 0.45,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: selected ? 1.08 : 1,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: AppText.body(
                  11.5,
                  weight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? AppColors.ink : AppColors.muted,
                ),
              ),
            ],
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
      padding: const EdgeInsets.fromLTRB(10, 9, 9, 9),
      radius: 20,
      borderColor: AppColors.line,
      onTap: done
          ? () => store.update((d) => d.toggleHabit(day, habit.id))
          : () => Navigator.of(context).push(
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
      child: Row(
        children: [
          EmojiTile(habit.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(
                    15,
                    weight: FontWeight.w700,
                    color: done ? AppColors.muted : AppColors.ink,
                  ).copyWith(decoration: done ? TextDecoration.lineThrough : TextDecoration.none),
                ),
                Text(
                  done ? '${habit.slot.label} · done' : '${habit.slot.label} · $minutes min · tap to start',
                  style: AppText.body(12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            checked: done,
            label: done ? 'Undo ${habit.title}' : 'Mark ${habit.title} done',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => store.update((d) => d.toggleHabit(day, habit.id)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: done ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: done ? AppColors.accent : AppColors.line, width: 2),
                ),
                child: done ? Icon(Icons.check_rounded, color: AppColors.onAccent, size: 22) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RitualCounterCard extends StatelessWidget {
  const _RitualCounterCard({required this.habit, required this.done, required this.day});

  final Habit habit;
  final bool done;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.read(context);
    return AppCard(
      color: AppColors.waterBg,
      child: Row(
        children: [
          EmojiTile(habit.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: AppText.body(13, color: AppColors.waterSub)),
                Text(
                  done ? '1 of 1 done' : '0 of 1 done',
                  style: AppText.body(17, weight: FontWeight.w800, color: AppColors.waterInk),
                ),
                const SizedBox(height: 6),
                SoftProgressBar(value: done ? 1 : 0, color: AppColors.waterBar, track: AppColors.waterTrack),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'Undo ${habit.title}',
            onPressed: !done
                ? null
                : () => store.update((d) {
                      if (d.isDone(day, habit.id)) d.toggleHabit(day, habit.id);
                    }),
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Add ${habit.title}',
            background: AppColors.waterBar,
            foreground: AppColors.isDark ? AppColors.waterBg : AppColors.white,
            borderColor: null,
            onPressed: done
                ? null
                : () => store.update((d) {
                      if (!d.isDone(day, habit.id)) d.toggleHabit(day, habit.id);
                    }),
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
            decoration: InputDecoration(
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