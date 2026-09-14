// ⚛️ אטום-Dart (דרגת-חוזה) · fxGroupInt
// מוצא: buildsmart/app_flutter/lib/screens/finance_hub_sheets.dart:1662 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__finance_hub_sheets — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): דוח · פיננסי · לפרויקט · מבקש · ימי · איחור · ליום · רישום · קנס · מהתקציב · צפוי · אושר

/// Group an integer with thousands commas (proto updateFXCalc toLocaleString).
/// Top-level + public so `fx_group_test` can pin it directly.
String fxGroupInt(int v) {
  final neg = v < 0;
  final d = v.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i > 0 && (d.length - i) % 3 == 0) buf.write(',');
    buf.write(d[i]);
  }
  return '${neg ? '-' : ''}$buf';
}
