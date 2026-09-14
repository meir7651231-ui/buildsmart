// ⚛️ אטום-Dart (דרגת-חוזה) · filterByImage
// מוצא: buildsmart/app_flutter/lib/screens/catalog_screen.dart:505 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): LipskeyCatalogProduct ← ../dart-data/k_lipskey_catalog-table.dart.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

import '../dart-data/k_lipskey_catalog-table.dart';

/// Pure: keep only products that have an image when [imageOnly] is set.
List<LipskeyCatalogProduct> filterByImage(
    List<LipskeyCatalogProduct> list, bool imageOnly) {
  if (!imageOnly) return list;
  return list.where((p) => p.imageAsset != null).toList();
}
