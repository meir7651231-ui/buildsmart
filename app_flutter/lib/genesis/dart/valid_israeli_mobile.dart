// ⚛️ אטום-Dart (דרגת-חוזה) · validIsraeliMobile
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:11-14 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: String.replaceAll · RegExp.hasMatch).
//        השקעים-המועמדים מהטיוטה (replaceAll, hasMatch) הם מתודות-סטנדרט — לא קריאות-שכן,
//        ולכן אינם הופכים לפרמטר-שקע (חוק-1/3: מותר שפה/סטנדרט בלבד).
//
// קלט:  input — מחרוזת חופשית (מספר-נייד כפי שהוקלד; רווחים/מקפים מותרים).
// פלט:  bool — true רק אם אחרי הסרת רווחים ומקפים נותרו בדיוק 10 ספרות-ASCII שמתחילות ב-05.

/// Israeli mobile number: exactly 10 digits starting with `05`.
/// Dashes and spaces are allowed in the input and stripped before the check
/// (e.g. `050-123 4567` → `0501234567`).
bool validIsraeliMobile(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^05\d{8}$').hasMatch(digits);
}
