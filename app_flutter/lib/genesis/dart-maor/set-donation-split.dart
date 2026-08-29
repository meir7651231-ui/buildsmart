// ⚛️ אטום-Dart (דרגת-חוזה) · setDonationSplit — חישוב ערך מצב-פיצול-התרומות החדש (מסלול-B).
// מוצא: maor/src/lib/cloud.ts:100-103 · המקור: new/atoms/set-donation-split.mjs —
//        `export function setDonationSplit(on) { return on; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: הדגל הנכנס עובר כמות-שהוא — הוא הערך שהצד-הדוחף ישאל דרך donationSplitActive
//        לפני push. במקור הערך הושם למשתנה-המודול splitOn; ההשמה (וברירת-המחדל
//        הבטוחה false) הן חיווט-קופסה (חוק-1/חוק-5) — האטום רק מחשב (מעביר) את הערך.
// קלט: on — boolean (מובטח ב-TS אצל הקורא). פלט: אותו ערך בדיוק, בלי כפייה.
//
// הערת-המרה (מקור→Dart): ה-JS מחזיר את הקלט verbatim לכל טיפוס (זהות-רפרנס, ===).
// כדי לשמר זאת החתימה `Object? → Object?` והזהות נבדקת ב-identical (מקביל ל-===).
// אין locale/תאריך/truthiness/מוטציה — אין צורך באף שקע מחוקי-ההמרה.

/// Returns the new donation-split state value: the incoming flag, as-is,
/// no coercion, exact same reference. Verbatim behaviour of the JS source
/// `setDonationSplit` (identity function; the module-variable assignment
/// and the safe default `false` belong to the wiring box, not this atom).
Object? setDonationSplit(Object? on) {
  return on;
}
