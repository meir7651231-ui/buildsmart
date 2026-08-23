// 🔑 Phase C (renderer, step 1) — route-preview meshes: each fitting becomes an
// envelope-sized tube placed into its turtle frame (world-space). The golden proof:
// the identity-frame fitting is centred on the X axis (world = P + F·lx + U·ly +
// side·lz collapses to identity when P=0, F=x̂, U=ŷ, side=ẑ); a 90°-up elbow lifts
// downstream fittings into +Y; every placed mesh stays watertight & unit-normal.
import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:buildsmart/features/fittings/geometry/route_meshes.dart';
import 'package:buildsmart/features/fittings/plan/envelope.dart';
import 'package:flutter_test/flutter_test.dart';

void _wellFormed(Mesh m) {
  expect(m.positions.length % 3, 0);
  expect(m.normals.length, m.positions.length);
  expect(m.indices.length % 3, 0);
  for (final i in m.indices) {
    expect(i, inInclusiveRange(0, m.vertexCount - 1));
  }
  for (final c in m.positions) {
    expect(c.isFinite, isTrue);
  }
  for (var v = 0; v < m.vertexCount; v++) {
    final nx = m.normals[v * 3];
    final ny = m.normals[v * 3 + 1];
    final nz = m.normals[v * 3 + 2];
    expect(math.sqrt(nx * nx + ny * ny + nz * nz), closeTo(1, 1e-9),
        reason: 'normal $v not unit',);
  }
}

double _mean(Mesh m, int axis) {
  var sum = 0.0;
  for (var v = 0; v < m.vertexCount; v++) {
    sum += m.positions[v * 3 + axis];
  }
  return sum / m.vertexCount;
}

void main() {
  test('empty route → no meshes', () {
    expect(buildRoutePreviewMeshes(const []), isEmpty);
  });

  test('one mesh per renderable placement; each a watertight 768-vert tube', () {
    final meshes = buildRoutePreviewMeshes(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.coupler, 32),
      RunElement(Family.coupler, 32),
    ]);
    expect(meshes.length, 3);
    for (final m in meshes) {
      expect(m.vertexCount, 4 * 48 * 4); // tube default seg=48 → 768
      _wellFormed(m);
    }
  });

  test('🔑 identity frame ⇒ placed tube is centred on the X axis, spanning its axial length', () {
    final meshes = buildRoutePreviewMeshes(const [
      RunElement(Family.coupler, 40),
    ]);
    expect(meshes, hasLength(1));
    final m = meshes.first;
    // P=(0,0,0), F=x̂, U=ŷ, side=ẑ ⇒ world = (lx, ly, lz): identity transform.
    // A local tube runs along +X and is radially symmetric ⇒ mean Y≈0, mean Z≈0.
    expect(_mean(m, 1), closeTo(0, 1e-9));
    expect(_mean(m, 2), closeTo(0, 1e-9));
    // and it spans [0, axialLength] on X — anchored to the engine envelope.
    final env = envelopeFor(Family.coupler.label, 40)!;
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    for (var v = 0; v < m.vertexCount; v++) {
      final x = m.positions[v * 3];
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
    }
    expect(minX, closeTo(0, 1e-9));
    expect(maxX, closeTo(env.axialLength, 1e-9));
  });

  test('🔑 a 90°-up elbow lifts downstream fittings into +Y', () {
    final meshes = buildRoutePreviewMeshes(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.elbow90, 32, dir: Dir.up),
      RunElement(Family.coupler, 32),
    ]);
    expect(meshes, hasLength(3));
    // Pre-turn fittings sit on the X axis (mean Y≈0); the fitting after the
    // elbow is displaced upward (mean Y strictly positive, well past float noise).
    expect(_mean(meshes[0], 1), closeTo(0, 1e-6));
    expect(_mean(meshes[2], 1), greaterThan(1));
  });

  test('an unrenderable family is skipped (M1 fallback) — no phantom mesh', () {
    final meshes = buildRoutePreviewMeshes(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.miteredElbow, 200), // dropped by the turtle
      RunElement(Family.coupler, 32),
    ]);
    expect(meshes.length, 2);
  });

  test('a plug terminates the run — nothing past it is meshed', () {
    final meshes = buildRoutePreviewMeshes(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.plug, 32),
      RunElement(Family.coupler, 32), // must not appear
    ]);
    expect(meshes.length, 2);
  });
}
