// ⚛️ אטום-Dart (דרגת-חוזה) · screenKeyForTab
// מוצא: buildsmart/app_flutter/lib/state/intel/screen_view.dart:49 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// The four bottom-nav tabs → their stable screen keys, in the shell's tab order
/// (בית · מחלקות · עדכונים · חנות — `home_shell.dart` `_BottomNav`). The ONE place
/// a tab key is spelled (§6). Out-of-range indices fall back to a safe `tab_N`.
String screenKeyForTab(int index) => switch (index) {
      0 => 'home',
      1 => 'departments',
      2 => 'updates',
      3 => 'store',
      _ => 'tab_$index',
    };
