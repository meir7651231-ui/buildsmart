// ⚛️ אטום-Dart (דרגת-חוזה) · payMethods — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/components/courses/lib.ts · המקור: new/atoms/pay-methods.mjs —
//   `export const PAY_METHODS = ['מזומן', 'העברה בנקאית', "צ'ק", 'אשראי', 'ביט'];`
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: אמצעי-התשלום לבורר החוגים — בדיוק חמש אפשרויות, בסדר-מקור.
// קלט:  אין. פלט: רשימת String בסדר-מקור.
//
// הערת-המרה (מקור→Dart): ה-JS הוא מערך-קבוע של חמש מחרוזות-עברית; ב-Dart רשימה-literal
// קבועה `const` שומרת על הסדר (כמו מערך-JS) ⇒ ביט-זהה לצילום שבבדיקה. המרכאות ב-"צ'ק"
// נשמרות כמות-שהן (גרש בתוך המחרוזת). אין locale/פורמט/getMonth/truthiness/מוטביליות
// מעורבים — קבוע טהור, ללא שקעים.

/// Course-picker payment methods — exactly five options in source order. Verbatim
/// value of the JS source new/atoms/pay-methods.mjs (`PAY_METHODS`). Element order
/// preserved so the list is bit-identical to the JS snapshot.
const List<String> payMethods = ['מזומן', 'העברה בנקאית', "צ'ק", 'אשראי', 'ביט'];
