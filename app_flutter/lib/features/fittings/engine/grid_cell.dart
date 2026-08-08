// 🧭 D12 · תאי-גריד — שכבת-החיבור מעל שכנוּת-הגריד (§2 · שלב P3→P4). מניחים אביזר
// בתא-סריג שלם; שני תאים "מחוברים" כשהם שכני-סריג, לכל אחד פורט-מכוון הפונה לשני,
// וה-od של הפורטים-הפונים תואם. זהו הבסיס למעקב-קצה-פנוי ולסינון-ההצעות של
// גריד-הסודוקו (D11/D13 — "רק מה שמתחבר לשכן").
//
// טהור · immutable · unit-testable. חלק מגרף-`features/fittings/` המגודר בדגל
// (`kFittingEngine`, ברירת-מחדל OFF) — נטרף עד ש-UI-הגריד צורך אותו.

import 'package:buildsmart/features/fittings/engine/directed_ports.dart';
import 'package:buildsmart/features/fittings/engine/grid_adjacency.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:flutter/foundation.dart';

/// אביזר המונח בתא-סריג שלם (x·y·z על הסריג).
@immutable
class GridCell {
  const GridCell(this.x, this.y, this.z, this.element);

  final int x;
  final int y;
  final int z;
  final RunElement element;

  /// צעד-הסריג מהתא הזה אל [o], או `null` כשאינם שכני-יחידה ציריים
  /// (מרחק >1, אלכסון, או אותו תא).
  GridStep? stepTo(GridCell o) => snapToGrid(
        Vec3((o.x - x).toDouble(), (o.y - y).toDouble(), (o.z - z).toDouble()),
      );

  @override
  bool operator ==(Object other) =>
      other is GridCell &&
      other.x == x &&
      other.y == y &&
      other.z == z &&
      other.element == element;

  @override
  int get hashCode => Object.hash(x, y, z, element);
}

/// שני תאים מחוברים ⟺ הם שכני-סריג · ל-[a] פורט-מכוון הפונה אל [b] ול-[b] הפורט-
/// הנגדי · וה-od של שני הפורטים-הפונים תואם (אותה מידה מתחברת). התאמת-מערכת/מגדר
/// עדינה יותר נבדקת בנפרד; כאן הגאומטריה + המידה.
bool cellsConnect(GridCell a, GridCell b) {
  final step = a.stepTo(b);
  if (step == null) {
    return false;
  }
  final aFacing =
      directedPortsOf(a.element).where((p) => snapToGrid(p.dir) == step);
  final bFacing = directedPortsOf(b.element)
      .where((p) => snapToGrid(p.dir) == step.opposite);
  if (aFacing.isEmpty || bFacing.isEmpty) {
    return false;
  }
  return aFacing.any((pa) => bFacing.any((pb) => pa.od == pb.od));
}
