// ⚛️ אטום-Dart (דרגת-חוזה) · rank
// מוצא: buildsmart/app_flutter/lib/features/ring_dive/ring_dive_catalog.dart:211-220 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

int rank(String field, String value, {required Map<String, List<String>> kRdOrder}) {
  final ord = kRdOrder[field];
  if (ord == null) return 999;
  final i = ord.indexOf(value);
  return i < 0 ? 999 : i;
}
