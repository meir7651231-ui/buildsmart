// ⚛️ אטום-Dart (דרגת-חוזה) · renewOf — החלטת-החידוש הנוכחית של שיבוץ (חסר = טרם הוחלט).
// מוצא: maor/src/components/courses/reenroll-lib.ts:47-51 (אפס שכנים) · המקור: new/atoms/renew-of.mjs —
//        `export function renewOf(e) { return e.renew ?? ''; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// הערת-המרה (מקור→Dart, לפי DART-PORTING-RULES כלל 2 · null≠undefined):
//   JS `??` נופל לברירת-מחדל על null **וגם** על undefined (שדה חסר). ב-Dart
//   `e['renew']` על Map מחזיר null גם לשדה-חסר וגם ל-null-מפורש — לכן
//   `e['renew'] ?? ''` מכסה את שני המקרים בדיוק כמו ה-JS. ריק-מפורש '' אינו
//   null ⇒ נשאר '' (אפס-נפילה). אין locale/פורמט/getMonth/truthiness/מוטביליות.
// קלט: e — אובייקט-השיבוץ (Map). פלט: ערך-שדה renew כמו-שהוא, או '' אם null/חסר.

/// Returns the assignment's current renewal decision, or '' when undecided
/// (field null or absent). Verbatim behaviour of the JS source `renewOf`.
Object renewOf(Map<String, dynamic> e) {
  return (e['renew'] ?? '') as Object;
}
