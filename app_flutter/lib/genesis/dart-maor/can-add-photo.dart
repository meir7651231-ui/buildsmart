// ⚛️ אטום-Dart (דרגת-חוזה) · canAddPhoto — האם יש מקום לעוד תמונה בגלריה.
// מוצא: maor/src/lib/photoGallery.ts:15-17 · המקור: new/atoms/can-add-photo.mjs —
//        `export function canAddPhoto(current, photoMax = 5) {
//             return (current?.length ?? 0) < photoMax; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מחזיר true כל עוד מספר-התמונות הקיים קטן מהתקרה. השכן PHOTO_MAX הוזרק
//        כשקע photoMax (חוק-1), ברירת-מחדל 5 = ערך-המוצא.
// שקע (חוק-1): photoMax — התקרה (במקור קבוע-שכן שהוזרק כפרמטר; ברירת-מחדל 5).
// קלט: current — הרשימה-הקיימת או null/undefined ; photoMax — התקרה.
// פלט: bool. אורך-הרשימה (0 אם null) < photoMax.
//
// הערת-המרה (מקור→Dart): ה-JS משתמש ב-`current?.length ?? 0` — null/undefined ⇒ 0.
// ב-Dart החתימה `List<Object?>? current` ; `current?.length ?? 0` שקול-ביט. אין
// locale/פורמט/getMonth/truthiness/מוטביליות שהמנוע צריך לתקן — פרט לכך שהטיוטה
// כתבה `current.length` (מתרסק על null) במקום `current?.length` (בטוח-null כמקור).

/// Returns whether another photo fits: the current count (0 when the list is
/// null) is below [photoMax]. Verbatim behaviour of the JS source `canAddPhoto`.
bool canAddPhoto(List<Object?>? current, [int photoMax = 5]) {
  return (current?.length ?? 0) < photoMax;
}
