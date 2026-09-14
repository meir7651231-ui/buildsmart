// ⚛️ אטום-Dart (דרגת-חוזה) · p58SaddleModel
// מוצא: buildsmart/app_flutter/lib/data/polyroll_catalog.dart:259 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// p58 (רוכב PPR EF saddle): catalog "מודל" column assigns A/B per-row.
/// Pattern from the catalog table:
/// - x32 sizes → B (rows 3, 6).
/// - 110-125-160x25 → B (row 5).
/// - All others → A.
String p58SaddleModel(String nameHe) {
  if (nameHe.contains('x32')) return 'B';
  if (nameHe.contains('110-125-160x25')) return 'B';
  return 'A';
}
