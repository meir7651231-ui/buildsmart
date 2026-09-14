// ⚛️ אטום-Dart (דרגת-חוזה) · safetyKitItems
// מוצא: buildsmart/app_flutter/lib/data/related_info.dart:1453 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): LipskeyCatalogProduct ← ../dart-data/k_lipskey_catalog-table.dart.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

import '../dart-data/k_lipskey_catalog-table.dart';

/// Pure list-diff by SKU: what's in [withCompliance] but not in [withoutCompliance].
/// Used to surface the items the engine's auto-compliance inserted into the
/// line (correct-by-construction — never invents a SKU). Order-preserving.
List<LipskeyCatalogProduct> safetyKitItems(
    List<LipskeyCatalogProduct> withCompliance,
    List<LipskeyCatalogProduct> withoutCompliance) {
  final base = withoutCompliance.map((p) => p.sku).toSet();
  return [for (final p in withCompliance) if (!base.contains(p.sku)) p];
}
