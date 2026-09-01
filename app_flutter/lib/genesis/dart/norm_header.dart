// ⚛️ אטום-Dart (דרגת-חוזה) · normHeader
// מוצא: buildsmart/app_flutter/lib/data/csv_kernel.dart:32-34 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// Header-cell normalization: stray BOMs out, trimmed, lowercased (English
/// aliases are case-insensitive; Hebrew is untouched by lowercase).
String normHeader(String s, {required String kCsvBom}) => s.replaceAll(kCsvBom, '').trim().toLowerCase();
