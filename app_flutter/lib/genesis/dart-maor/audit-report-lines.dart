// ⚛️ אטום-Dart (דרגת-חוזה) · auditReportLines — שורות דוח-תקינות-נתונים לייצוא.
// מוצא: maor/src/lib/audit.ts:222-227 (תורגם TS→JS) · המקור: new/atoms/audit-report-lines.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: בונה רשימת-שורות טקסט — כותרת + שורת-הופק + שורה-ריקה + שורה-פר-ממצא
//        ('[<קטגוריה>] <כותרת>'), בסדר-הקלט.
// קלט:  orgName (מחרוזת/null) · issues (איטרבל של ממצאים, כל אחד cat+title) ·
//        nowLabel (מחרוזת). פלט: List<String>.
//
// הערות-המרה (מקור→Dart) — תיקוני-מנוע:
//  • `orgName || 'מאור החסד'` = falsy-fallback של JS: לא רק null אלא גם מחרוזת-ריקה
//    ('' נופל לברירת-מחדל — דוגמה 2 של החוזה). המנוע ייצר `orgName ?? 'מאור החסד'`
//    (רק-null) — שגוי; תוקן ל-`(orgName == null || orgName.isEmpty)`.
//  • `i.cat`/`i.title` (גישת-שדה ב-JS) → `i['cat']`/`i['title']` על Map (חוק-1: אין
//    מודל-נתונים חיצוני; הממצא = Map<String,String>).
//  • מוטביליות: הרשימה `L` מוטבירת (push/add) ⇒ `final L = <String>[...]` (הפניה final,
//    התוכן משתנה) — תואם `const L = [...]` של JS. הלולאה `final i`.
//  • אין locale/פורמט/getMonth/truthiness-נוסף מעבר לזה שלמעלה.

/// Data-integrity audit report lines for export: title + generated-at + blank +
/// one line per issue ('[cat] title'), in input order.
/// Verbatim port of new/atoms/audit-report-lines.mjs (`auditReportLines`).
/// Empty/null orgName falls back to 'מאור החסד' (JS `||` truthiness).
List<String> auditReportLines(
  String? orgName,
  Iterable<Map<String, String>> issues,
  String nowLabel,
 {required String Function(String) term}) {
  final name = (orgName == null || orgName.isEmpty) ? term('mavr-hchsd') : orgName;
  final L = <String>[term('dvch-tkynvt-ntvnym') + name, term('hvpk') + nowLabel, ''];
  for (final i in issues) {
    L.add('[' + i['cat']! + '] ' + i['title']!);
  }
  return L;
}
