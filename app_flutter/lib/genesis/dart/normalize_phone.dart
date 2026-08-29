// ⚛️ אטום-Dart (דרגת-חוזה) · normalizePhone
// תפקיד: נירמול מספר-טלפון — ספרות-בלבד, פירוק קידומת-חיוג-בינ"ל (00 / 972 ⇒ 0).
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:48-58
//        (‏normalizePhone; חוק-4 — התנהגות זהה).
// אחים-שסוקטו/הוטבעו: אין. האטום קורא רק String/RegExp.
//        (האח בטיוטה — בדיקת-קוד-לוח 4-ספרות — שכן, לא האטום.)
// טוהר: אפס import (dart:core בלבד; RegExp מובנה).
//
// קלט:  input — מחרוזת-טלפון חופשית (מקפים/רווחים/‎+‎ מותרים).
// פלט:  String — ספרות-בלבד; "00XXX" ⇒ מסירים 2; "972XXX" ⇒ "0"+השאר; ריק ⇒ ''.

/// Normalize a free-text phone: digits only, then strip the intl dialing
/// prefix (`00…` → drop 2; `972…` → `0` + rest). Verbatim behaviour of
/// input_validators.dart:48-58.
String normalizePhone(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('972')) digits = '0${digits.substring(3)}';
  return digits;
}
