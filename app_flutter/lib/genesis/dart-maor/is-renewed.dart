// ⚛️ אטום-Dart (דרגת-חוזה) · isRenewed — האם שיבוץ כבר נרשם לשנה הבאה (יש renewedToId).
// מוצא: maor/src/components/courses/reenroll-lib.ts:52-54 · המקור: new/atoms/is-renewed.mjs —
//        `export function isRenewed(e) { return !!e.renewedToId; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מחזיר true אם לשיבוץ e יש renewedToId truthy (נרשם-מחדש לשנה הבאה).
// שקע (חוק-1): e — מפת-השיבוץ. פלט: bool.
//
// הערת-המרה (מקור→Dart): המקור הוא `!!e.renewedToId` — סמנטיקת-truthiness מלאה של
//   JS, לא `!= null` בלבד. renewedToId חסר/undefined (מפתח נעדר) ⇒ null ⇒ false;
//   מחרוזת-ריקה '' ⇒ false (rule 2 של DART-PORTING-RULES: null≠undefined ⇒ נעדר-מפתח
//   נופל ל-null בדיוק כמו undefined ב-JS). מומש ב-`_truthy` שמחקה `!!` לתחום
//   (null/bool/String/num). אין locale/פורמט/getMonth/מוטביליות.

bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// Returns true when the enrollment `e` has a truthy `renewedToId`
/// (already re-enrolled for next year). Verbatim behaviour of the JS
/// source `isRenewed` (`!!e.renewedToId`).
bool isRenewed(Map<String, dynamic> e) {
  return _truthy(e['renewedToId']);
}
