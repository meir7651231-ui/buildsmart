// ⚛️ אטום-Dart (דרגת-חוזה) · isDone — האם קמפיין-החייגן הסתיים (תור ריק).
// מוצא: maor/src/lib/dialer.ts:97-105 · המקור: new/atoms/is-done.mjs —
//        `export function isDone(c) { return c.queue.length === 0; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: הקמפיין הסתיים כאשר תור-החיוג (queue) ריק. טהור: לא נוגע ביומן (log)
//        ולא בשום שדה אחר; רק אורך ה-queue קובע.
// שקע (חוק-1): c — אובייקט-קמפיין; ב-Dart ממודל כ-Map עם המפתח 'queue' (List מזהים).
// קלט: השקע c. פלט: bool.
//
// הערת-המרה (מקור→Dart): המנוע (dart-from-maor/is-done.dart.draft) פלט
// `c.queue.length == 0` על `dynamic c` — גישת-שדה שנכשלת על Map (ל-Map אין getter
// בשם queue). התיקון: גישת-מפתח `c['queue']` והמרה ל-List. אין
// locale/פורמט/getMonth/truthiness/מוטביליות מעורבים — רק בדיקת-אורך-אפס.

/// Returns whether the dialer campaign is done — i.e. the call queue is empty.
/// Verbatim behaviour of the JS source `isDone`: only `queue.length === 0` decides.
bool isDone(Map c) {
  return (c['queue'] as List).isEmpty;
}
