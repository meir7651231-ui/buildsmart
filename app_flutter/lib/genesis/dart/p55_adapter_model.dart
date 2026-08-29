// ⚛️ אטום-Dart (דרגת-חוזה) · p55AdapterModel
// מוצא: buildsmart/app_flutter/lib/data/polyroll_catalog.dart:211-219 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_p55AdapterModel` — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  nameHe — שם עברי של הפריט.
// פלט:  'B' למידות 40-75, אחרת 'A' (מתאם ריתוך/הברגה עם רקורד).

/// דגם-קטלוג של מתאם-p55 לפי [nameHe]. טהור.
String p55AdapterModel(String nameHe) {
  for (final size in const ['40', '50', '63', '75']) {
    if (nameHe.contains('${size}x')) return 'B';
  }
  return 'A';
}
