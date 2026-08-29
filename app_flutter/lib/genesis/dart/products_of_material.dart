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
const Map<String, List<String>> kMaterials = <String, List<String>>{
  'נחושת': ['נחושת', 'פליז'], // OWNER-REVIEW
  'PPR': ['PPR'], // OWNER-REVIEW
  'HDPE': ['HDPE', 'פוליאתילן'], // OWNER-REVIEW
  'רב-שכבתי': ['רב שכבתי', 'רב-שכבתי'], // OWNER-REVIEW
  'פקס': ['פקסגול', 'פקס', 'PEX'], // OWNER-REVIEW
  'נירוסטה': ['נירוסטה'], // OWNER-REVIEW
  'פלדה': ['פלדה'], // OWNER-REVIEW
};

/// דריסת-חומר לכל-הקטגוריה — fallback אחרי היוריסטיקת-המונחים (מוסיפה, לא-משנה).
const Map<String, String> kCategoryMaterial = <String, String>{
  'ברזי ניל': 'נחושת',
  'ברזי מעבר': 'נחושת',
  'ברזי קיר': 'נחושת',
  'ברזי כיור': 'נחושת',
  'מחלקים': 'נחושת',
  'נקודות מים': 'נחושת',
};

/// The material of [p]: the FIRST [kMaterials] key whose any term is a substring
/// of the `'<nameHe> <categoryHe>'` text (so [kMaterials] order is the precedence);
/// else the [kCategoryMaterial] whole-category override for its `categoryHe`; else
/// null. PURE & deterministic.
String? materialOf(LipskeyCatalogProduct p) {
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
  String material,
) =>
    pool.where((p) => materialOf(p) == material).toList();
