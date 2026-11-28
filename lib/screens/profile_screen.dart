import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/dates.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'profile_card.dart';
import 'self_care_day_screen.dart';
import 'self_care_setup_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final d = store.data;
    final today = store.today;
    final sc = d.selfCare;
    final nextSelfCare = nextWeekday(today, sc.weekday);
    final entries = d.journal.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
        children: [
          Row(
            children: [
              Expanded(child: Text('Profile', style: AppText.display(30))),
              CircleIconButton(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ProfileCard(),
          const SizedBox(height: 18),
          _WeeklyConsistency(data: d, today: today),
          const SizedBox(height: 18),
          const SectionLabel('Self-Care Day'),
          AppCard(
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SelfCareSetupScreen())),
            child: Row(
              children: [
                const EmojiTile('spa', size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sc.enabled ? 'Every ${kWeekdayNames[sc.weekday - 1]}' : 'Turned off',
                        style: AppText.body(15, weight: FontWeight.w700),
                      ),
                      Text(
                        sc.enabled ? '${sc.categories.length} categories · tap to change' : 'Tap to set it up',
                        style: AppText.body(12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
          if (sc.enabled) ...[
            const SizedBox(height: 10),
            AppCard(
              onTap: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => SelfCareDayScreen(day: nextSelfCare))),
              child: Row(
                children: [
                  const EmojiTile('calendar', size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSameDay(nextSelfCare, today) ? "Today's plan" : 'Preview next plan',
                          style: AppText.body(15, weight: FontWeight.w700),
                        ),
                        Text(prettyDate(nextSelfCare), style: AppText.body(12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          SectionLabel('Journal · ${entries.length}'),
          if (entries.isEmpty)
            AppCard(
              child: Text('Your daily one-liners will collect here.', style: AppText.body(14, color: AppColors.muted)),
            ),
          for (final e in entries.take(14))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prettyDate(parseDayKey(e.key)), style: AppText.body(12, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text(e.value, style: AppText.display(18)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Only THIS week - 7 boxes, Mon to Sun.
/// Done day = dark / accent, missed day = light empty, future day = very light.
/// When Monday comes, this automatically shows the new week.
class _WeeklyConsistency extends StatelessWidget {
  const _WeeklyConsistency({required this.data, required this.today});

  final AppData data;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final thisMonday = addDays(today, -(today.weekday - 1));
    final thisSunday = addDays(thisMonday, 6);

    var done = 0;
    var elapsed = 0;
    for (var i = 0; i < 7; i++) {
      final day = addDays(thisMonday, i);
      if (day.isAfter(today)) continue;
      if (day.isBefore(data.firstUse)) continue;
      elapsed++;
      if (data.daySuccess(day)) done++;
    }
    final pct = elapsed == 0 ? 0 : (done * 100 / elapsed).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('This week', style: AppText.body(14, weight: FontWeight.w700)),
              ),
              Text(
                '$done / $elapsed days',
                style: AppText.body(13, weight: FontWeight.w700, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${prettyDate(thisMonday)} - ${prettyDate(thisSunday)}',
            style: AppText.body(12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
                    child: _DayBox(
                      day: addDays(thisMonday, i),
                      today: today,
                      isDone: _isDone(addDays(thisMonday, i)),
                      isToday: isSameDay(addDays(thisMonday, i), today),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text('Done', style: AppText.body(11, color: AppColors.muted)),
              const SizedBox(width: 14),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.sandDeep, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text('Missed / Not yet', style: AppText.body(11, color: AppColors.muted)),
            ],
          ),
          if (pct > 0) ...[
            const SizedBox(height: 10),
            Text('$pct% this week', style: AppText.body(12, color: AppColors.muted)),
          ],
        ],
      ),
    );
  }

  bool _isDone(DateTime day) {
    if (day.isAfter(today)) return false;
    if (day.isBefore(data.firstUse)) return false;
    return data.daySuccess(day);
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({required this.day, required this.today, required this.isDone, required this.isToday});

  final DateTime day;
  final DateTime today;
  final bool isDone;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final isFuture = day.isAfter(today);
    final color = isDone
        ? AppColors.accent
        : isFuture
            ? AppColors.sandDeep.withAlpha(0x66)
            : AppColors.sandDeep;

    return Column(
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: isToday && !isDone
                ? Border.all(color: AppColors.accent, width: 2)
                : null,
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check_rounded : Icons.circle_outlined,
              size: 22,
              color: isDone ? Colors.white : AppColors.muted,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          kWeekdayShort[day.weekday - 1],
          style: AppText.body(11, weight: FontWeight.w700, color: isToday ? AppColors.accent : AppColors.muted),
        ),
        Text(
          '${day.day}',
          style: AppText.body(11, color: AppColors.muted),
        ),
      ],
    );
  }
}