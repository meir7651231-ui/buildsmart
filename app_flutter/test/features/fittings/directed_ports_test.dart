import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/directed_ports.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('directedPortsOf — D12 directed-port primitive', () {
    test('coupler → two opposing straight ports (−X, +X)', () {
      final ports = directedPortsOf(const RunElement(Family.coupler, 32));
      expect(ports, hasLength(2));
      expect(ports[0].dir, const Vec3(-1, 0, 0));
      expect(ports[0].od, 32);
      // outlet is +X (through-flow), trig-derived so compare component-wise.
      expect(ports[1].dir.x, closeTo(1, 1e-9));
      expect(ports[1].dir.y, closeTo(0, 1e-9));
      expect(ports[1].dir.z, closeTo(0, 1e-9));
    });

    test('plug → a single inlet port (−X)', () {
      final ports = directedPortsOf(const RunElement(Family.plug, 40));
      expect(ports, hasLength(1));
      expect(ports.single.dir, const Vec3(-1, 0, 0));
      expect(ports.single.od, 40);
    });

    test('tee → 3 ports: inlet −X, outlet +X, branch along Dir', () {
      final ports =
          directedPortsOf(const RunElement(Family.tee, 50, dir: Dir.up));
      expect(ports, hasLength(3));
      expect(ports[0].dir, const Vec3(-1, 0, 0));
      expect(ports[1].dir, const Vec3(1, 0, 0));
      expect(ports[2].dir, const Vec3(0, 0, 1)); // up ⇒ +Z branch
    });

    test('tee branch follows the Dir hint', () {
      expect(
        directedPortsOf(const RunElement(Family.tee, 50))[2].dir,
        const Vec3(0, -1, 0), // default right ⇒ −Y
      );
      expect(
        directedPortsOf(const RunElement(Family.tee, 50, dir: Dir.left))[2].dir,
        const Vec3(0, 1, 0), // left ⇒ +Y
      );
    });

    test('elbow90 → outlet perpendicular to the inlet line', () {
      final ports = directedPortsOf(const RunElement(Family.elbow90, 32));
      expect(ports, hasLength(2));
      expect(ports[0].dir, const Vec3(-1, 0, 0));
      final out = ports[1].dir;
      // default Dir.right ⇒ 90° bend toward −Y ⇒ ~ (0, −1, 0)
      expect(out.x, closeTo(0, 1e-9));
      expect(out.y, closeTo(-1, 1e-9));
      expect(out.z, closeTo(0, 1e-9));
      // the through-forward (+X) is perpendicular to the outlet.
      expect(out.dot(const Vec3(1, 0, 0)), closeTo(0, 1e-9));
    });

    test('elbow45 → outlet at 45° from the through-forward', () {
      final out =
          directedPortsOf(const RunElement(Family.elbow45, 32, dir: Dir.up))[1]
              .dir;
      expect(out.dot(const Vec3(1, 0, 0)), closeTo(math.cos(math.pi / 4), 1e-9));
      expect(out.length, closeTo(1, 1e-9));
    });

    test('reducer → the outlet port carries od2', () {
      final ports =
          directedPortsOf(const RunElement(Family.reducer, 50, od2: 32));
      expect(ports, hasLength(2));
      expect(ports[0].od, 50);
      expect(ports[1].od, 32);
    });

    test('every family: correct port count + all unit vectors', () {
      expect(directedPortsOf(const RunElement(Family.coupler, 32)), hasLength(2));
      expect(directedPortsOf(const RunElement(Family.elbow90, 32)), hasLength(2));
      expect(directedPortsOf(const RunElement(Family.elbow45, 32)), hasLength(2));
      expect(directedPortsOf(const RunElement(Family.tee, 32)), hasLength(3));
      expect(directedPortsOf(const RunElement(Family.saddle, 32)), hasLength(3));
      expect(directedPortsOf(const RunElement(Family.plug, 32)), hasLength(1));
      for (final f in Family.values) {
        for (final p in directedPortsOf(RunElement(f, 32))) {
          expect(p.dir.length, closeTo(1, 1e-9), reason: '$f port not unit');
        }
      }
    });
  });
}
