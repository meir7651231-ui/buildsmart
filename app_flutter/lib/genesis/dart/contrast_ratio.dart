// ⚛️ אטום-Dart (דרגת-חוזה) · contrastRatio
// תפקיד: יחס-ניגודיות WCAG בין שני צבעים — `(hi+0.05)/(lo+0.05)` על הבהירויות-היחסיות.
//        משמש שער-בטיחות-עריכה לבדיקת קריאוּת-צבעים.
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:278-283 (‏_contrastRatio; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). פרטי-במקור ⇒ public.
// אחים-שסוקטו: `Color.computeLuminance()` (בהירות-יחסית של צבע) הומר לשקע `luminanceOf`
//        (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע; כך אין תלות ב-dart:ui/Flutter). האטום גנרי על `T`.
//        אחים-שהוטבעו: — (‏validateSafe ושאר-הקובץ אינם חלק מהאטום).
//
// קלט:  a, b        — שני צבעים (T).
//       luminanceOf — שקע: בהירות-יחסית (double Function(T)); במקור `c.computeLuminance()` (‏0..1).
// פלט:  double ≥ 1.0 — יחס-הניגודיות (‏1.0 = זהה, ‏21.0 = לבן↔שחור).

/// WCAG contrast ratio `(hi+0.05)/(lo+0.05)` over the two relative luminances.
/// `computeLuminance` is injected via [luminanceOf] (slot — no dart:ui dependency).
/// Verbatim behaviour of edit_safety.dart:278-283.
double contrastRatio<T>(T a, T b, {required double Function(T) luminanceOf}) {
  final la = luminanceOf(a);
  final lb = luminanceOf(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
