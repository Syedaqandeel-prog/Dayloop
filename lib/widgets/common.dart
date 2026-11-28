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
  'tv': Icons.tv_outlined,
  'movie': Icons.movie_outlined,
  'swim': Icons.pool_outlined,
  'run': Icons.directions_run,
  'bike': Icons.directions_bike_outlined,
  'music': Icons.music_note_outlined,
  'code': Icons.code_rounded,
  'work': Icons.work_outline,
  'clean': Icons.cleaning_services_outlined,
  'money': Icons.savings_outlined,
  'call': Icons.call_outlined,
  'art': Icons.palette_outlined,
  'plant': Icons.local_florist_outlined,
  'pet': Icons.pets_outlined,
  'car': Icons.directions_car_outlined,
  'shop': Icons.shopping_bag_outlined,
  'health': Icons.health_and_safety_outlined,
  'school': Icons.school_outlined,
  'prayer': Icons.mosque_outlined,
  'dance': Icons.music_note_rounded,
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
  'waves',
  'tv',
  'movie',
  'swim',
  'run',
  'bike',
  'music',
  'code',
  'work',
  'clean',
  'money',
  'call',
  'art',
  'plant',
  'pet',
  'car',
  'shop',
  'health',
  'school',
  'prayer',
];

/// Har key ka REAL emoji - is se sab icons ek jese real lagenge
const Map<String, String> kRealEmoji = {
  'water': '💧',
  'stretch': '🧘',
  'meditate': '🧘‍♀️',
  'focus': '🎯',
  'food': '🍱',
  'walk': '🚶',
  'book': '📚',
  'sleep': '😴',
  'journal': '📝',
  'workout': '💪',
  'sun': '☀️',
  'heart': '❤️',
  'star': '⭐',
  'flame': '🔥',
  'flag': '🚩',
  'trophy': '🏆',
  'calendar': '📅',
  'waves': '🌊',
  'spa': '🧖‍♀️',
  'coffee': '☕',
  'tv': '📺',
  'movie': '🎬',
  'swim': '🏊',
  'run': '🏃',
  'bike': '🚴',
  'music': '🎵',
  'code': '💻',
  'work': '💼',
  'clean': '🧹',
  'money': '💰',
  'call': '📞',
  'art': '🎨',
  'plant': '🌱',
  'pet': '🐾',
  'car': '🚗',
  'shop': '🛍️',
  'health': '🩺',
  'school': '🎓',
  'prayer': '🕌',
  'dance': '💃',
};

IconData appIcon(String key) => kAppIcons[key] ?? Icons.star_border;

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.borderColor,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
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
      color: color ?? AppColors.card,
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
  const IconBubble({super.key, required this.icon, this.background, this.foreground, this.size = 44, this.radius = 14});

  final IconData icon;
  final Color? background;
  final Color? foreground;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background ?? AppColors.accentSoft, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: foreground ?? (AppColors.isDark ? AppColors.accent : AppColors.accentSoftInk),
        size: size * 0.5,
      ),
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
    this.background,
    this.foreground,
    this.borderColor = kDefaultBorder,
    this.size = 44,
  });

  /// Marker meaning "use the theme's line colour"; pass null for no border.
  static const Color kDefaultBorder = Color(0x00000001);

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final border = borderColor == kDefaultBorder ? AppColors.line : borderColor;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? AppColors.card,
        shape: CircleBorder(side: border == null ? BorderSide.none : BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: size * 0.42,
              color: onPressed == null ? AppColors.muted : (foreground ?? AppColors.ink),
            ),
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
  const SoftProgressBar({super.key, required this.value, this.color, this.track, this.height = 8});

  final double value;
  final Color? color;
  final Color? track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color ?? AppColors.accent,
        backgroundColor: track ?? AppColors.sandDeep,
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

/// Names of the bundled 3D emoji (Microsoft Fluent Emoji, MIT licence),
/// stored in `assets/emoji/<name>.png`.
const Set<String> kEmojiNames = {
  'water', 'stretch', 'meditate', 'focus', 'food', 'walk', 'book', 'sleep', 'journal', 'workout', //
  'sun', 'heart', 'spa', 'coffee', 'star', 'flame', 'flag', 'trophy', 'calendar', 'waves', 'lock', //
  'mood1', 'mood2', 'mood3', 'mood4', 'mood5', 'mail',
};

/// Tile tint per emoji, so every habit type keeps one recognisable colour.
const Map<String, Color> _emojiHue = {
  'water': Color(0xFF2F80D1),
  'stretch': Color(0xFF23935F),
  'walk': Color(0xFF23935F),
  'workout': Color(0xFF23935F),
  'meditate': Color(0xFF7A5AD6),
  'spa': Color(0xFF7A5AD6),
  'waves': Color(0xFF2F80D1),
  'book': Color(0xFFD4762C),
  'journal': Color(0xFFD4762C),
  'sleep': Color(0xFF4A57C4),
  'focus': Color(0xFFD9453A),
  'food': Color(0xFF23935F),
  'coffee': Color(0xFFB0703A),
  'sun': Color(0xFFE0A02A),
  'heart': Color(0xFFD9466B),
  'star': Color(0xFFE0A02A),
  'flame': Color(0xFFE0702A),
  'flag': Color(0xFFD9453A),
  'trophy': Color(0xFFE0A02A),
  'calendar': Color(0xFF4A57C4),
  'mail': Color(0xFF2F80D1),
  'lock': Color(0xFFE0A02A),
  'tv': Color(0xFF4A57C4),
  'movie': Color(0xFF4A57C4),
  'swim': Color(0xFF2F80D1),
  'run': Color(0xFFD9453A),
  'bike': Color(0xFF23935F),
  'music': Color(0xFF7A5AD6),
  'code': Color(0xFF4A57C4),
  'work': Color(0xFFD4762C),
  'clean': Color(0xFF23935F),
  'money': Color(0xFFE0A02A),
  'call': Color(0xFFD9466B),
  'art': Color(0xFFD9453A),
  'plant': Color(0xFF23935F),
  'pet': Color(0xFFD4762C),
  'car': Color(0xFF4A57C4),
  'shop': Color(0xFFD9466B),
  'health': Color(0xFFD9453A),
  'school': Color(0xFFD4762C),
  'prayer': Color(0xFF7A5AD6),
  'dance': Color(0xFF7A5AD6),
};

/// A realistic 3D emoji image. Falls back to a plain icon if the image is missing.
class Emoji3D extends StatelessWidget {
  const Emoji3D(this.name, {super.key, this.size = 28});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final emoji = kRealEmoji[name];
    if (emoji != null) {
      return Text(
        emoji,
        style: TextStyle(fontSize: size, height: 1),
        textAlign: TextAlign.center,
      );
    }
    if (!kEmojiNames.contains(name)) {
      return Icon(appIcon(name), size: size, color: AppColors.accent);
    }
    return Image.asset(
      'assets/emoji/$name.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => Icon(appIcon(name), size: size, color: AppColors.accent),
    );
  }
}

/// Rounded, softly tinted tile holding a 3D emoji (habit and category icons).
class EmojiTile extends StatelessWidget {
  const EmojiTile(this.name, {super.key, this.size = 48});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hue = _emojiHue[name] ?? AppColors.accent;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hue.withAlpha(AppColors.isDark ? 0x33 : 0x1F),
        borderRadius: BorderRadius.circular(size * 0.33),
      ),
      alignment: Alignment.center,
      child: Emoji3D(name, size: size * 0.62),
    );
  }
}