// ⚛️ אטום-Dart (דרגת-חוזה) · demoAnchor — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/lib/demoFresh.ts:14-31 · המקור: new/atoms/demo-anchor.mjs —
//        `export const DEMO_ANCHOR = '2026-08-02';`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: תאריך-עוגן קבוע לרעננות-הדמו. קלט: אין. פלט: מחרוזת ISO (YYYY-MM-DD).
//
// הערת-המרה (מקור→Dart): האטום המיוצא-והנבדק הוא קבוע-מחרוזת בלבד. הפונקציות
// daysBetween/isoLocal/shift שבזנב-המקור אינן מיוצאות ואינן בחוזה/בדיקה (קוד-מת בזנב) ⇒
// לפי חוק-2 ממירים אך ורק את הקבוע שהחוזה מחייב — לא מוסיפים התנהגות שאין ברתמת-הזהב.
// אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים בקבוע עצמו — מחרוזת טהורה, ללא שקעים.
// המנוע-האוטומטי (dart-from-maor) לא הפיק טיוטה לאטום זה ⇒ נכתב ידנית לפי המקור.

/// Demo-freshness anchor date constant. Verbatim value of the JS source
/// new/atoms/demo-anchor.mjs (`DEMO_ANCHOR`) — the ISO date string '2026-08-02'.
const String demoAnchor = '2026-08-02';
