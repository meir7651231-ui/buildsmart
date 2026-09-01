// ⚛️ אטום-Dart (דרגת-חוזה) · swapMatesWithNeighbours
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:255-266
//        (‏_swapMatesWithNeighbours; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר (חוק-1): פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//        השם הפרטי במקור (_swapMatesWithNeighbours) הוסר; המזהה נשאר בורג-טהור.
//
// שקעים שהוזרקו (קריאה-לשכן / שדה-גלובלי ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • kVerifiedSpecs[candidate.sku] / kVerifiedSpecs[chain[ni].sku]
//     (pressure_drop.dart:257,261) — קיום-ה-spec קורס לשקע `specExists(sku) → bool`.
//     המקור: candSpec==null ⇒ החזר false (המועמד ללא-spec = לא-בטוח); neighborSpec==null
//     ⇒ continue (שכן ללא-spec מדולג). שני ההתנהגויות נשמרות ביט-בביט.
//   • candSpec.compatibleWith(neighborSpec) (pressure_drop.dart:263) ⇒ שקע
//     `compatible(skuA, skuB) → bool`. נקרא רק כששני ה-spec-ים קיימים (זהה למקור).
//   • שדה-המחלקה LipskeyCatalogProduct.sku ⇒ שקע `skuOf(P) → String`; טיפוס-המוצר
//     מופשט לגנריקה <P> (טוהר-מוחלט, אפס תלות ב-LipskeyCatalogProduct). מקור: P≡LipskeyCatalogProduct.
//
// קלט:  chain       — שרשרת-המוצרים (List<P>).
//       idx         — אינדקס המוצר-המוחלף בשרשרת.
//       candidate   — המוצר-המועמד להחלפה (P).
//       skuOf       — שקע: P → sku (String).
//       specExists  — שקע: sku → האם קיים spec-מאומת (bool).
//       compatible  — שקע: (skuA, skuB) → האם שני ה-spec-ים תואמים פיזית (bool).
// פלט:  bool — האם המועמד עדיין מתחבר לשני השכנים (idx-1 · idx+1) של השרשרת.

/// True when [candidate] still physically mates with [chain]'s neighbours
/// of [idx] — both the product before and after. Used to verify that a
/// "wider sibling" swap won't break the chain's connectivity.
bool swapMatesWithNeighbours<P>(
  List<P> chain,
  int idx,
  P candidate, {
  required String Function(P) skuOf,
  required bool Function(String sku) specExists,
  required bool Function(String skuA, String skuB) compatible,
}) {
  final candSku = skuOf(candidate);
  if (!specExists(candSku)) return false;
  for (final ni in [idx - 1, idx + 1]) {
    if (ni < 0 || ni >= chain.length) continue;
    final nSku = skuOf(chain[ni]);
    if (!specExists(nSku)) continue;
    if (!compatible(candSku, nSku)) return false;
  }
  return true;
}
