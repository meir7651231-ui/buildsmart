// 🔑 Phase E-lite slice 3 — build-plan export golden + smoke. exportBuildPlanText
// renders a deterministic Hebrew document: title, numbered sequence, cut-list.
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/build_plan_export.dart';
import 'package:buildsmart/features/fittings/intel/build_plan_export_screen.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final plan = FittingLinePlan.fromRoute(const [
    RunElement(Family.coupler, 50),
    RunElement(Family.elbow90, 50, dir: Dir.up),
    RunElement(Family.reducer, 50, od2: 32),
    RunElement(Family.plug, 32),
  ]);

  test('🔑 the document carries a title, a numbered sequence, and a cut-list', () {
    final doc = exportBuildPlanText(plan);
    expect(doc, contains('# תוכנית-בנייה'));
    expect(doc, contains('## רצף (4 אביזרים)'));
    expect(doc, contains('1. מצמד 50'));
    expect(doc, contains('2. ברך 90° 50'));
    expect(doc, contains('3. מצרה 50→32')); // reducer carries od2
    expect(doc, contains('4. פקק 32'));
    expect(doc, contains('## כתב-חיתוך'));
    expect(doc, contains('מ״מ')); // at least one cut length
  });

  test('an empty plan renders the empty markers, no crash', () {
    final doc = exportBuildPlanText(FittingLinePlan.fromRoute(const []));
    expect(doc, contains('## רצף (0 אביזרים)'));
    expect(doc, contains('(רצף ריק)'));
    expect(doc, contains('(אין מרווחי-צינור)'));
  });

  test('spacing flows into the cut-list header', () {
    final doc = exportBuildPlanText(plan, spacing: 250);
    expect(doc, contains('מרחק-מרכזים 250 מ״מ'));
  });

  testWidgets('the export screen shows the document as selectable text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    await tester.pumpWidget(MaterialApp(home: BuildPlanExportScreen(plan: plan)));
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.textContaining('# תוכנית-בנייה'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
