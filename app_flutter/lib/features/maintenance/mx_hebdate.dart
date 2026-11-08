/// Hebrew calendar date for display ("כ״ח בחשוון תשפ״ז"), offline, no deps.
///
/// Arithmetic Hebrew calendar (Dershowitz & Reingold, "Calendrical
/// Calculations"): molad + dehiyyot, months Nisan = 1 … Adar II = 13.
library;

const int _epoch = -1373427; // R.D. of 1 Tishrei, year 1

bool _leap(int y) => (7 * y + 1) % 19 < 7;

int _elapsed(int y) {
  final months = (235 * y - 234) ~/ 19;
  final parts = 12084 + 13753 * months;
  final day = 29 * months + parts ~/ 25920;
  return (3 * (day + 1)) % 7 < 3 ? day + 1 : day;
}

int _correction(int y) {
  final ny0 = _elapsed(y - 1);
  final ny1 = _elapsed(y);
  final ny2 = _elapsed(y + 1);
  if (ny2 - ny1 == 356) return 2;
  if (ny1 - ny0 == 382) return 1;
  return 0;
}

int _newYear(int y) => _epoch + _elapsed(y) + _correction(y);

int _daysInYear(int y) => _newYear(y + 1) - _newYear(y);

int _lastDay(int m, int y) {
  if (const {2, 4, 6, 10, 13}.contains(m)) return 29;
  if (m == 12 && !_leap(y)) return 29;
  if (m == 8 && _daysInYear(y) % 10 != 5) return 29;
  if (m == 9 && _daysInYear(y) % 10 == 3) return 29;
  return 30;
}

int _lastMonth(int y) => _leap(y) ? 13 : 12;

int _fixed(int y, int m, int d) {
  var days = _newYear(y) + d - 1;
  if (m < 7) {
    for (var i = 7; i <= _lastMonth(y); i++) {
      days += _lastDay(i, y);
    }
    for (var i = 1; i < m; i++) {
      days += _lastDay(i, y);
    }
  } else {
    for (var i = 7; i < m; i++) {
      days += _lastDay(i, y);
    }
  }
  return days;
}

/// (year, month, day) of the Hebrew date for a Gregorian [date].
(int, int, int) mxHebrewYmd(DateTime date) {
  final rd =
      DateTime.utc(
        date.year,
        date.month,
        date.day,
      ).difference(DateTime.utc(1970)).inDays +
      719163;
  var y = ((rd - _epoch) / (35975351 / 98496)).floor();
  while (_newYear(y + 1) <= rd) {
    y++;
  }
  while (_newYear(y) > rd) {
    y--;
  }
  var m = rd < _fixed(y, 1, 1) ? 7 : 1;
  while (rd > _fixed(y, m, _lastDay(m, y))) {
    m++;
  }
  final d = rd - _fixed(y, m, 1) + 1;
  return (y, m, d);
}

const List<String> _ones = ['', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט'];
const List<String> _tens = ['', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ'];
const List<String> _hundreds = ['', 'ק', 'ר', 'ש', 'ת'];

/// Gematria with geresh / gershayim: 28 → כ״ח, 15 → ט״ו, 787 → תשפ״ז.
String mxGematria(int n) {
  var v = n % 1000;
  final b = StringBuffer();
  while (v >= 400) {
    b.write('ת');
    v -= 400;
  }
  if (v >= 100) {
    b.write(_hundreds[v ~/ 100]);
    v %= 100;
  }
  if (v == 15) {
    b.write('טו');
  } else if (v == 16) {
    b.write('טז');
  } else {
    b
      ..write(_tens[v ~/ 10])
      ..write(_ones[v % 10]);
  }
  final s = b.toString();
  if (s.length == 1) return '$s׳';
  return '${s.substring(0, s.length - 1)}״${s.substring(s.length - 1)}';
}

String _monthName(int m, int y) => switch (m) {
  1 => 'ניסן',
  2 => 'אייר',
  3 => 'סיוון',
  4 => 'תמוז',
  5 => 'אב',
  6 => 'אלול',
  7 => 'תשרי',
  8 => 'חשוון',
  9 => 'כסלו',
  10 => 'טבת',
  11 => 'שבט',
  12 => _leap(y) ? 'אדר א׳' : 'אדר',
  _ => 'אדר ב׳',
};

/// "כ״ח בחשוון תשפ״ז".
String mxHebrewDate(DateTime date) {
  final (y, m, d) = mxHebrewYmd(date);
  return '${mxGematria(d)} ב${_monthName(m, y)} ${mxGematria(y)}';
}
