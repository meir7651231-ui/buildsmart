// ⚛️ אטום-Dart (דרגת-חוזה) · hhmm
// מוצא: buildsmart/app_flutter/lib/screens/worker_profile_screen.dart:674 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// `HH:MM` (zero-padded, 24h) — the worker's local clock for the נוכחות status.
String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
