// GIANT Phase-2 wave-2c — the fuzzy customer search box on the manager tab,
// gated `search.fuzzy`. Default (opt-in absent) ⇒ no box, the list is
// byte-identical (all seed cards). ON ⇒ a typo-tolerant name filter that
// composes AND-wise with the status chips. Over the wave-2a Damerau primitive.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(WidgetTester t, OrgConfig cfg) async {
  SharedPreferences.setMockInitialValues({
    'bs.board-auth.v1':
        '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
  });
  await t.binding.setSurfaceSize(const Size(440, 1700));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(ProviderScope(
    overrides: [orgConfigProvider.overrideWith((ref) => cfg)],
    child: const MaterialApp(
      locale: Locale('he'),
      home: ManagerDashboardScreen(),
    ),
  ));
  final c = ProviderScope.containerOf(
      t.element(find.byType(ManagerDashboardScreen)));
  c.read(managerTabProvider.notifier).state = 2; // 👥 לקוחות
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OFF by default — no search box, all 4 seed cards render '
      '(byte-identical)', (t) async {
    await _pump(t, const OrgConfig());
    expect(find.byType(TextField), findsNothing);
    for (final n in ['יוסי כהן', 'אבי מזרחי', 'משה אברהם', 'דוד לוי']) {
      expect(find.text(n), findsOneWidget, reason: n);
    }
  });

  testWidgets('ON — the box appears and a typo-tolerant query narrows the list',
      (t) async {
    await _pump(t, const OrgConfig(features: {'search.fuzzy': true}));
    expect(find.byType(TextField), findsOneWidget);
    // 'כוהן' is one edit from 'כהן' (inside tolerance) → matches 'יוסי כהן'.
    await t.enterText(find.byType(TextField), 'כוהן');
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    expect(find.text('יוסי כהן'), findsOneWidget);
    expect(find.text('אבי מזרחי'), findsNothing);
    expect(find.text('דוד לוי'), findsNothing);
  });

  testWidgets('ON — an empty query passes everything through (pass-through)',
      (t) async {
    await _pump(t, const OrgConfig(features: {'search.fuzzy': true}));
    // 'מזרחי' is distinctive → matches only 'אבי מזרחי'.
    await t.enterText(find.byType(TextField), 'מזרחי');
    for (var i = 0; i < 3; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    expect(find.text('אבי מזרחי'), findsOneWidget);
    expect(find.text('יוסי כהן'), findsNothing, reason: 'filtered');
    await t.enterText(find.byType(TextField), '');
    for (var i = 0; i < 3; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    for (final n in ['יוסי כהן', 'אבי מזרחי', 'משה אברהם', 'דוד לוי']) {
      expect(find.text(n), findsOneWidget, reason: 'empty query restores $n');
    }
  });
}
