// ⚛️ אטום-Dart (דרגת-חוזה) · otherLabel — נוסח-התווית לבחירת "אחר" (הקלדה חופשית).
// מוצא: maor/src/components/courses/lib.ts:402 (נוסח זהה ב-families/lib.ts:202) ·
//        המקור: new/atoms/other-label.mjs (export const OTHER_LABEL).
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — ערך
//        זהה-ביט למקור-ה-JS (המקור קדוש). חוק-5 — המחרוזת לא יודעת באיזה טופס תוצג;
//        השיוך לערך-הזקיף '__other' הוא חיווט-הקופסה, לא חלק מהאטום.
//
// הערות-המרה (מקור→Dart):
//  • `export const OTHER_LABEL = '…'` → `const otherLabel = '…'` — הטיוטה פלטה `var`
//    (מוקצה-מחדש); קבוע-קומפילציה נאמן יותר למקור ה-const. הזהות שונתה מ-SCREAMING_CASE
//    ל-lowerCamelCase כמוסכמת-Dart (מוסכמת-שמות בלבד; הערך זהה).
//  • המחרוזת verbatim כולל הקו-המפריד '—' (U+2014) ושלוש-הנקודות '…' (U+2026).
//  • אין locale/פורמט/getMonth/truthiness/מוטביליות — אטום-ערך טהור.
const String otherLabel = 'אחר — הקלדה חופשית…';
