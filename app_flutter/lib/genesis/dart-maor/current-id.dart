// ⚛️ אטום-Dart (דרגת-חוזה) · currentId — חזית תור-הקמפיין או null.
// מוצא: maor/src/lib/dialer.ts:37-39 · המקור: new/atoms/current-id.mjs —
//        `export function currentId(c) { return c.queue.length ? c.queue[0] : null; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מחזיר את הפריט-הראשון בתור (`queue[0]`) אם התור לא-ריק, אחרת null.
//        אינו נוגע בתור (חסר-מוטביליות — קריאה בלבד).
// שקע (חוק-1): c — אובייקט-הקמפיין הנושא `queue` (רשימה). ‏Map ב-Dart.
// קלט: c['queue'] (רשימה). פלט: c['queue'][0] אם לא-ריקה, אחרת null.
//
// הערת-המרה (מקור→Dart · כלל-7 truthiness): ה-JS `c.queue.length ? …`
// מסתמך על truthiness של המספר (0 ⇒ falsy). ‏Dart אוסר int-כ-bool ⇒
// `isNotEmpty` מחקה בדיוק את "אורך אפס ⇒ null, אחרת החזית". אין locale/פורמט/getMonth.

/// Returns the head of the campaign queue (`queue[0]`) when non-empty, else null.
/// The queue is read only — never mutated. Verbatim behaviour of the JS source
/// `currentId` (`c.queue.length ? c.queue[0] : null`).
Object? currentId(Map c) {
  final queue = c['queue'] as List;
  return queue.isNotEmpty ? queue[0] : null;
}
