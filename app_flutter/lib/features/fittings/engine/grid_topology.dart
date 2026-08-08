// 🧭 D12 · טופולוגיית-גריד — מעקב-קצה-פנוי (§2 · שלב P4). מעל תאים-מונחים: לכל
// פורט-מכוון של תא, אם אין שכן-מחובר בכיוון-הפורט — זהו "קצה-פנוי". רשימת
// הקצוות-הפנויים היא הבסיס להצעות-פר-קצה (D13) ולסינון-הסודוקו (D5 — "רק מה
// שמתחבר לשכן") ולתאימות-פר-צד של הכרטיס (D4).
//
// טהור · immutable · unit-testable. חלק מגרף-`features/fittings/` המגודר בדגל
// (`kFittingEngine`, ברירת-מחדל OFF) — נטרף עד ש-UI-הגריד/הכרטיס צורך אותו.

import 'package:buildsmart/features/fittings/engine/directed_ports.dart';
import 'package:buildsmart/features/fittings/engine/grid_adjacency.dart';
import 'package:buildsmart/features/fittings/engine/grid_cell.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:flutter/foundation.dart';

/// קצה-פנוי: פורט של [cell] הפונה בכיוון-הסריג [step] (od = [od]) שאין לו שכן
/// מחובר — כלומר מקום פנוי להוסיף אליו אביזר.
@immutable
class FreeEnd {
  const FreeEnd(this.cell, this.step, this.od);

  final GridCell cell;
  final GridStep step;
  final int od;

  @override
  bool operator ==(Object other) =>
      other is FreeEnd &&
      other.cell == cell &&
      other.step == step &&
      other.od == od;

  @override
  int get hashCode => Object.hash(cell, step, od);

  @override
  String toString() => 'FreeEnd(${cell.x},${cell.y},${cell.z} → $step, od$od)';
}

/// כל הקצוות-הפנויים על פני [cells]: לכל פורט-מכוון-צירי של כל תא, אם אין תא-שכן
/// *מחובר* במיקום שאליו הפורט פונה — הפורט פנוי. פורטים לא-ציריים (יציאת-45°)
/// אינם נעקבים על הגריד-הריבועי ומושמטים.
List<FreeEnd> freeEndsOf(List<GridCell> cells) {
  final byPos = <(int, int, int), GridCell>{
    for (final c in cells) (c.x, c.y, c.z): c,
  };
  final out = <FreeEnd>[];
  for (final c in cells) {
    for (final p in directedPortsOf(c.element)) {
      final step = snapToGrid(p.dir);
      if (step == null) {
        continue;
      }
      final neighbour = byPos[(c.x + step.dx, c.y + step.dy, c.z + step.dz)];
      final connected = neighbour != null && cellsConnect(c, neighbour);
      if (!connected) {
        out.add(FreeEnd(c, step, p.od));
      }
    }
  }
  return out;
}

/// 🧩 D5/D13 · סינון-הסודוקו — בהינתן תאים-מונחים [cells] ותא-יעד ריק [target],
/// מחזיר אילו מ-[candidates] יתחברו ל*לפחות* שכן-מונח אחד אם יונחו ב-[target].
/// זהו הלב של גריד-הסודוקו: "רק מה שמתחבר לשכן" — ה-UI צורך אותו כדי להציע
/// (ומסדר לפי-תפקיד/מידה במעלה-הזרם). מחזיר `[]` אם [target] תפוס.
List<RunElement> gridSuggestionsAt(
  List<GridCell> cells,
  (int, int, int) target,
  List<RunElement> candidates,
) {
  final (tx, ty, tz) = target;
  if (cells.any((c) => c.x == tx && c.y == ty && c.z == tz)) {
    return const [];
  }
  return [
    for (final cand in candidates)
      if (cells.any((c) => cellsConnect(GridCell(tx, ty, tz, cand), c))) cand,
  ];
}
