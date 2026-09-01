// ⚛️ אטום-Dart (דרגת-חוזה) · cleanSub
// מוצא: buildsmart/app_flutter/lib/atoms/finder_model.dart:85-93 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

String cleanSub(String cat) {
  for (final pre in const ['ברזי ', 'אביזרי ', 'מחברי ']) {
    if (cat.startsWith(pre)) return cat.substring(pre.length);
  }
  return cat;
}
