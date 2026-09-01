// ⚛️ אטום-Dart (דרגת-חוזה) · reaches
// מוצא: buildsmart/app_flutter/lib/features/ring_dive/plain_dive.dart:140-146 (חצב-בינה · חוק-3/4).
// שקע: plainProductsFor ← השכן `plainProductsFor(n)` — מוצרי-הקטלוג שצומת מגיע אליהם.
// מוטבע verbatim (טיפוס-נתונים מקומי, כלל-1): PlainNode (plain_dive.dart:42).
// טיפוס-האיבר של הרשימה (LipskeyCatalogProduct) לא-נגוע ⇒ נשאר Object? (הגוף רק .isNotEmpty).
// reaches — האם לצומת יש מוצר-כלשהו (true ⇒ ניתן-להצגה).

class PlainNode {
  const PlainNode({
    required this.superCat,
    required this.classification,
    required this.technical,
    required this.slang,
    required this.english,
    required this.usage,
    this.categoriesExact,
  });

  final String superCat; // ring 1
  final String classification; // ring 2
  final String technical; // ring 3 (the query that reaches products)
  final String slang; // ring 3 label — the everyday word
  final String english;
  final String usage; // "what it does / where it goes"

  /// When set, this leaf reaches products by EXACT catalog category membership
  /// (p.categoryHe ∈ categoriesExact) instead of the [technical] search — used by
  /// the coverage nodes (curated + auto-fallback) so every category is reachable.
  /// A list because several catalog categories can share one plain word (all the
  /// drain-pipe categories → "צינור ניקוז").
  final List<String>? categoriesExact;
}

bool reaches(PlainNode n,
        {required List<Object?> Function(PlainNode) plainProductsFor}) =>
    plainProductsFor(n).isNotEmpty;
