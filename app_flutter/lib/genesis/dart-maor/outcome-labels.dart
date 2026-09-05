// ⚛️ אטום-Dart (דרגת-חוזה) · outcomeLabels — תוויות תוצאת-שיחה בחייגן.
// מוצא: maor/src/lib/dialer.ts:15-24 · המקור: new/atoms/outcome-labels.mjs (OUTCOME_LABELS).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מפה קבועה של 6 מפתחות-תוצאה → תווית עברית, בסדר-המקור בדיוק.
// קלט:  אין. פלט: Map<String,String> באורך 6.
//
// הערות-המרה (מקור→Dart):
//  • `export const OUTCOME_LABELS = {...}` (object-literal) → getter top-level שמחזיר
//    `const {...}` (Map-literal). ה-const מבטיח ערך-קבוע ביט-זהה; getter נותן ממשק-קריאה
//    טהור בלי משתנה-מודול משותף (כמו absence-reason-chips).
//  • המפתחות/הערכים מועתקים כלשונם — אותם 6 זוגות, אותו סדר.
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// The six fixed dialer call-outcome labels, keyed by outcome id, in source order.
/// Verbatim port of new/atoms/outcome-labels.mjs (`OUTCOME_LABELS`).
Map<String, String> get outcomeLabels => const {
      'donated': 'תרם/ה',
      'noanswer': 'לא ענה',
      'refused': 'סירב/ה',
      'callback': 'לחזור',
      'done': 'טופל',
      'skip': 'דילוג',
    };
