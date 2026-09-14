// ⚛️ אטום-Dart (דרגת-חוזה) · illustrativeSiteSpend
// מוצא: buildsmart/app_flutter/lib/screens/budget_screen.dart:179 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__budget_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): הקש · לעריכה · הנתונים · להמחשה · בגרסה · המלאה · יתבססו · על · ההזמנות · וההוצאות · בפועל · של

/// #twin — the demo/illustrative per-site weight (decreasing by index): the
/// verbatim shipped formula `spent*(count-index)/(count*(count+1)/2)`. Pure.
num illustrativeSiteSpend(num spent, int count, int index) =>
    count <= 0 ? 0 : spent * (count - index) / (count * (count + 1) / 2);
