// ⚛️ אטום-Dart · productsOfMaterial
// מוצא: buildsmart/app_flutter/lib/features/word_finder/material_lexicon.dart:139-144 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: `LipskeyCatalogProduct` הוטבע בצורת-מינימום — נוגעים רק ב-nameHe/categoryHe;
//        ה-socket `materialOf` (:81-92) הוטבע verbatim יחד עם הקבועים `kMaterials` (:47)
//        ו-`kCategoryMaterial` (:68) — כך שהאטום עומד בפני-עצמו (לא סוכר-שקע).

/// צורת-מינימום של מוצר-הקטלוג — נוגעים רק ב-nameHe/categoryHe.
class LipskeyCatalogProduct {
  final String nameHe;
  final String categoryHe;
  const LipskeyCatalogProduct({required this.nameHe, required this.categoryHe});
}

/// חומר → רשימת מונחי-הזיהוי שלו. סדר-המפתחות = סדר-הקדימות.

/// דריסת-חומר לכל-הקטגוריה — fallback אחרי היוריסטיקת-המונחים (מוסיפה, לא-משנה).

/// The material of [p]: the FIRST [kMaterials] key whose any term is a substring
/// of the `'<nameHe> <categoryHe>'` text (so [kMaterials] order is the precedence);
/// else the [kCategoryMaterial] whole-category override for its `categoryHe`; else
/// null. PURE & deterministic.
String? materialOf(LipskeyCatalogProduct p, {required Map<String, List<String>> kMaterials, required Map<String, String> kCategoryMaterial}) {
  final haystack = '${p.nameHe} ${p.categoryHe}';
  for (final entry in kMaterials.entries) {
    for (final term in entry.value) {
      if (haystack.contains(term)) return entry.key;
    }
  }
  return kCategoryMaterial[p.categoryHe];
}

/// Every product in [pool] whose [materialOf] equals [material], in pool order.
/// PURE & deterministic.
List<LipskeyCatalogProduct> productsOfMaterial(
  List<LipskeyCatalogProduct> pool,
  String material, {required Map<String, List<String>> kMaterials, required Map<String, String> kCategoryMaterial}) =>
    pool.where((p) => materialOf(p, kMaterials: kMaterials, kCategoryMaterial: kCategoryMaterial) == material).toList();
