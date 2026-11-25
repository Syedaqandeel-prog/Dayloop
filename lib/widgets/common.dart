import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Icons are stored as short keys (not code points) so release builds can
/// tree-shake the icon font safely.
const Map<String, IconData> kAppIcons = {
  'water': Icons.water_drop_outlined,
  'stretch': Icons.accessibility_new,
  'meditate': Icons.self_improvement,
  'focus': Icons.center_focus_strong_outlined,
  'food': Icons.restaurant_outlined,
  'walk': Icons.directions_walk,
  'book': Icons.menu_book_outlined,
  'sleep': Icons.bedtime_outlined,
  'journal': Icons.edit_note,
  'workout': Icons.fitness_center,
  'sun': Icons.wb_sunny_outlined,
  'heart': Icons.favorite_border,
  'star': Icons.star_border,
  'flame': Icons.local_fire_department_outlined,
  'flag': Icons.flag_outlined,
  'trophy': Icons.emoji_events_outlined,
  'calendar': Icons.event_available,
  'waves': Icons.waves,
  'spa': Icons.spa_outlined,
  'coffee': Icons.coffee_outlined,
};

/// Icons a user can pick for a habit.
const List<String> kHabitIconChoices = [
  'water',
  'stretch',
  'meditate',
  'focus',
  'food',
  'walk',
  'book',
  'sleep',
  'journal',
  'workout',
  'sun',
  'heart',
  'spa',
  'coffee',
];

IconData appIcon(String key) => kAppIcons[key] ?? Icons.star_border;

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.card,
    this.onTap,
    this.borderColor,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
    );
    return Material(
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: AppText.label)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble({
    super.key,
    required this.icon,
    this.background = AppColors.accentSoft,
    this.foreground = AppColors.accent,
    this.size = 44,
    this.radius = 14,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Icon(icon, color: foreground, size: size * 0.5),
    );
  }
}

/// Round outlined icon button with a 44px touch target and a tooltip.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background = AppColors.card,
    this.foreground = AppColors.ink,
    this.borderColor = AppColors.line,
    this.size = 44,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: CircleBorder(side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.42, color: foreground),
          ),
        ),
      ),
    );
  }
}

/// Selectable pill used for weekdays, categories and modes.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.accent : AppColors.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.accentSoft : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? AppColors.accent : AppColors.line, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(14, weight: selected ? FontWeight.w700 : FontWeight.w500, color: fg),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded progress bar.
class SoftProgressBar extends StatelessWidget {
  const SoftProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.accent,
    this.track = AppColors.sandDeep,
    this.height = 8,
  });

  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color,
        backgroundColor: track,
      ),
    );
  }
}

void showNotice(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(title, style: AppText.body(18, weight: FontWeight.w700)),
      content: Text(message, style: AppText.body(14, color: AppColors.muted)),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: destructive ? AppColors.danger : AppColors.accent),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
