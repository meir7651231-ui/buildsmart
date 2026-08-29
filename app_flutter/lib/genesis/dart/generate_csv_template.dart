// ⚛️ אטום-Dart (דרגת-חוזה) · generateCsvTemplate
// תפקיד: מחולל תבנית-CSV להדבקה — שורת-כותרת (עמודות-קבועות + שמות-מאפיינים) + שורה-ריקה תואמת-רוחב.
// מוצא: buildsmart/app_flutter/lib/domain/trade_import.dart:36-232 (‏generateCsvTemplate; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). שני שקעים (חוק-3):
//        (1) הקריאה-לשכן `for (final d in defs) d.nameHe` (קריאת-שדה מטיפוס-השכן AttributeDef) קופלה
//            לשקע `defNames` — רשימת-השמות המוזרקת (הטיפוס AttributeDef גדול, לא-inline).
//        (2) ה-const `kImportFixedColumns` (trade_import.dart) **אינו-בר-שחזור** — הקובץ נמחק מהמקור-החי
//            (find לא מצא · grep ריק) ⇒ הוסקק כ-`fixedColumns` במקום זיוף-ערך (דיבר-9/חוק-6-רוח).
//        האחים בקובץ (ImportRowError, ImportReport, parseAndValidateCsv) — לא נקראים ⇒ לא-הוטבעו.
//
// קלט:  defNames     — שקע: שמות-המאפיינים (במקור `defs.map((d)=>d.nameHe)`).
//        fixedColumns — שקע: העמודות-הקבועות המובילות (במקור const kImportFixedColumns; לא-בר-שחזור).
// פלט:  String — `<כותרות מופרדות-פסיק>\n<שורה-ריקה: פסיקים בלבד, ‏count-1 פסיקים>`.

/// CSV import template: header row + one blank data row. Verbatim behaviour of
/// trade_import.dart:36-232 with the fixed-columns const and the def-name read
/// injected as sockets (law-3; the const's source file was deleted upstream).
String generateCsvTemplate(
  List<String> defNames, {
  required List<String> fixedColumns,
}) {
  final header = [...fixedColumns, ...defNames];
  final blankRow = List.filled(header.length, '').join(',');
  return '${header.join(',')}\n$blankRow';
}
