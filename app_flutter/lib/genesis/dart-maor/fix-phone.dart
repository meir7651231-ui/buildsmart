// ⚛️ אטום-Dart (דרגת-חוזה) · fixPhone — עיצוב-טלפון בטפסי-התומכים (האצלה לשקע הקנוני).
// מוצא: maor/src/components/supporters/lib.ts:230-234 · המקור: new/atoms/fix-phone.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן formatIsraeliPhone (lib/validate) הוזרק
//        כשקע (חוק-1/חוק-3 — אפס import פנימי).
//
// תפקיד: מאציל כלשונו לשקע — `return formatIsraeliPhone(p)`. אין לוגיקה משלו.
// קלט:  p (הטלפון הגולמי) · השקע formatIsraeliPhone(raw) ⇒ String. פלט: String.
//
// הערת-המרה: המקור הוא one-liner-מאציל; המנוע (dart-from-maor/fix-phone.dart.draft) חצב
//   `dynamic fixPhone(dynamic p, dynamic formatIsraeliPhone)` — הודקה החתימה לשקע-פונקציה
//   מפורש (`String Function(dynamic)`) כדי לשקף שהשקע נקרא כפונקציה. אין locale/getMonth/
//   מוטביליות/truthiness לתקן — כל אלו חיים בשקע המוזרק, לא באטום-המאציל.
String fixPhone(dynamic p, String Function(dynamic) formatIsraeliPhone) {
  return formatIsraeliPhone(p);
}
