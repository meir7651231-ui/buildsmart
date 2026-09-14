// ⚛️ אטום-Dart (דרגת-חוזה) · wk
// מוצא: buildsmart/app_flutter/lib/screens/tasks_screen.dart:50 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// שקעים (חוק-3 — הוזרקו אוטומטית מקריאות-שכן במקור): kWorkers.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__tasks_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): משימות · הושלמו · אין · לצוות · עדיין · חדשות · יופיעו · כאן · אישור · המשימה · אשר · אתה

/// CRASH-GUARD — a worker index can outrun [kWorkers] (a task stamped for a
/// worker who is no longer in the demo roster, or a malformed/server payload),
/// so `kWorkers[i]` would throw a RangeError. Clamp out-of-range indices to the
/// first worker label instead of crashing the whole board.
String wk(int i, {required List<String> kWorkers}) => kWorkers[(i >= 0 && i < kWorkers.length) ? i : 0];
