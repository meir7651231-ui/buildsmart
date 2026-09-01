// ⚛️ אטום-Dart (דרגת-חוזה) · fMoney
// מוצא: buildsmart/app_flutter/lib/data/contractor_seeds.dart:486-498 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית עצמאית, אפס import (רק dart:core).
//
// קלט:  v — מספר (num).
// פלט:  '₪' + מספר-שלם עם מפריד-אלפים (למשל 9840 → "₪9,840"). Proto finMoney.

/// '₪' + שלם עם מפריד-אלפים (מעגל, ערך-מוחלט, שלט למינוס). טהור.
String fMoney(num v) {
  final neg = v < 0;
  final digits = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${neg ? '-' : ''}₪$buf';
}
