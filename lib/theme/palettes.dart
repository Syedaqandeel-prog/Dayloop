import 'package:flutter/material.dart';

/// Every colour the app uses, for one scheme in one mode (light or dark).
/// Semantic colours (success, warning, water) adapt to the mode automatically.
class Palette {
  const Palette({
    required this.isDark,
    required this.sand,
    required this.sandDeep,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.accentSoftInk,
    required this.night,
    required this.nightInk,
    required this.nightSoft,
    required this.peach,
  });

  final bool isDark;

  /// Page background.
  final Color sand;

  /// Subtle filled areas (tracks, segmented controls).
  final Color sandDeep;

  /// Cards and sheets.
  final Color card;
  final Color ink;
  final Color muted;
  final Color line;

  /// Main action colour (buttons, checks) and the text/icon colour on it.
  final Color accent;
  final Color onAccent;

  /// Tinted background for selected chips, and readable text on it.
  final Color accentSoft;
  final Color accentSoftInk;

  /// Signature "hero" colour: header blocks, streak card, focus screen.
  /// Always deep in both modes, so light text sits on it.
  final Color night;
  final Color nightInk;
  final Color nightSoft;

  /// Highlight colour: streak flame, progress ring, selected mood.
  final Color peach;

  Color get success => isDark ? const Color(0xFF6FD3A5) : const Color(0xFF2E6B52);
  Color get successSoft => isDark ? const Color(0xFF183528) : const Color(0xFFE3F1EA);
  Color get warn => isDark ? const Color(0xFFF5A97A) : const Color(0xFF9A4A1F);
  Color get warnSoft => isDark ? const Color(0xFF3A2316) : const Color(0xFFFBEBDD);
  Color get danger => isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E);
  Color get waterBg => isDark ? const Color(0xFF13263A) : const Color(0xFFE4EEF6);
  Color get waterInk => isDark ? const Color(0xFFDCEBFA) : const Color(0xFF14284A);
  Color get waterSub => isDark ? const Color(0xFFA9C6E6) : const Color(0xFF24426E);
  Color get waterBar => isDark ? const Color(0xFF6DB3F2) : const Color(0xFF2A5DA8);
  Color get waterTrack => isDark ? const Color(0xFF24405E) : const Color(0xFFB9CCE6);

  /// Text on the highlight colour (all highlights are light, so dark text).
  Color get onPeach => const Color(0xFF14100A);
}

class AppScheme {
  const AppScheme({required this.id, required this.name, required this.light, required this.dark});
  final String id;
  final String name;
  final Palette light;
  final Palette dark;

  Palette of(bool dark) => dark ? this.dark : light;
}

const String kDefaultSchemeId = 'p1';

const List<AppScheme> kSchemes = [
  AppScheme(
    id: 'p1',
    name: 'Saffron Night',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF7F3EE),
      sandDeep: Color(0xFFF0EAE3),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF22172E),
      muted: Color(0xFF6B5F75),
      line: Color(0xFFE8E0D8),
      accent: Color(0xFF3B2558),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFEFE7F7),
      accentSoftInk: Color(0xFF3B2558),
      night: Color(0xFF2A1B3D),
      nightInk: Color(0xFFFFF6EA),
      nightSoft: Color(0xFFC9B9D9),
      peach: Color(0xFFF2A93B),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF120B1A),
      sandDeep: Color(0xFF261B34),
      card: Color(0xFF1D1428),
      ink: Color(0xFFF4EDF8),
      muted: Color(0xFFA797B7),
      line: Color(0xFF2F2340),
      accent: Color(0xFFF2A93B),
      onAccent: Color(0xFF1E1207),
      accentSoft: Color(0xFF3A2814),
      accentSoftInk: Color(0xFFF7C36E),
      night: Color(0xFF2C1C42),
      nightInk: Color(0xFFFFF6EA),
      nightSoft: Color(0xFFC2B0D6),
      peach: Color(0xFFF2A93B),
    ),
  ),
  AppScheme(
    id: 'p2',
    name: 'Emerald Ink',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF2F5F1),
      sandDeep: Color(0xFFE8EEE7),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF10241E),
      muted: Color(0xFF52665E),
      line: Color(0xFFDCE5DD),
      accent: Color(0xFF0F3D33),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFDDEFE6),
      accentSoftInk: Color(0xFF0F3D33),
      night: Color(0xFF0F3D33),
      nightInk: Color(0xFFF1FBF6),
      nightSoft: Color(0xFFA9CFC1),
      peach: Color(0xFFE5C07B),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF07130F),
      sandDeep: Color(0xFF152A23),
      card: Color(0xFF0F1F1A),
      ink: Color(0xFFE6F3EE),
      muted: Color(0xFF8FB0A4),
      line: Color(0xFF1C342C),
      accent: Color(0xFF7FE0B6),
      onAccent: Color(0xFF04140E),
      accentSoft: Color(0xFF133A2E),
      accentSoftInk: Color(0xFF9BEBC8),
      night: Color(0xFF0F3D33),
      nightInk: Color(0xFFF1FBF6),
      nightSoft: Color(0xFF9CC9B8),
      peach: Color(0xFFE5C07B),
    ),
  ),
  AppScheme(
    id: 'p3',
    name: 'Cobalt Peach',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF5F6FC),
      sandDeep: Color(0xFFECEEFA),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF121638),
      muted: Color(0xFF575C83),
      line: Color(0xFFE1E4F3),
      accent: Color(0xFF2340D9),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFE3E8FE),
      accentSoftInk: Color(0xFF1B32AD),
      night: Color(0xFF2340D9),
      nightInk: Color(0xFFFFFFFF),
      nightSoft: Color(0xFFD3DAFF),
      peach: Color(0xFFFFB38A),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF080B1F),
      sandDeep: Color(0xFF171D48),
      card: Color(0xFF11163A),
      ink: Color(0xFFECEEFF),
      muted: Color(0xFF9AA0CC),
      line: Color(0xFF232A5A),
      accent: Color(0xFFFFB38A),
      onAccent: Color(0xFF2A1206),
      accentSoft: Color(0xFF3A2620),
      accentSoftInk: Color(0xFFFFC9A9),
      night: Color(0xFF1B2FA8),
      nightInk: Color(0xFFFFFFFF),
      nightSoft: Color(0xFFC3CCFF),
      peach: Color(0xFFFFB38A),
    ),
  ),
  AppScheme(
    id: 'p4',
    name: 'Mulberry Sand',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF8F2EA),
      sandDeep: Color(0xFFF1E7DA),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF2B1420),
      muted: Color(0xFF725A64),
      line: Color(0xFFEADCCB),
      accent: Color(0xFF6E1C45),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFF6E2EA),
      accentSoftInk: Color(0xFF6E1C45),
      night: Color(0xFF6E1C45),
      nightInk: Color(0xFFFFF4EA),
      nightSoft: Color(0xFFE6BCCB),
      peach: Color(0xFFE9C49A),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF140A0F),
      sandDeep: Color(0xFF2A1820),
      card: Color(0xFF201218),
      ink: Color(0xFFF8ECEF),
      muted: Color(0xFFBB9EA8),
      line: Color(0xFF36202A),
      accent: Color(0xFFF0A2C0),
      onAccent: Color(0xFF26101A),
      accentSoft: Color(0xFF3E1C2B),
      accentSoftInk: Color(0xFFF7BFD3),
      night: Color(0xFF5A1738),
      nightInk: Color(0xFFFFF4EA),
      nightSoft: Color(0xFFE0B2C2),
      peach: Color(0xFFE9C49A),
    ),
  ),
  AppScheme(
    id: 'p5',
    name: 'Petrol Coral',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF1F5F6),
      sandDeep: Color(0xFFE5EDEF),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF0D2229),
      muted: Color(0xFF4E666E),
      line: Color(0xFFD8E4E7),
      accent: Color(0xFF0E4A5C),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFDCEDF1),
      accentSoftInk: Color(0xFF0E4A5C),
      night: Color(0xFF0E4A5C),
      nightInk: Color(0xFFF0FAFC),
      nightSoft: Color(0xFFA6CBD5),
      peach: Color(0xFFFF7A59),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF061217),
      sandDeep: Color(0xFF132A33),
      card: Color(0xFF0D1E25),
      ink: Color(0xFFE3F1F4),
      muted: Color(0xFF8AABB4),
      line: Color(0xFF1B3540),
      accent: Color(0xFFFF8A6B),
      onAccent: Color(0xFF2A0E06),
      accentSoft: Color(0xFF3B1F18),
      accentSoftInk: Color(0xFFFFAA93),
      night: Color(0xFF0E4A5C),
      nightInk: Color(0xFFF0FAFC),
      nightSoft: Color(0xFFA8D0DA),
      peach: Color(0xFFFF7A59),
    ),
  ),
  AppScheme(
    id: 'p6',
    name: 'Plum Lime',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF6F4F8),
      sandDeep: Color(0xFFEDE9F2),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF1E1229),
      muted: Color(0xFF63576F),
      line: Color(0xFFE3DDEA),
      accent: Color(0xFF3D1E5C),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFECE4F5),
      accentSoftInk: Color(0xFF3D1E5C),
      night: Color(0xFF3D1E5C),
      nightInk: Color(0xFFFBF8FF),
      nightSoft: Color(0xFFC6B4DB),
      peach: Color(0xFFC6F135),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF0E0814),
      sandDeep: Color(0xFF21162E),
      card: Color(0xFF180F22),
      ink: Color(0xFFF2ECF8),
      muted: Color(0xFFA596B5),
      line: Color(0xFF2C2039),
      accent: Color(0xFFC6F135),
      onAccent: Color(0xFF151F02),
      accentSoft: Color(0xFF2A3410),
      accentSoftInk: Color(0xFFD4F56A),
      night: Color(0xFF331A4D),
      nightInk: Color(0xFFFBF8FF),
      nightSoft: Color(0xFFC4B0DA),
      peach: Color(0xFFC6F135),
    ),
  ),
  AppScheme(
    id: 'p7',
    name: 'Graphite Tangerine',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF4F4F2),
      sandDeep: Color(0xFFEAEAE6),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF15171A),
      muted: Color(0xFF5B5E63),
      line: Color(0xFFE0E0DC),
      accent: Color(0xFF1F2328),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFFFE9D4),
      accentSoftInk: Color(0xFF8A4200),
      night: Color(0xFF1F2328),
      nightInk: Color(0xFFF7F7F5),
      nightSoft: Color(0xFFB3B7BD),
      peach: Color(0xFFFF8A1F),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF0B0C0E),
      sandDeep: Color(0xFF1C1F23),
      card: Color(0xFF15171A),
      ink: Color(0xFFF1F1EF),
      muted: Color(0xFF9DA1A7),
      line: Color(0xFF262A2F),
      accent: Color(0xFFFF8A1F),
      onAccent: Color(0xFF1F0E00),
      accentSoft: Color(0xFF33200D),
      accentSoftInk: Color(0xFFFFAA5C),
      night: Color(0xFF1E2227),
      nightInk: Color(0xFFF7F7F5),
      nightSoft: Color(0xFFAAAFB6),
      peach: Color(0xFFFF8A1F),
    ),
  ),
  AppScheme(
    id: 'p8',
    name: 'Midnight Aurora',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF3F5FA),
      sandDeep: Color(0xFFE9EDF6),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF0D1530),
      muted: Color(0xFF525C7A),
      line: Color(0xFFDDE3EF),
      accent: Color(0xFF0B1530),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFDDF7F1),
      accentSoftInk: Color(0xFF0B6B5A),
      night: Color(0xFF0B1530),
      nightInk: Color(0xFFF2F6FF),
      nightSoft: Color(0xFFA9B6D8),
      peach: Color(0xFF3DE0C0),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF050A18),
      sandDeep: Color(0xFF121C36),
      card: Color(0xFF0C1428),
      ink: Color(0xFFE8EEFF),
      muted: Color(0xFF8E9AC0),
      line: Color(0xFF1A2546),
      accent: Color(0xFF3DE0C0),
      onAccent: Color(0xFF031A15),
      accentSoft: Color(0xFF0F3530),
      accentSoftInk: Color(0xFF6FEBD3),
      night: Color(0xFF0E1A3D),
      nightInk: Color(0xFFF2F6FF),
      nightSoft: Color(0xFFA6B4DE),
      peach: Color(0xFF3DE0C0),
    ),
  ),
  AppScheme(
    id: 'p9',
    name: 'Terracotta Olive',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF7F2EA),
      sandDeep: Color(0xFFEFE7DA),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF2A1A12),
      muted: Color(0xFF6C5A4C),
      line: Color(0xFFE7DCCB),
      accent: Color(0xFF5B6B2E),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFE9EDD9),
      accentSoftInk: Color(0xFF47541F),
      night: Color(0xFF9E3E1E),
      nightInk: Color(0xFFFFF5E8),
      nightSoft: Color(0xFFFFE0CF),
      peach: Color(0xFFF2C46D),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF130D09),
      sandDeep: Color(0xFF281D16),
      card: Color(0xFF1E1611),
      ink: Color(0xFFF6ECE3),
      muted: Color(0xFFB7A392),
      line: Color(0xFF33261D),
      accent: Color(0xFFB9C979),
      onAccent: Color(0xFF161B05),
      accentSoft: Color(0xFF2B3115),
      accentSoftInk: Color(0xFFCCDB8E),
      night: Color(0xFF6E2A14),
      nightInk: Color(0xFFFFF1E6),
      nightSoft: Color(0xFFF3CDB9),
      peach: Color(0xFFF2C46D),
    ),
  ),
  AppScheme(
    id: 'p10',
    name: 'Sapphire Gold',
    light: Palette(
      isDark: false,
      sand: Color(0xFFF3F5F9),
      sandDeep: Color(0xFFE8ECF3),
      card: Color(0xFFFFFFFF),
      ink: Color(0xFF0E1A33),
      muted: Color(0xFF53607A),
      line: Color(0xFFDCE2EC),
      accent: Color(0xFF102A5C),
      onAccent: Color(0xFFFFFFFF),
      accentSoft: Color(0xFFE1E8F6),
      accentSoftInk: Color(0xFF102A5C),
      night: Color(0xFF102A5C),
      nightInk: Color(0xFFF5F8FF),
      nightSoft: Color(0xFFB6C6E6),
      peach: Color(0xFFE3B04B),
    ),
    dark: Palette(
      isDark: true,
      sand: Color(0xFF060C1A),
      sandDeep: Color(0xFF142036),
      card: Color(0xFF0E1729),
      ink: Color(0xFFE9EFFA),
      muted: Color(0xFF93A2BE),
      line: Color(0xFF1C2A45),
      accent: Color(0xFFE3B04B),
      onAccent: Color(0xFF1F1503),
      accentSoft: Color(0xFF33290F),
      accentSoftInk: Color(0xFFEFC66E),
      night: Color(0xFF0F2550),
      nightInk: Color(0xFFF5F8FF),
      nightSoft: Color(0xFFAFC0E4),
      peach: Color(0xFFE3B04B),
    ),
  ),
];

AppScheme schemeById(String id) {
  for (final s in kSchemes) {
    if (s.id == id) return s;
  }
  return kSchemes.first;
}
