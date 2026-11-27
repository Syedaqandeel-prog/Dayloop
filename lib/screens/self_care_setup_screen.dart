import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/models.dart';
import '../core/self_care_library.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SelfCareSetupScreen extends StatefulWidget {
  const SelfCareSetupScreen({super.key});

  @override
  State<SelfCareSetupScreen> createState() => _SelfCareSetupScreenState();
}

class _SelfCareSetupScreenState extends State<SelfCareSetupScreen> {
  late SelfCareSettings _settings;
  late int _suggested;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final store = StoreScope.read(context);
    final s = store.data.selfCare;
    _settings = SelfCareSettings(
      enabled: s.enabled,
      weekday: s.weekday,
      categories: {...s.categories},
      pauseStreaks: s.pauseStreaks,
    );
    _suggested = store.data.suggestedSelfCareWeekday(store.today);
    _loaded = true;
  }

  void _save() {
    if (_settings.enabled && _settings.categories.isEmpty) {
      showNotice(context, 'Pick at least one thing for your Self-Care Day.');
      return;
    }
    final copy = SelfCareSettings(
      enabled: _settings.enabled,
      weekday: _settings.weekday,
      categories: {..._settings.categories},
      pauseStreaks: _settings.pauseStreaks,
    );
    final messenger = ScaffoldMessenger.of(context);
    StoreScope.read(context).update((d) => d.selfCare = copy);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          copy.enabled ? 'Self-Care Day set for ${kWeekdayNames[copy.weekday - 1]}.' : 'Self-Care Day turned off.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Weekly reset',
                        style: AppText.body(14, weight: FontWeight.w600, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Your Self-Care Day', style: AppText.display(32)),
                  const SizedBox(height: 6),
                  Text(
                    'One day a week, just for you. The app plans it, you just show up.',
                    style: AppText.body(15, color: AppColors.muted),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _settings.enabled,
                      onChanged: (v) => setState(() => _settings.enabled = v),
                      title: Text('Self-Care Day is on', style: AppText.body(15, weight: FontWeight.w600)),
                    ),
                  ),
                  if (_settings.enabled) ..._details(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _save, child: const Text('Save Self-Care Day')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _details() {
    return [
      const SizedBox(height: 18),
      const SectionLabel('Pick your day'),
      Row(
        children: [
          for (var w = 1; w <= 7; w++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: w == 7 ? 0 : 6),
                child: _DayButton(
                  letter: kWeekdayShort[w - 1],
                  fullName: kWeekdayNames[w - 1],
                  selected: _settings.weekday == w,
                  onTap: () => setState(() => _settings.weekday = w),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 14),
      AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBubble(icon: Icons.auto_awesome, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suggested: ${kWeekdayNames[_suggested - 1]}', style: AppText.body(14, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    'Based on your last 4 weeks, this is usually your lightest day.',
                    style: AppText.body(13, color: AppColors.muted),
                  ),
                  if (_settings.weekday != _suggested)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 40)),
                      onPressed: () => setState(() => _settings.weekday = _suggested),
                      child: const Text('Use suggestion'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const SectionLabel('What should the day include?'),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.3,
        children: [
          for (final c in kSelfCareCategories)
            ChoicePill(
              label: c.label,
              icon: appIcon(c.icon),
              expand: true,
              selected: _settings.categories.contains(c.id),
              onTap: () => setState(() {
                if (!_settings.categories.remove(c.id)) _settings.categories.add(c.id);
              }),
            ),
        ],
      ),
      const SizedBox(height: 14),
      AppCard(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _settings.pauseStreaks,
          onChanged: (v) => setState(() => _settings.pauseStreaks = v),
          title: Text('Pause streaks that day', style: AppText.body(15, weight: FontWeight.w600)),
          subtitle: Text('A rest day never breaks your streak.', style: AppText.body(12, color: AppColors.muted)),
        ),
      ),
    ];
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({required this.letter, required this.fullName, required this.selected, required this.onTap});

  final String letter;
  final String fullName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: fullName,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.accent : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? AppColors.accent : AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Center(
              child: Text(
                letter,
                style: AppText.body(14, weight: FontWeight.w700, color: selected ? AppColors.onAccent : AppColors.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
