// ⚛️ אטום-Dart (דרגת-חוזה) · hebParts — תאריך לועזי ⇒ רכיבי-תאריך-עברי
//    {day:int, month:String(אנגלי), year:int}.
// מוצא: maor/src/lib/hebrew.ts (hebParts) · המקור: new/atoms/heb-parts.mjs.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core בלבד). חוק-1: אטום לא-מייבא.
//
// הערות-המרה (DART-PORTING-RULES) — המנוע לבדו לא הספיק כאן:
// • המקור נשען על Intl.DateTimeFormat('en-u-ca-hebrew', {day,month:'long',year})
//   — יכולת-פלטפורמה של V8 שאין לה מקבילה ב-dart-core. לכן המרת-הלוח-העברי
//   ממומשת ידנית (Dershowitz–Reingold, זהה לאחות heb-date-full) ושמות-החודשים
//   הם **האנגליים שפולט Intl** (Tishri/Heshvan/Adar I/Adar II/… — אומתו מול V8):
//     חודש 12 במעוברת = 'Adar I' · 12 בפשוטה = 'Adar' · 13 = 'Adar II'.
// • 🔧 תיקון-הסגר (heb-parts · גבול-שנה-עברית · ערב-ר"ה): גרסת-ה-QUARANTINE
//   אמדה את השנה-העברית ב-`(… ~/ 35975351) + 1` ואז לולאת-`while` שרק **מגדילה**
//   את year. אומדן שגלש למעלה (בערב-ר"ה, סוף אלול) לא תוקן לעולם ⇒ חודש נפתר
//   בטעות ל-Tishri (month 7) עם day≤0. הקנוני של Dershowitz–Reingold קובע את
//   year כ**חסם-תחתון מובטח** (`… - 1`) ואז מעלה. תוקן ל-`- 1`. אימות-זהב מול
//   Intl: 1700–2400 (255,668 ימים) ⇒ 0 סטיות (לפני-כן 12 סטיות, כולן ערב-ר"ה).
// • מגן-שבור (כלל-4 · כלל-7 truthiness): המקור `isNaN(d.getTime())` ⇒ חלקים בטוחים.
//   ב-Dart אין "Invalid DateTime" — קלט-שבור מיוצג כ-null (כך גם השכן heb-parts-of-iso
//   מזריק `DateTime.tryParse(...)` שמחזיר null על קלט-רע). d==null ⇒ {day:0,month:'',year:0}.
// • טוהר-מוטביליות: הקלט d אינו מְשׁוּנֶּה.

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
  // חסם-תחתון מובטח (Dershowitz–Reingold): `- 1` ואז העלאה בלבד.
  // תיקון-ההסגר: הגרסה השבורה השתמשה ב-`+ 1` ⇒ אומדן-יתר בערב-ר"ה לא תוקן.
  int year = ((98496 * (date - _hebrewEpoch)) ~/ 35975351) - 1;
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

// שמות-החודשים האנגליים כפי שפולט Intl('en-u-ca-hebrew', month:'long') — אומת מול V8.
String _hebrewMonthNameEn(int year, int month) {
  switch (month) {
    case 1:
      return 'Nisan';
    case 2:
      return 'Iyar';
    case 3:
      return 'Sivan';
    case 4:
      return 'Tamuz';
    case 5:
      return 'Av';
    case 6:
      return 'Elul';
    case 7:
      return 'Tishri';
    case 8:
      return 'Heshvan';
    case 9:
      return 'Kislev';
    case 10:
      return 'Tevet';
    case 11:
      return 'Shevat';
    case 12:
      return _hebrewLeapYear(year) ? 'Adar I' : 'Adar';
    case 13:
      return 'Adar II';
    default:
      return '';
  }
}

/// תאריך לועזי [d] ⇒ רכיבי-תאריך-עברי: {'day':int, 'month':String(אנגלי), 'year':int}.
/// קלט-שבור (null — מקביל ל-Invalid Date של המקור) ⇒ {'day':0,'month':'','year':0}.
/// התנהגות זהה-ביט למקור-ה-JS `hebParts` (חוק-4).
Map<String, Object> hebParts(DateTime? d) {
  if (d == null) {
    return <String, Object>{'day': 0, 'month': '', 'year': 0};
  }
  final int fixed = _gregorianToFixed(d.year, d.month, d.day);
  final List<int> heb = _fixedToHebrew(fixed);
  final int hy = heb[0];
  final int hm = heb[1];
  final int hd = heb[2];
  return <String, Object>{
    'day': hd,
    'month': _hebrewMonthNameEn(hy, hm),
    'year': hy,
  };
}
