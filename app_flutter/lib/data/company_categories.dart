// Company-catalog category derivation (import feature follow-up — owner
// 2026-07-25: the browse rows must BE the imported catalog's categories, not
// BuildSmart's const plumbing taxonomy).
//
// Pure functions over an injected product list — no reads of the live seam,
// no Flutter — so the define-less suite proves every behavior directly.
// Consumers pass `resolvedCatalogProducts` at the call site (catalog_screen's
// rows seam), gated by `companyCatalogActive`.

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/sections.dart' show Section;

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

/// The distinct DEPARTMENTS of a company catalog as grid [Section]s — the
/// open-spec column `dims['מחלקה']`, distinct non-empty values in
/// FIRST-APPEARANCE order (the company's own file order is its taxonomy;
/// never re-sorted), id 'companyDept.<name>', emoji from the first product of
/// the department (template default '📦' when the cell was left empty). When
/// NO product carries the column, falls back to [companyCategorySections] —
/// after an import the departments tab is never dead.
List<Section> companyDepartments(List<LipskeyCatalogProduct> products) {
  final out = <Section>[];
  final seen = <String>{};
  for (final p in products) {
    final dept = p.dims?['מחלקה'];
    if (dept is! String || dept.isEmpty || !seen.add(dept)) continue;
    out.add(Section(
      id: 'companyDept.$dept',
      emoji: p.categoryEmoji.isEmpty ? '📦' : p.categoryEmoji,
      title: dept,
    ));
  }
  return out.isEmpty ? companyCategorySections(products) : out;
}

/// Per-category (count, desc) map in the shape `categorySummaryProvider`
/// serves — desc keeps the tree idiom '$count מוצרים' (no invented copy).
Map<String, ({int count, String desc})> companyCategorySummaries(
  List<LipskeyCatalogProduct> products,
) {
  final counts = <String, int>{};
  for (final p in products) {
    final cat = p.categoryHe;
    if (cat.isEmpty) continue;
    counts[cat] = (counts[cat] ?? 0) + 1;
  }
  return {
    for (final e in counts.entries)
      e.key: (count: e.value, desc: '${e.value} מוצרים'),
  };
}
