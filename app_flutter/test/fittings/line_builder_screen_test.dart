// 🔑 Phase D slice 2 — build-a-line capability screen smoke test: the gated
// off-live screen builds, shows a summary chip per fitting, renders the 3D, and
// survives an empty plan — the thin shell over the D1 planner + C6 preview.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/line_builder_screen.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the demo build-a-line screen builds + paints, no exception', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LineBuilderScreen()));
    expect(find.byType(FittingPreview3d), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(Chip), findsWidgets); // a chip per fitting
    expect(tester.takeException(), isNull);
  });

  testWidgets('a supplied plan drives both the summary and the 3D', (tester) async {
    final plan = FittingLinePlan.fromRoute(const [
      RunElement(Family.coupler, 32),
      RunElement(Family.elbow90, 32, dir: Dir.up),
      RunElement(Family.coupler, 32),
    ]);
    await tester.pumpWidget(MaterialApp(home: LineBuilderScreen(plan: plan)));
    expect(find.byType(Chip), findsNWidgets(3)); // one per route element
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty plan shows the empty label and does not crash', (tester) async {
    final plan = FittingLinePlan.fromRoute(const []);
    await tester.pumpWidget(MaterialApp(home: LineBuilderScreen(plan: plan)));
    expect(find.text('רצף ריק'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
