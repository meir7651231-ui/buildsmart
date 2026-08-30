// ⚛️ אטום-Dart (דרגת-חוזה) · norm
// מוצא: buildsmart/app_flutter/lib/features/ring_dive/ring_dive_qty.dart:91-92 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: נרמול-זווית לטווח מינוס-מאה-שמונים עד מאה-שמונים.

double norm(double a) => ((a + 180) % 360 + 360) % 360 - 180;
