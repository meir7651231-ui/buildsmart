// ⚛️ אטום-Dart (דרגת-חוזה) · portCountFor
// מוצא: buildsmart/app_flutter/lib/data/polyroll_specs.dart:41-51 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_portCountFor` — הוצא לחוזה כ-top-level ציבורי.
//
// אח שהוטבע (טיפוס-שכן, כלל-1): `LipskeyCatalogProduct` — מ-lipskey_catalog.dart,
//        רק השדה `productType` (היחיד שהפונקציה קוראת).
//
// קלט:  p — מוצר-קטלוג.
// פלט:  מספר פורטי-החיבור (צינור=2, פקק=1, מסעף/רוכב=3, ברירת-מחדל 2).

/// טיפוס-שכן מוטבע (lipskey_catalog.dart) — רק `productType`.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({this.productType});
  final String? productType;
}

/// מספר פורטי-החיבור של [p] (= מספר קצות-שקע). טהור.
int portCountFor(LipskeyCatalogProduct p, {required String Function(String) term}) {
  final t = p.productType ?? '';
  if (t.contains(term('tsynvr'))) return 2;
  if (t.contains(term('pkk'))) return 1;
  if (t.contains(term('msaf')) || t.contains(term('rvkb'))) return 3;
  if (t.contains(term('avmgh'))) return 2;
  return 2; // elbow / coupler / adapter / valve / collar default
}
