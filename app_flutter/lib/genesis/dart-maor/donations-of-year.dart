// ⚛️ אטום-Dart (דרגת-חוזה) · donationsOfYear — תרומות שנה אחת, ממוינות עולה.
// מוצא: maor/src/lib/annualReport.ts:37-39 (דוח-שנתי-לתורם) · המקור: new/atoms/donations-of-year.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מסננת תרומות שהתאריך שלהן פותח ב-`year-` וממיינת אותן בסדר-עולה לפי התאריך.
//        הרשומות עצמן עוברות כמו-שהן (שדות נשמרים — amount וכו').
// קלט:  donations (List של Map — כל תרומה עם 'date' אופציונלי + שדות נוספים) · year (String).
//        פלט: List<Map> חדש, מסונן וממוין; אותן רשומות (identity) של הקלט.
//
// הערות-המרה (מקור→Dart · המנוע פספס את הזנב):
//  • `(d.date || '')` → `((d['date'] ?? '') as String)`. במקור זו בדיקת-falsy; עבור חוזה-הדאטה
//    ('date' = String או חסר/null בלבד) `?? ''` ⇒ תוצאה זהה: מפתח-חסר/null ⇒ '' (אין
//    startsWith), מחרוזת-ריקה '' נשארת '' (גם היא נכשלת ב-startsWith). אין 0/false בשדה-תאריך.
//  • `.filter(...).sort(...)` של המנוע הפך ל-`.where(...)..sort(...)` — **שגוי**: `where`
//    מחזיר Iterable חסר-`sort`, וה-cascade היה מפעיל sort על ה-Iterable. תוקן: מממשים
//    לרשימה (`toList`) ואז ממיינים רשימה חדשה (המקור מחזיר מערך-חדש, אינו משנה קלט).
//  • **מיון-יציב** (DART-PORTING-RULES §1): `List.sort` של Dart אינו יציב ל-≥32; JS יציב.
//    לכן decorate-sort עם אינדקס-מקורי כשובר-שוויון — תאריכים-שווים שומרים סדר-הקלט כמו ב-JS.
//  • `a.date.localeCompare(b.date)` → `compareTo`. אחרי הסינון כל רשומה נושאת 'date' שהוא
//    מחרוזת שפותחת ב-`year-` ⇒ בטוח ל-cast. עבור מחרוזות-ISO (ספרות + '-') סדר ה-code-unit
//    זהה ל-collation ⇒ פלט זהה-ביט לחמש דוגמאות-החוזה (dart:core בלי Intl — חוק-1).
//  • מוטביליות: הקלט אינו משתנה; נבנית רשימה חדשה. אין locale/פורמט/getMonth.

/// Donations of a single year, sorted ascending by date.
/// Verbatim port of new/atoms/donations-of-year.mjs (`donationsOfYear`).
/// Keeps only records whose 'date' starts with `year-`, sorted by date
/// (localeCompare in the JS source → compareTo here); records pass through
/// unchanged and the input list is not mutated. Sort is made stable via an
/// original-index tiebreaker (Dart's List.sort is not stable for >=32).
List<Map<String, dynamic>> donationsOfYear(
  List<Map<String, dynamic>> donations,
  String year,
) {
  final filtered = <Map<String, dynamic>>[];
  for (final d in donations) {
    final date = (d['date'] ?? '') as String;
    if (date.startsWith(year + '-')) filtered.add(d);
  }
  final idx = <int>[for (var i = 0; i < filtered.length; i++) i];
  idx.sort((a, b) {
    final c = (filtered[a]['date'] as String)
        .compareTo(filtered[b]['date'] as String);
    return c != 0 ? c : a.compareTo(b);
  });
  return [for (final i in idx) filtered[i]];
}
