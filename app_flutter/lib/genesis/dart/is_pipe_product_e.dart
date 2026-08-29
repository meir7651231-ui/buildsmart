// ⚛️ אטום-Dart (דרגת-חוזה) · isPipeProductE
// תפקיד: האם המוצר הוא צינור (לפי productType) — 'צינור' / 'צנרת' / 'גמיש' / 'מאריך'; null ⇒ ''.
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:1198-1207 (‏_isPipeProductE; חוק-4 — verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). הקריאה-לשדה p.productType קופלה
//        לשקע-מחרוזת nullable `productType` (חוק-3; LipskeyCatalogProduct גדול, לא-inline). `??` = שפה.
//        פרטי-במקור (`_`) ⇒ פורסם public. האח _kDrainageFamily (:1209) — לא נקרא ⇒ לא-הוטבע.
//
// קלט:  productType — שקע: סוג-המוצר (nullable; במקור p.productType).
// פלט:  bool — true אם (productType ?? '') הוא אחד מ-{'צינור','צנרת','גמיש','מאריך'}.

/// True iff the product is a pipe (by product type). Verbatim of install_engine.dart:1198-1207
/// with `p.productType` injected as the nullable `productType` socket (law-3).
bool isPipeProductE(String? productType, {required String Function(String) term}) {
  final t = productType ?? '';
  return t == term('tsynvr') || t == term('tsnrt') || t == term('gmysh') || t == term('maryk');
}
