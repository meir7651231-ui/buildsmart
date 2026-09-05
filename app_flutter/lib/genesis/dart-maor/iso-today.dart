// ⚛️ אטום-Dart (דרגת-חוזה) · isoToday
// מוצא: maor · new/atoms/iso-today.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). השכן isoLocal מוזרק כשקע
//        (חוק-3 — חוט לא מייבא שכן; קריאה-לשכן ⇒ פרמטר-שקע).
//
// תיקוני-פורט מול טיוטת-המנוע (התנהגות משומרת ביט-אחר-ביט):
//   • default now — המנוע פלט `[dynamic now = DateTime.now()]`; ב-Dart ברירת-מחדל חייבת
//                   להיות קבוע-קומפילציה ⇒ לא מתקמפל. הפורט: `[DateTime? now]` + `?? DateTime.now()`
//                   בגוף — נאמן ל-JS `now = new Date()` (עכשיו כשלא סופק).
//   • טיפוסים      — `dynamic` הוחלף בחוזה מפורש: isoLocal = `String Function(DateTime)`,
//                   הפלט `String`. אפס truthiness/מוטביליות מעורבים (הגוף חד-שורתי).
//   • getMonth     — אין תיקון-אינדקס באטום עצמו: ההמרה 0↔1 חיה בשקע isoLocal (בצד המזריק),
//                   בדיוק כמו במקור-ה-JS שבו getMonth()+1 חי בשכן, לא בחוט.
//
// קלט:  isoLocal — שקע חובה: DateTime ⇒ "YYYY-MM-DD" מקומי · now — אופציונלי, ברירת-מחדל עכשיו.
// פלט:  מחרוזת "YYYY-MM-DD".

/// "היום" כ-ISO מקומי (YYYY-MM-DD): מפעיל את שקע isoLocal על now (או על עכשיו כברירת-מחדל).
String isoToday(String Function(DateTime) isoLocal, [DateTime? now]) {
  return isoLocal(now ?? DateTime.now());
}
