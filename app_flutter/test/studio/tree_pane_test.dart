// Pins the Studio tree pane (#studio · Pillar 1 · step 18): it lists the registry
// elements (grouped), the search box filters by labelHe, tapping a leaf selects it
// (studioSelectedIdProvider), and the persona dropdown sets the scope. Read-only —
// uses the real const registry (cart.cta + 5 cockpit KPIs); no store/auth needed.
import 'package:buildsmart/screens/studio/panes/tree_pane.dart';
import 'package:buildsmart/state/studio/studio_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(ProviderContainer c) => UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: TreePane()),
        ),
      ),
    );

void main() {
  testWidgets('lists registry elements', (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));

    expect(find.text('KPI — הזמנות פתוחות'), findsOneWidget);
    expect(find.text('KPI — חנויות פעילות'), findsOneWidget);
    expect(find.text('כפתור הזמנה (עגלה)'), findsOneWidget);
  });

  testWidgets('search filters by labelHe', (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));

    await tester.enterText(find.byType(TextField), 'חנויות');
    await tester.pump();

    expect(find.text('KPI — חנויות פעילות'), findsOneWidget);
    expect(find.text('KPI — הזמנות פתוחות'), findsNothing);
  });

  testWidgets('tapping a leaf selects it', (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));

    await tester.tap(find.text('KPI — חנויות פעילות'));
    await tester.pump();

    expect(c.read(studioSelectedIdProvider), 'manager.cockpit.kpi.stores');
  });

  testWidgets('persona dropdown sets the scope', (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c));

    expect(c.read(studioScopePersonaProvider), 'contractor');
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('שליח').last);
    await tester.pumpAndSettle();

    expect(c.read(studioScopePersonaProvider), 'courier');
  });
}
