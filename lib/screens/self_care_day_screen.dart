import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/models.dart';
import '../core/self_care_library.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'focus_screen.dart';
import 'self_care_setup_screen.dart';

/// The plan for one Self-Care Day. Opened on the day itself, or as a
/// preview of the next one.
class SelfCareDayScreen extends StatelessWidget {
  const SelfCareDayScreen({super.key, required this.day});

  final DateTime day;

  static const Map<String, String> _categoryTones = {
    'meditation': 'indigo',
    'reading': 'peach',
    'rest': 'blue',
    'relaxation': 'green',
    'reflection': 'pink',
  };

  static String _emojiFor(String category) => switch (category) {
    'meditation' => 'meditate',
    'reading' => 'book',
    'rest' => 'sleep',
    'relaxation' => 'waves',
    _ => 'journal',
  };

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final d = store.data;
    final today = store.today;
    final isToday = isSameDay(day, today);
    final isPast = day.isBefore(today);
    final plan = d.selfCarePlanFor(day);
    final done = plan.where((i) => i.status == ItemStatus.done).length;
    final totalMinutes = plan.fold<int>(0, (s, i) => s + i.minutes);
    final rating = d.restRatings[dayKey(day)];
    SelfCareItem? next;
    for (final i in plan) {
      if (i.status == ItemStatus.pending) {
        next = i;
        break;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          _Header(
            day: day,
            isToday: isToday,
            pause: d.selfCare.pauseStreaks,
            count: plan.length,
            totalMinutes: totalMinutes,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                SectionLabel(
                  isToday ? 'Suggested for you' : 'Preview',
                  trailing: Text(
                    '$done of ${plan.length} done',
                    style: AppText.body(12, weight: FontWeight.w700, color: AppColors.accent),
                  ),
                ),
                for (final item in plan)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ItemTile(
                      item: item,
                      tone: Tone.of(_categoryTones[item.category] ?? 'indigo'),
                      emoji: _emojiFor(item.category),
                      canAct: isToday,
                      onToggle: () => store.update(
                        (data) => data.setSelfCareStatus(
                          day,
                          item.id,
                          item.status == ItemStatus.done ? ItemStatus.pending : ItemStatus.done,
                        ),
                      ),
                      onSwap: isPast
                          ? null
                          : () {
                              var swapped = false;
                              store.update((data) => swapped = data.swapSelfCareItem(day, item.id, store.random));
                              if (!swapped) showNotice(context, 'No other suggestion in this category right now.');
                            },
                    ),
                  ),
                if (isToday) ...[const SizedBox(height: 8), _RestRating(day: day, rating: rating)],
                if (!isToday && !isPast) ...[
                  const SizedBox(height: 8),
                  Text(
                    'This is a preview of ${prettyDate(day)}. You can swap suggestions now; '
                    'ticking them off opens on the day.',
                    style: AppText.body(13, color: AppColors.muted),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SelfCareSetupScreen())),
                  icon: const Icon(Icons.tune),
                  label: const Text('Change day or categories'),
                ),
              ],
            ),
          ),
          if (!isPast)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => store.update((data) => data.surpriseSelfCare(day, store.random)),
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Surprise me'),
                      ),
                    ),
                    if (isToday && next != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            final item = next!;
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FocusScreen(
                                  title: item.title,
                                  minutes: item.minutes,
                                  onFinished: (s) =>
                                      s.update((data) => data.setSelfCareStatus(day, item.id, ItemStatus.done)),
                                ),
                              ),
                            );
                          },
                          child: Text('Start: ${next.title}', overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.day,
    required this.isToday,
    required this.pause,
    required this.count,
    required this.totalMinutes,
  });

  final DateTime day;
  final bool isToday;
  final bool pause;
  final int count;
  final int totalMinutes;

  String _duration(int m) {
    final h = m ~/ 60;
    final r = m % 60;
    if (h == 0) return '${r}m';
    return r == 0 ? '${h}h' : '${h}h ${r}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(color: AppColors.peach.withAlpha(0x22), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(color: AppColors.peach.withAlpha(0x40), shape: BoxShape.circle),
                alignment: const Alignment(0.3, -0.2),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    background: AppColors.night,
                    foreground: AppColors.nightInk,
                    borderColor: AppColors.whiteFaint,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${kWeekdayNames[day.weekday - 1]}, ${shortDate(day)} · Self-Care Day',
                    style: AppText.body(13, weight: FontWeight.w600, color: AppColors.nightSoft),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 240,
                    child: Text(
                      isToday ? 'Slow down. Today is for you.' : 'Your next day of rest.',
                      style: AppText.display(28, color: AppColors.nightInk),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (pause) const _HeaderChip('Streaks paused'),
                      _HeaderChip('$count suggestions · ${_duration(totalMinutes)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(color: AppColors.whiteFaint, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text,
        style: AppText.body(12, weight: FontWeight.w700, color: AppColors.nightInk),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.tone,
    required this.emoji,
    required this.canAct,
    required this.onToggle,
    required this.onSwap,
  });

  final SelfCareItem item;
  final Tone tone;
  final String emoji;
  final bool canAct;
  final VoidCallback onToggle;
  final VoidCallback? onSwap;

  @override
  Widget build(BuildContext context) {
    final done = item.status == ItemStatus.done;
    return Opacity(
      opacity: done ? 0.6 : 1,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
        onTap: canAct ? onToggle : null,
        child: Row(
          children: [
            EmojiTile(emoji),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.when} · ${selfCareCategoryLabel(item.category)}'.toUpperCase(),
                    style: AppText.label.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.title} · ${item.minutes} min',
                    style: AppText.body(
                      15,
                      weight: FontWeight.w700,
                    ).copyWith(decoration: done ? TextDecoration.lineThrough : TextDecoration.none),
                  ),
                  Text(item.note, style: AppText.body(12, color: AppColors.muted)),
                ],
              ),
            ),
            if (onSwap != null && item.category != 'reflection' && !done)
              IconButton(
                tooltip: 'Swap ${item.title} for another suggestion',
                icon: Icon(Icons.swap_horiz, color: AppColors.muted),
                onPressed: onSwap,
              ),
            if (canAct)
              Checkbox(
                value: done,
                activeColor: AppColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (_) => onToggle(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RestRating extends StatelessWidget {
  const _RestRating({required this.day, required this.rating});

  final DateTime day;
  final int? rating;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.read(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How rested do you feel?', style: AppText.body(15, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Your answer helps plan a better day next week.', style: AppText.body(12, color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var v = 1; v <= 5; v++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: v == 5 ? 0 : 6),
                    child: ChoicePill(
                      label: '$v',
                      expand: true,
                      selected: rating == v,
                      onTap: () => store.update((d) => d.rateRest(day, v)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
