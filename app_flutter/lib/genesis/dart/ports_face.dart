// ⚛️ אטום-Dart · portsFace
// מוצא: buildsmart/app_flutter/lib/features/fittings/engine/grid_adjacency.dart:58-65 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: `Vec3` (route_layout.dart:18) הוטבע בצורת-מינימום — snapToGrid נוגע רק ב-x/y/z
//        (אופרטורים/norm/length הושמטו); ה-enum `GridStep` (:14-40) הוטבע verbatim (רק
//        dx/dy/dz + הגטר `opposite`; `vec` הושמט); ה-socket `snapToGrid` (:45) הוטבע verbatim
//        (טהור — אין תלות-חוץ).

/// צורת-מינימום של וקטור-תלת — snapToGrid נוגע רק ב-x/y/z.
class Vec3 {
  const Vec3(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

/// צעד-יחידה על סריג-השלמים — הצורה-הבדידה של פורט-מכוון צירי.
enum GridStep {
  east(1, 0, 0), // +X
  west(-1, 0, 0), // −X
  north(0, 1, 0), // +Y
  south(0, -1, 0), // −Y
  above(0, 0, 1), // +Z
  below(0, 0, -1); // −Z

  const GridStep(this.dx, this.dy, this.dz);

  final int dx;
  final int dy;
  final int dz;

  /// הצעד-ההפוך (מזרח↔מערב · צפון↔דרום · מעלה↔מטה).
  GridStep get opposite => switch (this) {
        GridStep.east => GridStep.west,
        GridStep.west => GridStep.east,
        GridStep.north => GridStep.south,
        GridStep.south => GridStep.north,
        GridStep.above => GridStep.below,
        GridStep.below => GridStep.above,
      };
}

/// מצמיד וקטור-כיוון (כמעט-)צירי לצעד-הסריג שלו, או `null` אם [dir] אינו בתוך
/// [tol] מציר-יחיד (למשל יציאת-ברך-45° האלכסונית).
GridStep? snapToGrid(Vec3 dir, {double tol = 1e-6}) {
  for (final s in GridStep.values) {
    if ((dir.x - s.dx).abs() < tol &&
        (dir.y - s.dy).abs() < tol &&
        (dir.z - s.dz).abs() < tol) {
      return s;
    }
  }
  return null;
}

/// שני פורטים "פונים זה-לזה" ⟺ הנורמלים-היוצאים שלהם הם צעדי-סריג הפוכים.
bool portsFace(Vec3 a, Vec3 b) {
  final sa = snapToGrid(a);
  final sb = snapToGrid(b);
  return sa != null && sb != null && sa.opposite == sb;
}
