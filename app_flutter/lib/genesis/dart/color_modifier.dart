// ⚛️ אטום-Dart · colorModifier
// מוצא: buildsmart/app_flutter/lib/screens/lipskey_products_screen.dart:802-808
//        (‏_colorModifier; חוק-2 — verbatim, לא-משופר).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core — RegExp/split).
//
// שקעים/הטבעות (חוק-3, דיבר-3):
//   • `kColorModifiers` (lipskey_products_screen.dart:1783) — מוטבע verbatim;
//     מילון קבוע ({'מוברש','מט'}), לא קטלוג מתחלף.
//   • המחלקה LipskeyCatalogProduct קורסת ל-`ColorProduct` — מחזיק-קלט טהור,
//     רק השדה `nameHe` ש-_colorModifier קורא.
//
// קלט:  product — ColorProduct (nameHe).
// פלט:  String? — מילת-ה-finish ("מוברש"/"מט") הראשונה בשם, או null אם אין.

/// מחזיק-קלט טהור: רק השדה ש-colorModifier קורא (lipskey_products_screen.dart:803).
class ColorProduct {
  final String nameHe;
  const ColorProduct({required this.nameHe});
}

/// מילות finish/modifier — verbatim (lipskey_products_screen.dart:1783).

/// מילת-ה-finish ("מוברש"/"מט") של [product], או null.
/// התנהגות verbatim של lipskey_products_screen.dart:802-808.
String? colorModifier(ColorProduct product, {required Set<String> kColorModifiers}) {
  final w = product.nameHe
      .split(RegExp(r'\s+'))
      .firstWhere((w) => kColorModifiers.contains(w), orElse: () => '');
  return w.isEmpty ? null : w;
}
