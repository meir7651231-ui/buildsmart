// ⚛️ אטום-Dart (דרגת-חוזה) · firstSizeNum
// מוצא: buildsmart/app_flutter/lib/screens/lipskey_products_screen.dart:2532 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__lipskey_products_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): יוסר · מהסל · מוצרים · ׳״ · קוטר · חיצוני · נומינלי · או · אורך · אין · להצגה · אישור

/// First numeric value in a size label (e.g. "1/2\"" → 1, "DN50" → 50). Used
/// to sort size siblings in an intuitive order.
double firstSizeNum(String s) {
  final m = RegExp(r'\d+(?:\.\d+)?').firstMatch(s);
  if (m == null) return 0;
  return double.tryParse(m.group(0)!) ?? 0;
}
