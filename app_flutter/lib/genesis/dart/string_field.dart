// ⚛️ אטום-Dart (דרגת-חוזה) · stringField
// מוצא: buildsmart/app_flutter/lib/config/org_config.dart:242-245 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// A string field: a String rides, anything else drops to '' (per-field
/// tolerance — a garbled slug never costs its siblings).
String stringField(Object? v) => v is String ? v : '';
