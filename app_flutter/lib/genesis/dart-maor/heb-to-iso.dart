// ⚛️ אטום-Dart (דרגת-חוזה) · hebToIso — עברי→לועזי: יום+חודש-עברי+שנה ⇒ ISO.
// מוצא: maor/src/lib/hebdate.ts:100-104 · המקור: new/atoms/heb-to-iso.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכנים monthEnOf/hebToIsoEn
//        (פרטיים באותו קובץ-מקור) הוזרקו כשקעים (חוק-1/חוק-3 — אפס import פנימי).
//
// תפקיד: monthEnOf(monthHe) ⇒ שם-חודש-Intl אנגלי או null; תווית לא-מוכרת ⇒ null
//        (נעצר לפני השקע); אחרת hebToIsoEn(day, en, hebYear) ⇒ ISO או null.
// קלט:  day (int) · monthHe (String) · hebYear (int) + 2 השקעים.
// פלט:  String? — 'YYYY-MM-DD' או null.
//
// הערות-המרה (מקור→Dart) — הכללים ב-machtzev/emit/DART-PORTING-RULES.md:
//  • (§7 truthiness) `if (!en)` של JS ⇒ `_falsy(en)`: null או '' ⇒ אמת (המנוע פלט
//    `_falsy(en)` — נשמר; en הוא String? מן השקע). אחרי המגן — `en!` (לא-null).
//  • השכנים monthEnOf/hebToIsoEn — פרמטרי-פונקציה מוקלדים, לא import (חוק-3).

/// Hebrew date (day + Hebrew month label + Hebrew year) → ISO date, or null.
/// Verbatim port of new/atoms/heb-to-iso.mjs (`hebToIso`). `monthEnOf` and
/// `hebToIsoEn` are injected sockets (Law 1/3).
String? hebToIso(
  int day,
  String monthHe,
  int hebYear,
  String? Function(String monthHe) monthEnOf,
  String? Function(int day, String monthEn, int hebYear) hebToIsoEn,
) {
  final en = monthEnOf(monthHe);
  if (_falsy(en)) return null;
  return hebToIsoEn(day, en!, hebYear);
}

// §7 — `!en` של JS: null או מחרוזת-ריקה נחשבים falsy.
bool _falsy(String? s) => s == null || s.isEmpty;
