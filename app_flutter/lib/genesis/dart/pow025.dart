// ⚛️ אטום-Dart (דרגת-חוזה) · pow025
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:327-333 (‏_pow025; חוק-4 — התנהגות זהה, לא-משופרת).
// תפקיד: שורש-רביעי מהיר (x^0.25) לנתיב-חם של חישוב-לחץ — sqrt(sqrt(x)),
//        עם מגן על x שאינו-חיובי (מוצמד ל-1e-9 כדי למנוע sqrt של שלילי/אפס).
// טוהר: פונקציית top-level עצמאית. במקור פרטית (`_pow025`) ⇒ פורסמה (כלל-הגלגול).
//        השכן `_sqrt` (‏שקע-מועמד `sqrt`) = פונקציית-הספרייה `sqrt` — נלקחת מ-dart:math
//        (‏dart:* מותר, חוק-1); אינו אטום ואינו שקע. אין import-אטום.
//
// קלט:  x — double. אם ‏x > 0 ⇒ מחושב עליו; אחרת מוצמד ל-‏1e-9 (מגן-המקור, :329).
// פלט:  double — ‏sqrt(sqrt(s)) כאשר ‏s = (x > 0 ? x : 1e-9); כלומר s^0.25.

import 'dart:math' as math;

/// Fourth root (x^0.25) via sqrt(sqrt·) — the hot-path shortcut of
/// pressure_drop.dart:327-333. Non-positive x is clamped to 1e-9 (source guard).
double pow025(double x) {
  // sqrt(sqrt(x)) — faster than dart's pow() for this hot path
  final s = x > 0 ? x : 1e-9;
  final r1 = math.sqrt(s);
  return math.sqrt(r1);
}
