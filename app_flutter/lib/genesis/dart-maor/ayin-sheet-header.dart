// ⚛️ אטום-Dart (דרגת-חוזה) · ayinSheetHeader — כותרות גיליון-הייצוא של "עופרת".
// מוצא: maor/src/lib/ayin.ts:380-395 (16 שורות) · המקור: new/atoms/ayin-sheet-header.mjs
//        (`AYIN_SHEET_HEADER`, קודם אוטומטית — צילום-ערך).
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). אין שכן, אין locale/פורמט/getMonth/truthiness.
//
// תפקיד: 8 כותרות-העמודה של גיליון-הייצוא, בסדר-המקור בדיוק. חוק-5 — הרשימה לא
//        יודעת מי כותב אותה או לאיזה קובץ; זהו נתון-קבוע בלבד.
// קלט:  אין (קבוע). פלט: List<String> באורך 8 —
//        ['תומכת','טלפון','שם למסירה','כמה עיניים','נמסר (כן/לא)','שולם (כן/לא)',
//         'תשובה/הערה','עופרת בוצעה (כן/לא)'].
//
// הערות-המרה (מקור→Dart):
//  • `export const AYIN_SHEET_HEADER = [...]` → `const List<String>` top-level.
//    ⚠️ טיוטת-המנוע פלטה `var` (מוקצה-מחדש) — תוקן ל-`const` (immutable מוחלט),
//    נאמן ל-`const` של המקור-ה-JS (מוטביליות — כלל-מוטציה).
//  • הצילום ב-JS הוא JSON.stringify של המערך; ‏jsonEncode של Dart מקביל — אותם ערכים,
//    אותו סדר, ללא-רווחים ⇒ מחרוזת זהה-ביט. רתמת-הזהב מוכיחה זהות מול אותו snapshot.
//  • המחרוזות-העבריות ראשוניות (codepoints U+05D0..) — מועתקות verbatim, אפס-שינוי.
//  • אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// Column headers for the "Ayin" (עופרת) distribution export sheet, in source
/// order. Verbatim port of new/atoms/ayin-sheet-header.mjs (`AYIN_SHEET_HEADER`).
const List<String> ayinSheetHeader = [
  'תומכת',
  'טלפון',
  'שם למסירה',
  'כמה עיניים',
  'נמסר (כן/לא)',
  'שולם (כן/לא)',
  'תשובה/הערה',
  'עופרת בוצעה (כן/לא)',
];
