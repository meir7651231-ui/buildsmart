// ⚛️ אטום-Dart (דרגת-חוזה) · paidOf
// מוצא: maor · new/atoms/paid-of.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
//   `export const paidOf = (e) => (e.payments || []).reduce(
//        (a, p) => a + (Number.isFinite(p.amount) ? p.amount : 0), 0);`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core).
//
// תיקוני-פורט מול טיוטת-המנוע (dart-from-maor/paid-of.dart.draft) והתנהגות משומרת ביט:
//   • המנוע פלט `dynamic paidOf(dynamic e) => (e.payments ?? []).fold(...)` — `e.payments`
//     דורש getter-אמת ולא עובד על Map; מודלים את הישות כ-Map ואת התשלומים כ-List של Map.
//   • truthiness — JS `e.payments || []` מחליף null/undefined ב-[]; ב-Dart `?? const []`
//     (מפתח-חסר ⇒ null ⇒ רשימה-ריקה). כך `paidOf({})` = 0.
//   • Number.isFinite — **לא-מקדם** (ללא coercion): רק num סופי נספר; NaN/∞/לא-מספר ⇒ 0.
//     JS `Number.isFinite(NaN)`=false ⇒ Dart `amount is num && amount.isFinite`.
//   • אין locale/פורמט/getMonth מעורבים באטום זה.
//   • מוטביליות — הצטבר var-מקומי (מקביל ל-accumulator של reduce, התחלה 0).
//
// קלט:  e — ישות עם payments[] (Map?, מפתח 'payments' אופציונלי). פלט: num ≥ 0.

/// סכום-ששולם על שיבוץ: חיבור כל p['amount'] הסופיים; ערך לא-חוקי (NaN/∞/לא-מספר) נספר 0.
num paidOf(Map? e) {
  final payments = (e?['payments'] as List?) ?? const [];
  num sum = 0;
  for (final p in payments) {
    final amount = (p as Map)['amount'];
    if (amount is num && amount.isFinite) sum += amount;
  }
  return sum;
}
