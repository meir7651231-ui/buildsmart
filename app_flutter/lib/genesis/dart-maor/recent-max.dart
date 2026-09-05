// ⚛️ אטום-Dart (דרגת-חוזה) · RECENT_MAX — תקרה 6 ("נפתחו לאחרונה")
// מוצא: maor/src/lib/navhist.ts:20 (RECENT_MAX — recentIds עד 6;
//        legacy-main-script.js:344-346,422). חוק-4 — ערך זהה-ביט למקור-ה-JS.
//        המקור: new/atoms/recent-max.mjs — `export const RECENT_MAX = 6;`
// טוהר (חוק-5): המספר הוא פיגמנט-בלבד — לא יודע שהוא "תקרת נפתחו-לאחרונה".
//        החיתוך `slice(0, RECENT_MAX)` (pushRecent) הוא חיווט-הקופסה, לא באטום.
// אפס-import (dart-core בלבד). const int ⇒ מספר-שלם כמו המקור.
//
// הערת-המרה (מקור→Dart): קבוע-מספרי — אין locale/פורמט/getMonth/מודולו/
// truthiness/מוטביליות מעורבים. `const` שומר טוהר-מוחלט.

/// Recency cap of 6 for the "recently opened" list. Value-only atom — verbatim
/// behaviour of the JS source new/atoms/recent-max.mjs (RECENT_MAX = 6).
const int RECENT_MAX = 6;
