// ⚛️ אטום-Dart (דרגת-חוזה) · guardExport — שער יציאת-מידע.
// מוצא: maor/src/lib/exportGate.ts:33-39 · המקור: new/atoms/guard-export.mjs —
//        `export function guardExport(blocked, notify){ if(blocked){ notify?.(); return false; } return true; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: שער לפני כל נתיב יציאת-מידע (הורדה/הדפסה/העתקה). מותר ⇒ true; חסום ⇒
//        מריץ את ההתרעה (אם סופקה) ומחזיר false, כדי שהקורא יעצור בלי להוציא דבר.
// שקעים (חוק-1+חוק-5 — מצב-המודול של המקור הוזרק כפרמטרים):
//   blocked ⇒ bool — האם יציאת-מידע חסומה (במקור משתנה-מודול מ-setExportBlocked).
//   notify  ⇒ (()=>void)? — התרעת-סירוב; נקראת רק בחסימה, פעם אחת. חסרה ⇒ null.
// קלט: שני השקעים. פלט: bool — האם מותר להמשיך.
//
// הערת-המרה (מקור→Dart): ה-JS משתמש ב-`notify?.()` — קורא רק אם notify קיים,
//   לא-קורס על undefined/null. ב-Dart זה `notify?.call()` (טיוטת-המנוע קראה
//   ל-notify() ללא-שמירה ⇒ קריסה על (true, null)). blocked הוא boolean בחוזה,
//   לכן `if (blocked)` מדויק. אין locale/פורמט/getMonth/מודולו/מוטביליות.

/// Export gate: allowed ⇒ true; blocked ⇒ fires [notify] (if given) once and
/// returns false, so the caller stops without exporting anything.
/// Verbatim behaviour of the JS source `guardExport`.
bool guardExport(bool blocked, void Function()? notify) {
  if (blocked) {
    notify?.call();
    return false;
  }
  return true;
}
