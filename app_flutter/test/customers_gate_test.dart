// GIANT Phase-2 wave-2b — the saved-customer detail-sheet augmentation, gated
// `manager.customers`. Default (opt-in absent) ⇒ the detail sheet is byte-
// identical (no saved-customer block). ON ⇒ the block renders, showing a saved
// entity's phone/notes joined by name. The pure store/dedup is covered in
// customers_store_test; here only the gate + the by-name render on the screen.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/state/customers_store.dart';
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
  await t.binding.setSurfaceSize(const Size(440, 1600));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(ProviderScope(
    overrides: [orgConfigProvider.overrideWith((ref) => cfg)],
    child: const MaterialApp(
      locale: Locale('he'),
      home: ManagerDashboardScreen(),
    ),
  ));
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
  return ProviderScope.containerOf(
      t.element(find.byType(ManagerDashboardScreen)));
}

/// Open the customers tab and tap the first seed contractor ('יוסי כהן') to
/// bring up its detail sheet.
Future<void> _openFirstCustomer(WidgetTester t, ProviderContainer c) async {
  c.read(managerTabProvider.notifier).state = 2; // 👥 לקוחות
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
  await t.tap(find.text('יוסי כהן').first);
  for (var i = 0; i < 5; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OFF by default — the detail sheet has no saved-customer block '
      '(byte-identical)', (t) async {
    final c = await _pump(t, const OrgConfig());
    await _openFirstCustomer(t, c);
    expect(find.text('מסגרת אשראי'), findsOneWidget, reason: 'sheet is open');
    expect(find.text('הוסף פרטי לקוח'), findsNothing);
    expect(find.text('אין פרטי לקוח שמורים עדיין'), findsNothing);
  });

  testWidgets('ON — the block renders; a saved entity shows by name', (t) async {
    final c = await _pump(
        t, const OrgConfig(features: {'manager.customers': true}));
    // seed a saved entity for the first contractor
    c.read(savedCustomersProvider.notifier).upsert(const SavedCustomer(
        id: '1', name: 'יוסי כהן', phone: '0501234567', notes: 'לקוח ותיק'));
    await _openFirstCustomer(t, c);
    expect(find.text('ערוך פרטי לקוח'), findsOneWidget,
        reason: 'a saved entity exists → edit affordance');
    expect(find.text('0501234567'), findsOneWidget);
    expect(find.text('לקוח ותיק'), findsOneWidget);
  });

  testWidgets('ON but no saved entity yet — the empty prompt + add button',
      (t) async {
    final c = await _pump(
        t, const OrgConfig(features: {'manager.customers': true}));
    await _openFirstCustomer(t, c);
    expect(find.text('אין פרטי לקוח שמורים עדיין'), findsOneWidget);
    expect(find.text('הוסף פרטי לקוח'), findsOneWidget);
  });
}
