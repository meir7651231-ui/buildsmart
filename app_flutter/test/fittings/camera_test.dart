// 🔑 Phase C (renderer, step 2) — camera/projection golden: the pure port of
// gen3d's persp/look/eye. Verified by the invariants that make a 3D camera correct
// (the target projects to screen centre; +Y lands above centre; farther points get
// larger depth; behind-camera points are culled) plus the exact gen3d formulae —
// without running any WebGL.
import 'dart:math' as math;

import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:buildsmart/features/fittings/render/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('perspective — gen3d M.persp formula', () {
    test('structural: t=1/tan(f/2), m[11]=-1, aspect scales m[0]', () {
      final p = perspective(kDefaultFov, 2, 0.1, 100);
      final t = 1 / math.tan(kDefaultFov / 2);
      expect(p.m[0], closeTo(t / 2, 1e-12)); // t/aspect
      expect(p.m[5], closeTo(t, 1e-12));
      expect(p.m[10], closeTo((100 + 0.1) / (0.1 - 100), 1e-12));
      expect(p.m[11], -1);
      expect(p.m[14], closeTo(2 * 100 * 0.1 / (0.1 - 100), 1e-12));
      expect(p.m[15], 0);
    });

    test('aspect=1 ⇒ x and y scales equal', () {
      final p = perspective(kDefaultFov, 1, 0.1, 100);
      expect(p.m[0], closeTo(p.m[5], 1e-12));
    });
  });

  group('lookAt — gen3d M.look', () {
    test('eye on +Z, target origin ⇒ origin maps to (0,0,-dist)', () {
      final v = lookAt(const Vec3(0, 0, 6), const Vec3(0, 0, 0), const Vec3(0, 1, 0));
      final o = v.apply(const Vec3(0, 0, 0));
      expect(o.x, closeTo(0, 1e-12));
      expect(o.y, closeTo(0, 1e-12));
      expect(o.z, closeTo(-6, 1e-12));
      expect(o.w, closeTo(1, 1e-12));
    });
  });

  group('orbitEye — gen3d eye()', () {
    test('yaw=0,pitch=0 ⇒ straight down +Z at distance', () {
      final e = orbitEye(const Vec3(0, 0, 0), 6, 0, 0);
      expect(e.x, closeTo(0, 1e-12));
      expect(e.y, closeTo(0, 1e-12));
      expect(e.z, closeTo(6, 1e-12));
    });
    test('yaw=π/2 ⇒ swings onto +X', () {
      final e = orbitEye(const Vec3(0, 0, 0), 6, math.pi / 2, 0);
      expect(e.x, closeTo(6, 1e-12));
      expect(e.z, closeTo(0, 1e-9));
    });
  });

  group('projectToScreen', () {
    const w = 400.0;
    const h = 300.0;
    final proj = perspective(kDefaultFov, w / h, 0.1, 100);

    test('🔑 the camera target projects to screen centre (default orbit)', () {
      const target = Vec3(0, 0, 0);
      final eye = orbitEye(target, 6, kDefaultYaw, kDefaultPitch);
      final view = lookAt(eye, target, const Vec3(0, 1, 0));
      final s = projectToScreen(proj, view, target, w, h);
      expect(s.visible, isTrue);
      expect(s.x, closeTo(w / 2, 1e-6));
      expect(s.y, closeTo(h / 2, 1e-6));
    });

    test('🔑 a point above the target lands above screen centre (+Y → smaller sy)', () {
      // Straight-on camera (no orbit tilt) isolates the vertical mapping.
      const target = Vec3(0, 0, 0);
      final view = lookAt(const Vec3(0, 0, 6), target, const Vec3(0, 1, 0));
      final up = projectToScreen(proj, view, const Vec3(0, 2, 0), w, h);
      final down = projectToScreen(proj, view, const Vec3(0, -2, 0), w, h);
      expect(up.visible, isTrue);
      expect(down.visible, isTrue);
      expect(up.y, lessThan(h / 2)); // above centre
      expect(down.y, greaterThan(h / 2)); // below centre
    });

    test('🔑 farther points get larger depth (painter sorts far→near)', () {
      final view = lookAt(const Vec3(0, 0, 6), const Vec3(0, 0, 0), const Vec3(0, 1, 0));
      final near = projectToScreen(proj, view, const Vec3(0, 0, 0), w, h); // dist 6
      final far = projectToScreen(proj, view, const Vec3(0, 0, -4), w, h); // dist 10
      expect(near.visible, isTrue);
      expect(far.visible, isTrue);
      expect(far.depth, greaterThan(near.depth));
    });

    test('🔑 a point behind the camera is culled (w ≤ 0)', () {
      final view = lookAt(const Vec3(0, 0, 6), const Vec3(0, 0, 0), const Vec3(0, 1, 0));
      final behind = projectToScreen(proj, view, const Vec3(0, 0, 10), w, h);
      expect(behind.visible, isFalse);
    });
  });

  group('Mat4.mul — column-major, matches applying b then a', () {
    test('proj·view·v ≡ proj.mul(view).apply(v)', () {
      const target = Vec3(0, 0, 0);
      final view = lookAt(const Vec3(0, 0, 6), target, const Vec3(0, 1, 0));
      final proj = perspective(kDefaultFov, 1, 0.1, 100);
      const v = Vec3(1, 2, -3);
      final combined = proj.mul(view).apply(v);
      // apply proj to (view·v) separately
      final vv = view.apply(v);
      final stepwise = proj.apply(Vec3(vv.x, vv.y, vv.z), w: vv.w);
      expect(combined.x, closeTo(stepwise.x, 1e-9));
      expect(combined.y, closeTo(stepwise.y, 1e-9));
      expect(combined.z, closeTo(stepwise.z, 1e-9));
      expect(combined.w, closeTo(stepwise.w, 1e-9));
    });
  });
}
