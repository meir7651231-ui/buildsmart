// ⚛️ אטום-Dart (דרגת-חוזה) · hexRod
// מוצא: buildsmart/app_flutter/lib/features/fittings/geometry/primitives.dart:76 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית; הייבוא היחיד הוא ספריית-שפה טהורה (import 'dart:math' as math;).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): Mesh.
// חלול: Mesh = const Mesh(const <double>[], const <double>[], const <int>[])

import 'dart:math' as math;

/// רשת-משולשים: מיקומים ונורמלים כ-xyz שטוח, אינדקסים למשולשים.
class Mesh {
  const Mesh(this.positions, this.normals, this.indices);

  final List<double> positions; // [x,y,z, x,y,z, …]
  final List<double> normals; // מקביל ל-positions
  final List<int> indices; // 3 לכל משולש

  int get vertexCount => positions.length ~/ 3;
  int get triangleCount => indices.length ~/ 3;
}

/// מוט-משושה (או פריזמה כללית) בעל [sides] פאות, רדיוס `r`, אורך `len`, סביב `cx`.
/// פורט 1:1 מ-`hexRod` ב-gen3d (בלי סקאלת-`S` — טהור).
Mesh hexRod(int sides, double r, double len, double cx) {
  final p = <double>[];
  final n = <double>[];
  final idx = <int>[];
  final hh = len / 2;
  for (var i = 0; i < sides; i++) {
    final a0 = i / sides * 2 * math.pi;
    final a1 = (i + 1) / sides * 2 * math.pi;
    final am = (a0 + a1) / 2;
    final nc = math.cos(am);
    final ns = math.sin(am);
    final b = p.length ~/ 3;
    p.addAll([cx - hh, r * math.cos(a0), r * math.sin(a0)]);
    n.addAll([0, nc, ns]);
    p.addAll([cx + hh, r * math.cos(a0), r * math.sin(a0)]);
    n.addAll([0, nc, ns]);
    p.addAll([cx - hh, r * math.cos(a1), r * math.sin(a1)]);
    n.addAll([0, nc, ns]);
    p.addAll([cx + hh, r * math.cos(a1), r * math.sin(a1)]);
    n.addAll([0, nc, ns]);
    idx.addAll([b, b + 1, b + 2, b + 2, b + 1, b + 3]);
  }
  return Mesh(p, n, idx);
}
