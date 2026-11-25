import 'package:flutter/material.dart';

/// App name in one place, so renaming the app is a one-line change.
class AppConfig {
  static const String appName = 'Sukoon';
}

class AppColors {
  static const Color sand = Color(0xFFF6F1EA);
  static const Color sandDeep = Color(0xFFEADFD2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF2A2320);
  static const Color muted = Color(0xFF6B5E55);
  static const Color line = Color(0xFFE3D9CC);
  static const Color accent = Color(0xFF4A5BB8);
  static const Color accentSoft = Color(0xFFECEEFB);
  static const Color night = Color(0xFF2F3A78);
  static const Color nightSoft = Color(0xFFD5DAF5);
  static const Color peach = Color(0xFFF2C9A8);
  static const Color success = Color(0xFF2E6B52);
  static const Color successSoft = Color(0xFFE3F1EA);
  static const Color warn = Color(0xFF9A4A1F);
  static const Color warnSoft = Color(0xFFFBEBDD);
  static const Color danger = Color(0xFFB3261E);
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

  static const Tone locked = Tone(Color(0xFFE3D9CC), Color(0xFFF3EEE8), Color(0xFF8A7D72));

  static Tone of(String name) => all[name] ?? all['indigo']!;
}

class AppText {
  static const String sans = 'PlusJakartaSans';
  static const String serif = 'Fraunces';

  static TextStyle display(double size, {Color color = AppColors.ink}) =>
      TextStyle(fontFamily: serif, fontSize: size, fontWeight: FontWeight.w600, height: 1.15, color: color);

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double height = 1.4,
  }) => TextStyle(fontFamily: sans, fontSize: size, fontWeight: weight, color: color, height: height);

  static const TextStyle label = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.muted,
  );
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      surface: AppColors.sand,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppText.sans,
      scaffoldBackgroundColor: AppColors.sand,
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.line,
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontFamily: AppText.sans, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 54),
          side: const BorderSide(color: AppColors.line),
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontFamily: AppText.sans, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(fontFamily: AppText.sans, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(fontFamily: AppText.sans, color: AppColors.white, fontSize: 14),
      ),
    );
  }
}
