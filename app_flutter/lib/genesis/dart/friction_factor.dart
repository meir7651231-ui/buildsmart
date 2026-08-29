// ⚛️ אטום-חוט Dart · frictionFactor — מקדם-חיכוך Darcy מודע-ריינולדס למים בצינור חלק.
// מוצא (קדוש, חוק-4): buildsmart/app_flutter/lib/logic/pressure_drop.dart:317-323 (_frictionFactor).
// טוהר (חוק-1): אפס import; אפס תלות-אטום. קריאת-השכן _pow025 (call:322, def pressure_drop.dart:325) הפכה
//   לשקע-מוזרק [pow025] (חוק-3) — האטום לא יודע איך מחשבים x^0.25, רק שהוא מקבל חוט כזה.
// התנהגות משומרת ביט-בביט מהמקור (חוק-4 — לא "משפרים"): הסף 100 (מתחת ⇒ 0.64), טווח
//   לאמינרי 64/Re, וברז Blasius 0.316/pow025(Re). אי-הרציפות ב-Re=2300 נשמרת כמות-שהיא.

/// Reynolds-aware Darcy friction factor for water in a smooth-walled pipe.
///
/// - `reynolds < 100`  → `0.64` (very slow trickle — capped to avoid blow-up).
/// - `100 ≤ reynolds < 2300` → `64.0 / reynolds` (laminar flow).
/// - `reynolds ≥ 2300` → `0.316 / pow025(reynolds)` (Blasius, smooth-pipe turbulent).
///
/// [pow025] is the injected socket that computes `reynolds^0.25` (חוק-3). The source
/// wired its own Newton-based `_pow025`; the atom stays agnostic and takes it as a
/// function so the box decides which `pow025` atom to wire. It is only ever invoked
/// on the turbulent branch (`reynolds ≥ 2300`).
double frictionFactor(
  double reynolds, {
  required double Function(double) pow025,
}) {
  if (reynolds < 100) return 0.64; // very slow trickle — cap to avoid blow-up
  if (reynolds < 2300) return 64.0 / reynolds;
  // Blasius — valid up to Re ≈ 1e5; beyond that real Colebrook would tweak
  // by < 10%, an error band well below the K-value uncertainty anyway.
  return 0.316 / pow025(reynolds);
}
