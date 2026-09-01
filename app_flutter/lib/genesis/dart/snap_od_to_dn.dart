// ⚛️ אטום-Dart (דרגת-חוזה) · snapOdToDn
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/dn_scale.dart:37-56 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// Snap an outer-diameter magnitude to the nearest [kDnRungs] step.
int snapOdToDn(num od, {required List<int> kDnRungs}) {
  var best = kDnRungs.first;
  var bestDist = (od - best).abs();
  for (final rung in kDnRungs) {
    final dist = (od - rung).abs();
    if (dist < bestDist) {
      bestDist = dist;
      best = rung;
    }
  }
  return best;
}
