// ⚛️ אטום-Dart (דרגת-חוזה) · fmtTime
// מוצא: buildsmart/app_flutter/lib/screens/worker_attendance_screen.dart:1061 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__worker_attendance_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): ימים · שעות · מיקום · כניסה · שלבים · ימי · עבודה · אוגוסט · אוקטובר · אין · פתוחה · להיום

String fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
