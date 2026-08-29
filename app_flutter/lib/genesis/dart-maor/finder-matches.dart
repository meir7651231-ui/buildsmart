// ⚛️ אטום-Dart (דרגת-חוזה) · finderMatches — סינון-משפחות לפי נעילות-הגלגל (AND).
// מוצא: maor/src/components/families/lib.ts:119-128 · המקור: new/atoms/finder-matches.mjs —
//   `db.families.filter((f) => Object.entries(locks).every(([k,v]) => finderAxisValue(db,f,k)===v))`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: המשפחות העוברות את כל נעילות-הגלגל — לכל זוג [ציר, ערך] ב-locks, ערך-הציר
//        של המשפחה (דרך השקע) חייב להיות שווה-בדיוק. locks ריק ⇒ כולן עוברות
//        (every על ריק = true). סדר-המקור נשמר; מוחזרים אותם אובייקטים (לא עותקים).
// שקע (חוק-1): finderAxisValue(db, f, axis) ⇒ String — ערך-המשפחה בציר (במקור: שכן
//        באותו קובץ, הוזרק כפרמטר).
// קלט: db (עם families: List) · locks (Map ציר⇒ערך) · השקע. פלט: תת-List של db.families.
//
// הערת-המרה (מקור→Dart, מול הטיוטה שהמנוע פספס):
//   • `Object.entries(locks).every(...)` ⇒ `locks.entries.every((e) => ... e.key/e.value)`
//     (המנוע השאיר `Object.entries` + `k`/`v` לא-מוגדרים — שבור-תחביר).
//   • `filter` ⇒ `where(...).toList()`; where שומר סדר-מקור ומחזיר אותן רפרנסות (=== ⇒ identical).
//   • `===` על מחרוזות (השקע מחזיר String, v מחרוזת) ⇒ `==` ב-Dart (זהה-ערך; טיפוס-שונה ⇒ false, בלי זריקה).
//   אין locale/פורמט/getMonth/מיון/substring/truthiness/מוטביליות — לא רלוונטיים לחוט זה.

/// The families passing every wheel-lock (AND). Empty locks ⇒ all families
/// (every-on-empty = true). Source order preserved; same object references
/// returned (no copies). Verbatim behaviour of the JS source `finderMatches`.
List<dynamic> finderMatches(
  Map<dynamic, dynamic> db,
  Map<dynamic, dynamic> locks,
  dynamic Function(Map<dynamic, dynamic> db, dynamic f, dynamic axis) finderAxisValue,
) {
  final families = db['families'] as List<dynamic>;
  return families
      .where((f) => locks.entries.every((e) => finderAxisValue(db, f, e.key) == e.value))
      .toList();
}
