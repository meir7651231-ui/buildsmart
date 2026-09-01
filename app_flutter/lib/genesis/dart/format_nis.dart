// ⚛️ אטום-Dart (דרגת-חוזה) · formatNis
// מוצא: buildsmart/app_flutter/lib/logic/money_format.dart:31-33 (‏formatNis; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import. הקריאה-לשכן `groupThousands(n)` הופכה
//        לשקע-פרמטר (חוק-3/דיבר-3). ⚠️ המקור מעביר את `n` **המקורי** (כולל שלילי)
//        ל-groupThousands — שימור-מקור, לא-שיפור: סימן-המינוס מודבק בנפרד לפני ה-₪.
//
// קלט:  n              — סכום שלם (₪, יכול להיות שלילי).
//       prefix         — קידומת אופציונלית (ברירת-מחדל '').
//       groupThousands — שקע: int ⇒ מחרוזת-מקובצת (במקור פונקציית-השכן).
// פלט:  '<prefix><'-' אם n<0>₪<groupThousands(n)>'.

/// Format an integer NIS amount: optional prefix, leading '-' for negatives,
/// a ₪ sign, then the grouped digits. Verbatim behaviour of money_format.dart:31-33.
String formatNis(
  int n, {
  String prefix = '',
  required String Function(int) groupThousands,
}) =>
    '$prefix${n < 0 ? '-' : ''}₪${groupThousands(n)}';
