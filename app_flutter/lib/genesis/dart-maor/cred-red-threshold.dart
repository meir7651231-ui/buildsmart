// ⚛️ אטום-Dart (דרגת-חוזה) · CRED_RED_THRESHOLD — ערך-סף 500
// מוצא: maor/src/components/families/lib.ts:52 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/cred-red-threshold.mjs — `export const CRED_RED_THRESHOLD = 500;`
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט). ערך בלבד (חוק-5): המספר
//        לא יודע שהוא "סף סיכון-נטישה" — ההשוואה `score < 500` היא חיווט-הקופסה (tierOf).
//
// תפקיד: קבוע מספרי — ערך-סף 500. יושר ללגאסי: legacy tier red ‎<500 (מול 300 שהיה ב-React).
// קלט:  — (קבוע). פלט: מספר שלם 500.
//
// הערת-המרה (מקור→Dart): מספר-שלם ליטרלי; ב-JS `500` הוא Number, כאן `int` — הערך
// זהה. אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים — אטום טהור, ללא שקעים.

/// Credibility "red" (attrition-risk) threshold value. Verbatim behaviour of the JS
/// source new/atoms/cred-red-threshold.mjs (`CRED_RED_THRESHOLD = 500`).
const int CRED_RED_THRESHOLD = 500;
