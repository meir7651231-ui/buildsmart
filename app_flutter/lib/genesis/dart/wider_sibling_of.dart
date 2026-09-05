// ⚛️ אטום-Dart (דרגת-חוזה) · widerSiblingOf
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:271-311
//        (‏widerSiblingOf; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר (חוק-1): פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//
// שקעים שהוזרקו (קריאה-לשכן / שדה-גלובלי ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • kCatalogProducts (pressure_drop.dart:288) — הקטלוג-המאוחד ⇒ שקע `catalog: List<P>`.
//   • חישוב הקוטר-המינימלי של מוצר (pressure_drop.dart:275-281 עבור p · :297-302 עבור q,
//     דרך kVerifiedSpecs[sku]?.ends + _boreMeters) ⇒ שקע-יחיד `minBoreOf(P) → double?`
//     (זהו האטום min_bore_of המולחם ל-boreMeters; הקופסה מחווטת). null במקור = spec==null
//     או אף-קצה-לא-פענח; במקור שתי הבדיקות (:272 spec==null ⇒ null · :281 myMin==null ⇒ null)
//     מתמזגות ל-`minBoreOf(p)==null ⇒ null` — התנהגות זהה. לצד-q: :293 qSpec==null ⇒ continue
//     · :303 qMin==null ⇒ continue מתמזגות ל-`minBoreOf(q)==null ⇒ continue`.
//   • שדות-המחלקה LipskeyCatalogProduct (sku/productType/brand/categoryHe) ⇒ שקעי-שדה
//     skuOf/productTypeOf/brandOf/categoryHeOf; טיפוס-המוצר מופשט לגנריקה <P>. מקור: P≡LipskeyCatalogProduct.
//
// קלט:  p              — המוצר שמחפשים לו "אח רחב-יותר" (P).
//       catalog        — שקע: רשימת-המוצרים לסריקה (List<P>, מקור=kCatalogProducts).
//       skuOf          — שקע: P → sku (String).
//       productTypeOf  — שקע: P → סוג-מוצר (String?, ‏nullable).
//       brandOf        — שקע: P → מותג (String).
//       categoryHeOf   — שקע: P → קטגוריה-עברית (String).
//       minBoreOf      — שקע: P → הקוטר-הפנימי-המינימלי במטרים (double?), null אם אין נתון.
// פלט:  P? — האח ה"רחב-הקטן-ביותר-שעדיין-עוזר" (אותו סוג/מותג/קטגוריה, קוטר גדול-יותר על
//       קצה אחד לפחות), או null כשאין ל-p קוטר-ניתן-לפענוח / אין מועמד רחב-יותר.

/// Find a "wider sibling" of [p] — same productType + same brand + same
/// category, but with a larger nominal bore on at least one end. Used to
/// suggest "swap the bottleneck for a wider one" without leaving the catalog.
P? widerSiblingOf<P>(
  P p, {
  required List<P> catalog,
  required String Function(P) skuOf,
  required String? Function(P) productTypeOf,
  required String Function(P) brandOf,
  required String Function(P) categoryHeOf,
  required double? Function(P) minBoreOf,
}) {
  // Smallest bore mm on this product — the bottleneck end. (מקור:272-281)
  final myMin = minBoreOf(p);
  if (myMin == null) return null;

  P? best;
  double? bestBore;
  // Unified catalog (Lipskey + Polyroll) so PPR products can also surface
  // a wider-bore upgrade. The brand/category filters below ensure we only
  // suggest same-vendor same-family upgrades — no cross-vendor noise.
  for (final q in catalog) {
    if (skuOf(q) == skuOf(p)) continue;
    if (productTypeOf(q) != productTypeOf(p)) continue;
    if (brandOf(q) != brandOf(p)) continue;
    if (categoryHeOf(q) != categoryHeOf(p)) continue;
    // require at least one end same-DN-or-larger than p's bottleneck end
    final qMin = minBoreOf(q);
    if (qMin == null) continue;
    if (qMin <= myMin) continue; // not wider — skip
    if (bestBore == null || qMin < bestBore) {
      // pick the SMALLEST upgrade that still helps, not the giant one
      best = q;
      bestBore = qMin;
    }
  }
  return best;
}
