// ⚛️ אטום-Dart (דרגת-חוזה) · grouped
// מוצא: buildsmart/app_flutter/lib/screens/manager_dashboard_screen.dart:2030 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__manager_dashboard_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · הזמנות · אתרים · פריטים · התקבלה · בהכנה · מוכן · נאסף · בדרך · נמסר · עקיפת · מנהל

/// Thousands-grouped integer (the legacy `Number.toLocaleString()` for the ₪
/// sums) — e.g. 3150 → "3,150". Pure, no locale dependency.
String grouped(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}
