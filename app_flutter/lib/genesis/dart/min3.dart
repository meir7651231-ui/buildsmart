// ⚛️ אטום-Dart (דרגת-חוזה) · min3
// מוצא: buildsmart/app_flutter/lib/logic/fuzzy_match.dart:87-88 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: הקטן מבין שלושה מספרים שלמים.

int min3(int a, int b, int c) => a < b ? (a < c ? a : c) : (b < c ? b : c);
