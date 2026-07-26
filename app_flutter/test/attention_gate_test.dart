// GIANT Phase-2 wave-1 — the attention GATE on the manager cockpit: default
// (opt-in absent) ⇒ the card never renders even when items exist (byte-identical
// live app); features{'manager.attention':true} ⇒ the ranked card renders and a
// row drills to its manager tab. The fan-in wiring is covered separately in
// attention_engine_test; here the item list is injected to isolate the gate.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/logic/attention_engine.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/state/attention_source.dart'
    show attentionItemsProvider;
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _items = [
  AttentionItem(
    key: 'order:BS-9',
    tag: 'הזמנה',
    title: 'הזמנה BS-9 ממתינה 9 ימים',
    sev: AttentionSev.crit,
    navTab: 1,
  ),
];

Future<ProviderContainer> _pump(WidgetTester t, OrgConfig cfg) async {
  SharedPreferences.setMockInitialValues({
    'bs.board-auth.v1':
        '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
  });
  await t.binding.setSurfaceSize(const Size(440, 1200));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        orgConfigProvider.overrideWith((ref) => cfg),
        attentionItemsProvider.overrideWithValue(_items),
      ],
      child: const MaterialApp(
        locale: Locale('he'),
        home: ManagerDashboardScreen(),
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
  return ProviderScope.containerOf(
    t.element(find.byType(ManagerDashboardScreen)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OFF by default (opt-in absent) — the card never renders even '
      'with live items (byte-identical cockpit)', (t) async {
    await _pump(t, const OrgConfig());
    expect(find.text('🔔 דורש טיפול'), findsNothing);
    expect(find.text('הזמנה BS-9 ממתינה 9 ימים'), findsNothing);
  });

  testWidgets('ON when the company opts in — the ranked card renders and a '
      'row drills to its manager tab', (t) async {
    final c = await _pump(
        t, const OrgConfig(features: {'manager.attention': true}));
    expect(find.text('🔔 דורש טיפול'), findsOneWidget);
    expect(find.text('הזמנה BS-9 ממתינה 9 ימים'), findsOneWidget);

    expect(c.read(managerTabProvider), 0, reason: 'starts on the cockpit');
    await t.tap(find.text('הזמנה BS-9 ממתינה 9 ימים'));
    await t.pump();
    expect(c.read(managerTabProvider), 1, reason: 'drilled to the orders tab');
  });

  testWidgets('module cascade — manager OFF forces the feature off even when '
      'explicitly true', (t) async {
    await _pump(
      t,
      const OrgConfig(
        modules: {'manager': false},
        features: {'manager.attention': true},
      ),
    );
    expect(find.text('🔔 דורש טיפול'), findsNothing);
  });
}
