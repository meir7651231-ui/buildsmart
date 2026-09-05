// ⚛️ אטום-Dart (דרגת-חוזה) · renewTargets — מי מיועד לרישום-המוני לשנה הבאה:
//    "ממשיך" (decision==='yes') שעדיין לא נרשם (!renewed).
// מוצא: maor · new/atoms/renew-targets.mjs (חולץ מ-maor/src/components/courses/reenroll-lib.ts:198-206).
//        חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS (המקור קדוש, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//
// תיקוני-פורט מול טיוטת-המנוע (dart-from-maor/renew-targets.dart.draft):
//   • גישת-שדות — המנוע פלט `r.decision`/`r.renewed` על `dynamic`; ב-Dart על אובייקט-JS
//                 (Map) זו גישת-מפתח ⇒ `r['decision']`/`r['renewed']`. הטיפוסים הופכים מפורשים.
//   • materialize — המנוע פלט `.where(...)` בלבד; ב-Dart זה Iterable עצל, לא List. JS `filter`
//                 מחזיר **מערך חדש** ⇒ `.toList()` (חוזה: out!==rows, אך שורות = אותן הפניות —
//                 Map הוא טיפוס-הפניה, ו-.toList() שומר את ההפניות המקוריות. immutability נשמרת).
//   • truthiness — המנוע פלט `_falsy(...)` (לא-מוגדר). JS `!r.renewed`: renewed falsy =
//                 false/null/חסר/0/'' ⇒ נכלל; renewed truthy (true) ⇒ בחוץ. כלל-פורט 7 ⇒
//                 שקע-מפורש `_falsy` (היפוך ה-`_truthy` הקנוני של המחסן).
//   • decision === 'yes' — `r['decision'] == 'yes'`; מפתח-חסר ⇒ null == 'yes' ⇒ false
//                 (כמו JS undefined === 'yes' ⇒ false). '', 'no', 'hold' ⇒ בחוץ.
//
// קלט:  rows — List<Map> ({decision: 'yes'|'no'|'hold'|'', renewed: bool, ...}).
// פלט:  List<Map> — תת-מערך של אותן שורות (אותן הפניות), בסדר-המקור.

bool _falsy(dynamic v) => v == null || v == false || v == '' || v == 0;

/// מועמדי הרישום-מחדש: 'yes' שטרם-נרשם. מערך חדש, אותן הפניות-שורה, סדר-מקור.
/// Verbatim port of new/atoms/renew-targets.mjs (`renewTargets`).
List<Map> renewTargets(List<Map> rows) {
  return rows
      .where((r) => r['decision'] == 'yes' && _falsy(r['renewed']))
      .toList();
}
