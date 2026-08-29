// ⚛️ אטום-Dart (דרגת-חוזה) · focusIndex
// מוצא: buildsmart/app_flutter/lib/features/ring_dive/ring_dive_qty.dart:73-76 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

int focusIndex(double rot) => (((-rot / 36).round() % 10) + 10) % 10;
