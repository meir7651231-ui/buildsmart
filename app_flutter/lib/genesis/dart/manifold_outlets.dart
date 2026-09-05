// ⚛️ אטום-Dart (דרגת-חוזה) · manifoldOutlets
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:1249-1258
//        (‏manifoldOutlets; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kVerifiedSpecs[p.sku]?.ends`  (install_engine.dart:1250-1251)
//     — המפה-הגלובלית קורסת לשקע `endSizesOf(p) → List<String>?` המחזיר את
//       **גדלי-הקצוות** בלבד (‏e.size לכל קצה), או null כשאין spec למוצר.
//       (‏האטום קורא רק את e.size; לא את e.type — לכן השקע מחזיר רשימת-גדלים).
//   • טיפוס-המוצר מופשט לגנריקה <P>; במקור P≡LipskeyCatalogProduct.
//
// התנהגות (מקור:1251-1257):
//   • אין spec, או פחות מ-3 קצוות ⇒ 0 (לא-מחלק).
//   • אחרת: סופרים כמה קצוות חולקים כל גודל; maxc = הריבוי-המרבי.
//   • maxc ≥ 2 ⇒ maxc (מספר-המוצאים הזהים); אחרת 0.
//
// קלט:  p          — המוצר (מועבר ל-endSizesOf).
//       endSizesOf — שקע: p → רשימת-גדלי-קצוות (List<String>) או null (אין spec).
// פלט:  int — מספר-המוצאים הזהים של מחלק, או 0 כשאינו מחלק.

/// How many identical outlets a manifold-type product exposes (e.g. a
/// "מחלק 1\" 4 יציאות" has four ½" outlets). 0 when the product isn't a manifold.
int manifoldOutlets<P>(
  P p, {
  required List<String>? Function(P) endSizesOf,
}) {
  final sizes = endSizesOf(p);
  if (sizes == null || sizes.length < 3) return 0;
  final counts = <String, int>{};
  for (final size in sizes) {
    counts[size] = (counts[size] ?? 0) + 1;
  }
  final maxc = counts.values.fold(0, (a, b) => a > b ? a : b);
  return maxc >= 2 ? maxc : 0;
}
