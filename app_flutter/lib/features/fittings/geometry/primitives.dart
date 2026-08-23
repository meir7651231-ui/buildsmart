// 🔌 מנוע-קטלוג-3D · פאזה C (שלב 42) — פרימיטיבים→רשתות: `revolve`/`tube`/`hexRod`/
// `sphere` הופכים פרופיל-2D לרשת-3D (מיקומים · נורמלים · אינדקסים). פורט 1:1 מ-
// `gen3d.html:153-172` (מימוש-הייחוס של ה-3D). טהור · מגודר (`features/fittings/`).
//
// היחידות = מ״מ (כמו המנוע); סקאלת-התצוגה (`S`) היא ענייני-render ואינה נאפית כאן,
// כדי שהגיאומטריה תישאר טהורה וניתנת-לבדיקה. אפס גזירת-פיזיקה חדשה.

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;

/// רשת-משולשים: מיקומים ונורמלים כ-xyz שטוח, אינדקסים למשולשים.
@immutable
class Mesh {
  const Mesh(this.positions, this.normals, this.indices);

  final List<double> positions; // [x,y,z, x,y,z, …]
  final List<double> normals; // מקביל ל-positions
  final List<int> indices; // 3 לכל משולש

  int get vertexCount => positions.length ~/ 3;
  int get triangleCount => indices.length ~/ 3;
}

/// גוף-סיבוב: מסובב פרופיל-2D `[[x, r], …]` (לולאה סגורה) סביב ציר-X ל-[seg] מקטעים.
/// כל צלע-פרופיל × מקטע = 4 קודקודים + 2 משולשים. פורט 1:1 מ-`revolve` ב-gen3d.
Mesh revolve(List<List<double>> profile, int seg) {
  final p = <double>[];
  final n = <double>[];
  final idx = <int>[];
  for (var i = 0; i < profile.length; i++) {
    final p0 = profile[i];
    final p1 = profile[(i + 1) % profile.length];
    final dx = p1[0] - p0[0];
    final dr = p1[1] - p0[1];
    var nx = -dr;
    var nr = dx;
    final nl = math.sqrt(nx * nx + nr * nr);
    if (nl != 0) {
      nx /= nl;
      nr /= nl;
    }
    for (var s = 0; s < seg; s++) {
      final a0 = s / seg * 2 * math.pi;
      final a1 = (s + 1) / seg * 2 * math.pi;
      final c0 = math.cos(a0);
      final s0 = math.sin(a0);
      final c1 = math.cos(a1);
      final s1 = math.sin(a1);
      final b = p.length ~/ 3;
      p.addAll([p0[0], p0[1] * c0, p0[1] * s0]);
      n.addAll([nx, nr * c0, nr * s0]);
      p.addAll([p1[0], p1[1] * c0, p1[1] * s0]);
      n.addAll([nx, nr * c0, nr * s0]);
      p.addAll([p0[0], p0[1] * c1, p0[1] * s1]);
      n.addAll([nx, nr * c1, nr * s1]);
      p.addAll([p1[0], p1[1] * c1, p1[1] * s1]);
      n.addAll([nx, nr * c1, nr * s1]);
      idx.addAll([b, b + 1, b + 2, b + 2, b + 1, b + 3]);
    }
  }
  return Mesh(p, n, idx);
}

/// צינור: גוף-סיבוב של מלבן (רדיוס-חוץ `ro`, רדיוס-פנים `ri`, מ-`x0` ל-`x1`).
Mesh tube(double x0, double x1, double ro, double ri, {int seg = 48}) =>
    revolve([
      [x0, ro],
      [x1, ro],
      [x1, ri],
      [x0, ri],
    ], seg,);

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

/// כדור (למשל כדור-הברז) — רדיוס `r`, `la` קווי-רוחב × `lo` קווי-אורך.
/// פורט 1:1 מ-`sphere` ב-gen3d: `(la+1)·(lo+1)` קודקודים · `la·lo·2` משולשים.
Mesh sphere(double r, int la, int lo) {
  final p = <double>[];
  final n = <double>[];
  final idx = <int>[];
  for (var i = 0; i <= la; i++) {
    final th = i / la * math.pi;
    for (var j = 0; j <= lo; j++) {
      final ph = j / lo * 2 * math.pi;
      final x = r * math.sin(th) * math.cos(ph);
      final y = r * math.cos(th);
      final z = r * math.sin(th) * math.sin(ph);
      p.addAll([x, y, z]);
      n.addAll([x / r, y / r, z / r]);
    }
  }
  for (var i = 0; i < la; i++) {
    for (var j = 0; j < lo; j++) {
      final a = i * (lo + 1) + j;
      final b = a + lo + 1;
      idx.addAll([a, b, a + 1, a + 1, b, b + 1]);
    }
  }
  return Mesh(p, n, idx);
}
