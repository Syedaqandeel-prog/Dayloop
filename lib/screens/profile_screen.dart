import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/dates.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';
import 'self_care_day_screen.dart';
import 'self_care_setup_screen.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          TabHeader(title: d.name.isEmpty ? 'Me' : d.name, subtitle: 'Since ${prettyDate(d.firstUse)}'),
          _Heatmap(data: d, today: today),
          const SizedBox(height: 18),
          const SectionLabel('Self-Care Day'),
          AppCard(
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SelfCareSetupScreen())),
            child: Row(
              children: [
                const IconBubble(icon: Icons.spa_outlined),
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
                const Icon(Icons.chevron_right, color: AppColors.muted),
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
                  const IconBubble(
                    icon: Icons.event_available,
                    background: AppColors.warnSoft,
                    foreground: AppColors.warn,
                  ),
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
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          const SectionLabel('Daily water goal'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('${d.waterGoal} glasses', style: AppText.body(15, weight: FontWeight.w700)),
                ),
                CircleIconButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Lower goal',
                  onPressed: d.waterGoal <= 1 ? null : () => store.update((x) => x.waterGoal--),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Raise goal',
                  onPressed: d.waterGoal >= 20 ? null : () => store.update((x) => x.waterGoal++),
                ),
              ],
            ),
          ),
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
          const SizedBox(height: 18),
          const SectionLabel('Data'),
          AppCard(
            child: Text(
              'Everything is saved only on this phone. Deleting the app deletes your data.',
              style: AppText.body(13, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'Reset everything?',
                message: 'All habits, progress, badges and journal entries will be deleted. This cannot be undone.',
                confirmLabel: 'Reset',
                destructive: true,
              );
              if (ok) await store.resetAll();
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Reset all data'),
          ),
        ],
      ),
    );
  }
}

/// Last 12 weeks, one column per week, Monday at the top.
class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.data, required this.today});

  final AppData data;
  final DateTime today;

  static const List<Color> _levels = [Color(0xFFECE6DD), Color(0xFFC5CCF0), Color(0xFF8A97DD), AppColors.accent];

  @override
  Widget build(BuildContext context) {
    const weeks = 12;
    final thisMonday = addDays(today, -(today.weekday - 1));
    final start = addDays(thisMonday, -7 * (weeks - 1));
    final first = data.firstUse;

    var counted = 0;
    var good = 0;
    for (var i = 0; i < weeks * 7; i++) {
      final day = addDays(start, i);
      if (day.isAfter(today) || day.isBefore(first)) continue;
      counted++;
      if (data.daySuccess(day)) good++;
    }
    final pct = counted == 0 ? 0 : (good * 100 / counted).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Consistency · 12 weeks', style: AppText.body(14, weight: FontWeight.w700)),
              ),
              Text(
                '$pct%',
                style: AppText.body(20, weight: FontWeight.w800, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Consistency heatmap: $good good days out of $counted',
            excludeSemantics: true,
            child: Row(
              children: [
                for (var w = 0; w < weeks; w++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : 4),
                      child: Column(
                        children: [
                          for (var r = 0; r < 7; r++)
                            Padding(
                              padding: EdgeInsets.only(bottom: r == 6 ? 0 : 4),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _colorFor(addDays(start, w * 7 + r), first),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: AppText.body(11, color: AppColors.muted)),
              for (final c in _levels)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
                ),
              const SizedBox(width: 4),
              Text('More', style: AppText.body(11, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFor(DateTime day, DateTime first) {
    if (day.isAfter(today) || day.isBefore(first)) return const Color(0xFFF4F0EA);
    return _levels[data.dayLevel(day)];
  }
}
