// ⚛️ אטום-Dart (דרגת-חוזה) · cleanSub
// מוצא: buildsmart/app_flutter/lib/atoms/finder_model.dart:85-93 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: הסרת-קידומת מתווית-קטגוריה (ניקוי תת-שם).

String cleanSub(String cat, {required String Function(String) term}) {
  for (final pre in [term('brzy'), term('abyzry'), term('mchbry')]) {
    if (cat.startsWith(pre)) return cat.substring(pre.length);
  }
  return cat;
}
