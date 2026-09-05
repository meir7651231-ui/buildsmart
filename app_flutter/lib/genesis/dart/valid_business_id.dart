// ⚛️ אטום-Dart (דרגת-חוזה) · validBusinessId
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:29-38 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: String.replaceAll · RegExp.hasMatch ·
//        String.codeUnitAt · int.isEven). השקעים-המועמדים מהטיוטה (replaceAll, hasMatch, codeUnitAt)
//        הם מתודות-סטנדרט — לא קריאות-שכן, ולכן אינם הופכים לפרמטר-שקע (חוק-1/3: מותר שפה/סטנדרט בלבד).
//
// קלט:  input — מחרוזת חופשית (מזהה-עוסק/ח"פ כפי שהוקלד).
// פלט:  bool — true רק אם אחרי הסרת רווחים ומקפים נותרו בדיוק 9 ספרות-ASCII וספרת-הביקורת תקינה
//        (סכום-משוקלל 1-2-1-2 עם קיפול, ≡0 mod 10).

/// Israeli business id (ח"פ / ע.מ.): exactly 9 digits AND a valid check digit.
/// Dashes and spaces are allowed in the input and stripped before the check.
///
/// Phase-2 bug-fix (was 9-digits-only, so a mistyped id slipped through): the
/// standard Israeli 1-2-1-2 weighted checksum — each digit times its weight,
/// products over 9 fold (sum their digits, i.e. −9), and the total must be
/// ≡ 0 (mod 10). A pure tightening; no toggle (a bug fix, not a feature).
bool validBusinessId(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^\d{9}$').hasMatch(digits)) return false;
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    final product = (digits.codeUnitAt(i) - 0x30) * (i.isEven ? 1 : 2);
    sum += product > 9 ? product - 9 : product;
  }
  return sum % 10 == 0;
}
