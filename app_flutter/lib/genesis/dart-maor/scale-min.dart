// ⚛️ אטום-Dart (דרגת-חוזה) · scaleMin — רצפת-סולם (ערך-קבוע)
// מוצא: maor/src/lib/a11y.ts:13 (SCALE_MIN — גבול-הזום התחתון כמו בלגאסי,
//        script:3193-3194). המקור: new/atoms/scale-min.mjs — `export const SCALE_MIN = 0.8;`
// חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת. חוק-5 — ערך בלבד: המספר לא
//         יודע שהוא "זום-הגופן המזערי"; אכיפת-הגבול (clamp) היא חיווט-הקופסה.
// טוהר: קבוע top-level עצמאי, אפס import (רק dart-core). המקור אינו פונקציה
//       אלא קבוע-מיוצא ⇒ המקבילה הנאמנה ב-Dart היא `const` top-level, לא פונקציה
//       (חוק-4 — המקור קדוש, לא ממציאים עטיפה שלא קיימת ב-JS).
// הערת-המרה: אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים — ליטרל
//            double יחיד. `0.8` ב-JS = `double` ב-Dart (זהה על 0.8 בדיוק-כפול).
//
// קלט: — (קבוע). פלט: מספר (double) = 0.8.

/// The minimum scale floor — verbatim value of the JS source
/// new/atoms/scale-min.mjs (`SCALE_MIN = 0.8`). A pure pigment value (חוק-5):
/// clamping lives in the wiring box, not here.
const double scaleMin = 0.8;
