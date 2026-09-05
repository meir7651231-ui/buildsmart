// ⚛️ אטום-Dart (דרגת-חוזה) · p54AdapterModel
// מוצא: buildsmart/app_flutter/lib/data/polyroll_catalog.dart:190-201 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_p54AdapterModel` — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  nameHe — שם עברי של הפריט.
// פלט:  'C' ל-63-110, 'B' ל-40/50, אחרת 'A' (מתאם PPRCT לריתוך הברגה חיצוני).

/// דגם-קטלוג של מתאם-p54 לפי [nameHe]. טהור.
String p54AdapterModel(String nameHe) {
  for (final size in const ['63', '75', '90', '110']) {
    if (nameHe.contains('${size}x')) return 'C';
  }
  for (final size in const ['40', '50']) {
    if (nameHe.contains('${size}x')) return 'B';
  }
  return 'A';
}
