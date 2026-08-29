// ⚛️ אטום-Dart (דרגת-חוזה) · csvIsBlank
// מוצא: buildsmart/app_flutter/lib/data/csv_kernel.dart:35-38 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// A record whose every cell is whitespace — importers skip it silently.
bool csvIsBlank(List<String> cells) => cells.every((c) => c.trim().isEmpty);
