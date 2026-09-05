// ⚛️ אטום-Dart (דרגת-חוזה) · tierOrder — סדר-הדרגות הקבוע של תורמים.
// מוצא: maor/src/components/supporters/lib.ts:179-183 (`TIER_ORDER`) · המקור:
//        new/atoms/tier-order.mjs (אטום-קבוע, קודם אוטומטית — צילום-ערך).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של 4 דרגות-התורם, בסדר-המקור בדיוק (מהגבוהה לנמוכה):
//        זהב → כסף → ארד → רדומה.
// קלט:  אין. פלט: List<String> באורך 4 — ['זהב','כסף','ארד','רדומה'].
//
// הערות-המרה (מקור→Dart):
//  • `export const TIER_ORDER = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור.
//  • התוכן מועתק כלשונו — אותן 4 מחרוזות-עברית, אותו סדר
//    (index 0='זהב' · 1='כסף' · 2='ארד' · 3='רדומה').
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// Supporter tier order, highest first, in source order.
/// Verbatim port of new/atoms/tier-order.mjs (`TIER_ORDER`).
List<String> get tierOrder => const [
      'זהב',
      'כסף',
      'ארד',
      'רדומה',
    ];
