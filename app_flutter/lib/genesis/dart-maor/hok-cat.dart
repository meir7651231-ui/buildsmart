// ⚛️ אטום-Dart (דרגת-חוזה) · hokCat — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/components/supporters/lib.ts:679-693 · המקור: new/atoms/hok-cat.mjs —
//        `export const HOK_CAT = 'הו"ק';`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: קטגוריית-קבלה קבועה ל"הוראת-קבע" (הו"ק). קלט: אין. פלט: מחרוזת.
//
// הערת-המרה (מקור→Dart): האטום המיוצא-והנבדק הוא קבוע-מחרוזת בלבד. הפונקציה
// monthsAgoIso שבזנב-המקור אינה מיוצאת ואינה בחוזה/בדיקה (קוד-מת בזנב) ⇒ לפי חוק-2
// ממירים אך ורק את הקבוע שהחוזה מחייב — לא מוסיפים התנהגות שאין ברתמת-הזהב.
// אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים — קבוע-מחרוזת טהור, ללא שקעים.
// המנוע-האוטומטי (dart-from-maor) לא הפיק טיוטה לאטום זה ⇒ נכתב ידנית לפי המקור.

/// Recurring-donation ("הוראת-קבע") category constant. Verbatim value of the JS
/// source new/atoms/hok-cat.mjs (`HOK_CAT`) — the 4-char string he·vav·quote·qof.
const String hokCat = 'הו"ק';
