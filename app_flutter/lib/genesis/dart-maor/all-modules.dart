// ⚛️ אטום-Dart (דרגת-חוזה) · allModules — כל מפתחות-המודולים של המערכת.
// מוצא: maor/src/components/platform/lib.ts:39 (`ALL_MODULES` — "מקור אחד לפאנל
//        ולקונפיג-הלידה") · המקור: new/atoms/all-modules.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של 9 מפתחות-המודולים, בסדר-המקור בדיוק. חוק-5 — הרשימה
//        לא יודעת מי דלוק/כבוי; הדלקה/כיבוי = חיווט-הקופסה. בית והגדרות אינם ברשימה.
// קלט:  אין. פלט: List<String> באורך 9 —
//        ['families','courses','calendar','diary','supporters','reports','tzedaka','shop','shop7'].
//
// הערות-המרה (מקור→Dart):
//  • `export const ALL_MODULES = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור.
//  • התוכן מועתק כלשונו — אותם 9 slug-ים באנגלית-קטנה, אותו סדר (index 0='families' … 8='shop7').
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// All system module keys, in source order.
/// Verbatim port of new/atoms/all-modules.mjs (`ALL_MODULES`).
List<String> get allModules => const [
      'families',
      'courses',
      'calendar',
      'diary',
      'supporters',
      'reports',
      'tzedaka',
      'shop',
      'shop7',
    ];
