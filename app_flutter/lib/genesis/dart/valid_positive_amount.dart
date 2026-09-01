// ⚛️ אטום-Dart (דרגת-חוזה) · validPositiveAmount
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:91-92 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: num.isFinite · אופרטורים).
//        השקעים-המועמדים שנרשמו בטיוטה (validDateRange, isAfter) שייכים לשכן validDateRange
//        שנחצב באותה טיוטה — לא ל-validPositiveAmount, שאין לו שום קריאת-חוץ (חוק-1/3).
//
// קלט:  value — num? (תוצאת int.tryParse / double.tryParse; עשוי null).
// פלט:  bool — true רק אם value אינו null, סופי, וגדול-ממש מ-0.

/// Amount (price / budget / expense): a finite number strictly greater than 0.
/// Accepts the nullable result of `int.tryParse` / `double.tryParse` directly.
bool validPositiveAmount(num? value) =>
    value != null && value.isFinite && value > 0;
