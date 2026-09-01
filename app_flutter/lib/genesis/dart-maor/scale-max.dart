// ⚛️ אטום-Dart (דרגת-חוזה) · scaleMax — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/lib/a11y.ts · המקור: new/atoms/scale-max.mjs —
//        `export const SCALE_MAX = 1.6;`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: תקרת-סולם-הזום (SCALE_MAX). קלט: אין. פלט: מספר (1.6).
//
// הערת-המרה (מקור→Dart): האטום המיוצא-והנבדק הוא קבוע-מספר בלבד. אין
// locale/פורמט/getMonth 0↔1/truthiness/מוטביליות מעורבים — קבוע טהור, ללא שקעים.
// המנוע-האוטומטי הפיק `var SCALE_MAX = 1.6;` — טיוטה שגויה בטוהר (var=מוטבילי,
// שם-JS). תוקן ל-`const double` top-level בשם camelCase כמוסכמת-Dart, ערך זהה-ביט.

/// Zoom-scale ceiling constant. Verbatim value of the JS source
/// new/atoms/scale-max.mjs (`SCALE_MAX`) — the double `1.6`.
const double scaleMax = 1.6;
