// 🔑 Phase C (renderer, step 3a) — mesh projector golden: world triangles →
// depth-sorted, Lambert-shaded screen triangles. Verified by the invariants a
// painter relies on (far→near ordering; two-sided shade in [ambient,1]; behind-
// camera triangles culled; a real route projects to a non-empty, ordered set).
import 'dart:ui' show Size;

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/element_meshes.dart'
    show PartMaterial;
import 'package:buildsmart/features/fittings/geometry/primitives.dart';
import 'package:buildsmart/features/fittings/geometry/route_assembly.dart'
    show WorldPart;
import 'package:buildsmart/features/fittings/geometry/route_meshes.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:buildsmart/features/fittings/render/camera.dart';
import 'package:buildsmart/features/fittings/render/mesh_projector.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = Size(400, 300);

// A camera that frames a target at the gen3d default angle/distance.
({Mat4 proj, Mat4 view, Vec3 eye}) _camera(Vec3 target, double dist) {
  final proj = perspective(kDefaultFov, _size.width / _size.height, 0.1, 1000);
  final eye = orbitEye(target, dist, kDefaultYaw, kDefaultPitch);
  final view = lookAt(eye, target, const Vec3(0, 1, 0));
  return (proj: proj, view: view, eye: eye);
}

double _maxSpecular(List<RenderTriangle> tris) =>
    tris.fold(0, (m, t) => t.specular > m ? t.specular : m);

void main() {
  test('empty meshes → no triangles', () {
    final cam = _camera(const Vec3(0, 0, 0), 100);
    expect(projectMeshes(const [], cam.proj, cam.view, cam.eye, _size), isEmpty);
  });

  group('🔑 specular highlights (P4 — gen3d-lite Blinn-Phong + Fresnel)', () {
    final tubeMesh = tube(-20, 20, 16, 10);
    final cam = _camera(const Vec3(0, 0, 0), 120);

    List<RenderTriangle> asMat(PartMaterial mat) => projectParts(
          [WorldPart(tubeMesh, mat)], cam.proj, cam.view, cam.eye, _size,);

    test('every specular ∈ [0,1]; a lit tube shows at least one highlight', () {
      final tris = asMat(PartMaterial.ppr);
      expect(tris, isNotEmpty);
      for (final t in tris) {
        expect(t.specular, inInclusiveRange(0, 1));
      }
      expect(_maxSpecular(tris), greaterThan(0.0)); // a highlight exists
    });

    test('brass (glossy metal) peaks brighter than PP-R (rough dielectric)', () {
      // Same geometry & camera — only the material changes. Brass has lower
      // roughness (sharper, taller peak) + higher F0 ⇒ a stronger highlight.
      expect(_maxSpecular(asMat(PartMaterial.brass)),
          greaterThan(_maxSpecular(asMat(PartMaterial.ppr))),);
    });

    test('projectMeshes (no material) still yields finite specular in range', () {
      final tris = projectMeshes([tubeMesh], cam.proj, cam.view, cam.eye, _size);
      for (final t in tris) {
        expect(t.specular, inInclusiveRange(0, 1));
      }
    });
  });

  group('meshBounds — camera framing', () {
    test('empty → origin/unit fallback (no divide-by-zero)', () {
      final b = meshBounds(const []);
      expect(b.center, const Vec3(0, 0, 0));
      expect(b.radius, 1);
    });

    test('a centred tube → centre≈origin, radius≈half the longest extent', () {
      final b = meshBounds([tube(-20, 20, 16, 10)]); // X spans 40, radial ±16
      expect(b.center.x, closeTo(0, 1e-9));
      expect(b.center.y, closeTo(0, 1e-9));
      expect(b.center.z, closeTo(0, 1e-9));
      expect(b.radius, closeTo(20, 1e-9)); // half of the 40mm axial extent
    });
  });

  group('a single tube facing the camera', () {
    // A tube along X, centred near origin; frame it from the default angle.
    final tubeMesh = tube(-20, 20, 16, 10);
    final cam = _camera(const Vec3(0, 0, 0), 120);
    final tris = projectMeshes([tubeMesh], cam.proj, cam.view, cam.eye, _size);

    test('projects to a non-empty triangle set', () {
      expect(tris, isNotEmpty);
      // never more than the source triangles (some may be culled behind camera)
      expect(tris.length, lessThanOrEqualTo(tubeMesh.triangleCount));
    });

    test('🔑 sorted far→near (depth strictly non-increasing)', () {
      for (var i = 1; i < tris.length; i++) {
        expect(tris[i - 1].depth, greaterThanOrEqualTo(tris[i].depth));
      }
    });

    test('🔑 every shade is two-sided-lit ∈ [ambient, 1]', () {
      for (final t in tris) {
        expect(t.shade, greaterThanOrEqualTo(kAmbient - 1e-9));
        expect(t.shade, lessThanOrEqualTo(1 + 1e-9));
      }
    });

    test('at least one face catches the light (shade > ambient)', () {
      expect(tris.any((t) => t.shade > kAmbient + 1e-3), isTrue);
    });
  });

  test('🔑 a mesh entirely behind the camera is culled to nothing', () {
    // Eye at +Z looking toward -Z; put the tube well behind the eye (+Z beyond it).
    final proj = perspective(kDefaultFov, _size.width / _size.height, 0.1, 1000);
    final view = lookAt(const Vec3(0, 0, 100), const Vec3(0, 0, 0), const Vec3(0, 1, 0));
    final behind = tube(0, 40, 16, 10); // lives around z≈0..; shift it behind eye
    // Translate the tube to z=+300 (behind the eye at z=100 looking toward -z).
    final pos = <double>[];
    for (var i = 0; i < behind.positions.length; i += 3) {
      pos
        ..add(behind.positions[i])
        ..add(behind.positions[i + 1])
        ..add(behind.positions[i + 2] + 300);
    }
    final shifted = Mesh(pos, behind.normals, behind.indices);
    expect(projectMeshes([shifted], proj, view, const Vec3(0, 0, 100), _size), isEmpty);
  });

  test('🔑 a real route (coupler→elbow90↑→coupler) projects to an ordered set', () {
    final meshes = buildRoutePreviewMeshes(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.elbow90, 32, dir: Dir.up),
      RunElement(Family.coupler, 32),
    ]);
    expect(meshes, hasLength(3));
    final cam = _camera(const Vec3(0, 40, 0), 400); // roughly centre the bend
    final tris = projectMeshes(meshes, cam.proj, cam.view, cam.eye, _size);
    expect(tris, isNotEmpty);
    for (var i = 1; i < tris.length; i++) {
      expect(tris[i - 1].depth, greaterThanOrEqualTo(tris[i].depth));
    }
  });
}
