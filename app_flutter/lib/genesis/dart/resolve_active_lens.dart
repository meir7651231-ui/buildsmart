// ⚛️ אטום-Dart (דרגת-חוזה) · resolveActiveLens
// מוצא: buildsmart/app_flutter/lib/state/catalog_lens_state.dart:19 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): CatalogLens.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__lens_selector_row — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): סדר · לפי

/// The three organising axes for a product list.
enum CatalogLens { category, variant, smartTree }

/// Resolve the lens to actually USE for [available] lenses: the selected one if
/// it's still available for the current set, else the first available
/// (category is always available, so this never returns something unusable).
CatalogLens resolveActiveLens(
  CatalogLens selected,
  List<CatalogLens> available,
) {
  if (available.contains(selected)) return selected;
  return available.isEmpty ? CatalogLens.category : available.first;
}
