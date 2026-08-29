// ⚛️ אטום-Dart (דרגת-חוזה) · isShutoff
// תפקיד: האם המוצר הוא ברז-ניתוק (isolation/shutoff) — לפי מק"ט ברשימת-ברזי-הבידוד, או ברז-מעבר/ניל/דלי.
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:1037-1197 (‏isShutoff, השורות 841-848; חוק-4 — verbatim).
//        ⚠️ שאר גוף-הטיוטה (isolations, insertAt-ים, לולאות-החימוש) = קוד-סובב מהמתודה-העוטפת — לא-חלק-מהאטום.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
//        · ה-const `_kIsolationValveSkus` הוטבע inline verbatim (install_engine.dart:25-30 — עוגן חי, אומת).
//        · הקריאות-לשדה p.sku/p.productType/p.categoryHe קופלו לשקעים (חוק-3; LipskeyCatalogProduct גדול, לא-inline).
//        פרטי-במקור? לא — isShutoff public במקור. `Set.contains` = שפה/סטנדרט.
//
// קלט:  sku         — שקע: מק"ט-המוצר (במקור p.sku).
//        productType — שקע: סוג-המוצר (nullable; במקור p.productType).
//        categoryHe  — שקע: קטגוריית-המוצר (במקור p.categoryHe).
// פלט:  bool — _kIsolationValveSkus מכיל sku, או (productType∈{'ברז','ברז גן'} ∧ categoryHe∈{'ברזי מעבר','ברזי ניל','ברזי דלי'}).

// עוגן חי — install_engine.dart:25-30 (verbatim).
const _kIsolationValveSkus = {
  'HW-BALL-INLET-1', 'HW-BALL-INLET-40',
  'HW-BALL-1', 'HW-BALL-15', 'HW-BALL-40', 'HW-BALL-32',
  'HW-BALL-CU-40', 'HW-BALL-CU-32', 'HW-BALL-CU-25', 'HW-BALL-CU-20',
};

/// True iff the product is an isolation/shutoff valve. Verbatim predicate of
/// install_engine.dart:841-848 with `_kIsolationValveSkus` inlined and the three
/// product fields injected as sockets (law-3).
bool isShutoff({required String Function(String) term, 
  required String sku,
  required String? productType,
  required String categoryHe,
}) =>
    _kIsolationValveSkus.contains(sku) ||
    ((productType == term('brz') || productType == term('brz-gn')) &&
        (categoryHe == term('brzy-mabr') ||
            categoryHe == term('brzy-nyl') ||
            categoryHe == term('brzy-dly')));
