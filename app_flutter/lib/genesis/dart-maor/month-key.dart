// ⚛️ אטום-Dart (דרגת-חוזה) · monthKey — מפתח-חודש מ-ISO
// מוצא: maor/src/components/reports/lib.ts:59-63 (monthKey; חוק-4 — התנהגות זהה
//        למקור-ה-JS, לא-משופרת). המקור: new/atoms/month-key.mjs —
//        `export function monthKey(iso) { return iso.slice(0, 7); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: חיתוך 7 התווים הראשונים של תאריך-ISO ⇒ מפתח-חודש "YYYY-MM"
//        (לקיבוץ-דוחות פר-חודש). על כל מחרוזת אחרת — פשוט 7 התווים הראשונים.
// קלט:  iso — String (בכל דוגמאות-ה-Golden הקלט מחרוזת).
// פלט:  String — עד 7 תווי-UTF-16 ראשונים.
//
// הערות-המרה (מקור→Dart):
// • כלל-5 (substring שלילי/גולש): JS `slice(0,7)` **קוצץ-בחסד** — מחרוזת קצרה מ-7
//   חוזרת שלמה ("" ⇒ "", "12" ⇒ "12"); Dart `substring(0,7)` היה זורק RangeError.
//   ⇒ קיצוץ-end מפורש ל-min(7, length).
// • יחידות-תווים: גם JS slice וגם Dart substring פועלים על יחידות-קוד UTF-16 —
//   "שלום עולם" (9 יחידות) ⇒ "שלום עו" בשתי השפות, זהה-ביט.
// • אין locale/לוח-עברי/truthiness/מערכים — אין צורך בשקעים (חוק-11 לא רלוונטי).

/// Month key from an ISO date string: the first 7 UTF-16 code units
/// (clamped — a shorter string is returned whole), verbatim behaviour of
/// JS `iso.slice(0, 7)` in new/atoms/month-key.mjs.
String monthKey(String iso) {
  final end = iso.length < 7 ? iso.length : 7;
  return iso.substring(0, end);
}
