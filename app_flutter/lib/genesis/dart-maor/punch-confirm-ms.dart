// ⚛️ אטום-Dart (דרגת-חוזה) · PUNCH_CONFIRM_MS — ערך-מערכת קבוע 3000 (מ"ש חלון-אישור-כפול).
// מוצא: maor/src/components/courses/lib.ts:560-571 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/punch-confirm-ms.mjs — `export const PUNCH_CONFIRM_MS = 3000;`
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט). ערך בלבד (חוק-5): המספר לא
//        יודע שהוא "חלון-אישור-הניקוב" — סמנטיקת מכונת-המצבים היא חיווט-הקופסה.
//
// הערת-המרה (מקור→Dart): המנוע פלט `var PUNCH_CONFIRM_MS = 3000;` — mutable ולא-מוטבע.
//        תוקן ל-`const int` (מוטביליות: המקור `export const` = immutable; טיפוס: JS Number
//        שלם ⇒ int). אין locale/פורמט/getMonth/truthiness מעורבים — אטום טהור, ללא שקעים.

/// Double-confirm window value in milliseconds. Verbatim behaviour of the JS source
/// new/atoms/punch-confirm-ms.mjs (`PUNCH_CONFIRM_MS = 3000`).
const int PUNCH_CONFIRM_MS = 3000;
