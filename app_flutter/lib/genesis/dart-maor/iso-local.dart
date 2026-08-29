// ⚛️ אטום-Dart (דרגת-חוזה) · isoLocal
// מוצא: maor · new/atoms/iso-local.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). אפס שקעים (טהור-מלידה).
//
// תיקוני-פורט מול מקור-ה-JS (התנהגות משומרת ביט-אחר-ביט):
//   • getMonth 0↔1 — ה-JS כותב `d.getMonth() + 1` כי `Date.getMonth()` הוא 0-מבוסס
//                    (0=ינואר). ב-Dart `DateTime.month` כבר 1-מבוסס ⇒ **בלי `+1`**.
//                    הפלט זהה. הזחת-האינדקס חיה בהמרת-הקלט (ראה רתמת-הזהב).
//   • pad2         — JS `String(n).padStart(2,'0')` ⇒ Dart `n.toString().padLeft(2,'0')`.
//                    שניהם מרפדים לשתי-ספרות; לחודש/יום (1..31) התוצאה זהה.
//   • שדות מקומיים  — `getFullYear/getMonth/getDate` (מקומי, לא-UTC) ⇒ `.year/.month/.day`
//                    של DateTime מקומי. אין הזחת-אזור-זמן (חוזה: לא toISOString/toUtc).
//   • השעה נבלעת    — נגזרים רק year/month/day; שדות שעה/דקה של הקלט לא נכנסים לפלט.
//
// קלט:  d — DateTime (מקומי). פלט:  מחרוזת "YYYY-MM-DD".

/// Date ⇒ "YYYY-MM-DD" מקומי (בלי הזחת-UTC). חודש/יום מרופדים לשתי ספרות.
String isoLocal(DateTime d) {
  String p2(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${p2(d.month)}-${p2(d.day)}';
}
