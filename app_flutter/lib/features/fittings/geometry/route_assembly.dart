// 🔌 מנוע-קטלוג-3D · renderer-polish 2: assembler-הרצף (ריתוך). פורט 1:1 מ-
// `gen3d.buildPlan` (`:324-352`), סקאלת-S מוסרת (מ״מ). מרכיב רצף-אביזרים למרחב-עולם:
// גוף-אמת פר-אביזר (`elementMeshesFor`) + **צנרת-מעבר בין אביזרים** (ה"ריתוך" שסוגר
// את מרווח-ה-45°) + ניתוב-turtle (F/U/Gram-Schmidt) + חומר פר-חלק.
//
// זה מחליף את ה-envelope-tube הצף (C4) ברצף-צנרת רציף ונאמן. מגודר · טהור · הכרטיס
// החי לא-נגוע. אפס גזירת-פיזיקה חדשה.

import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/element_meshes.dart';
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:flutter/foundation.dart' show immutable;

/// חלק מוגמר במרחב-עולם: רשת + חומר (לצביעה פר-חומר אצל הצייר).
@immutable
class WorldPart {
  const WorldPart(this.mesh, this.mat);
  final Mesh mesh;
  final PartMaterial mat;
}

/// כיוון-הפנייה (`dirVec` ב-gen3d): up→U · down→−U · right→side · left→−side.
Vec3 _dirVec(Dir d, Vec3 f, Vec3 u) {
  final side = f.cross(u).norm();
  return switch (d) {
    Dir.down => u.scale(-1),
    Dir.right => side,
    Dir.left => side.scale(-1),
    Dir.up => u,
  };
}

/// ממקם רשת-מקומית למרחב-עולם דרך מסגרת (P, F, axis): מקומי-X→F · Y→axis · Z→side,
/// `side = norm(F × axis)`. נורמלים מסובבים בלבד. (זהה ל-`emitAt` ב-gen3d.)
Mesh _place(Mesh local, Vec3 p, Vec3 f, Vec3 axis) {
  final side = f.cross(axis).norm();
  final wp = <double>[];
  final wn = <double>[];
  for (var v = 0; v < local.vertexCount; v++) {
    final lx = local.positions[v * 3];
    final ly = local.positions[v * 3 + 1];
    final lz = local.positions[v * 3 + 2];
    final w = p + f.scale(lx) + axis.scale(ly) + side.scale(lz);
    wp.addAll([w.x, w.y, w.z]);
    final nx = local.normals[v * 3];
    final ny = local.normals[v * 3 + 1];
    final nz = local.normals[v * 3 + 2];
    final n = (f.scale(nx) + axis.scale(ny) + side.scale(nz)).norm();
    wn.addAll([n.x, n.y, n.z]);
  }
  return Mesh(wp, wn, local.indices);
}

/// מרכיב `route` לרשימת-חלקים במרחב-עולם, כולל צנרת-המעבר בין האביזרים (ריתוך).
/// אביזר לא-פריס (משפחה בלי `elementMeshesFor`) מדולג (M1). פורט 1:1 מ-`buildPlan`.
List<WorldPart> assembleRoute(List<RunElement> route) {
  final out = <WorldPart>[];
  // רק אביזרים שיש להם גוף (משמיטים ברך-מחותכת/לא-מוכר — כמו ה-turtle).
  final steps = <({RunElement el, ElementMeshes em})>[];
  for (final el in route) {
    final em = elementMeshesFor(el.family.label, el.od, od2: el.od2);
    if (em != null) steps.add((el: el, em: em));
  }
  if (steps.isEmpty) return out;

  var p = const Vec3(0, 0, 0);
  var f = const Vec3(1, 0, 0);
  var u = const Vec3(0, 1, 0);

  void emitPipe(double len, int oA, int oB) {
    final geo = oA == oB
        ? straightPipe(len, oA.toDouble())
        : taperGeom(len, oA.toDouble(), oB.toDouble());
    out.add(WorldPart(_place(geo, p, f, u), PartMaterial.pipe));
    p = p + f.scale(len);
  }

  // צינור-הובלה (STUB) לפני האביזר הראשון.
  final firstOd = steps.first.el.od;
  emitPipe(kStubLen, firstOd, firstOd);
  var prev = firstOd;

  for (var i = 0; i < steps.length; i++) {
    final el = steps[i].el;
    final em = steps[i].em;
    if (i > 0) emitPipe(kPipeLen, prev, el.od); // צנרת-המעבר (ריתוך)

    final b = _dirVec(el.dir, f, u);
    for (final part in em.parts) {
      final axis = (part.branchAxis || em.turn != 0) ? b : u;
      out.add(WorldPart(_place(part.mesh, p, f, axis), part.mat));
    }

    final bendAxis = em.turn != 0 ? b : u;
    p = p + f.scale(em.ex) + bendAxis.scale(em.ey);
    if (em.turn != 0) {
      final t = em.turn;
      final nF = (f.scale(math.cos(t)) + b.scale(math.sin(t))).norm();
      final nB = (f.scale(-math.sin(t)) + b.scale(math.cos(t))).norm();
      var newU = u;
      if (el.dir == Dir.up) {
        newU = nB;
      } else if (el.dir == Dir.down) {
        newU = nB.scale(-1);
      }
      f = nF;
      u = (newU - f.scale(newU.dot(f))).norm(); // Gram-Schmidt: U ⟂ F
    }

    prev = el.family == Family.reducer ? (el.od2 ?? el.od) : el.od;
    if (em.term) return out; // פקק סוגר — בלי צינור-סיום
  }

  // צינור-סיום (STUB) כשהאחרון אינו פקק.
  emitPipe(kStubLen, prev, prev);
  return out;
}
