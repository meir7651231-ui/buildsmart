// ⚛️ אטום-Dart (דרגת-חוזה) · sizeTable
// מוצא: buildsmart/app_flutter/lib/domain/connection_schema.dart:40-45 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

List<List<String>>? sizeTable(Object? v) => v is List
    ? v
        .whereType<List<dynamic>>()
        .map((row) => row.whereType<String>().toList())
        .toList()
    : null;
