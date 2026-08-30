// ⚛️ אטום-Dart (דרגת-חוזה) · groupThousands
// תפקיד: פורמט מספר-שלם עם מפרידי-אלפים (פסיק כל 3 ספרות), על הערך-המוחלט (הסימן מושמט).
// מוצא: buildsmart/app_flutter/lib/logic/money_format.dart:19-30 (‏groupThousands; חוק-4 — verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). `int.abs`/`int.toString`/`StringBuffer`
//        = שפה/סטנדרט. האח שמתחת (‏formatNis, קישוט-₪-חתום) לא נקרא ⇒ לא-הוטבע.
//
// קלט:  n — מספר-שלם (חיובי/שלילי/אפס).
// פלט:  String — ‏|n| עם פסיק לפני כל שלישיית-ספרות. הסימן **אינו** נכלל (‏n.abs()).

/// Group an integer's digits in thousands (on its absolute value; no sign).
/// Verbatim of money_format.dart:19-30.
String groupThousands(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
