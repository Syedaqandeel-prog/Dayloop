import 'package:flutter/material.dart';

import 'palettes.dart';

export 'palettes.dart';

/// App name in one place, so renaming the app is a one-line change.
class AppConfig {
  static const String appName = 'Dayloop';
  static const String version = '1.0.0';
  static const String company = 'Innovexa Technologies';
  static const String supportEmail = 'innovexa.technologies01@gmail.com';

  /// Public web address of the privacy policy (fill in after hosting
  /// `docs/privacy-policy.html`, e.g. on GitHub Pages). Empty = in-app only.
  static const String privacyPolicyUrl = '';
}

/// The colours of the active scheme and mode.
///
/// [current] is set once per frame by the app root (see `main.dart`) before
/// any screen builds, so every widget reads the same palette. Screens rebuild
/// automatically when the user changes the scheme or mode, because they all
/// listen to the app store.
class AppColors {
  static Palette current = kSchemes.first.light;

  static bool get isDark => current.isDark;
  static Color get sand => current.sand;
  static Color get sandDeep => current.sandDeep;
  static Color get card => current.card;
  static Color get ink => current.ink;
  static Color get muted => current.muted;
  static Color get line => current.line;
  static Color get accent => current.accent;
  static Color get onAccent => current.onAccent;
  static Color get accentSoft => current.accentSoft;
  static Color get accentSoftInk => current.accentSoftInk;
  static Color get night => current.night;
  static Color get nightInk => current.nightInk;
  static Color get nightSoft => current.nightSoft;
  static Color get peach => current.peach;
  static Color get onPeach => current.onPeach;
  static Color get success => current.success;
  static Color get successSoft => current.successSoft;
  static Color get warn => current.warn;
  static Color get warnSoft => current.warnSoft;
  static Color get danger => current.danger;
  static Color get waterBg => current.waterBg;
  static Color get waterInk => current.waterInk;
  static Color get waterSub => current.waterSub;
  static Color get waterBar => current.waterBar;
  static Color get waterTrack => current.waterTrack;

  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteFaint = Color(0x26FFFFFF);
}

/// Badge colour families: ring, background, icon.
class Tone {
  const Tone(this.ring, this.bg, this.ink);
  final Color ring;
  final Color bg;
  final Color ink;

  static const Map<String, Tone> all = {
    'peach': Tone(Color(0xFFE59A62), Color(0xFFFBEBDD), Color(0xFF9A4A1F)),
    'gold': Tone(Color(0xFFE8C25A), Color(0xFFFBF3DC), Color(0xFF7A5A0E)),
    'blue': Tone(Color(0xFF6FA3D6), Color(0xFFE4EEF6), Color(0xFF2D5B80)),
    'pink': Tone(Color(0xFFC97BAE), Color(0xFFF4E6F0), Color(0xFF7A3B66)),
    'indigo': Tone(Color(0xFF8A97DD), Color(0xFFECEEFB), Color(0xFF4A5BB8)),
    'green': Tone(Color(0xFF7DBB9C), Color(0xFFE3F1EA), Color(0xFF2E6B52)),
  };

  static Tone get locked => AppColors.isDark
      ? const Tone(Color(0xFF4A4550), Color(0xFF26222B), Color(0xFF9C95A6))
      : const Tone(Color(0xFFE3D9CC), Color(0xFFF3EEE8), Color(0xFF8A7D72));

  /// In dark mode the light tints become deep tints of the same hue.
  static Tone of(String name) {
    final t = all[name] ?? all['indigo']!;
    if (!AppColors.isDark) return t;
    return Tone(t.ring, t.ring.withAlpha(0x33), t.ring);
  }
}

class AppText {
  static const String sans = 'Bricolage';
  static const String serif = 'BricolageDisplay';

  static TextStyle display(double size, {Color? color}) => TextStyle(
    fontFamily: serif,
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.02 * size,
    color: color ?? AppColors.ink,
  );

  static TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color? color, double height = 1.4}) =>
      TextStyle(fontFamily: sans, fontSize: size, fontWeight: weight, color: color ?? AppColors.ink, height: height);

  static TextStyle get label => TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.muted,
  );
}

class AppTheme {
  static ThemeData build(Palette p) {
    final brightness = p.isDark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      surface: p.sand,
      onSurface: p.ink,
      error: p.danger,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppText.sans,
      scaffoldBackgroundColor: p.sand,
      canvasColor: p.sand,
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          disabledBackgroundColor: p.line,
          disabledForegroundColor: p.muted,
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontFamily: AppText.sans, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, 54),
          side: BorderSide(color: p.line),
          backgroundColor: p.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontFamily: AppText.sans, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.isDark ? p.accent : p.accentSoftInk,
          textStyle: const TextStyle(fontFamily: AppText.sans, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        hintStyle: TextStyle(color: p.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.night,
        contentTextStyle: TextStyle(fontFamily: AppText.sans, color: p.nightInk, fontSize: 14),
      ),
    );
  }
}
