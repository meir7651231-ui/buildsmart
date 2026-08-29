// ⚛️ אטום-Dart (דרגת-חוזה) · donationYears — שנות-התרומה של תורם/ת, בסדר יורד.
// מוצא: maor/src/lib/annualReport.ts:32-34 (דוח-שנתי-לתורם) · המקור: new/atoms/donation-years.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: קבוצת-השנים (4-ספרות) המופיעות בתאריכי-התרומות, ייחודית וממוינת יורד.
// קלט:  donations — איטרבל של תרומות; כל תרומה מפה עם שדה 'date' (String או חסר).
//        פלט: List<String> ייחודי, ממוין יורד (2026 לפני 2024).
//
// הערות-המרה (מקור→Dart), המקור:
//   [...new Set(donations.map(d => (d.date||'').slice(0,4)).filter(y => /^\d{4}$/.test(y)))].sort().reverse()
//  • גישת-מאפיין `d.date` → גישת-מפתח `d['date']` (Map ב-Dart, כמו donation-split-on).
//  • `(d.date || '')`: המקור מחליף כל ערך-falsy (null/undefined/'') ב-''. בחוזה ה-date
//    הוא String או חסר ⇒ `(v is String ? v : '')` מחקה זאת (חסר⇒null⇒'' · ''⇒'').
//  • `.slice(0,4)`: JS מחזיר את כל המחרוזת כשקצרה מ-4. `substring(0,4)` של Dart זורק
//    על מחרוזת קצרה ⇒ שער-אורך: `s.length <= 4 ? s : s.substring(0,4)` (כלל-substring
//    מ-DART-PORTING-RULES §5). '' → '' · 'שבור' (4 תווים) → 'שבור' (נופל ב-regex).
//  • `/^\d{4}$/.test(y)` → `RegExp(r'^\d{4}$').hasMatch(y)`. '202X'/'שבור'/'' נדחים.
//  • `new Set(...)` → `<String>{}` (LinkedHashSet) — דדופ. סדר-ההכנסה חסר-משמעות
//    כי ה-sort שלאחריו קובע.
//  • `.sort()` (JS ברירת-מחדל = לקסיקוגרפי על מחרוזות) → `..sort()` (compareTo). על
//    מחרוזות-שנה בנות 4-ספרות הסדר הלקסיקוגרפי ≡ המספרי ⇒ פלט זהה. כל השנים ייחודיות
//    ⇒ אין תיקו ⇒ אי-יציבות-המיון (DART-PORTING-RULES §1) לא רלוונטית כאן.
//  • `.reverse()` → `.reversed.toList()` (יורד).
//  • מוטביליות: אין var מוקצה-מחדש; אין locale/פורמט/getMonth/truthiness.

/// Distinct 4-digit years present in a donation list's dates, sorted descending.
/// Verbatim port of new/atoms/donation-years.mjs (`donationYears`).
List<String> donationYears(Iterable<Map<String, dynamic>> donations) {
  final years = <String>{};
  for (final d in donations) {
    final v = d['date'];
    final s = v is String ? v : '';
    final y = s.length <= 4 ? s : s.substring(0, 4);
    if (RegExp(r'^\d{4}$').hasMatch(y)) {
      years.add(y);
    }
  }
  final out = years.toList()..sort();
  return out.reversed.toList();
}
