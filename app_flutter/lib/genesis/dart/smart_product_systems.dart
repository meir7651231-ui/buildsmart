// ⚛️ אטום-Dart (דרגת-חוזה) · smartProductSystems
// מוצא: buildsmart/app_flutter/lib/logic/system_division.dart:101-117 (חוק-4 —
//        התנהגות זהה, לא-משופרת; הקובץ אינו עוד ב-checkout — אומת מול
//        git show claude/align-main, זהה-ביט לטיוטה).
// תפקיד: מערכות-המים של מוצר עץ-חכם — נגזרות מ-sku-י-המותגים שלו במיפוי-חזרה
//        לקטלוג. קבוצה ריקה = אף sku לא נפתר ⇒ system-agnostic במורד-הזרם
//        (מוצג בשתי-המערכות — לא מסתירים על-חוסר-נתונים).
// טוהר / שקעים (חוק-3 — כל קריאת-שכן הפכה לפרמטר):
//   • `sp.brands` (מקור:103, שימש רק ל-`b.sku`) ⇒ הורם ל-`brandSkus`.
//   • `catalogRepo().allProducts()` (מקור:106, דאטה-לא-מוזרקת) ⇒ שקע `allProducts`
//     — במקור נקרא פר-מותג אך טהור מעל קטלוג-const ⇒ רשימה-מוזרקת זהת-התנהגות.
//   • `p.sku` (מקור:107) ⇒ שקע-ריאדר `skuOf`.
//   • `productDivisionSystems(p)` (מקור:108 — אטום-שכן שכבר קודם) ⇒ שקע
//     `divisionSystemsOf`.
//   גנרי מעל `P`/`S` (במקור LipskeyCatalogProduct/WaterSystem) ⇒ אפס טיפוסי-שכן.
//   אין import כלל (dart:core בלבד).
//
// קלט:  brandSkus — sku-י המותגים של המוצר (‏String? — null מדולג, מקור:104-105) ·
//       allProducts — הקטלוג · skuOf — sku של מוצר-קטלוג · divisionSystemsOf —
//       מערכות-החלוקה של מוצר-קטלוג.
// פלט:  Set<S> — איחוד מערכות המוצר-הראשון-התואם פר-sku; ריק כשאין פתרון.

/// Smart-tree products carry no spec of their own, so their system is inferred
/// from their brand SKUs mapped back to the catalog. An empty result = no
/// resolvable SKU → treated as system-agnostic downstream (shown in both)
/// rather than hidden on a guess (R8 — no invention).
/// Verbatim behaviour of system_division.dart:101-117: per SKU, the FIRST
/// matching catalog product wins (`break`), and results union into one set.
Set<S> smartProductSystems<P, S>(
  Iterable<String?> brandSkus, {
  required List<P> allProducts,
  required String Function(P) skuOf,
  required Set<S> Function(P) divisionSystemsOf,
}) {
  final out = <S>{};
  for (final sku in brandSkus) {
    if (sku == null) continue;
    for (final p in allProducts) {
      if (skuOf(p) == sku) {
        out.addAll(divisionSystemsOf(p));
        break;
      }
    }
  }
  return out;
}
