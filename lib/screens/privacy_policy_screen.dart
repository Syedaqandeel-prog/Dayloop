import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/links.dart';

/// The same policy as `docs/privacy-policy.html`, readable offline in the app.
/// Keep both texts in sync when the policy changes.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String effectiveDate = '27 November 2026';

  static const List<(String, String)> _sections = [
    (
      'Who we are',
      '${AppConfig.appName} is a habit and routine app made by ${AppConfig.company}. '
          'This policy explains what information the app uses and how it is handled.',
    ),
    (
      'Information stored on your phone',
      'The app saves the things you enter so it can work: your name, profile photo, habits, '
          'completed habits, mood check-ins, water count, journal lines, Self-Care Day plans, '
          'badges, challenges and your settings. All of this is stored only on your device. '
          'We do not have an account system and we do not receive or store this information on any server.',
    ),
    (
      'Information we do not collect',
      'We do not collect your location, contacts, phone number, email or device identifiers. '
          'The app has no advertising and no analytics or tracking tools, and it does not sell or '
          'share any personal information with anyone.',
    ),
    (
      'Camera and photos',
      'If you choose to add a profile photo, the app asks to use your camera or photo library. '
          'The photo you pick is resized and saved only on your device. You can remove it at any time '
          'from your profile. The app never accesses your camera or photos without your action.',
    ),
    (
      'Deleting your data',
      'You can delete everything at any time from Profile → Settings → Reset all data. '
          'Uninstalling the app also deletes all of its data from your phone. '
          'Because we do not store your data, there is no account to delete on our side.',
    ),
    ('Children', 'The app is not directed at children under 13 and does not knowingly collect information from them.'),
    (
      'Changes to this policy',
      'If this policy changes, the new version will be shown in the app and on our website with a new effective date.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: Text('Privacy policy', style: AppText.display(26))),
              ],
            ),
            const SizedBox(height: 8),
            Text('Effective $effectiveDate', style: AppText.body(13, color: AppColors.muted)),
            const SizedBox(height: 18),
            for (final s in _sections) ...[
              Text(s.$1, style: AppText.body(17, weight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(s.$2, style: AppText.body(15, color: AppColors.ink, height: 1.55)),
              const SizedBox(height: 20),
            ],
            Text('Contact us', style: AppText.body(17, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Questions about privacy or the app? Write to us and we will reply as soon as we can.',
              style: AppText.body(15, height: 1.55),
            ),
            const SizedBox(height: 12),
            AppCard(
              color: AppColors.accentSoft,
              onTap: () => contactSupport(context, subject: 'Dayloop privacy question'),
              child: Row(
                children: [
                  Icon(Icons.mail_outline_rounded, color: AppColors.accentSoftInk),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppConfig.supportEmail,
                      style: AppText.body(15, weight: FontWeight.w700, color: AppColors.accentSoftInk),
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.accentSoftInk),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
