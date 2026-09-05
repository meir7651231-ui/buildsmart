// ⚛️ אטום-Dart (דרגת-חוזה) · catValueLabel
// מוצא: buildsmart/app_flutter/lib/features/ring_dive/catalog_slang.dart:114-116 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: תווית-תצוגה לערך-ציר לפי מילון-הסלנג של הציר.

/// The layman label for [value] on [axis] — its slang if the owner mapped one,
/// else the value verbatim (sizes, colours, angles already read plainly).
String catValueLabel(String axis, String value, {required Map<String, Map<String, String>> kAxisValueSlang}) =>
    kAxisValueSlang[axis]?[value] ?? value;
