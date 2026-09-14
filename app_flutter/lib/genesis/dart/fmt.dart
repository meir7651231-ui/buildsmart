// ⚛️ אטום-Dart (דרגת-חוזה) · fmt
// מוצא: buildsmart/app_flutter/lib/screens/_size_norm.dart:166 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens___size_norm — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מ׳ · מס

/// Render a `double` the way a chip label should read: integers lose the
/// decimal point; values like `1.5` stay `1.5`. Crucially this strips
/// leading zeros from source strings like `020` → `20`.
String fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';
