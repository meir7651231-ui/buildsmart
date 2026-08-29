// ⚛️ אטום-Dart (דרגת-חוזה) · hebDateFull — 'ט״ו אלול תשפ״ו' מתוך ISO.
// מוצא: maor/src/lib/hebrew.ts:156-161 (hebDateFull) — חולץ כלשונו (חוק-4:
//        התנהגות זהה למקור-ה-JS, לא-משופרת). המקור: new/atoms/heb-date-full.mjs.
// שקעים (חוק-1 — קריאות-לשכנים הוזרקו כפרמטרים): gem · gemYear · hebParts.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core בלבד).
//
// הערות-המרה (DART-PORTING-RULES):
// • fmtHM/fmtHY של המקור הם Intl.DateTimeFormat('he-u-ca-hebrew',...) — אין להם
//   מקבילה ב-dart-core, לכן המרת-הלוח-העברי ממומשת ידנית (Dershowitz–Reingold):
//   fmtHM ⇒ שם-החודש העברי · fmtHY ⇒ מספר-השנה העברית כמחרוזת-ספרות ("5786").
//   השמות/המספר זהים ביט-אחר-ביט לפלט Intl בטווח דוגמאות-החוזה.
// • כלל-4 (תאריך-מגלגל): המקור עושה `new Date(iso.slice(0,10)+'T12:00:00')`
//   ומחזיר '' על isNaN. Dart substring(0,-1) זורק — slice(0,10) מוחלף בגזירה-בטוחה;
//   ולידציית-חודש/יום מחקה את V8 (חודש 1..12 · יום ≥1 · גלישת-יום מתגלגלת, לא נדחית).
// • טוהר-מוטביליות: הקלט iso אינו מְשׁוּנֶּה.

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
  if (month == 2 || month == 4 || month == 6 || month == 10 || month == 13) {
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
  int year = ((98496 * (date - _hebrewEpoch)) ~/ 35975351) + 1;
  while (_hebrewNewYear(year + 1) <= date) {
    year++;
  }
  final int start = (date < _hebrewToFixed(year, 1, 1)) ? 7 : 1;
  int month = start;
  while (date > _hebrewToFixed(year, month, _lastDayOfHebrewMonth(year, month))) {
    month++;
  }
  final int day = date - _hebrewToFixed(year, month, 1) + 1;
  return <int>[year, month, day];
}

// fmtHM: שם-החודש העברי (זהה לפלט Intl he-u-ca-hebrew, month:'long').
String _hebrewMonthName(int year, int month) {
  switch (month) {
    case 1:
      return 'ניסן';
    case 2:
      return 'אייר';
    case 3:
      return 'סיוון';
    case 4:
      return 'תמוז';
    case 5:
      return 'אב';
    case 6:
      return 'אלול';
    case 7:
      return 'תשרי';
    case 8:
      return 'חשוון';
    case 9:
      return 'כסלו';
    case 10:
      return 'טבת';
    case 11:
      return 'שבט';
    case 12:
      return _hebrewLeapYear(year) ? 'אדר א׳' : 'אדר';
    case 13:
      return 'אדר ב׳';
    default:
      return '';
  }
}

// מחקה `new Date(head+'T12:00:00')` של V8: מחזיר DateTime בצהריים או null (isNaN).
// חודש חייב 1..12 · יום ≥1 · גלישת-יום מתגלגלת לחודש-הבא (כמו V8), חודש/יום
// מחוץ-לטווח = null. head נגזר כבר ל-slice(0,10).
DateTime? _parseNoon(String head) {
  final RegExp re = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  final Match? m = re.firstMatch(head);
  if (m == null) return null;
  final int y = int.parse(m.group(1)!);
  final int mo = int.parse(m.group(2)!);
  final int day = int.parse(m.group(3)!);
  if (mo < 1 || mo > 12) return null; // V8: חודש 13/00 ⇒ Invalid
  if (day < 1) return null; // V8: יום 00 ⇒ Invalid
  // DateTime מגלגל גלישת-יום (2026-02-30 ⇒ 03-02) בדיוק כמו V8 (כלל-4).
  return DateTime(y, mo, day, 12, 0, 0);
}

/// "ט״ו אלול תשפ״ו" מתוך [iso] (צהריים-מקומי — חסין-אזורי-זמן). ריק/שבור ⇒ ''.
/// שקעים: [gem] (גימטריית-יום) · [gemYear] (גימטריית-שנה מ-"5786") · [hebParts]
/// (רכיבי-התאריך-העברי — נלקח רק day). התנהגות זהה למקור-ה-JS (חוק-4).
String hebDateFull(
  String? iso,
  String Function(num n) gem,
  String Function(String y) gemYear,
  Map<String, Object> Function(DateTime d) hebParts,
) {
  if (iso == null || iso.isEmpty) return ''; // JS: if (!iso) return ''
  final String head = iso.length >= 10 ? iso.substring(0, 10) : iso; // slice(0,10)
  final DateTime? d = _parseNoon(head);
  if (d == null) return ''; // JS: if (isNaN(d.getTime())) return ''
  final int day = (hebParts(d)['day'] as num).toInt(); // gem(hebParts(d).day)
  final int fixed = _gregorianToFixed(d.year, d.month, d.day);
  final List<int> heb = _fixedToHebrew(fixed);
  final String month = _hebrewMonthName(heb[0], heb[1]); // fmtHM.format(d)
  final String yearStr = heb[0].toString(); // fmtHY.format(d) ⇒ "5786"
  return '${gem(day)} $month ${gemYear(yearStr)}';
}
