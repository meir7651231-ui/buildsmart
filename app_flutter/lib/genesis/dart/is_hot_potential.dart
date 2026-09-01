// ⚛️ אטום-Dart (דרגת-חוזה) · isHotPotential
// מוצא: buildsmart/app_flutter/lib/data/related_info.dart:823-837 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core).
// פרטי-במקור: `_isHotPotential` — הוצא לחוזה כ-top-level ציבורי.
//
// אח שהוטבע (טיפוס-שכן, כלל-1): `LipskeyCatalogProduct` — מ-lipskey_catalog.dart,
//        רק השדה `categoryHe` (היחיד שהפונקציה קוראת).
//
// קלט:  p — מוצר-קטלוג.
// פלט:  true אם הקטגוריה היא אחת מ-10 קטגוריות ה"פוטנציאל-חם".

/// טיפוס-שכן מוטבע (lipskey_catalog.dart) — רק `categoryHe`.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({required this.categoryHe});
  final String categoryHe;
}

/// True אם [p] שייך לקטגוריית פוטנציאל-חם. טהור.
bool isHotPotential(LipskeyCatalogProduct p, {required String Function(String) term}) {
  final cat = p.categoryHe;
  return cat == term('mchlkym') ||
      cat == term('rashy-mklcht') ||
      cat == term('markvt-ambtyh') ||
      cat == term('arkvt-rchtsh') ||
      cat == term('brzy-ambtyh') ||
      cat == term('brzy-mklcht') ||
      cat == term('brzy-mtbch') ||
      cat == term('brzy-kyr') ||
      cat == term('brzy-kyvr') ||
      cat == term('markvt-shtyph');
}
