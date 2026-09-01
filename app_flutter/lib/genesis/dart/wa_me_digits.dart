// ⚛️ אטום-Dart (דרגת-חוזה) · waMeDigits
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:74-90 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: RegExp + String).
//       אין קריאה-לשכן ואין שדה-מחלקה — ה"שקעים-המועמדים" בטיוטה (replaceAll/substring)
//       הם מתודות-מחרוזת סטנדרטיות, לא תלות-להזרקה. לכן אפס-שקע (חוק-1/3).
//
// קלט:  input — טלפון חופשי-טקסט (רווחים/מקפים/סוגריים/`+`/`00` מותרים).
// פלט:  מחרוזת-ספרות בפורמט ש-`wa.me` מצפה לו (קוד-מדינה, בלי `+`/`00`/מפרידים);
//       `''` כשאין ולו ספרה אחת (הקורא מסתיר את כפתור-הוואטסאפ במקום לפתוח wa.me/).

/// Normalize a free-text phone to the international digit string `wa.me`
/// expects (digits only, country code, NO `+`/`00`/separators). Pure →
/// unit-testable. Rules (Israeli-first, the only market today):
///   • strip everything that isn't a digit (spaces, dashes, parens, `+`);
///   • a `00`-prefixed international form drops the `00` (→ bare country code);
///   • an Israeli LOCAL number (leading `0`, e.g. `050-123 4567`) maps its
///     trunk `0` to the `972` country code → `972501234567`;
///   • an already-international number (`+972…` / `972…`) keeps its digits.
/// Returns `''` when there are no digits at all.
String waMeDigits(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  // `00<cc>…` international prefix → strip the `00` to the bare country code.
  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }
  // Israeli local form: a single leading trunk `0` → the 972 country code.
  // (A `972…` that happens to start with no `0` is left untouched.)
  if (digits.startsWith('0')) {
    digits = '972${digits.substring(1)}';
  }
  return digits;
}
