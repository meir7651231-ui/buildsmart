// ⚛️ אטום-Dart (דרגת-חוזה) · fmtAuthorDate
// מוצא: buildsmart/app_flutter/lib/screens/tasks_screen.dart:1145 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__tasks_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): משימות · הושלמו · אין · לצוות · עדיין · חדשות · יופיעו · כאן · אישור · המשימה · אשר · אתה

/// `dd.MM.yyyy` zero-padded date label for the author start-date button (Wave
/// G2b) — a small local formatter (no dart:intl in this codebase). Only ever
/// called with a date the contractor actually picked (never invented).
String fmtAuthorDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';
