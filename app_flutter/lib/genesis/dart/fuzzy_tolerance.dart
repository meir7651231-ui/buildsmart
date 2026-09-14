// ⚛️ אטום-Dart (דרגת-חוזה) · fuzzyTolerance
// מוצא: buildsmart/app_flutter/lib/logic/fuzzy_match.dart:54 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// סף-הסובלנות של Maor: `floor(len/3) + 1` — מרחק-העריכה המרבי שעדיין נחשב
/// התאמה, פר-אורך-המחרוזת-המנורמלת של השאילתה.
int fuzzyTolerance(int len) => (len ~/ 3) + 1;
