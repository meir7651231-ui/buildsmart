// ⚛️ אטום-Dart (דרגת-חוזה) · bomRows
// מוצא: buildsmart/app_flutter/lib/features/fittings/intel/line_bom.dart:40-45
//        (חוק-4 — התנהגות זהה).
// טוהר: פונקציית top-level ציבורית עצמאית, אפס import (רק dart:core).
//
// אחים שהוטבעו (טיפוסי-שכן קטנים, כלל-1):
//   • `BomRow` — verbatim מ-line_bom.dart:16 (sku · nameHe · qty + constructor).
//   • `LipskeyCatalogProduct` — מ-lipskey_catalog.dart:4, רק השדות הנקראים
//        (sku · nameHe).
//   • `InstallationPlan` — מ-install_engine.dart:939, רק מה שהפונקציה קוראת:
//        השדות items · quantities והמתודה qtyOf (שגופה `quantities[sku] ?? 1`
//        אינו קורא סמלים חיצוניים — הוטבע verbatim, כלל-1). שאר השדות/מתודות
//        (gaps · zones · compliance …) הושמטו.
//
// קלט:  plan — תוכנית-התקנה.
// פלט:  שורות ה-BOM — פר-רכיב בסדר-הופעה, עם כמותו מ-qtyOf.

/// טיפוס-שכן מוטבע (line_bom.dart:16) — verbatim.
class BomRow {
  const BomRow(this.sku, this.nameHe, this.qty);
  final String sku;
  final String nameHe;
  final int qty;
}

/// טיפוס-שכן מוטבע (lipskey_catalog.dart:4) — רק השדות הנקראים.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({required this.sku, required this.nameHe});
  final String sku;
  final String nameHe;
}

/// טיפוס-שכן מוטבע (install_engine.dart:939) — רק items · quantities · qtyOf.
class InstallationPlan {
  const InstallationPlan(this.items, this.quantities);
  final List<LipskeyCatalogProduct> items;
  final Map<String, int> quantities;
  int qtyOf(String sku) => quantities[sku] ?? 1;
}

/// שורות ה-BOM של [plan] — פר-רכיב (בסדר-הופעה) עם כמותו (`qtyOf`). טהור.
List<BomRow> bomRows(InstallationPlan plan) => [
      for (final p in plan.items) BomRow(p.sku, p.nameHe, plan.qtyOf(p.sku)),
    ];
