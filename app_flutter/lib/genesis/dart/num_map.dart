// ⚛️ אטום-Dart (דרגת-חוזה) · numMap
// מוצא: buildsmart/app_flutter/lib/domain/connection_schema.dart:37-39 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

Map<String, num> numMap(Object? v) => v is Map
    ? {for (final e in v.entries) if (e.value is num) '${e.key}': e.value as num}
    : const {};
