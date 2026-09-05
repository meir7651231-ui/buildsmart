// ⚛️ אטום-Dart (דרגת-חוזה) · parseSupporterCsv — פענוח טקסט-CSV לשורות-ייבוא תומכות (הרכבה).
// מוצא: maor/src/components/supporters/lib.ts:506-533 (חוק-4 — התנהגות זהה למקור-ה-JS).
//        המקור: new/atoms/parse-supporter-csv.mjs —
//        `return parseSupporterGrid(parseCsv(text));`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). קריאות-השכן
//        (parseCsv / parseSupporterGrid) הוזרקו כשקעים-פרמטרים — חוק-1.
//
// תפקיד: חוט-הרכבה טהור — מעביר את הטקסט דרך parseCsv (טקסט⇒רשת-תאים) ואת
//        התוצאה **כמות-שהיא** דרך parseSupporterGrid (רשת⇒שורות-ייבוא), ומחזיר
//        את פלט-הרשת ללא נגיעה (זהות-הפניה נשמרת — אין העתקה).
// קלט:  text — מחרוזת CSV/TSV גולמית + 2 שקעי-פונקציה.
// פלט:  בדיוק הערך (אותה הפניה) ש-parseSupporterGrid מחזיר.
//
// הערת-המרה (מקור→Dart): המנוע פלט חתימת-`dynamic` שלושה-שקעים; כאן הודקה
// לחתימת-פונקציה מטיפוסת עם פרמטר-טיפוס T לשורת-הייבוא. אין locale/פורמט/
// getMonth/truthiness/מוטביליות מעורבים — הרכבה טהורה, אפס לוגיקה נגזרת.

/// Raw CSV text → supporter import rows, by pure composition:
/// `parseSupporterGrid(parseCsv(text))`. The grid output is returned by the
/// same reference, untouched. Verbatim behaviour of the JS source
/// new/atoms/parse-supporter-csv.mjs. Neighbour calls are injected sockets (חוק-1).
List<T> parseSupporterCsv<T>(
  String text,
  List<List<String>> Function(String text) parseCsv,
  List<T> Function(List<List<String>> rows) parseSupporterGrid,
) {
  return parseSupporterGrid(parseCsv(text));
}
