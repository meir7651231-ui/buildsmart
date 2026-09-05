// ⚛️ אטום-Dart (דרגת-חוזה) · defaultFavicon — data-URI קבוע של SVG עיגול-זהב.
// מוצא: maor/src/lib/config.ts:886-887 (זהה ל-index.html) · המקור: new/atoms/default-favicon.mjs
//        (חוק-4 — התנהגות זהה-ביט למקור-ה-JS, לא-משופרת).
// טוהר: קבוע top-level עצמאי, אפס import (רק dart-core).
//
// תפקיד: מחרוזת-ערך בלבד (חוק-5) — data:image/svg+xml של שני עיגולים קונצנטריים
//        (חיצוני זהב %23f3c76b רדיוס 38, פנימי חום %23b45309 רדיוס 20) על
//        viewBox 0 0 100 100. המחרוזת אינה יודעת שהיא "favicon-ברירת-מחדל";
//        השיוך ל-<link rel=icon> הוא חיווט-הקופסה.
// קלט:  — (קבוע). פלט: String — ה-data-URI המלא.
//
// הערת-המרה (מקור→Dart): במקור-ה-JS זהו `export const` של מחרוזת בגרשיים-כפולים
//   המכילה גרשים-בודדים. ב-Dart נבחרה מחרוזת בגרשיים-כפולים (ללא escape לגרש-הבודד),
//   בלי אינטרפולציה ($) — אין תו-$ במטען, ולכן ביט-זהה למקור. אין
//   locale/getMonth/truthiness/תאריך-מגלגל/קידוד מעורבים — מחרוזת-ליטרל בלבד.

/// Default gold-circle SVG favicon as a constant data-URI. Verbatim value of the
/// JS source new/atoms/default-favicon.mjs (bit-identical string literal).
const String defaultFavicon =
    "data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><circle cx='50' cy='50' r='38' fill='%23f3c76b'/><circle cx='50' cy='50' r='20' fill='%23b45309'/></svg>";
