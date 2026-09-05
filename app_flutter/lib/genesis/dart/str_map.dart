// ⚛️ אטום-Dart (דרגת-חוזה) · strMap
// מוצא: buildsmart/app_flutter/lib/logic/studio/config_op.dart:143-145 (‏_strMap; חוק-4).
//        פרטי-במקור (`_`) — גולגל לאטום top-level, גוף verbatim (הוסרה רק תחילית `_`).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). אין שכנים/const.
//
// קלט:  m — מפה עם מפתחות מטיפוס-כלשהו (Map<dynamic, dynamic>).
// פלט:  אותה מפה כשכל מפתח עבר `.toString()` (הערכים ללא-שינוי): Map<String, dynamic>.
//        שני מפתחות ששווים אחרי toString ⇒ המאוחר דורס (סמנטיקת Map.map).

/// [m] with every key stringified via `.toString()`; values unchanged.
/// Verbatim behaviour of config_op.dart:143-145.
Map<String, dynamic> strMap(Map<dynamic, dynamic> m) =>
    m.map((k, v) => MapEntry(k.toString(), v));
