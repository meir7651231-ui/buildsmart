// ⚛️ אטום-Dart · chipPriority
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/product_chips.dart:78 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הקבועים `kChipPriority` (product_chips.dart:49-73) ו-`_kUnknownPriority` (66)
//        הוטבעו verbatim; אין טיפוס-דומיין (מפתח=String, ערך=int).

/// עדיפות-הטקסונומיה פר-מזהה-צ'יפ — verbatim (product_chips.dart:49-73).
const Map<String, int> kChipPriority = {
  'diameter': 1, // קוטר (inch / DN / mm — one size wheel)
  'diameter-large': 1, // קוטר (reducer big end)
  'diameter-small': 2, // קוטר-שני / מעבר
  'angle': 3, // זווית
  'ports': 4, // יציאות
  'length': 5, // אורך
  'height': 6, // גובה
  'kind': 7, // סוג
  'color': 8, // צבע
  'thread': 9, // תבריג
  'method': 9, // שיטה (connection method — the תבריג band)
  'structure': 10, // מבנה
  'gender': 10, // מין חיבור (the מבנה band)
  'shape': 11, // צורה
  'material': 12, // חומר
  'target': 13, // יעד / חדר
  'temp': 14, // טמפ'
  'capacity': 15, // תכולה (the תוספת band)
  'addon': 15, // תוספת
  'spout': 16, // פיה
  'brand': 17, // מותג
  'size': 18, // גודל
};

/// צ'יפ שאינו-בטקסונומיה ממוין אחרון — verbatim (product_chips.dart:66).
const int _kUnknownPriority = 99;

/// עדיפות-הטקסונומיה של מזהה-מאפיין, או [_kUnknownPriority] אם לא-רשום. PURE.
int chipPriority(String id) => kChipPriority[id] ?? _kUnknownPriority;
