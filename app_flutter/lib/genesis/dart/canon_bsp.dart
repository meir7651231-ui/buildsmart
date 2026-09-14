// ⚛️ אטום-Dart (דרגת-חוזה) · canonBsp
// מוצא: buildsmart/app_flutter/lib/features/fittings/plan/deep_ends.dart:54 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// מבטיח את סימן-האינץ' על מידת-BSP (`'1/2'` → `'1/2"'`) — `directMatesWith`
/// משווה raw-string, וכל ה-BSP הסטטיים נכתבים עם הסימן. בלי הסימן החיבור פשוט
/// **לא נוצר** (false-negative בטוח, לעולם לא זיווג-שווא) — הנרמול מונע החמצה.
String canonBsp(String inch) {
  final t = inch.trim();
  return t.contains('"') ? t : '$t"';
}
