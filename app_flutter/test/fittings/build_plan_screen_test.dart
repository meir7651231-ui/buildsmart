// 🔑 Phase D slice 6 — build-plan capstone smoke test: the gated screen unifies
// the 3D + the cut-list for a route (surfacing the D5 cut-list behind a button),
// and survives an empty/gapless route.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/build_plan_screen.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the demo build-plan builds: 3D + a cut-list header, no exception', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    await tester.pumpWidget(const MaterialApp(home: BuildPlanScreen()));
    expect(find.byType(FittingPreview3d), findsOneWidget);
    expect(find.textContaining('כתב-חיתוך'), findsOneWidget);
    expect(find.textContaining('מ״מ'), findsWidgets); // cut length tiles
    expect(tester.takeException(), isNull);
  });

  testWidgets('a single-fitting route has no pipe gaps → empty cut-list label', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    await tester.pumpWidget(
      const MaterialApp(
        home: BuildPlanScreen(route: [RunElement(Family.coupler, 32)]),
      ),
    );
    expect(find.textContaining('אין מרווחי-צינור'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
