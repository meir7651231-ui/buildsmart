// ⚛️ אטום-Dart (דרגת-חוזה) · csvEscape — הגנת תא-CSV (חסימת הזרקת-נוסחאות + ציטוט).
// מוצא: maor/src/lib/csvx.ts (csvEscape) · המקור: new/atoms/csv-escape.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core RegExp).
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מגן על תא-CSV — תא שמתחיל ב-=+-@/טאב/CR מקבל גרש מוביל (חסימת
//        CSV-injection), ותא עם פסיק/גרשיים/שורה מצוטט בגרשיים כפולים.
// קלט:  ערך כלשהו (מחרוזת/מספר/null). פלט: מחרוזת בטוחה לאקסל.
//
// הערות-המרה (מקור→Dart):
//  • `String(x ?? '')` → `(x ?? '').toString()` — null⇒'' לפני toString (5⇒"5").
//  • `/^[=+\-@\t\r]/.test(v)` → `RegExp(r'^[=+\-@\t\r]').hasMatch(v)` — אותה מחלקת-תווים;
//    מנוע-ה-RegExp מפרש \t/\r כטאב/CR (raw-string שומר על ה-backslash-ים למנוע).
//  • `.includes` → `.contains` · `.replace(/"/g,'""')` → `.replaceAll('"', '""')`.
//  • '\n'/'\r' בבדיקת-contains = תווי newline/CR ממש (מחרוזת-Dart רגילה), כמו ב-JS.
//  • מוטביליות: `let v` → `var v` (מוקצה מחדש כשמוסיפים גרש מוביל).
//  אין locale/פורמט/getMonth מעורבים.

/// CSV cell guard. Verbatim port of the JS source new/atoms/csv-escape.mjs
/// (`csvEscape`): prefixes a leading apostrophe to formula-triggering cells,
/// and quotes cells containing comma/quote/newline with doubled quotes.
String csvEscape(Object? x) {
  var v = (x ?? '').toString();
  if (RegExp(r'^[=+\-@\t\r]').hasMatch(v)) v = "'" + v;
  return v.contains(',') || v.contains('"') || v.contains('\n') || v.contains('\r')
      ? '"' + v.replaceAll('"', '""') + '"'
      : v;
}
