// 🔑 Phase C (step 41, vector turtle) — layoutRoute frame evolution ≡ gen3d.buildPlan.
// The intricate part is the Gram-Schmidt turn; verified by its invariants (a 90°
// elbow rotates forward [1,0,0]→[0,1,0]; frames stay orthonormal) without running JS.
import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void _expectVec(Vec3 a, Vec3 b, {double eps = 1e-9}) {
  expect(a.x, closeTo(b.x, eps));
  expect(a.y, closeTo(b.y, eps));
  expect(a.z, closeTo(b.z, eps));
}

void main() {
  test('empty route → empty layout', () {
    expect(layoutRoute(const []), isEmpty);
  });

  group('straight run — forward is preserved, position advances along +X', () {
    test('three couplers march along X', () {
      final r = layoutRoute(const [
        RunElement(Family.coupler, 32),
        RunElement(Family.coupler, 32),
        RunElement(Family.coupler, 32),
      ]);
      expect(r.length, 3);
      for (final p in r) {
        _expectVec(p.forward, const Vec3(1, 0, 0));
        expect(p.position.y, 0);
        expect(p.position.z, 0);
      }
      expect(r[1].position.x, greaterThan(r[0].position.x));
      expect(r[2].position.x, greaterThan(r[1].position.x));
    });
  });

  group('🔑 the turn — a 90° elbow (up) rotates the frame', () {
    final r = layoutRoute(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.elbow90, 32, dir: Dir.up),
      RunElement(Family.coupler, 32),
    ]);

    test('before the elbow forward is +X; after it is +Y (turned up)', () {
      _expectVec(r[0].forward, const Vec3(1, 0, 0));
      _expectVec(r[1].forward, const Vec3(1, 0, 0)); // the elbow itself sits pre-turn
      _expectVec(r[2].forward, const Vec3(0, 1, 0)); // the run now goes up
    });

    test('the element after the elbow is displaced in +Y', () {
      expect(r[2].position.y, greaterThan(0));
    });
  });

  test('a 45° elbow rotates forward by 45° → (cos45, sin45, 0)', () {
    final r = layoutRoute(const [
      RunElement(Family.elbow45, 32, dir: Dir.up),
      RunElement(Family.coupler, 32),
    ]);
    final c = math.cos(math.pi / 4);
    final s = math.sin(math.pi / 4);
    _expectVec(r[1].forward, Vec3(c, s, 0));
  });

  test('every frame stays orthonormal (|F|=1, |U|=1, F⟂U)', () {
    final r = layoutRoute(const [
      RunElement(Family.coupler, 50),
      RunElement(Family.elbow90, 50, dir: Dir.up),
      RunElement(Family.elbow45, 50),
      RunElement(Family.tee, 50),
      RunElement(Family.elbow90, 50, dir: Dir.down),
    ]);
    for (final p in r) {
      expect(p.forward.length, closeTo(1, 1e-9));
      expect(p.up.length, closeTo(1, 1e-9));
      expect(p.forward.dot(p.up), closeTo(0, 1e-9)); // orthogonal
    }
  });

  test('a plug terminates the run', () {
    final r = layoutRoute(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.plug, 32),
      RunElement(Family.coupler, 32), // must be dropped — run ended
    ]);
    expect(r.length, 2);
    expect(r.last.family, 'פקק');
  });

  test('an unrenderable family is skipped (M1 fallback)', () {
    final r = layoutRoute(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.miteredElbow, 200), // not a turtle family
      RunElement(Family.coupler, 32),
    ]);
    expect(r.length, 2); // mitered dropped
  });
}
