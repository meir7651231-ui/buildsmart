// ⚛️ אטום-Dart (דרגת-חוזה) · fmtDate
// מוצא: buildsmart/app_flutter/lib/logic/delivery_note.dart:12 (_fmtDate; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). ה-DateTime מגיע
//        כפרמטר — אין DateTime.now (טהור, דטרמיניסטי).
// פרטי-במקור: `_fmtDate` → הוצא-לחוזה כ-top-level ציבורי `fmtDate`.
//
// קלט:  d — תאריך. פלט: מחרוזת DD/MM/YYYY (בלי padding — verbatim מהמקור).

/// תאריך קצר DD/MM/YYYY (טהור, בלי תלות-חבילה).
String fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
