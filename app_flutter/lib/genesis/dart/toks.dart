// ⚛️ אטום-Dart (דרגת-חוזה) · toks
// מוצא: buildsmart/app_flutter/lib/features/word_finder/narrow_axis.dart:60-92 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: פירוק שם-מוצר לאסימוני-חיפוש מנורמלים.

List<String> toks(String name, {required String Function(String) term}) => name
      .split(RegExp(term('t0')))
      .where((w) => w.length >= 2 && !RegExp(r'\d').hasMatch(w))
      .toList();
