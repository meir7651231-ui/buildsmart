// ⚛️ אטום-Dart (דרגת-חוזה) · companyComplementsFor
// מוצא: buildsmart/app_flutter/lib/data/company_categories.dart:74-91 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core).
//
// אח שהוטבע (טיפוס-שכן, כלל-1): `LipskeyCatalogProduct` — מ-lipskey_catalog.dart,
//        רק `sku` + `dims` (השדות שהפונקציה קוראת).
//
// קלט:  p — המוצר; pool — היקום להיפתר-מולו.
// פלט:  המשלימים שלו (dims['מוצרים משלימים'], skus מופרד-|) מסודר, לא-ידועים נופלים.

/// טיפוס-שכן מוטבע (lipskey_catalog.dart) — רק `sku` + `dims`.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({required this.sku, this.dims});
  final String sku;
  final Map<String, dynamic>? dims;
}

/// המשלימים של [p] הנפתרים מול [pool] — שומר-סדר, לא-ידוע נופל. טהור.
List<LipskeyCatalogProduct> companyComplementsFor(
    LipskeyCatalogProduct p, List<LipskeyCatalogProduct> pool, {required String Function(String) term}) {
  final cell = p.dims?[term('mvtsrym-mshlymym')];
  if (cell is! String || cell.isEmpty) return const [];
  final out = <LipskeyCatalogProduct>[];
  for (final part in cell.split('|')) {
    final sku = part.trim();
    if (sku.isEmpty) continue;
    for (final q in pool) {
      if (q.sku == sku) {
        out.add(q);
        break; // first match wins; a miss simply contributes nothing
      }
    }
  }
  return out;
}
