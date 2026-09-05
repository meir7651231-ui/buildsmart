// ⚛️ אטום-Dart (דרגת-חוזה) · pressureFromDims
// מוצא: buildsmart/app_flutter/lib/data/polyroll_specs.dart:128-137
//        (הפונקציה הפרטית `_pressureFromDims` — חוק-4, התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//
// אח שהוטבע (טיפוס-שכן קטן, כלל-1): `LipskeyCatalogProduct` — טיפוס-הקלט. הוטבע
//        מ-lib/data/lipskey_catalog.dart:4 עם רק השדה שהפונקציה קוראת (dims).
// פרטי-במקור: `_pressureFromDims` היה פרטי — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  p — מוצר-קטלוג.
// פלט:  `PN<ערך>` כאשר dims מכיל 'PN' לא-ריק, אחרת null.

/// טיפוס-שכן מוטבע (lipskey_catalog.dart:4) — רק השדה שהפונקציה קוראת.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({this.dims});
  final Map<String, dynamic>? dims;
}

/// דירוג-הלחץ הנגזר מ-dims: `PN<ערך>` כש-'PN' קיים ולא-ריק, אחרת null.
String? pressureFromDims(LipskeyCatalogProduct p) {
  final pn = p.dims?['PN']?.toString();
  if (pn != null && pn.isNotEmpty) return 'PN$pn';
  return null;
}
