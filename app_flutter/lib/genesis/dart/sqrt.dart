// ⚛️ אטום-Dart (דרגת-חוזה) · sqrt
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:334-342 (‏_sqrt; חוק-4 — התנהגות
//        זהה, לא-משופרת). האטום = הפונקציה בלבד; שאר הטיוטה (estimatePressureDrop,
//        checkDrainageSlope) אינם היעד ולא הוטבעו.
// טוהר: פונקציית top-level עצמאית לחלוטין — אפס import, אפס const-שכן, אפס שקע (חוק-1).
//        רק אריתמטיקה של dart:core. שם-המקור פרטי (`_sqrt`) → נחשף כ-top-level `sqrt`.
//
// קלט:  x — הרדיקנד (double).
// פלט:  שורש-ריבועי מקורב בשיטת ניוטון, 5 איטרציות קבועות (r₀ = x/2).
//        נאמנות-מקור: אין הגנה על x==0 (‏0/0 = NaN ⇒ הפלט NaN) ואין הגנה על x<0.

/// Newton's method square root — EXACTLY 5 iterations from r₀ = x/2.
/// Verbatim behaviour of pressure_drop.dart:334-342 (`_sqrt`). No guards:
/// `sqrt(0)` yields `NaN` (0/0 in the first update), negatives are undefined.
double sqrt(double x) {
  // Newton's method, 5 iterations — sufficient for the resolution we need
  var r = x / 2;
  for (var i = 0; i < 5; i++) {
    r = 0.5 * (r + x / r);
  }
  return r;
}
