import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/achievements.dart';
import '../core/app_data.dart';
import '../core/dates.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final d = store.data;
    final today = store.today;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          TabHeader(
            title: 'Achievements',
            action: CircleIconButton(
              icon: Icons.ios_share,
              tooltip: 'Copy a summary to share',
              onPressed: () => _shareSummary(context, d, today),
            ),
          ),
          _SummaryCard(
            badges: d.earnedBadges.length,
            challenges: d.completedChallenges.length,
            bestStreak: d.bestStreak(today),
          ),
          const SizedBox(height: 16),
          _Tabs(index: _tab, onChanged: (i) => setState(() => _tab = i)),
          const SizedBox(height: 16),
          if (_tab == 0) _BadgesTab(data: d, today: today) else _ChallengesTab(data: d, today: today),
        ],
      ),
    );
  }

  Future<void> _shareSummary(BuildContext context, AppData d, DateTime today) async {
    final text =
        'My ${AppConfig.appName} progress: ${d.earnedBadges.length} badges, '
        '${d.completedChallenges.length} challenges completed, best streak ${d.bestStreak(today)} days.';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) showNotice(context, 'Summary copied. Paste it anywhere to share.');
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.badges, required this.challenges, required this.bestStreak});

  final int badges;
  final int challenges;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppText.body(28, weight: FontWeight.w800, color: AppColors.peach, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.body(12, color: AppColors.sandDeep)),
        ],
      ),
    );
    return AppCard(
      color: AppColors.ink,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          stat('$badges', 'Badges earned'),
          stat('$challenges', 'Challenges won'),
          stat('$bestStreak', 'Best streak'),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(int i, String label) => Expanded(
      child: Semantics(
        selected: index == i,
        button: true,
        child: Material(
          color: index == i ? AppColors.card : AppColors.sandDeep,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onChanged(i),
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(label, style: AppText.body(14, weight: index == i ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.sandDeep, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [tab(0, 'Badges'), tab(1, 'Challenges')]),
    );
  }
}

// -----------------------------------------------------------------------------
// Badges
// -----------------------------------------------------------------------------

class _BadgesTab extends StatelessWidget {
  const _BadgesTab({required this.data, required this.today});

  final AppData data;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    BadgeDef? newest;
    String? newestKey;
    data.earnedBadges.forEach((id, key) {
      final def = badgeById(id);
      if (def == null) return;
      if (newestKey == null || key.compareTo(newestKey!) > 0) {
        newest = def;
        newestKey = key;
      }
    });

    final earned = kBadges.where((b) => data.isEarned(b.id)).toList();
    final locked = kBadges.where((b) => !data.isEarned(b.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (newest != null) ...[
          AppCard(
            onTap: () => _showBadge(context, newest!, data, today),
            child: Row(
              children: [
                _BadgeMedal(def: newest!, earned: true, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LATEST · ${shortDate(parseDayKey(newestKey!)).toUpperCase()}',
                        style: AppText.label.copyWith(color: Tone.of(newest!.tone).ink, fontSize: 11),
                      ),
                      Text(newest!.title, style: AppText.body(15, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ] else ...[
          AppCard(
            child: Text(
              'Your first badge is close. Complete one habit today to earn "First Step".',
              style: AppText.body(14, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 14),
        ],
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.78,
          children: [
            for (final b in [...earned, ...locked])
              _BadgeTile(
                def: b,
                earned: data.isEarned(b.id),
                progress: b.progress(data, today),
                onTap: () => _showBadge(context, b, data, today),
              ),
          ],
        ),
      ],
    );
  }
}

class _BadgeMedal extends StatelessWidget {
  const _BadgeMedal({required this.def, required this.earned, this.size = 52});

  final BadgeDef def;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tone = earned ? Tone.of(def.tone) : Tone.locked;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.bg,
        shape: BoxShape.circle,
        border: Border.all(color: tone.ring, width: 3),
      ),
      alignment: Alignment.center,
      child: Icon(earned ? appIcon(def.icon) : Icons.lock_outline, color: tone.ink, size: size * 0.45),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.def, required this.earned, required this.progress, required this.onTap});

  final BadgeDef def;
  final bool earned;
  final int progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shown = progress.clamp(0, def.target);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BadgeMedal(def: def, earned: earned),
          const SizedBox(height: 8),
          Text(
            def.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(
              12,
              weight: FontWeight.w700,
              color: earned ? AppColors.ink : AppColors.muted,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(earned ? 'Earned' : '$shown / ${def.target}', style: AppText.body(11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

void _showBadge(BuildContext context, BadgeDef def, AppData data, DateTime today) {
  final earnedKey = data.earnedBadges[def.id];
  final progress = def.progress(data, today).clamp(0, def.target);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sand,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BadgeMedal(def: def, earned: earnedKey != null, size: 84),
            const SizedBox(height: 14),
            Text(def.title, style: AppText.display(26), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              def.description,
              style: AppText.body(14, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (earnedKey != null)
              Text(
                'Earned on ${prettyDate(parseDayKey(earnedKey))}',
                style: AppText.body(14, weight: FontWeight.w700, color: AppColors.success),
              )
            else ...[
              SoftProgressBar(value: progress / def.target),
              const SizedBox(height: 8),
              Text('$progress of ${def.target}', style: AppText.body(13, color: AppColors.muted)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: earnedKey != null
                  ? FilledButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: 'I just earned the "${def.title}" badge on ${AppConfig.appName}!'),
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) showNotice(context, 'Copied. Paste it anywhere to share.');
                      },
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Copy to share'),
                    )
                  : OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Keep going')),
            ),
          ],
        ),
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// Challenges
// -----------------------------------------------------------------------------

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({required this.data, required this.today});

  final AppData data;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.read(context);
    final completed = [...data.completedChallenges]..sort((a, b) => b.completedKey.compareTo(a.completedKey));
    final available = kChallenges.where((c) => !data.isChallengeActive(c.id)).toList();
    final full = data.activeChallenges.length >= kMaxActiveChallenges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel('In progress · ${data.activeChallenges.length}/$kMaxActiveChallenges'),
        if (data.activeChallenges.isEmpty)
          AppCard(
            child: Text(
              'No active challenge. Join one below to get started.',
              style: AppText.body(14, color: AppColors.muted),
            ),
          ),
        for (final a in data.activeChallenges)
          if (challengeById(a.id) case final def?)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActiveChallengeCard(
                def: def,
                status: data.challengeStatus(a, today),
                onLeave: () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Leave "${def.title}"?',
                    message: 'Your progress in this challenge will be lost.',
                    confirmLabel: 'Leave',
                    destructive: true,
                  );
                  if (ok) store.update((d) => d.leaveChallenge(def.id));
                },
              ),
            ),
        const SizedBox(height: 8),
        SectionLabel('Completed · ${completed.length}'),
        if (completed.isEmpty)
          AppCard(
            child: Text(
              'Finished challenges will show up here with their date.',
              style: AppText.body(14, color: AppColors.muted),
            ),
          ),
        for (final c in completed)
          if (challengeById(c.id) case final def?)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const IconBubble(
                      icon: Icons.check_rounded,
                      background: AppColors.successSoft,
                      foreground: AppColors.success,
                      size: 40,
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(def.title, style: AppText.body(15, weight: FontWeight.w700)),
                          Text(
                            'Completed ${shortDate(parseDayKey(c.completedKey))}',
                            style: AppText.body(12, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${def.days} days',
                      style: AppText.body(12, weight: FontWeight.w700, color: AppColors.warn),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 8),
        const SectionLabel('Join a challenge'),
        for (final c in available)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: const EdgeInsets.all(12),
              borderColor: AppColors.line,
              color: AppColors.sand,
              child: Row(
                children: [
                  IconBubble(icon: appIcon(c.icon), size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: AppText.body(15, weight: FontWeight.w700)),
                        Text(
                          data.timesCompleted(c.id) > 0
                              ? '${c.description} Done ${data.timesCompleted(c.id)}x.'
                              : c.description,
                          style: AppText.body(12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: full
                        ? null
                        : () {
                            String? error;
                            store.update((d) => error = d.joinChallenge(c.id, today));
                            showNotice(context, error ?? 'You joined ${c.title}. Day 1 starts today!');
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      minimumSize: const Size(72, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Join'),
                  ),
                ],
              ),
            ),
          ),
        if (full)
          Text(
            'You are running $kMaxActiveChallenges challenges. Finish or leave one to join another.',
            style: AppText.body(12, color: AppColors.muted),
          ),
      ],
    );
  }
}

class _ActiveChallengeCard extends StatelessWidget {
  const _ActiveChallengeCard({required this.def, required this.status, required this.onLeave});

  final ChallengeDef def;
  final ChallengeStatus status;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final results = status.dayResults;
    return AppCard(
      color: AppColors.accent,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('IN PROGRESS', style: AppText.label.copyWith(color: AppColors.nightSoft)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.whiteFaint, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '${status.daysLeft} ${status.daysLeft == 1 ? 'day' : 'days'} left',
                  style: AppText.body(12, weight: FontWeight.w700, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            def.title,
            style: AppText.body(21, weight: FontWeight.w800, color: AppColors.white),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: '${status.doneDays} of ${status.totalDays} days complete',
            excludeSemantics: true,
            child: Row(
              children: [
                for (var i = 0; i < status.totalDays; i++)
                  Expanded(
                    child: Container(
                      height: 16,
                      margin: EdgeInsets.only(right: i == status.totalDays - 1 ? 0 : 3),
                      decoration: BoxDecoration(color: _cellColor(i, results), borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${status.doneDays} / ${status.totalDays} days'
                  '${status.graceUsed ? ' · grace day used' : ' · 1 grace day left'}',
                  style: AppText.body(13, color: AppColors.nightSoft),
                ),
              ),
              TextButton(
                onPressed: onLeave,
                style: TextButton.styleFrom(foregroundColor: AppColors.white, minimumSize: const Size(0, 40)),
                child: const Text('Leave'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Done days fill from the left.
  Color _cellColor(int index, List<bool?> results) {
    final done = results.where((r) => r == true).length;
    return index < done ? AppColors.peach : AppColors.whiteFaint;
  }
}
