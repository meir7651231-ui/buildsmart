// ⚛️ אטום-Dart (דרגת-חוזה) · isManifold
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/product_config_schema.dart:310-314
//        (הפונקציה הפרטית `_isManifold` — חוק-4, התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//
// אח שהוטבע (טיפוס-שכן קטן, כלל-1): `LipskeyCatalogProduct` — טיפוס-הקלט. הוטבע
//        מ-lib/data/lipskey_catalog.dart:4 עם רק השדה שהפונקציה קוראת (nameHe);
//        שאר השדות/constructor הושמטו (כלל-1).
// פרטי-במקור: `_isManifold` היה פרטי — הוצא לחוזה כ-top-level ציבורי `isManifold`.
//
// קלט:  p — מוצר-קטלוג.
// פלט:  true אם שם-המוצר מכיל 'מחלק' או 'סעפת' (זיהוי מחלק/סעפת לפי השם).

/// טיפוס-שכן מוטבע (lipskey_catalog.dart:4) — רק השדה שהפונקציה קוראת.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({required this.nameHe});
  final String nameHe;
}

/// זיהוי מחלק/סעפת לפי השם — שם-המוצר מכיל 'מחלק' או 'סעפת'.
bool isManifold(LipskeyCatalogProduct p, {required String Function(String) term}) =>
    p.nameHe.contains(term('mchlk')) || p.nameHe.contains(term('sapt'));
