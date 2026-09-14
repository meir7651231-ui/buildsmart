// ⚛️ אטום-Dart (דרגת-חוזה) · day
// מוצא: buildsmart/app_flutter/lib/screens/intel/intel_tab.dart:662 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__intel__intel_tab — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): סשנים · לקוחות · אחוז · המרה · במסך · אין · נתונים · עדיין · אף · לקוח · לא · מחובר

/// yyyy-mm-dd for a cohort day marker (UTC-midnight, see segments.dart).
String day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
