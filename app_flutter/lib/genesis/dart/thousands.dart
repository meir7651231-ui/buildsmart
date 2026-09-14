// ⚛️ אטום-Dart (דרגת-חוזה) · thousands
// מוצא: buildsmart/app_flutter/lib/screens/budget_screen.dart:195 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__budget_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): הקש · לעריכה · הנתונים · להמחשה · בגרסה · המלאה · יתבססו · על · ההזמנות · וההוצאות · בפועל · של

String thousands(int n) {
  final neg = n < 0;
  var s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (neg ? '-' : '') + buf.toString();
}
