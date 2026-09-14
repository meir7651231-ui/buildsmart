// ⚛️ אטום-Dart (דרגת-חוזה) · r1
// מוצא: buildsmart/app_flutter/lib/features/fittings/engine/fitting_dims.dart:27 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// עיגול לספרה-עשרונית אחת, **זהה ל-Python `round(x, 1)`** — half-to-even על
/// *הערך-האמיתי* של ה-double. מאומת golden 1:1 מול `pure_engine.py` (140 שורות).
///
/// למה לא `x*10`/`toStringAsFixed(1)`: הכפל ב-10 הופך ערך כמו 26.7/2=13.34999… ל-
/// תיקו-שקרי (133.5) ומעגל להיפך; `toStringAsFixed(1)` סוטה מ-half-even על עשרות
/// ערכים. הפתרון: הרחבה ל-15 ספרות (נאמנה לערך-האמיתי) + עיגול-לזוגי ידני מדויק.
double r1(double x) {
  final neg = x.isNegative;
  final ax = neg ? -x : x;
  // 18 ספרות — נאמן ל*צד* של הערך-האמיתי מול גבול-ה-.05 לכל גודל כאן (ulp ≪ 1e-13
  // עד ~1200). 15 היה מעט-מדי: 26.7/2=13.34999…964 (מתחת ל-13.35) עוגל שקרית ל-13.350.
  final s = ax.toStringAsFixed(18);
  final dot = s.indexOf('.');
  var intVal = int.parse(s.substring(0, dot));
  final frac = s.substring(dot + 1);
  var keep = frac.codeUnitAt(0) - 48; // הספרה הנשמרת (עשירית)
  final firstDrop = frac.codeUnitAt(1) - 48; // הספרה שמחליטה
  var restNonZero = false;
  for (var i = 2; i < frac.length; i++) {
    if (frac.codeUnitAt(i) != 48) {
      restNonZero = true;
      break;
    }
  }
  final roundUp = firstDrop > 5 ||
      (firstDrop == 5 && restNonZero) ||
      (firstDrop == 5 && !restNonZero && keep.isOdd); // תיקו → לזוגי
  if (roundUp && ++keep == 10) {
    keep = 0;
    intVal += 1;
  }
  final v = intVal + keep / 10.0;
  return neg ? -v : v;
}
