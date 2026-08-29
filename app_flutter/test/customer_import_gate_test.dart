// GIANT Phase-2 wave-3d — the customer CSV import: the tab trigger (gated
// `manager.customers`), the sheet's upload→commit→quality flow, and the store's
// bulk importAll. Default (opt-in absent) ⇒ the customers tab shows no import
// button (byte-identical). The pure parser is covered in customer_import_test.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/screens/customer_import_sheet.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/services/file_transfer.dart'
    show PickedTextFile, pickTextFileProvider;
import 'package:buildsmart/state/customers_store.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Two rows that PARSE clean and are NOT hard duplicates (different names), but
// share a phone → a non-blocking near-key quality warning.
const _csv = 'שם הלקוח,טלפון\n'
    'דנה כהן,0501112222\n'
    'דני לוי,0501112222\n';

Future<ProviderContainer> _pumpDash(WidgetTester t, OrgConfig cfg) async {
  SharedPreferences.setMockInitialValues({
    'bs.board-auth.v1':
        '{"role":"manager","username":"admin","displayName":"מנהל","demo":false}',
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
  final c = ProviderScope.containerOf(
      t.element(find.byType(ManagerDashboardScreen)));
  c.read(managerTabProvider.notifier).state = 2; // 👥 לקוחות
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tab OFF by default — no import button (byte-identical)',
      (t) async {
    await _pumpDash(t, const OrgConfig());
    expect(find.text('⬆️ ייבוא לקוחות מ-CSV'), findsNothing);
  });

  testWidgets('tab ON — the import button appears', (t) async {
    await _pumpDash(t, const OrgConfig(features: {'manager.customers': true}));
    expect(find.text('⬆️ ייבוא לקוחות מ-CSV'), findsOneWidget);
  });

  testWidgets('sheet: upload commits via importAll + shows a quality warning',
      (t) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(overrides: [
      pickTextFileProvider
          .overrideWithValue((a) async => const PickedTextFile('c.csv', _csv)),
    ]);
    addTearDown(container.dispose);
    await t.binding.setSurfaceSize(const Size(440, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showCustomerImportSheet(ctx),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('⬆️ העלה נתונים'));
    await t.pumpAndSettle();
    expect(find.text('✅ נטענו 2 לקוחות'), findsOneWidget);
    expect(find.textContaining('אזהרות איכות'), findsOneWidget);
    expect(container.read(savedCustomersProvider).length, 2,
        reason: 'both rows folded into the store');
  });

  group('CustomersStore.importAll', () {
    test('folds through dedup — same name+phone collapses to one', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(savedCustomersProvider.notifier).importAll(const [
        SavedCustomer(id: 'a', name: 'דנה כהן', phone: '0501112222'),
        SavedCustomer(id: 'b', name: 'דנה כהן', phone: '050-111-2222'),
      ]);
      expect(c.read(savedCustomersProvider).length, 1);
    });

    test('empty input is a no-op', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(savedCustomersProvider.notifier).importAll(const []);
      expect(c.read(savedCustomersProvider), isEmpty);
    });
  });
}
