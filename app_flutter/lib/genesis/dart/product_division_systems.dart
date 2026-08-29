// ⚛️ אטום-Dart (דרגת-חוזה) · productDivisionSystems
// מוצא: buildsmart/app_flutter/lib/logic/system_division.dart:22-27 (‏productDivisionSystems
//        בראש-הקטע; חוק-4 — התנהגות זהה, לא-משופרת).
// תפקיד: לאיזו מערכת-מים שייך מוצר — אספקה / ניקוז. אם ה-VerifiedSpec של המק"ט
//        מגדיר מערכות-קצה לא-ריקות ⇒ הן קובעות; אחרת המותג מכריע (פולירול=אספקה,
//        כל השאר=ניקוז).
// טוהר: פונקציית top-level עצמאית.
//   • השכן `kVerifiedSpecs[p.sku]?.endSystems` (טבלת-const חיצונית) הורם לשקע-ערך
//     `verifiedEndSystems` (חוק-3) — כך נשמט טיפוס-השכן `LipskeyCatalogProduct`
//     (‏p שימש רק ל-`.sku` (לשקע) ול-`.brand` (הורם לפרמטר `brand`)).
//   • הטיפוס-השכן-הקטן `WaterSystem` הוטבע inline. ⚠️ ערכיו אינם בטיוטה זו;
//     הוסקו כ-`{ supply, drainage }` מ-**ראיית-אחות מפורשת**: הטיוטה
//     plumbing_systems (‏plumbing_trade_seed.dart) בונה בדיוק 2 מערכות
//     ("אספקה"/"ניקוז") ומתעדת "These mirror [WaterSystem]"; והטיוטה הזו עצמה
//     נוגעת אך-ורק ב-supply/drainage. תועד (חוק: enum-חסר ⇒ הסק+תעד).
//   אין import-אטום (dart:core בלבד).

/// מערכת-מים (הוטבע inline; ערכים הוסקו — ראה כותרת). אספקה בלחץ / ניקוז בכבידה.
enum WaterSystem { supply, drainage }

/// Which water system(s) a product divides into. Verbatim behaviour of
/// system_division.dart:22-27, with the `kVerifiedSpecs[p.sku]?.endSystems`
/// lookup lifted to the `verifiedEndSystems` socket and `p.brand` to `brand`.
/// Verified end-systems win when present & non-empty; else brand decides
/// (פולירול ⇒ supply, otherwise ⇒ drainage — R8: don't guess).
Set<WaterSystem> productDivisionSystems(
  String brand, {required String Function(String) term, 
  required Set<WaterSystem>? verifiedEndSystems,
}) {
  final ends = verifiedEndSystems;
  if (ends != null && ends.isNotEmpty) return ends;
  if (brand == term('pvlyrvl')) return const {WaterSystem.supply};
  return const {WaterSystem.drainage};
}
