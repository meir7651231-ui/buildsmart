// 🔑 Phase C (renderer-polish 2) — chain assembler golden. Ports gen3d.buildPlan:
// real per-family bodies + TRANSITION PIPES welded between fittings (closing the
// floating-segment gap) + turtle routing + per-part material. Verified by: pipes
// appear between fittings, the run bends in 3D, materials are carried, a plug
// terminates without a trailing pipe, and unrenderable families are skipped.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/element_meshes.dart'
    show PartMaterial;
import 'package:buildsmart/features/fittings/geometry/route_assembly.dart';
import 'package:flutter_test/flutter_test.dart';

double _maxY(WorldPart p) {
  var my = double.negativeInfinity;
  final m = p.mesh;
  for (var v = 0; v < m.vertexCount; v++) {
    if (m.positions[v * 3 + 1] > my) my = m.positions[v * 3 + 1];
  }
  return my;
}

int _pipes(List<WorldPart> parts) =>
    parts.where((p) => p.mat == PartMaterial.pipe).length;

void main() {
  test('empty route → nothing', () {
    expect(assembleRoute(const []), isEmpty);
  });

  test('all-unrenderable route → nothing (M1 skip)', () {
    expect(assembleRoute(const [RunElement(Family.miteredElbow, 200)]), isEmpty);
  });

  group('🔑 welding — transition pipes between fittings', () {
    test('a lone coupler gets a lead pipe AND a trailing pipe (2 pipes)', () {
      final parts = assembleRoute(const [RunElement(Family.coupler, 32)]);
      expect(parts, isNotEmpty);
      // lead STUB + coupler body + trailing STUB
      expect(_pipes(parts), 2);
      expect(parts.any((p) => p.mat == PartMaterial.ppr), isTrue);
    });

    test('coupler→coupler inserts a middle pipe: lead + mid + trail = 3 pipes', () {
      final parts = assembleRoute(const [
        RunElement(Family.coupler, 32),
        RunElement(Family.coupler, 32),
      ]);
      expect(_pipes(parts), 3);
    });

    test('every part is well-formed (indices in range, normals paired)', () {
      final parts = assembleRoute(const [
        RunElement(Family.coupler, 50),
        RunElement(Family.elbow90, 50, dir: Dir.up),
        RunElement(Family.tee, 50),
        RunElement(Family.reducer, 50, od2: 32),
        RunElement(Family.plug, 32),
      ]);
      expect(parts, isNotEmpty);
      for (final p in parts) {
        expect(p.mesh.normals.length, p.mesh.positions.length);
        for (final i in p.mesh.indices) {
          expect(i, inInclusiveRange(0, p.mesh.vertexCount - 1));
        }
        for (final c in p.mesh.positions) {
          expect(c.isFinite, isTrue);
        }
      }
    });
  });

  test('🔑 a 90°-up elbow lifts the downstream run into +Y', () {
    final parts = assembleRoute(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.elbow90, 32, dir: Dir.up),
      RunElement(Family.coupler, 32),
    ]);
    // some part clearly sits above the start plane (the lifted downstream run)
    expect(parts.any((p) => _maxY(p) > 20), isTrue);
  });

  test('🔑 a plug terminates: no trailing pipe past it', () {
    final withPlug = assembleRoute(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.plug, 32),
    ]);
    final withoutPlug = assembleRoute(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.coupler, 32),
    ]);
    // plug ends the run → one fewer pipe than the equivalent open run
    expect(_pipes(withPlug), lessThan(_pipes(withoutPlug)));
  });

  test('🔑 a brass-bearing fitting (adapter) carries brass parts through', () {
    final parts = assembleRoute(const [RunElement(Family.adapter, 32)]);
    expect(parts.any((p) => p.mat == PartMaterial.brass), isTrue);
    expect(parts.any((p) => p.mat == PartMaterial.ppr), isTrue);
  });

  test('a reducer transition pipe uses the reduced OD downstream (taper, no crash)', () {
    final parts = assembleRoute(const [
      RunElement(Family.reducer, 50, od2: 32),
      RunElement(Family.coupler, 32),
    ]);
    expect(parts, isNotEmpty);
    expect(_pipes(parts), greaterThanOrEqualTo(3)); // lead + post-reducer + trail
  });
}
