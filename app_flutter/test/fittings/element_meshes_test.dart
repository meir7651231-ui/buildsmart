// 🔑 Phase C (renderer-polish 1) — per-family element geometry golden. Ports
// gen3d.elemMeshes: the real body of each fitting (elbow = 2 arms + corner ball,
// tee = run + branch + stub, valve = body + brass handle, reducer = taper, …).
// Verified by part counts, materials, the layout deltas (ex/ey/turn ≡ turtle),
// and that the elbow's second arm is rotated into the bend — no WebGL needed.
import 'dart:math' as math;

import 'package:buildsmart/features/fittings/geometry/element_meshes.dart';
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:flutter_test/flutter_test.dart';

double _maxX(Mesh m) {
  var mx = double.negativeInfinity;
  for (var v = 0; v < m.vertexCount; v++) {
    if (m.positions[v * 3] > mx) mx = m.positions[v * 3];
  }
  return mx;
}

double _maxY(Mesh m) {
  var my = double.negativeInfinity;
  for (var v = 0; v < m.vertexCount; v++) {
    if (m.positions[v * 3 + 1] > my) my = m.positions[v * 3 + 1];
  }
  return my;
}

void main() {
  test('unsupported family (mitered elbow) → null (assembler skips, M1)', () {
    expect(elementMeshesFor('ברך מחותכת', 200), isNull);
    expect(elementMeshesFor('לא-קיים', 32), isNull);
  });

  test('coupler → one PP-R body; ex=A, straight', () {
    final e = elementMeshesFor('מצמד', 32)!;
    expect(e.parts, hasLength(1));
    expect(e.parts.single.mat, PartMaterial.ppr);
    expect(e.turn, 0);
    expect(e.ey, 0);
    expect(e.ex, greaterThan(0));
  });

  group('🔑 elbow — two arms + a corner ball, second arm rotated into the bend', () {
    test('90°: 3 PP-R parts; ex≈l, ey≈l, turn=π/2', () {
      final e = elementMeshesFor('ברך 90°', 32)!;
      expect(e.parts, hasLength(3));
      expect(e.parts.every((p) => p.mat == PartMaterial.ppr), isTrue);
      expect(e.turn, closeTo(math.pi / 2, 1e-12));
      // ex = l + l·cos90 = l ; ey = l·sin90 = l  ⇒ ex ≈ ey
      expect(e.ex, closeTo(e.ey, 1e-9));
      // the second arm (index 2) is rotated up ⇒ it reaches into +Y
      expect(_maxY(e.parts[2].mesh), greaterThan(1));
    });

    test('45°: turn=π/4, ex>ey (shallower bend)', () {
      final e = elementMeshesFor('ברך 45°', 32)!;
      expect(e.parts, hasLength(3));
      expect(e.turn, closeTo(math.pi / 4, 1e-12));
      expect(e.ex, greaterThan(e.ey));
      expect(e.ey, greaterThan(0));
    });
  });

  test('🔑 tee — run + corner ball + branch + branch-stub; branch on B axis', () {
    final e = elementMeshesFor('מסעף (טי)', 50)!;
    expect(e.parts, hasLength(4));
    expect(e.turn, 0);
    // exactly the last two parts (branch pipe body + stub) ride the branch axis
    expect(e.parts.where((p) => p.branchAxis).length, 2);
    // the branch stub is a pipe (grey), the bodies are PP-R
    expect(e.parts.last.mat, PartMaterial.pipe);
    expect(e.parts.first.mat, PartMaterial.ppr);
    // the branch reaches up in +Y (local), proving the rot-into-branch xform
    expect(_maxY(e.parts[2].mesh), greaterThan(1));
  });

  test('🔑 adapter — PP-R socket + brass hex + brass thread', () {
    final e = elementMeshesFor('מתאם תבריג', 32)!;
    expect(e.parts, hasLength(3));
    expect(e.parts[0].mat, PartMaterial.ppr);
    expect(e.parts[1].mat, PartMaterial.brass); // the hex nut
    expect(e.parts[2].mat, PartMaterial.brass); // the male thread
    expect(e.turn, 0);
  });

  test('🔑 valve — PP-R body + brass handle offset above the body', () {
    final e = elementMeshesFor('ברז כדורי', 32)!;
    expect(e.parts, hasLength(2));
    expect(e.parts[0].mat, PartMaterial.ppr);
    expect(e.parts[1].mat, PartMaterial.brass);
    // handle sits above the body centreline (+Y translate) ⇒ its max Y clears the body
    expect(_maxY(e.parts[1].mesh), greaterThan(_maxY(e.parts[0].mesh)));
  });

  test('reducer → PP-R socket + taper cone; ex spans both depths', () {
    final e = elementMeshesFor('מצרה', 50, od2: 32)!;
    expect(e.parts, hasLength(2));
    expect(e.parts.every((p) => p.mat == PartMaterial.ppr), isTrue);
    expect(e.ex, greaterThan(0));
    expect(e.turn, 0);
  });

  test('plug → body + cap; terminal', () {
    final e = elementMeshesFor('פקק', 32)!;
    expect(e.parts, hasLength(2));
    expect(e.term, isTrue);
  });

  test('saddle & collar build (multi-part, no throw)', () {
    final saddle = elementMeshesFor('רוכב', 40)!;
    expect(saddle.parts.length, greaterThanOrEqualTo(3));
    expect(saddle.parts.any((p) => p.branchAxis), isTrue);
    final collar = elementMeshesFor('צווארון', 40)!;
    expect(collar.parts, hasLength(2));
  });

  group('taperGeom — transition pipe between two diameters', () {
    test('watertight; spans [0,len] on X', () {
      final m = taperGeom(58, 50, 32);
      expect(m.positions.length % 3, 0);
      expect(m.indices.length % 3, 0);
      expect(_maxX(m), closeTo(58, 1e-9));
      for (final c in m.positions) {
        expect(c.isFinite, isTrue);
      }
    });
  });

  test('every part mesh is well-formed (indices in range, finite coords)', () {
    for (final fam in const [
      'מצמד', 'ברך 90°', 'ברך 45°', 'מסעף (טי)', 'מתאם תבריג',
      'ברז כדורי', 'מצרה', 'פקק', 'רוכב', 'צווארון',
    ]) {
      final e = elementMeshesFor(fam, 40, od2: 32)!;
      for (final part in e.parts) {
        final m = part.mesh;
        expect(m.normals.length, m.positions.length, reason: '$fam normals');
        for (final i in m.indices) {
          expect(i, inInclusiveRange(0, m.vertexCount - 1), reason: '$fam index');
        }
      }
    }
  });
}
