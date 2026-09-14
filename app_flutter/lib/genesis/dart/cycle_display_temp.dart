// ⚛️ אטום-Dart (דרגת-חוזה) · cycleDisplayTemp
// מוצא: buildsmart/app_flutter/lib/state/display_temp.dart:10 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

/// Pure cycle: 60 → 80 → 95 → 60 → ...
/// Any other input snaps back to 60 (defensive — shouldn't happen via UI).
int cycleDisplayTemp(int current) {
  switch (current) {
    case 60:
      return 80;
    case 80:
      return 95;
    case 95:
      return 60;
  }
  return 60;
}
