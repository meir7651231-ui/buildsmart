// ⚛️ אטום-Dart (דרגת-חוזה) · pseudonym
// מוצא: buildsmart/app_flutter/lib/screens/intel/intel_tab.dart:659 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__intel__intel_tab — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): סשנים · לקוחות · אחוז · המרה · במסך · אין · נתונים · עדיין · אף · לקוח · לא · מחובר

/// Short, safe pseudonym label for a stable actor key — the pseudonymous key is
/// safe to show (R1-4: it is NOT PII); shortened so a long uid stays readable.
String pseudonym(String key) => key.length <= 8 ? key : key.substring(0, 8);
