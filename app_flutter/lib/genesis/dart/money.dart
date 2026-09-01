// ⚛️ אטום-Dart (דרגת-חוזה) · money
// תפקיד: עיצוב שקלי — קיבוץ-אלפים בפסיקים + ₪, סימן-מינוס לפני ה-₪ (לא "₪-").
// מוצא: buildsmart/app_flutter/lib/logic/manager_copilot.dart:59-70 (‏money; חוק-4).
//        במקור פונקציה מקוננת בתוך בונה-הפרומפט; כאן top-level עצמאי (כלל-הגלגול).
// אחים-שסוקטו/הוטבעו: אין. האטום קורא רק int/String/StringBuffer.
//        (האחים בטיוטה — pipe/top/creditLimitTotal/StringBuffer — שכני-סקופ, לא האטום.)
// טוהר: אפס import (dart:core בלבד).
//
// קלט:  n — סכום שלם (int; שקלים; יכול להיות שלילי).
// פלט:  String — "₪" + הספרות מקובצות ב-3 עם פסיקים; שלילי ⇒ "-" מקדים.

/// Money formatting: thousands-grouped with commas, prefixed `₪`, minus before
/// the ₪ (never "₪-,100"). Verbatim behaviour of manager_copilot.dart:59-70.
String money(int n) {
  final neg = n < 0;
  final s = n.abs().toString(); // group over abs, re-apply sign (no "₪-,100")
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${neg ? '-' : ''}₪$b';
}
