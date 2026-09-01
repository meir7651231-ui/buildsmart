// ⚛️ אטום-Dart (דרגת-חוזה) · isTrueColor
// מוצא: buildsmart/app_flutter/lib/features/word_finder/color_truth.dart:23-27 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: האם שם-הצבע נמצא ברשימת-הצבעים-האמיתיים.

/// Whether [color] is a genuine colour (in [kTrueColors]) rather than a metal
/// finish miscoded into the catalog's colour field.
bool isTrueColor(String color, {required Set<String> kTrueColors}) => kTrueColors.contains(color);
