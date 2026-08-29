// ⚛️ אטום-Dart (דרגת-חוזה) · contractorCredit
// תפקיד: מספר-אשראי יציב (₪) לקבלן לפי שמו — hash דטרמיניסטי בתוך רצועה, מעוגל ל-₪100.
// מוצא: buildsmart/app_flutter/lib/logic/manager_dashboard.dart:263-278 (חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). כל ה-const-ים
//        (lo/hi/span) הם עוזרי-מקום פרטיים — מוטבעים inline verbatim מגוף-הטיוטה.
// אחים-שהוטבעו: lo=30000 · hi=120000 · span=hi-lo=90000 (const-ים מקומיים בגוף המקור).
// אחים-שסוקטו: — (אין קריאה-לשכן).
//
// קלט:  name — שם-הקבלן (String). המקור קורא `name.hashCode.abs()`.
// פלט:  int בטווח [30000, 120000], מעוגל כלפי-מטה למכפלת-₪100.

/// Stable per-name contractor credit (₪): `abs(hashCode)` folded into the band
/// `[30000,120000]`, floored to the nearest ₪100. Verbatim behaviour of
/// manager_dashboard.dart:263-278. Deterministic + idempotent for a given SDK.
int contractorCredit(String name) {
  const lo = 30000;
  const hi = 120000;
  const span = hi - lo; // 90,000
  // Stable non-negative hash → bucket within the band, rounded to ₪100.
  final h = name.hashCode.abs();
  final raw = lo + (h % (span + 1));
  return (raw ~/ 100) * 100;
}
