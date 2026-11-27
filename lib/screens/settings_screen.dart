import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/links.dart';
import 'privacy_policy_screen.dart';
import 'self_care_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final d = store.data;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Row(
              children: [
                CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 14),
                Text('Settings', style: AppText.display(28)),
              ],
            ),
            const SizedBox(height: 22),

            const SectionLabel('Appearance'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mode', style: AppText.body(15, weight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final m in const [
                        ('system', 'System', Icons.brightness_auto_outlined),
                        ('light', 'Light', Icons.light_mode_outlined),
                        ('dark', 'Dark', Icons.dark_mode_outlined),
                      ])
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: m.$1 == 'dark' ? 0 : 8),
                            child: ChoicePill(
                              label: m.$2,
                              icon: m.$3,
                              expand: true,
                              selected: d.themeMode == m.$1,
                              onTap: () => store.update((x) => x.themeMode = m.$1),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'System follows your phone’s light or dark setting.',
                    style: AppText.body(12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Colour scheme', style: AppText.body(15, weight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: [
                      for (final s in kSchemes)
                        _SchemeTile(
                          scheme: s,
                          dark: AppColors.isDark,
                          selected: schemeById(d.schemeId).id == s.id,
                          onTap: () => store.update((x) => x.schemeId = s.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const SectionLabel('Routine'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily water goal', style: AppText.body(15, weight: FontWeight.w700)),
                        Text('${d.waterGoal} glasses', style: AppText.body(12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  CircleIconButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Lower water goal',
                    onPressed: d.waterGoal <= 1 ? null : () => store.update((x) => x.waterGoal--),
                  ),
                  const SizedBox(width: 8),
                  CircleIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Raise water goal',
                    onPressed: d.waterGoal >= 20 ? null : () => store.update((x) => x.waterGoal++),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _NavRow(
              emoji: 'spa',
              title: 'Self-Care Day',
              subtitle: d.selfCare.enabled ? 'On · tap to change day and categories' : 'Off · tap to set it up',
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SelfCareSetupScreen())),
            ),

            const SizedBox(height: 18),
            const SectionLabel('Help & legal'),
            _NavRow(
              emoji: 'mail',
              title: 'Contact us',
              subtitle: AppConfig.supportEmail,
              onTap: () => contactSupport(context),
            ),
            const SizedBox(height: 10),
            _NavRow(
              emoji: 'lock',
              title: 'Privacy policy',
              subtitle: 'How your data stays on your phone',
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen())),
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
                final navigator = Navigator.of(context);
                final ok = await confirmDialog(
                  context,
                  title: 'Reset everything?',
                  message: 'All habits, progress, badges, journal entries and your profile will be deleted. This cannot be undone.',
                  confirmLabel: 'Reset',
                  destructive: true,
                );
                if (!ok) return;
                navigator.popUntil((route) => route.isFirst);
                await store.resetAll();
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Reset all data'),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '${AppConfig.appName} · version ${AppConfig.version} · ${AppConfig.company}',
                style: AppText.body(12, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemeTile extends StatelessWidget {
  const _SchemeTile({required this.scheme, required this.dark, required this.selected, required this.onTap});

  final AppScheme scheme;
  final bool dark;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = scheme.of(dark);
    return Semantics(
      button: true,
      selected: selected,
      label: '${scheme.name} colour scheme',
      excludeSemantics: true,
      child: Material(
        color: AppColors.sand,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? AppColors.accent : AppColors.line, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 32,
                  child: Stack(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: p.night, shape: BoxShape.circle),
                      ),
                      Positioned(
                        left: 18,
                        top: 9,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: p.peach,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.sand, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scheme.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12.5, weight: selected ? FontWeight.w800 : FontWeight.w600, height: 1.2),
                  ),
                ),
                if (selected) Icon(Icons.check_circle, size: 18, color: AppColors.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.emoji, required this.title, required this.subtitle, required this.onTap});

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          EmojiTile(emoji, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body(15, weight: FontWeight.w700)),
                Text(subtitle, style: AppText.body(12, color: AppColors.muted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
