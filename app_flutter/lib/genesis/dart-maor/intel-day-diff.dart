// ⚛️ אטום-Dart (דרגת-חוזה) · dayDiff — הפרש-ימים בין ISO ליום.
// מוצא: maor-system/src/components/supporters/intel.ts:16 (dayDiff)+MS_DAY:13 · המקור: new/atoms/intel-day-diff.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//
// הערות-המרה (JS→Dart — הנקודות שהמנוע נוטה לפספס):
//  • JS `!iso` (מחרוזת-ריקה) ⇒ Infinity. ב-Dart: iso.isEmpty ⇒ double.infinity.
//  • JS `iso.slice(0,10)` על מחרוזת קצרה-מ-10 מחזיר את כולה; ‏Dart substring(0,10) זורק —
//    ⇒ שומר: אורך<10 ⇒ המחרוזת כמות-שהיא (זהה ל-slice).
//  • JS `Date.parse('..T12:00:00')` = זמן-מקומי (ללא Z); ‏Invalid ⇒ NaN. ב-Dart:
//    DateTime.tryParse (מקומי); null ≡ NaN ⇒ double.infinity (מקביל ל-Number.isNaN).
//  • `Math.floor((b-a)/MS_DAY)` ⇒ `(…).floor()` (int). floor זהה-ביט בשני-הסימנים.
//  • הפלט num: Infinity=double.infinity · סופי=int. (JSON.stringify(Infinity)="null" — ארטיפקט-סריאליזציה בלבד.)

/// Whole days between an ISO date and a reference day (positive = past).
/// double.infinity for empty/invalid input. Verbatim port of intel-day-diff.mjs (`dayDiff`).
num dayDiff(String iso, String todayIso) {
  const msDay = 86400000;
  if (iso.isEmpty) return double.infinity;
  final a = DateTime.tryParse(
      '${iso.length < 10 ? iso : iso.substring(0, 10)}T12:00:00');
  final b = DateTime.tryParse(
      '${todayIso.length < 10 ? todayIso : todayIso.substring(0, 10)}T12:00:00');
  if (a == null || b == null) return double.infinity;
  return ((b.millisecondsSinceEpoch - a.millisecondsSinceEpoch) / msDay).floor();
}
