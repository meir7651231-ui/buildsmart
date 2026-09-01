// ⚛️ אטום-Dart (דרגת-חוזה) · catNodeProductCount
// תפקיד: סופר כמה מוצרים (מתוך רשימה) שייכים לאחת מקטגוריות-העלים שמתחת ל-CatalogNode.
// מוצא: buildsmart/app_flutter/lib/logic/category_division.dart:110-126 (‏catNodeProductCount +
//       ה-closure הפנימי collect; חוק-4). הטיוטה חולקה לשני אטומים; כאן שוחזרה הפונקציה המלאה.
// אחים: ה-closure הפנימי `collect` הוטבע inline verbatim (עוזר-מקומי, שייך לפונקציה).
//       `catalogRepo().allProducts()` (מאגר-מוצרים חיצוני) קופל לשקע `allProducts`
//       (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע). טיפוסי CatalogNode/Product הוטבעו inline.
// טוהר: dart:core בלבד.

/// אוסף את lipskeyCategory של כל עלה מתחת ל-[node], ומחזיר כמה מ-[allProducts]
/// יש להם categoryHe בקבוצת-הקטגוריות הזו. verbatim category_division.dart:110-126.
int catNodeProductCount(
  CatalogNode node, {
  required Iterable<CatProduct> allProducts,
}) {
  final cats = <String>{};
  void collect(CatalogNode n) {
    if (n.isLeaf) {
      final l = n.lipskeyCategory;
      if (l != null) cats.add(l);
    } else {
      for (final c in n.children) {
        collect(c);
      }
    }
  }

  collect(node);
  return allProducts.where((p) => cats.contains(p.categoryHe)).length;
}

// — טיפוסי-שכן מוטבעים (השדות הנקראים ע"י האטום בלבד) —
class CatalogNode {
  const CatalogNode({
    required this.isLeaf,
    this.lipskeyCategory,
    this.children = const [],
  });

  final bool isLeaf;
  final String? lipskeyCategory;
  final List<CatalogNode> children;
}

class CatProduct {
  const CatProduct({required this.categoryHe});
  final String categoryHe;
}
