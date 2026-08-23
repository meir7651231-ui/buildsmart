// 🔑 Phase D slice 7 — exploded-view golden + smoke. assembleRoute(explode:) spreads
// the fittings along the run; explode:0 is byte-identical to the plain assembler.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/route_assembly.dart';
import 'package:buildsmart/features/fittings/intel/exploded_view_screen.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _route = [
  RunElement(Family.coupler, 50),
  RunElement(Family.elbow90, 50, dir: Dir.up),
  RunElement(Family.coupler, 50),
  RunElement(Family.plug, 50),
];

double _spanX(List<WorldPart> parts) {
  var lo = double.infinity;
  var hi = double.negativeInfinity;
  for (final p in parts) {
    for (var v = 0; v < p.mesh.vertexCount; v++) {
      final x = p.mesh.positions[v * 3];
      if (x < lo) lo = x;
      if (x > hi) hi = x;
    }
  }
  return hi - lo;
}

void main() {
  test('🔑 explode preserves the part count (it only moves parts, never adds)', () {
    expect(assembleRoute(_route, explode: 2).length, assembleRoute(_route).length);
  });

  test('🔑 a positive explode spreads the run wider along X', () {
    final assembled = _spanX(assembleRoute(_route));
    final exploded = _spanX(assembleRoute(_route, explode: 2));
    expect(exploded, greaterThan(assembled));
  });

  test('explode grows monotonically with the factor', () {
    final s1 = _spanX(assembleRoute(_route, explode: 1));
    final s2 = _spanX(assembleRoute(_route, explode: 3));
    expect(s2, greaterThan(s1));
  });

  testWidgets('the exploded-view screen builds with a slider + 3D, no exception',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExplodedViewScreen()));
    expect(find.byType(FittingPreview3d), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
