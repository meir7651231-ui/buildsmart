// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitDaysSince — ימים בין ISO ליום-ייחוס.
// מוצא: maor/src/components/supporters/cockpit.ts:42 (daysSince) · המקור: new/atoms/cockpit-days-since.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//
// הערות-המרה (JS→Dart):
//  • JS `!iso` (ריק) ⇒ Infinity. ב-Dart: iso.isEmpty ⇒ double.infinity.
//  • JS `new Date(iso+'T12:00:00')` (זמן-מקומי, ללא Z) ⇒ Dart DateTime.tryParse (מקומי);
//    Invalid Date/NaN ⇒ null ⇒ double.infinity (מקביל ל-Number.isNaN guard).
//  • Math.floor((now-t)/MS_DAY) ⇒ (…).floor() (int). ערך שלם זהה; שלילי floor זהה.
//  • הפלט num: Infinity=double.infinity · סופי=int. (JSON.stringify(Infinity)="null" — ארטיפקט-סריאליזציה; הערך זהה.)

/// Whole days between an ISO date and the reference day (positive = past).
/// double.infinity for empty/invalid input. Verbatim port of cockpit-days-since.mjs.
num cockpitDaysSince(String iso, String todayIso) {
  const msDay = 86400000;
  if (iso.isEmpty) return double.infinity;
  final t = DateTime.tryParse('${iso}T12:00:00');
  final now = DateTime.tryParse('${todayIso}T12:00:00');
  if (t == null || now == null) return double.infinity;
  return ((now.millisecondsSinceEpoch - t.millisecondsSinceEpoch) / msDay).floor();
}
