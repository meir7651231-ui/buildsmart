// ⚛️ אטום-Dart (דרגת-חוזה) · validBoardCode
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:59-62 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: String.replaceAll · RegExp.hasMatch).
//        השקעים-המועמדים מהטיוטה (replaceAll, hasMatch) הם מתודות-סטנדרט — לא קריאות-שכן,
//        ולכן אינם הופכים לפרמטר-שקע (חוק-1/3: מותר שפה/סטנדרט בלבד).
//
// קלט:  input — מחרוזת חופשית (קוד-כניסה-ללוח כפי שהוקלד).
// פלט:  bool — true רק אם אחרי הסרת רווחים ומקפים נותרו בדיוק 4 ספרות-ASCII.

/// Board login code (task #65): exactly 4 digits — the seeded board-account
/// codes (`data/board_accounts_local.dart`). Dashes and spaces are allowed in
/// the input and stripped before the check.
bool validBoardCode(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^\d{4}$').hasMatch(digits);
}
