// 🧭 D12 · שכנוּת-גריד — הגשר בין הכיוונים-הרציפים (שלב-1) לבין הגריד-הבדיד (§2·P3).
// כל פורט-מכוון (`DirectedPort.dir`) שהוא צירי מוצמד לצעד-סריג יחיד; שני פורטים
// "פונים זה-לזה" כשצעדי-הסריג שלהם הפוכים — הבדיקה שמאפשרת "פורט של תא מתחבר
// לפורט-הפונה של השכן". ברך-45° אינה צירית ⇒ לא מוצמדת לגריד-הריבועי (מתועד).
//
// טהור · immutable · unit-testable. חלק מגרף-`features/fittings/` המגודר בדגל
// (`kFittingEngine`, ברירת-מחדל OFF) — נטרף עד שהשלב-הבא צורך אותו.

import 'package:buildsmart/features/fittings/engine/directed_ports.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;

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

  /// הווקטור-הרציף המתאים (וקטור-יחידה צירי).
  Vec3 get vec => Vec3(dx.toDouble(), dy.toDouble(), dz.toDouble());

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
/// [tol] מציר-יחיד (למשל יציאת-ברך-45° האלכסונית). ה-[tol] בולע את אבק-הטריג
/// (cos(π/2) ≈ 6e-17) אך דוחה 45°.
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

/// שני פורטים "פונים זה-לזה" ⟺ הנורמלים-היוצאים שלהם הם צעדי-סריג הפוכים
/// (התנאי-הגיאומטרי לחיבור בין תאים שכנים; תאימות-DN/מערכת נבדקת בנפרד).
bool portsFace(Vec3 a, Vec3 b) {
  final sa = snapToGrid(a);
  final sb = snapToGrid(b);
  return sa != null && sb != null && sa.opposite == sb;
}

/// צעדי-הסריג של [el] — פורטיו-המכוונים שהם ציריים (יציאות-45° נשמטות, כי אינן
/// יושבות על הגריד-הריבועי). מגשר שלב-1 (`directedPortsOf`) אל הגריד.
List<GridStep> gridPortsOf(RunElement el) =>
    [for (final p in directedPortsOf(el)) snapToGrid(p.dir)]
        .whereType<GridStep>()
        .toList();
