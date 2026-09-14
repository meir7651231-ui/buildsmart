// ⚛️ אטום-Dart (דרגת-חוזה) · companyCategorySections
// מוצא: buildsmart/app_flutter/lib/data/company_categories.dart:18 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): LipskeyCatalogProduct ← ../dart-data/k_lipskey_catalog-table.dart.
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): Section.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

import '../dart-data/k_lipskey_catalog-table.dart';

class Section {
  const Section({
    required this.id,
    required this.emoji,
    required this.title,
    this.children = const [],
  });

  final String id;
  final String emoji;
  final String title;
  final List<Section> children;

  bool get hasChildren => children.isNotEmpty;
}

/// The distinct categories of a company catalog as browse-row [Section]s —
/// FIRST-APPEARANCE order (the company's own file order is its taxonomy;
/// never re-sorted), emoji from the first product of the category (template
/// default '📦' when the cell was left empty).
List<Section> companyCategorySections(List<LipskeyCatalogProduct> products) {
  final out = <Section>[];
  final seen = <String>{};
  for (final p in products) {
    final cat = p.categoryHe;
    if (cat.isEmpty || !seen.add(cat)) continue;
    out.add(Section(
      id: 'company.$cat',
      emoji: p.categoryEmoji.isEmpty ? '📦' : p.categoryEmoji,
      title: cat,
    ));
  }
  return out;
}
