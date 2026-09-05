// ⚛️ אטום-Dart (דרגת-צילום-ערך) · GRADE_ORDER — סולם הכיתות (גן ואז א׳–י"ב).
// מוצא: maor/src/components/courses/lib.ts:453 · המקור: new/atoms/grade-order.mjs
//        (`export const GRADE_ORDER = [...]`) · חוזה: new/atoms/grade-order.contract.md.
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — ערך
//        זהה-ביט למקור-ה-JS (המקור קדוש). זהו אטום-קבוע (צילום-ערך), לא פונקציה.
//
// תפקיד: 13 דרגות-הכיתה בסדר-המקור: 'גן' ואז א׳–י"ב בצורה הנקייה (בלי גרשיים).
//        האינדקס במערך = הסדר; ניקוי-קלט/טווחי-חוג הם חיווט-קופסה, לא האטום (חוק-5).
//        פלט: List<String> קפוא באורך 13.
//
// הערות-המרה (מקור→Dart):
//  • `export const GRADE_ORDER = [...]` → `const List<String> gradeOrder = [...]`.
//    שלוש-עשרה מחרוזות עברית, בסדר-המקור בדיוק, אותם תווים.
//  • מוטביליות: `const` (בלתי-משתנה מוחלט) — שקול ל-frozen-by-convention של המקור.
//    אין locale/פורמט/getMonth/truthiness/substring/מודולו מעורבים — קבוע טהור, ללא שקעים.

/// The 13 grade rungs, in source order: `'גן'` then א׳–י"ב in the clean form
/// (no gershayim). The array index is the ordering. Value-snapshot port of
/// new/atoms/grade-order.mjs (`GRADE_ORDER`).
const List<String> gradeOrder = [
  'גן',
  'א',
  'ב',
  'ג',
  'ד',
  'ה',
  'ו',
  'ז',
  'ח',
  'ט',
  'י',
  'יא',
  'יב',
];
