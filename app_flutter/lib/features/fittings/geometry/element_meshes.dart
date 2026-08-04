// 🔌 מנוע-קטלוג-3D · פאזה C (renderer-polish 1) — גוף-אביזר אמיתי פר-משפחה. פורט 1:1
// מ-`gen3d.html:elemMeshes` (`:280-319`) + `taperGeom` (`:174`), **סקאלת-S מוסרת**
// (הכל מ״מ · טהור). מחליף את ה-envelope-tube הזמני בגיאומטריה נאמנה: ברך = שתי זרועות
// + כדור-פינה · טי = שלוש זרועות · ברז = גוף+ידית-פליז · מצרה = חרוט-מעבר · וכו׳.
//
// כל חלק נבנה במסגרת-המקומית של האביזר (loc = rotateZ ואז translate, מוטבע ברשת),
// עם תגית-חומר (PP-R / צינור / פליז). ה-assembler (פרוסה הבאה) ממקם למרחב-עולם
// ומוסיף צנרת-מעבר (ריתוך). אפס גזירת-פיזיקה חדשה · מגודר · הכרטיס-החי לא-נגוע.

import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:flutter/foundation.dart' show immutable;

/// חומר-החלק — קובע צבע/הצללה אצל הצייר (PP-R ירוק · צינור אפור · פליז).
enum PartMaterial { ppr, pipe, brass }

/// תת-רשת של אביזר, כבר במסגרת-המקומית (מ״מ), עם חומר וסימון זרוע-הסתעפות.
/// `branchAxis` ⇒ החלק נפרס לאורך ציר-ההסתעפות (B) ולא ציר-המעלה (U) — לטי/רוכב.
@immutable
class ElementPart {
  const ElementPart(this.mesh, this.mat, {this.branchAxis = false});
  final Mesh mesh;
  final PartMaterial mat;
  final bool branchAxis;
}

/// גוף-האביזר: חלקיו + דלתות-הפריסה (`ex`/`ey`/`turn`) + סימון-קצה (`term`, פקק).
/// זהה ל-`layoutDeltaFor` בדלתות — הגיאומטריה וההתקדמות נגזרות יחד (כמו gen3d).
@immutable
class ElementMeshes {
  const ElementMeshes(this.parts,
      {required this.ex, required this.ey, required this.turn, this.term = false,});
  final List<ElementPart> parts;
  final double ex;
  final double ey;
  final double turn;
  final bool term;
}

/// גוף-האביזר של (family, od[, od2]) — פורט 1:1 מ-`elemMeshes`. משפחה לא-נתמכת
/// (ברך-מחותכת / לא-מוכר) → `null` (fallback · ה-assembler מדלג · M1).
ElementMeshes? elementMeshesFor(String family, int od, {int? od2}) {
  if (!_kSupported.contains(family)) return null;
  final g = generate(family, od, od2: od2);

  if (family == 'מצמד') {
    final bore = g['C']! / 2;
    final a = g['A']!;
    return ElementMeshes(
      [ElementPart(tube(0, a, g['B']! / 2, bore), PartMaterial.ppr)],
      ex: a,
      ey: 0,
      turn: 0,
    );
  }

  if (family == 'ברך 90°' || family == 'ברך 45°') {
    final l = g['l']!;
    final bore = g['C']! / 2;
    final ro = g['D']! / 2;
    final t = (family.contains('45') ? 45 : 90) * math.pi / 180;
    final arm = tube(0, l, ro, bore);
    return ElementMeshes(
      [
        ElementPart(arm, PartMaterial.ppr),
        ElementPart(_xf(sphere(ro * 1.02, 18, 26), tx: l), PartMaterial.ppr),
        ElementPart(_xf(arm, rotZ: t, tx: l), PartMaterial.ppr),
      ],
      ex: l + l * math.cos(t),
      ey: l * math.sin(t),
      turn: t,
    );
  }

  if (family == 'מסעף (טי)') {
    final e = g['E']!;
    final bore = g['C']! / 2;
    final ro = g['B']! / 2;
    final bh = g['A']!;
    final f = g['F']!;
    final id = g['ID']! / 2;
    ElementPart up(Mesh m, PartMaterial mat) =>
        ElementPart(_xf(m, rotZ: math.pi / 2, tx: e / 2), mat, branchAxis: true);
    return ElementMeshes(
      [
        ElementPart(tube(0, e, ro, bore), PartMaterial.ppr),
        ElementPart(_xf(sphere(ro * 1.02, 18, 26), tx: e / 2), PartMaterial.ppr),
        up(tube(ro * 0.5, bh, ro, bore), PartMaterial.ppr),
        up(tube(bh - f, bh + _kStub, od / 2 * 0.98, id), PartMaterial.pipe),
      ],
      ex: e,
      ey: 0,
      turn: 0,
    );
  }

  if (family == 'מתאם תבריג') {
    final f = g['F']!;
    final bore = g['C']! / 2;
    final id = g['ID']! / 2;
    final l = g['l']!;
    return ElementMeshes(
      [
        ElementPart(tube(0, f + 3, g['B']! / 2, bore), PartMaterial.ppr),
        ElementPart(
            hexRod(6, g['hex']! / 2, od * 0.55, f + 3 + od * 0.28), PartMaterial.brass,),
        ElementPart(tube(f + 3 + od * 0.55, l, g['thread']! / 2, id), PartMaterial.brass),
      ],
      ex: l,
      ey: 0,
      turn: 0,
    );
  }

  if (family == 'ברז כדורי') {
    final f = g['F']!;
    final bore = g['C']! / 2;
    final l = 2 * f + od * 1.6;
    return ElementMeshes(
      [
        ElementPart(tube(0, l, g['D']! / 2, bore), PartMaterial.ppr),
        ElementPart(
          _xf(hexRod(4, od * 0.28, g['h']! * 0.62, l / 2), rotZ: 0.5, ty: g['D']! / 2),
          PartMaterial.brass,
        ),
      ],
      ex: l,
      ey: 0,
      turn: 0,
    );
  }

  if (family == 'מצרה') {
    final f = g['F1']!;
    final bore = g['C1']! / 2;
    final b = g['B1']!;
    final b2 = g['B2']! / 2;
    final c2 = g['C2']! / 2;
    final s2f = g['F2']!;
    return ElementMeshes(
      [
        ElementPart(tube(0, f, b / 2, bore), PartMaterial.ppr),
        ElementPart(
          revolve([
            [f, b / 2],
            [f + 4, b2],
            [f + 4 + s2f, b2],
            [f + 4 + s2f, c2],
            [f + 4, c2],
            [f, bore],
          ], 48,),
          PartMaterial.ppr,
        ),
      ],
      ex: f + 4 + s2f,
      ey: 0,
      turn: 0,
    );
  }

  if (family == 'פקק') {
    final f = g['F']!;
    final bore = g['C']! / 2;
    final cap = g['cap']!;
    final ro = g['B']! / 2;
    return ElementMeshes(
      [
        ElementPart(tube(0, f, ro, bore), PartMaterial.ppr),
        ElementPart(
          revolve([
            [f, ro],
            [f + cap, ro * 0.55],
            [f + cap, 0],
            [f, 0],
          ], 48,),
          PartMaterial.ppr,
        ),
      ],
      ex: f + cap,
      ey: 0,
      turn: 0,
      term: true,
    );
  }

  if (family == 'רוכב') {
    final f = g['F']!;
    final bore = g['C']! / 2;
    final id = g['ID']! / 2;
    final runL = g['d1']! * 0.9;
    final c = runL / 2;
    final l = g['l']!;
    ElementPart up(Mesh m, PartMaterial mat) =>
        ElementPart(_xf(m, rotZ: math.pi / 2, tx: c), mat, branchAxis: true);
    return ElementMeshes(
      [
        ElementPart(tube(0, runL, od / 2 * 0.98, id), PartMaterial.pipe),
        ElementPart(
            tube(c - od * 0.7, c + od * 0.7, od / 2 * 1.18, od / 2 * 0.99), PartMaterial.ppr,),
        up(tube(od / 2, l + od / 2, g['D']! / 2, bore), PartMaterial.ppr),
        up(tube(l + od / 2 - f, l + od / 2 + _kStub, od / 2 * 0.98, id), PartMaterial.pipe),
      ],
      ex: runL,
      ey: 0,
      turn: 0,
    );
  }

  if (family == 'צווארון') {
    final bore = g['C']! / 2;
    final a = g['A']!;
    var th = od * 0.18;
    if (th < 4) th = 4; // gen3d: max(4, od·0.18)
    return ElementMeshes(
      [
        ElementPart(tube(0, a, g['D']! / 2, bore), PartMaterial.ppr),
        ElementPart(tube(a, a + th, g['D1']! / 2, bore), PartMaterial.ppr),
      ],
      ex: a + th,
      ey: 0,
      turn: 0,
    );
  }

  return null; // unreachable (guarded by _kSupported)
}

/// צינור-מעבר בין שני קטרים (חיבור גדלים שונים) — פורט 1:1 מ-`taperGeom` (gen3d:174).
/// `oA→oB` קוטר-חיצוני · דופן ≈ ⅙. משמש את ה-assembler לצנרת-הריתוך בין אביזרים.
Mesh taperGeom(double len, double oA, double oB) {
  final rA = oA / 2 * 0.98;
  final rB = oB / 2 * 0.98;
  final iA = (oA - 2 * oA / 6) / 2;
  final iB = (oB - 2 * oB / 6) / 2;
  return revolve([
    [0, rA],
    [len * 0.4, rA],
    [len * 0.6, rB],
    [len, rB],
    [len, iB],
    [len * 0.6, iB],
    [len * 0.4, iA],
    [0, iA],
  ], 48,);
}

/// צינור ישר (אותו קוטר) — לצנרת-מעבר של קוטר-אחיד. פורט מ-`pipe()` ב-gen3d:333.
Mesh straightPipe(double len, double od) =>
    tube(0, len, od / 2 * 0.98, (od - 2 * od / 6) / 2);

/// אורך-קצה (STUB) ואורך-צנרת-מעבר (PIPELEN) — verbatim מ-gen3d (`:331`).
const double kStubLen = 26;
const double kPipeLen = 58;
const double _kStub = kStubLen;

/// המשפחות שיש להן גוף-אמת (זהה לקבוצת ה-turtle/envelope).
const Set<String> _kSupported = {
  'מצמד', 'ברך 90°', 'ברך 45°', 'מסעף (טי)', 'מתאם תבריג',
  'ברז כדורי', 'מצרה', 'פקק', 'רוכב', 'צווארון',
};

/// טרנספורם-מקומי (rotateZ ואז translate) מוטבע ברשת — נורמלים מסובבים בלבד.
/// תואם `M.mul(M.t(..),M.rotZ(θ))` ב-gen3d (translate אחרי rotate).
Mesh _xf(Mesh m, {double rotZ = 0, double tx = 0, double ty = 0, double tz = 0}) {
  final c = math.cos(rotZ);
  final s = math.sin(rotZ);
  final p = <double>[];
  final n = <double>[];
  for (var i = 0; i < m.vertexCount; i++) {
    final x = m.positions[i * 3];
    final y = m.positions[i * 3 + 1];
    final z = m.positions[i * 3 + 2];
    p.addAll([c * x - s * y + tx, s * x + c * y + ty, z + tz]);
    final nx = m.normals[i * 3];
    final ny = m.normals[i * 3 + 1];
    final nz = m.normals[i * 3 + 2];
    n.addAll([c * nx - s * ny, s * nx + c * ny, nz]);
  }
  return Mesh(p, n, m.indices);
}
