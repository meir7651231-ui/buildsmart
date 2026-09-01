// ⚛️ אטום-Dart (דרגת-חוזה) · basename
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/image_quality.dart:66-74 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: שם-הקובץ מתוך נתיב-נכס (החלק אחרי הלוכסן האחרון).

/// The basename of [assetPath] (after the last '/'), or null.
String? basename(String? assetPath) {
  if (assetPath == null) return null;
  final slash = assetPath.lastIndexOf('/');
  return slash < 0 ? assetPath : assetPath.substring(slash + 1);
}
