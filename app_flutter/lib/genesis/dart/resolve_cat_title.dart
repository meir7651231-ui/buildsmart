// ⚛️ אטום-Dart (דרגת-חוזה) · resolveCatTitle
// תפקיד: פותר כותרת-מדור לצומת-עץ-קטלוג — צומת אמיתי (title/lipskeyCategory תואמים,
//        pre-order ראשון-מנצח), ואם אין — עלה-סינתטי כשקיים מוצר עם categoryHe==title, אחרת null.
// מוצא: buildsmart/app_flutter/lib/logic/category_division.dart:84-107 (‏resolveCatTitle +
//       ה-closure הפנימי walk; ענף origin/claude/whats-happening-LyY9G; חוק-4).
// הכרעות-קידום:
//   • `kCatalogTree` (דאטה-קטלוג גלובלית, data/catalog_tree.dart) קופל לשקע `tree`
//     (חוק-1/חוק-3: דאטה-לא-מוזרקת ⇒ פרמטר-שקע; אפס דאטה צרובה במנוע).
//   • `catalogRepo().allProducts()` (מאגר-שכן) קופל לשקע `allProducts` — אותה מוסכמה
//     כמו האח cat_node_product_count (‏CatProduct{categoryHe} מוטבע).
//   • טיפוס CatalogNode הוטבע inline מינימלי (catalog_tree.dart:10-34 — רק השדות
//     שהאטום קורא/בונה: id/title/emoji/children/lipskeyCategory + isLeaf).
//   • ה-closure `walk` הוטבע verbatim (עוזר-מקומי, שייך לפונקציה).
// טוהר: dart:core בלבד.

/// פותר [title] לצומת-קטלוג: סריקת pre-order על [tree] — התאמה על `n.title` או
/// `n.lipskeyCategory` (הראשון מנצח); אין צומת אך יש מוצר עם `categoryHe == title`
/// ⇒ עלה-סינתטי `catdept.<title>` עם אימוג'י 📦; אחרת null.
/// verbatim category_division.dart:84-107 (השכנים קופלו לשקעים).
CatalogNode? resolveCatTitle(
  String title, {
  required List<CatalogNode> tree,
  required Iterable<CatProduct> allProducts,
}) {
  CatalogNode? hit;
  void walk(CatalogNode n) {
    if (hit != null) return;
    if (n.title == title || n.lipskeyCategory == title) {
      hit = n;
      return;
    }
    for (final c in n.children) {
      walk(c);
    }
  }

  for (final t in tree) {
    walk(t);
  }
  if (hit != null) return hit;
  // Bare categoryHe with no node of its own → synthetic leaf.
  if (allProducts.any((p) => p.categoryHe == title)) {
    return CatalogNode(
        id: 'catdept.$title', title: title, emoji: '📦', lipskeyCategory: title);
  }
  return null;
}

// — טיפוסי-שכן מוטבעים (השדות הנקראים/נבנים ע"י האטום בלבד; catalog_tree.dart:10-34) —
class CatalogNode {
  const CatalogNode({
    required this.id,
    required this.title,
    required this.emoji,
    this.children = const [],
    this.lipskeyCategory,
  });

  final String id;
  final String title;
  final String emoji;
  final List<CatalogNode> children;
  final String? lipskeyCategory;

  bool get isLeaf => children.isEmpty;
}

class CatProduct {
  const CatProduct({required this.categoryHe});
  final String categoryHe;
}
