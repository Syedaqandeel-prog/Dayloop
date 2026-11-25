/// Date helpers. All app data is stored per calendar day using a
/// `yyyy-MM-dd` key in the user's local time, so timezones and
/// daylight-saving changes never shift a day.
library;

const List<String> kWeekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

const List<String> kWeekdayShort = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

const List<String> kMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Strips the time part.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Adds whole calendar days (safe across daylight-saving changes).
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

String _two(int v) => v.toString().padLeft(2, '0');

/// `2026-11-24`
String dayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// Parses a key made by [dayKey]. Returns null when the key is malformed.
DateTime? tryParseDayKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  return DateTime(y, m, d);
}

DateTime parseDayKey(String key) => tryParseDayKey(key) ?? dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Number of whole days from [from] to [to] (can be negative).
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// `Tuesday, 24 November`
String prettyDate(DateTime d) => '${kWeekdayNames[d.weekday - 1]}, ${d.day} ${kMonthNames[d.month - 1]}';

/// `24 Nov`
String shortDate(DateTime d) => '${d.day} ${kMonthNames[d.month - 1].substring(0, 3)}';

/// The next date (today included) that falls on [weekday] (1 = Monday ... 7 = Sunday).
DateTime nextWeekday(DateTime from, int weekday) {
  final start = dateOnly(from);
  final diff = (weekday - start.weekday + 7) % 7;
  return addDays(start, diff);
}
