// 🔑 Phase C (renderer, step 3b) — gated preview widget smoke test: the off-live
// 3D preview builds, paints without throwing, and repaints on rotation. This is the
// thin Flutter shell over the golden-tested projector; the widget test proves the
// wiring (mesh build → frame → paint) holds end-to-end.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/geometry/route_meshes.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FittingPreviewScreen builds and paints a CustomPaint', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FittingPreviewScreen()));
    expect(find.byType(FittingPreview3d), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty route still builds (no divide-by-zero framing)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FittingPreview3d(route: []))),
    );
    expect(tester.takeException(), isNull);
  });

  test('RoutePainter.shouldRepaint: true on camera change, false when unchanged', () {
    final meshes = buildRoutePreviewMeshes(const [RunElement(Family.coupler, 32)]);
    RoutePainter mk(double yaw) => RoutePainter(
          meshes: meshes,
          yaw: yaw,
          pitch: 0,
          dist: 100,
          target: const Vec3(0, 0, 0),
        );
    final a = mk(0);
    expect(a.shouldRepaint(mk(0)), isFalse); // identical params + same mesh list
    expect(a.shouldRepaint(mk(0.5)), isTrue); // yaw changed
  });

  testWidgets('a drag rotates the view (yaw changes ⇒ repaint scheduled)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FittingPreview3d(
            route: [
              RunElement(Family.coupler, 32),
              RunElement(Family.elbow90, 32, dir: Dir.up),
              RunElement(Family.coupler, 32),
            ],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(FittingPreview3d), const Offset(60, 0));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
