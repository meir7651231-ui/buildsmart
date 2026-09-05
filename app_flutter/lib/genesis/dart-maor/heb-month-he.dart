// חוט · heb-month-he — שם-חודש עברי. חוזה: heb-month-he.contract.md
// פורט Dart טהור מ-new/atoms/heb-month-he.mjs (מקור קדוש, חוק-4).
// המקור נשען על Intl.DateTimeFormat('he-u-ca-hebrew',{month:'long'}) —
// אין לו מקבילה ב-dart-core, לכן המרת-הלוח-העברי ממומשת ידנית (אלגוריתם
// Dershowitz–Reingold), והשמות זהים ביט-אחר-ביט לפלט Intl.
// אפס import (dart-core בלבד). קלט לא-תקין (התאריך לא ניתן לבנייה) ⇒ '' — מקביל
// ל-isNaN(d.getTime()) שמחזיר '' במקור.
//
// ⚠️ תיקון-הסגר (26.8): קירוב-השנה ב-_fixedToHebrew היה `floor(...) + 1` —
// גבוה-בשנה-אחת מהקנוני של Dershowitz–Reingold (`floor(...)`), ולכן בערב-ר"ה
// (יום אחרון לשנה, למשל 29 אלול 5784 = 2024-10-02) הקירוב קפץ ל-5785 ולולאת-
// ההעלאה לא יכלה לתקן כלפי-מטה ⇒ 'תשרי' במקום 'אלול'. הקנוני מבטיח
// floor(...) ≤ השנה-האמיתית, ולולאת-ההעלאה מטפסת לשנה הנכונה. הוסר ה-+1.

const int _hebrewEpoch = -1373427; // RD של תשרי א׳ שנת א׳

bool _hebrewLeapYear(int year) => ((7 * year + 1) % 19) < 7;

int _lastMonthOfHebrewYear(int year) => _hebrewLeapYear(year) ? 13 : 12;

int _hebrewCalendarElapsedDays(int year) {
  final int monthsElapsed = ((235 * year - 234) ~/ 19);
  final int partsElapsed = 12084 + 13753 * monthsElapsed;
  final int day = 29 * monthsElapsed + (partsElapsed ~/ 25920);
  if (((3 * (day + 1)) % 7) < 3) {
    return day + 1;
  }
  return day;
}

int _hebrewYearLengthCorrection(int year) {
  final int ny0 = _hebrewCalendarElapsedDays(year - 1);
  final int ny1 = _hebrewCalendarElapsedDays(year);
  final int ny2 = _hebrewCalendarElapsedDays(year + 1);
  if ((ny2 - ny1) == 356) return 2;
  if ((ny1 - ny0) == 382) return 1;
  return 0;
}

int _hebrewNewYear(int year) =>
    _hebrewEpoch +
    _hebrewCalendarElapsedDays(year) +
    _hebrewYearLengthCorrection(year);

int _daysInHebrewYear(int year) =>
    _hebrewNewYear(year + 1) - _hebrewNewYear(year);

bool _longMarheshvan(int year) {
  final int d = _daysInHebrewYear(year);
  return d == 355 || d == 385;
}

bool _shortKislev(int year) {
  final int d = _daysInHebrewYear(year);
  return d == 353 || d == 383;
}

int _lastDayOfHebrewMonth(int year, int month) {
  if (month == 2 ||
      month == 4 ||
      month == 6 ||
      month == 10 ||
      month == 13) {
    return 29;
  }
  if (month == 8 && !_longMarheshvan(year)) return 29;
  if (month == 9 && _shortKislev(year)) return 29;
  if (month == 12 && !_hebrewLeapYear(year)) return 29;
  return 30;
}

int _hebrewToFixed(int year, int month, int day) {
  int fixed = _hebrewNewYear(year) + day - 1;
  if (month < 7) {
    final int lastMonth = _lastMonthOfHebrewYear(year);
    for (int m = 7; m <= lastMonth; m++) {
      fixed += _lastDayOfHebrewMonth(year, m);
    }
    for (int m = 1; m < month; m++) {
      fixed += _lastDayOfHebrewMonth(year, m);
    }
  } else {
    for (int m = 7; m < month; m++) {
      fixed += _lastDayOfHebrewMonth(year, m);
    }
  }
  return fixed;
}

bool _gregorianLeapYear(int year) =>
    (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);

int _gregorianToFixed(int year, int month, int day) {
  int fixed = 365 * (year - 1) +
      ((year - 1) ~/ 4) -
      ((year - 1) ~/ 100) +
      ((year - 1) ~/ 400) +
      ((367 * month - 362) ~/ 12);
  if (month > 2) {
    fixed += _gregorianLeapYear(year) ? -1 : -2;
  }
  return fixed + day;
}

List<int> _fixedToHebrew(int date) {
  // קנוני: קירוב תחתון (floor) שמובטח ≤ השנה-האמיתית, ואז טיפוס כלפי-מעלה.
  int year = ((98496 * (date - _hebrewEpoch)) ~/ 35975351);
  while (_hebrewNewYear(year + 1) <= date) {
    year++;
  }
  final int start = (date < _hebrewToFixed(year, 1, 1)) ? 7 : 1;
  int month = start;
  while (date >
      _hebrewToFixed(
          year, month, _lastDayOfHebrewMonth(year, month))) {
    month++;
  }
  final int day = date - _hebrewToFixed(year, month, 1) + 1;
  return <int>[year, month, day];
}

// שמות-החודשים = שקע-דאטה (הכרעה 16): אינדקסים 0..10 = ניסן..שבט · 11 = אדר ·
// 12 = אדר א׳ · 13 = אדר ב׳ (dart-data-maor/heb-month-he-sockets.dart).
String _hebrewMonthName(int year, int month, List<String> monthNames) {
  if (month >= 1 && month <= 11) return monthNames[month - 1];
  if (month == 12) return _hebrewLeapYear(year) ? monthNames[12] : monthNames[11];
  if (month == 13) return monthNames[13];
  return '';
}

/// שם-החודש העברי עבור [d]. תאריך לא-תקין (null) ⇒ '' (מקביל ל-isNaN במקור).
String hebMonthHe(DateTime? d, List<String> monthNames) {
  if (d == null) return '';
  final int fixed = _gregorianToFixed(d.year, d.month, d.day);
  final List<int> heb = _fixedToHebrew(fixed);
  return _hebrewMonthName(heb[0], heb[1], monthNames);
}
