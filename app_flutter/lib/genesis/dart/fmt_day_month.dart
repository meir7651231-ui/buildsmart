// ⚛️ אטום-Dart (דרגת-חוזה) · fmtDayMonth
// מוצא: buildsmart/app_flutter/lib/screens/tasks_gantt_sheet.dart:393 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__tasks_gantt_sheet — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): ימ׳ · אין · משימות · לוח · הזמנים · של · המשימות · לפי · תאריך · התחלה · מתוזמן · לצפייה

/// `dd.MM` zero-padded calendar label — a small local formatter (no dart:intl in
/// this codebase; mirrors the hand-formatting in the attendance/forms sheets).
/// The date is always a task's real [TaskItem.scheduledStart] — never invented.
String fmtDayMonth(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}';
