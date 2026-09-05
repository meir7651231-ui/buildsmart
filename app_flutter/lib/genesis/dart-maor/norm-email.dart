// ⚛️ אטום-Dart (דרגת-חוזה) · normEmail — נרמול-מייל
// מוצא: maor/src/components/platform/lib.ts:77-82 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/norm-email.mjs —
//        `export function normEmail(email) { return email.trim().toLowerCase(); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: נרמול מחרוזת-מייל לצורה קנונית להשוואה — קיצוץ רווחים מקצה-לקצה + אותיות-קטנות.
// קלט:  email — מחרוזת, String.
// פלט:  המחרוזת מקוצצת-ומוקטנת, String.
//
// הערת-המרה (מקור→Dart): ה-JS מיישם `String.prototype.trim()` +
// `String.prototype.toLowerCase()`. שני אלה תואמים ל-Dart `String.trim()` +
// `String.toLowerCase()`: שניהם מקצצים רווחים לפי Unicode White_Space, ושניהם
// ממירים לאותיות-קטנות בצורה עצמאית-locale (ברירת-Unicode default, לא toLocaleLowerCase).
// אין getMonth/פורמט-locale/truthiness/מוטביליות מעורבים — אטום טהור בן שורה אחת, ללא שקעים.

/// Normalise an email string to a canonical comparison form: trim surrounding
/// whitespace and lower-case. Verbatim behaviour of the JS source
/// new/atoms/norm-email.mjs.
String normEmail(String email) => email.trim().toLowerCase();
