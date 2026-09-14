// ⚛️ אטום-Dart (דרגת-חוזה) · patternOutlets
// מוצא: buildsmart/app_flutter/lib/screens/catalog_screen.dart:7366 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

int patternOutlets(String p) {
  if (p == '1') return 1;
  if (p == 'A×A' || p == 'A×B') return 2;
  if (p.startsWith('A×A×') || p.startsWith('A×B×')) return 3;
  return 9;
}
