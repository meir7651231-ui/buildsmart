// ⚛️ אטום-Dart (דרגת-חוזה) · addTeacher — ערך-זקיף קבוע (צילום-ערך).
// מוצא: maor/src/components/courses/lib.ts (ADR ADD_TEACHER, "ערכי הבחירה בטופס — verbatim מהמקור").
//        המקור: new/atoms/add-teacher.mjs — `export const ADD_TEACHER = '__add';`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: ערך-הזקיף (sentinel) של בורר-המורה בטופס-חוג — הבחירה "הוספת מורה חדש/ה"
//        מסומנת בערך הזה במקום מזהה-מורה אמיתי. קלט: אין. פלט: מחרוזת.
//
// הערת-המרה (מקור→Dart): האטום המיוצא-והנבדק הוא קבוע-מחרוזת בלבד — אפס
// locale/פורמט/getMonth/truthiness/מוטביליות מעורבים ⇒ אין שקעים, אין כלל מ-DART-PORTING-RULES
// שחל כאן. הערך '__add' הוא ASCII טהור (2×'_' + 'a','d','d'), אורך 5. חוק-5: ערך-פיגמנט
// בלבד — פרשנותו כ"פתיחת-שדה-הוספה" חיה בקופסה (טופס-החוג), לא באטום.
// המנוע-האוטומטי (dart-from-maor) לא הפיק טיוטה לאטום זה ⇒ נכתב ידנית לפי המקור.

/// Teacher-picker "add new teacher" sentinel value. Verbatim value of the JS
/// source new/atoms/add-teacher.mjs (`ADD_TEACHER`) — the 5-char string '__add'.
const String addTeacher = '__add';
