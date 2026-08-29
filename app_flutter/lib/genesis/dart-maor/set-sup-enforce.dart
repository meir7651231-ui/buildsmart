// ⚛️ אטום-Dart (דרגת-חוזה) · setSupEnforce — חישוב ערך מצב אכיפת-התומכים החדש (פאזה-2, dormant).
// מוצא: maor/src/lib/cloud.ts:122-125 · המקור: new/atoms/set-sup-enforce.mjs —
//        `export function setSupEnforce(on) { return on; }`
// חוזה: new/atoms/set-sup-enforce.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: הדגל הנכנס עובר כמות-שהוא — הערך שהצד-הדוחף/המושך ישאל דרך supEnforceActive.
//        במקור הערך הושם למשתנה-המודול supEnforceOn; ההשמה (וברירת-המחדל הדורמנטית
//        false) הן חיווט-קופסה (חוק-1/חוק-5) — האטום רק מחשב (מעביר) את הערך החדש.
// קלט: on — boolean. פלט: אותו boolean בדיוק, בלי כפייה.
//
// הערת-המרה (מקור→Dart): ה-JS מעביר את הערך verbatim לכל טיפוס (טיפוס-boolean מובטח
// ב-TS אצל הקורא, לא באטום). כדי לשמר זהות-ערך מלאה החתימה `Object? → Object?`;
// זהות נבדקת ב-identical (מקביל ל-=== של JS). אין locale/תאריך/truthiness/מוטציה.

/// Computes the new supporters-enforcement state value (phase-2, dormant).
/// The incoming flag is passed through as-is — verbatim behaviour of the JS
/// source `setSupEnforce` (identity function; the module-variable assignment
/// and the dormant-false default belong to the wiring box, not to this atom).
Object? setSupEnforce(Object? on) {
  return on;
}
