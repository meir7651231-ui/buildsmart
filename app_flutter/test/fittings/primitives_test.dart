// 🔑 Phase C (step 42) — mesh primitives golden: counts, gen3d parity, and the
// geometric invariants (unit normals, in-range indices, watertight structure).
import 'dart:math' as math;

import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:flutter_test/flutter_test.dart';

void _wellFormed(Mesh m) {
  expect(m.positions.length % 3, 0);
  expect(m.normals.length, m.positions.length);
  expect(m.indices.length % 3, 0);
  // every index addresses a real vertex
  for (final i in m.indices) {
    expect(i, inInclusiveRange(0, m.vertexCount - 1));
  }
  // every coordinate finite
  for (final c in m.positions) {
    expect(c.isFinite, isTrue);
  }
  // normals are unit-length
  for (var v = 0; v < m.vertexCount; v++) {
    final nx = m.normals[v * 3];
    final ny = m.normals[v * 3 + 1];
    final nz = m.normals[v * 3 + 2];
    expect(math.sqrt(nx * nx + ny * ny + nz * nz), closeTo(1, 1e-9),
        reason: 'normal $v not unit',);
  }
}

void main() {
  group('revolve — vertex/triangle counts (gen3d parity)', () {
    test('N-edge profile × seg → N·seg·4 verts, N·seg·2 tris', () {
      final m = revolve(const [
        [0.0, 5.0],
        [10.0, 5.0],
        [10.0, 3.0],
        [0.0, 3.0],
      ], 16,);
      expect(m.vertexCount, 4 * 16 * 4);
      expect(m.triangleCount, 4 * 16 * 2);
      _wellFormed(m);
    });

    test('a revolve places the profile at angle 0 → (x, r, 0)', () {
      final m = revolve(const [
        [2.0, 7.0],
        [9.0, 7.0],
      ], 8,);
      // first vertex = p0 at angle 0: (x=2, r·cos0=7, r·sin0=0)
      expect(m.positions[0], 2.0);
      expect(m.positions[1], closeTo(7.0, 1e-12));
      expect(m.positions[2], closeTo(0.0, 1e-12));
    });
  });

  test('tube = a 4-point revolve at seg=48 → 768 verts (gen3d)', () {
    final m = tube(0, 40, 16, 10);
    expect(m.vertexCount, 4 * 48 * 4); // 768
    expect(m.triangleCount, 4 * 48 * 2); // 384
    _wellFormed(m);
  });

  test('hexRod(6) → 24 verts, 12 tris; a generic prism scales with sides', () {
    final hex = hexRod(6, 12, 30, 0);
    expect(hex.vertexCount, 6 * 4);
    expect(hex.triangleCount, 6 * 2);
    _wellFormed(hex);
    expect(hexRod(4, 8, 20, 5).vertexCount, 4 * 4); // square rod
  });

  test('sphere(r, la, lo) → (la+1)(lo+1) verts, la·lo·2 tris; on the radius', () {
    final s = sphere(6, 12, 16);
    expect(s.vertexCount, 13 * 17);
    expect(s.triangleCount, 12 * 16 * 2);
    _wellFormed(s);
    // every vertex sits on the sphere of radius r
    for (var v = 0; v < s.vertexCount; v++) {
      final x = s.positions[v * 3];
      final y = s.positions[v * 3 + 1];
      final z = s.positions[v * 3 + 2];
      expect(math.sqrt(x * x + y * y + z * z), closeTo(6, 1e-9));
    }
  });
}
