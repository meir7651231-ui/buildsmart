// ⚛️ אטום-Dart (דרגת-חוזה) · diameterSortKey
// מוצא: buildsmart/app_flutter/lib/screens/catalog_screen.dart:7381 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

double diameterSortKey(String atom) {
  final m = RegExp(r'\d+(?:\.\d+)?').firstMatch(atom);
  if (m == null) return 9999;
  return double.tryParse(m.group(0)!) ?? 9999;
}
