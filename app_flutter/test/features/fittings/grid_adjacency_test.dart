import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/grid_adjacency.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('grid adjacency — D12 continuous→discrete bridge', () {
    test('snapToGrid maps axis unit vectors to lattice steps', () {
      expect(snapToGrid(const Vec3(1, 0, 0)), GridStep.east);
      expect(snapToGrid(const Vec3(-1, 0, 0)), GridStep.west);
      expect(snapToGrid(const Vec3(0, 1, 0)), GridStep.north);
      expect(snapToGrid(const Vec3(0, -1, 0)), GridStep.south);
      expect(snapToGrid(const Vec3(0, 0, 1)), GridStep.above);
      expect(snapToGrid(const Vec3(0, 0, -1)), GridStep.below);
    });

    test('snapToGrid absorbs trig dust but rejects 45° diagonals', () {
      // cos(π/2) ≈ 6.12e-17 — still snaps to the axis.
      expect(snapToGrid(Vec3(math.cos(math.pi / 2), -1, 0)), GridStep.south);
      // A 45° outlet is diagonal — no lattice step.
      const d = math.sqrt1_2; // ≈ 0.707
      expect(snapToGrid(const Vec3(d, -d, 0)), isNull);
    });

    test('opposite + vec are self-consistent for every step', () {
      for (final s in GridStep.values) {
        expect(s.opposite.opposite, s);
        expect(snapToGrid(s.vec), s);
        expect(snapToGrid(s.opposite.vec), snapToGrid(s.vec.scale(-1)));
      }
    });

    test('portsFace: opposing steps face; same/perpendicular/diagonal do not', () {
      expect(portsFace(const Vec3(1, 0, 0), const Vec3(-1, 0, 0)), isTrue);
      expect(portsFace(const Vec3(0, 0, 1), const Vec3(0, 0, -1)), isTrue);
      expect(portsFace(const Vec3(1, 0, 0), const Vec3(1, 0, 0)), isFalse);
      expect(portsFace(const Vec3(1, 0, 0), const Vec3(0, 1, 0)), isFalse);
      const d = math.sqrt1_2;
      expect(portsFace(const Vec3(d, d, 0), const Vec3(-d, -d, 0)), isFalse);
    });

    test('gridPortsOf snaps a fitting to its lattice steps', () {
      // coupler: inlet −X=west, outlet +X=east.
      expect(
        gridPortsOf(const RunElement(Family.coupler, 32)),
        [GridStep.west, GridStep.east],
      );
      // elbow90 (default Dir.right): inlet west, outlet south (0,−1,0).
      expect(
        gridPortsOf(const RunElement(Family.elbow90, 32)),
        [GridStep.west, GridStep.south],
      );
      // tee up: west, east, above.
      expect(
        gridPortsOf(const RunElement(Family.tee, 50, dir: Dir.up)),
        [GridStep.west, GridStep.east, GridStep.above],
      );
      // elbow45 outlet is diagonal ⇒ dropped; only the inlet snaps.
      expect(
        gridPortsOf(const RunElement(Family.elbow45, 32)),
        [GridStep.west],
      );
    });
  });
}
