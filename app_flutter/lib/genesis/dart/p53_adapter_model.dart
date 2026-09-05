// ⚛️ אטום-Dart (דרגת-חוזה) · p53AdapterModel
// מוצא: buildsmart/app_flutter/lib/data/polyroll_catalog.dart:202-210 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_p53AdapterModel` — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  nameHe — שם עברי של הפריט.
// פלט:  'B' למידות PPR 40-110, אחרת 'A' (מתאם לריתוך הברגה תבריג פנימי).

/// דגם-קטלוג של מתאם-p53 לפי [nameHe]. טהור.
String p53AdapterModel(String nameHe) {
  for (final size in const ['40', '50', '63', '75', '90', '110']) {
    if (nameHe.contains('${size}x')) return 'B';
  }
  return 'A';
}
