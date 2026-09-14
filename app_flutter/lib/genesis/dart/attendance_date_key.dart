// ⚛️ אטום-Dart (דרגת-חוזה) · attendanceDateKey
// מוצא: buildsmart/app_flutter/lib/state/worker_attendance.dart:23 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__contractor_attendance_sheet — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): שעות · מיקום · כניסה · אין · נוכחות · רשומה · היום · עובדים · מחותמים · כרגע · יציאה · מי

/// `yyyy-MM-dd` key for [d] — the per-day identity of an [AttendanceDay].
String attendanceDateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
