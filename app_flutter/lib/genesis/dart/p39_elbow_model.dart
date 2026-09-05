// ⚛️ אטום-Dart (דרגת-חוזה) · p39ElbowModel
// מוצא: buildsmart/app_flutter/lib/data/polyroll_catalog.dart:220-258 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_p39ElbowModel` — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  nameHe — שם עברי של הפריט.
// פלט:  'B' לברך-מקוטעת 355/400, אחרת 'A' (ברך 90° לריתוך פנים, large).

/// דגם-קטלוג של ברך-p39 לפי [nameHe]. טהור.
String p39ElbowModel(String nameHe) {
  for (final size in const ['355', '400']) {
    if (nameHe.contains(' $size')) return 'B';
  }
  return 'A';
}
