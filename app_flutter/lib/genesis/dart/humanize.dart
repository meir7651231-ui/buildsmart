// ⚛️ אטום-Dart (דרגת-חוזה) · humanize
// מוצא: buildsmart/app_flutter/lib/config/screen_labels_he.dart:190-197 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// גיבוי לזנב-הארוך: מסיר סיומת '_screen', מחליף '_' ברווח, מקצץ. לעולם לא
/// מחזיר מחרוזת ריקה (מזהה-ריק ⇒ 'מסך').
String humanize(String screen, {required String Function(String) term}) {
  var s = screen.endsWith('_screen')
      ? screen.substring(0, screen.length - '_screen'.length)
      : screen;
  s = s.replaceAll('_', ' ').trim();
  return s.isEmpty ? term('msk') : s;
}
