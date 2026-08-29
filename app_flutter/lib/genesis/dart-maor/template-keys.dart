// ⚛️ אטום-Dart (דרגת-חוזה) · templateKeys — גזירת רשימת-המפתחות מהגדרות-התבניות.
// מוצא: maor/src/lib/templates.ts:54-56 (‏TEMPLATE_KEYS = TEMPLATE_DEFS.map) ·
//        המקור: new/atoms/template-keys.mjs · חוזה: new/atoms/template-keys.contract.md.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: ‏defs.map(d => d.key) — בסדר-ההגדרה, כולל כפילויות (האטום לא שופט).
// שקעים (חוק-1): ‏defs — קבוע-השכן TEMPLATE_DEFS הוזרק כפרמטר; בקופסה מחווטים
//        את template-defs פנימה ומקבלים את הרשימה ההיסטורית.
// קלט:  ‏defs — מערך אובייקטים עם ‏key (‏List של Map). פלט: מערך המפתחות.
//
// הערות-המרה (מקור→Dart):
//  • גישת-שדה ‏d.key של JS ⇒ ‏d['key'] (אובייקט-JS ↔ Map ב-Dart).
//  • ‏Array.map של JS = מערך חדש מיידי ⇒ ‏.map(...).toList() (לא Iterable עצל).
//  • אין locale/תאריך/truthiness/מודולו — מיפוי-שדה טהור בלבד.

/// Derive the template-key list from the template definitions, in
/// definition order (duplicates preserved).
/// Verbatim port of new/atoms/template-keys.mjs (`templateKeys`).
dynamic templateKeys(dynamic defs) {
  return (defs as List).map((d) => d['key']).toList();
}
