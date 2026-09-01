// ⚛️ אטום-Dart (דרגת-חוזה) · sizeTableEq
// מוצא: buildsmart/app_flutter/lib/domain/connection_schema.dart:51-59 (חוק-4 — התנהגות זהה, לא-משופרת).
// גלגול: במקור פונקציה פרטית `_sizeTableEq` (עוזר value-== ל-SizeConstraint); קודמה ל-top-level טהור.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). הקריאה-לשכן `listEquals`
//        (package:flutter/foundation.dart) הופכה לשקע-פרמטר `rowEq` (חוק-3) — כך האטום רץ בדארט-טהור
//        בלי תלות ב-flutter. ברירת-המחדל `_listEq` משכפלת את התנהגות listEquals אחד-לאחד.
//
// קלט:  a, b  — טבלאות-מידה: List<List<String>>? (nullable), שורות של מחרוזות.
//       rowEq — שקע: משווה שתי שורות (List<String>) איבר-לאיבר; ברירת-מחדל = listEquals-שקול.
// פלט:  bool — האם שתי הטבלאות שקולות (null==null ⇒ true; אחד-null ⇒ false; אורך-חיצוני שונה ⇒ false;
//        אחרת ⇒ כל שורה שקולה דרך rowEq).

/// ברירת-מחדל לשקע rowEq — משכפלת את `listEquals` (flutter/foundation) עבור List<String>.
bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// שוויון-ערך של שתי טבלאות-מידה. הועתק verbatim מ-connection_schema.dart:51-59 (חוק-4),
/// עם `listEquals` מוזרק כשקע `rowEq`.
bool sizeTableEq(
  List<List<String>>? a,
  List<List<String>>? b, {
  bool Function(List<String> x, List<String> y) rowEq = _listEq,
}) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!rowEq(a[i], b[i])) return false;
  }
  return true;
}
