// ⚛️ אטום-Dart (דרגת-חוזה) · emptyDiff — האם diff-הענן ריק (אין מה לדחוף).
// מוצא: maor/src/lib/cloud-diff.ts:184-187 · המקור: new/atoms/empty-diff.mjs —
//        `return d.sets.length === 0 && d.deletes.length === 0 && d.meta === null;`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקע (חוק-1): d — אובייקט-ה-diff עם sets (רשימה), deletes (רשימה), meta (null / undefined / ערך).
// קלט: השקע d. פלט: bool — true רק כאשר אין sets, אין deletes, ו-meta הוא null בדיוק.
//
// הערת-המרה (מקור→Dart, DART-PORTING-RULE 2 — null≠undefined):
//   ב-JS `d.meta === null` הוא true אך-ורק כאשר meta הוא null המפורש; `meta: undefined`
//   (וגם מפתח-חסר) מחזירים undefined ⇒ `=== null` הוא false. ל-Dart אין undefined, ולכן
//   המידול הנאמן: "meta הוא null" ⟺ המפתח 'meta' *קיים* וערכו null. מפתח-חסר במפה = ה-undefined
//   של JS ⇒ false. אחרת `d['meta'] == null` היה בולע גם מפתח-חסר (RULE 2) ומזייף true.
//   אין locale/פורמט/getMonth/מיון/מוטביליות מעורבים.

/// Returns whether the cloud diff is empty (nothing to push).
/// Verbatim behaviour of the JS source `emptyDiff`:
/// true only when `sets` is empty, `deletes` is empty, and `meta` is exactly null.
/// JS `meta === null` distinguishes null from undefined — modelled here as the
/// 'meta' key being present with a null value (an absent key mirrors JS undefined).
bool emptyDiff(Map d) {
  final sets = d['sets'] as List;
  final deletes = d['deletes'] as List;
  final metaIsNull = d.containsKey('meta') && d['meta'] == null;
  return sets.isEmpty && deletes.isEmpty && metaIsNull;
}
