// ⚛️ אטום-Dart (דרגת-חוזה) · fmtDateKey
// מוצא: buildsmart/app_flutter/lib/screens/courier_attendance_screen.dart:665 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__courier_attendance_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): שעות · ימים · ימי · עבודה · אוגוסט · אוקטובר · אין · כניסה · פתוחה · להיום · רישומי · נוכחות

/// `yyyy-MM-dd` → `d.M` (the table's compact date).
String fmtDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return key;
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (m == null || d == null) return key;
  return '$d.$m';
}
