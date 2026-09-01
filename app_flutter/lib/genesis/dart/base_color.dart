// ⚛️ אטום-Dart · baseColor
// מוצא: buildsmart/app_flutter/lib/screens/lipskey_products_screen.dart:796-800
//        (‏_baseColor; חוק-2 — verbatim, לא-משופר).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core — RegExp/split).
//
// שקעים/הטבעות (חוק-3, דיבר-3):
//   • טבלת-האוצר kLipskeyColors (data/lipskey_catalog.dart:484-487) — **מוטבעת
//     verbatim** כאן, כי היא מילון-הסיווג של הצבע (לוגיקת-הפירוק עצמה), לא
//     קטלוג-ארגון מתחלף. ממנה נגזר `kColorWords` באותה נוסחה כמו במקור
//     (lipskey_products_screen.dart:1776-1778: תת-מילים באורך ≥2).
//   • `kColorModifiers` (lipskey_products_screen.dart:1783) — מוטבע verbatim.
//   • המחלקה LipskeyCatalogProduct קורסת ל-`ColorProduct` — מחזיק-קלט טהור,
//     רק השדה `nameHe` ש-_baseColor קורא.
//
// קלט:  product — ColorProduct (nameHe).
// פלט:  String — מילות-הצבע-הבסיסי (צבע שאינו finish-modifier), מחוברות ברווח; '' כשאין.

/// מחזיק-קלט טהור: רק השדה ש-baseColor קורא (lipskey_products_screen.dart:797).
class ColorProduct {
  final String nameHe;
  const ColorProduct({required this.nameHe});
}

/// טבלת-הצבעים המקורית — verbatim (data/lipskey_catalog.dart:484-487).

/// כל תת-מילה (אורך ≥2) שמופיעה באחת מרשומות-הצבע — verbatim מ-
/// lipskey_products_screen.dart:1776-1778 (`kColorWords`).

/// מילות finish/modifier — verbatim (lipskey_products_screen.dart:1783).

/// מילת-הצבע-הבסיסי של [product] — תת-מילות-צבע שאינן modifiers.
/// התנהגות verbatim של lipskey_products_screen.dart:796-800.
String baseColor(ColorProduct product, {required Set<String> kColorWords, required Set<String> kColorModifiers}) => product.nameHe
    .split(RegExp(r'\s+'))
    .where((w) => kColorWords.contains(w) && !kColorModifiers.contains(w))
    .join(' ');
