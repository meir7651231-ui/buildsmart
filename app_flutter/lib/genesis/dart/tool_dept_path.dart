// ⚛️ אטום-Dart (דרגת-חוזה) · toolDeptPath
// מוצא: buildsmart/app_flutter/lib/screens/departments_screen.dart:33 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): CatalogNode.

/// Catalog drill-down tree. Three logical levels:
///   L1 — main category (e.g. "ניקוז וצנרת")
///   L2 — sub-category (e.g. "סיפונים")
///   L3 — sub-sub-category / leaf (e.g. "מחסומי רצפה")
/// Leaves carry [brandIds] + an optional [lipskeyCategory] that maps to
/// Lipskey's own categoryHe field (so we can pull products from kLipskeyCatalog).
class CatalogNode {
  const CatalogNode({
    required this.id,
    required this.title,
    required this.emoji,
    this.children = const [],
    this.brandIds = const [],
    this.lipskeyCategory,
    this.smartKey,
  });

  final String id;
  final String title;
  final String emoji;
  final List<CatalogNode> children;
  final List<String> brandIds;
  final String? lipskeyCategory;

  /// Key of the matching [SmartProduct]. When set, drilling to this leaf opens
  /// the unified "ברז לכיור" sheet (brand picker + accessories + cart) instead
  /// of the raw brand-products list.
  final String? smartKey;

  bool get isLeaf => children.isEmpty;
}

/// Build a drill path for a tool department straight from its leaf `categoryHe`
/// names — a synthetic node tree, so the department gathers categories that live
/// in different branches (e.g. כלי עבודה + חותך צינורות). One category drills
/// straight to its products; several show a row each, then drill to products.
/// `_TreeDrill` only needs `lipskeyCategory` (leaf) / `children` (branch).
List<CatalogNode> toolDeptPath(String name, List<String> cats) {
  CatalogNode leaf(String c) =>
      CatalogNode(id: 'dept-cat.$c', title: c, emoji: '🧰', lipskeyCategory: c);
  if (cats.length == 1) return [leaf(cats.first)];
  return [
    CatalogNode(
      id: 'dept.$name',
      title: name,
      emoji: '🧰',
      children: [for (final c in cats) leaf(c)],
    ),
  ];
}
