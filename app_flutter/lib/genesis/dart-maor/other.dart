// ⚛️ אטום-Dart (ערך-הזקיף) · OTHER — ערך בחירת "אחר" בטופס.
// מוצא: היה מועתק ביט-זהה ב-2 מודולים — maor/src/components/courses/lib.ts:401
//        ו-maor/src/components/families/lib.ts:201 (‏OTHER) — אוחד לחוט-יחיד.
//        המקור: new/atoms/other.mjs (`export const OTHER = '__other'`) ·
//        חוזה: new/atoms/other.contract.md.
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        ערך זהה-ביט למקור-ה-JS (המקור קדוש). אטום-קבוע (צילום-ערך), לא פונקציה.
//
// תפקיד: ערך-הזקיף שהטופס משתמש בו כדי לסמן "אחר" (חוק-5): המחרוזת לא יודעת
//        שהיא פותחת הקלדה-חופשית — פתיחת שדה-הטקסט היא חיווט-הקופסה. פלט: String.
//
// הערות-המרה (מקור→Dart):
//  • `export const OTHER = '__other'` → `const String other = '__other'`.
//    אותם תווים בדיוק (קידומת-זקיף '__' + 'other'). אין locale/פורמט/getMonth/
//    truthiness/substring/מודולו מעורבים — קבוע-מחרוזת טהור, ללא שקעים.
//  • המנוע פלט `var OTHER = '__other'`; תוקן ל-`const` (בלתי-משתנה, שקול ל-const
//    של המקור) ולשם-Dart תקני `other` (lowerCamel לקבוע top-level).

/// The sentinel value a form uses to mark the "other" choice. Value-snapshot
/// port of new/atoms/other.mjs (`OTHER`). Same bytes: the '__' sentinel prefix
/// (which will not collide with a real user value) followed by 'other'.
const String other = '__other';
