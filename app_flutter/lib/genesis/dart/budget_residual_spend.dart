// ⚛️ אטום-Dart (דרגת-חוזה) · budgetResidualSpend
// מוצא: buildsmart/app_flutter/lib/screens/budget_screen.dart:185 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// #twin — orders whose site matched NO project (the "אחר / ללא פרויקט" residual):
/// Σ all orders − Σ orders that landed on a known project name. Pure → testable;
/// the row only renders when this is `> 0`.
int budgetResidualSpend(Map<String, int> spendBySite, Iterable<String> projectNames) =>
    spendBySite.values.fold<int>(0, (s, v) => s + v) -
    projectNames.fold<int>(0, (s, n) => s + (spendBySite[n] ?? 0));
