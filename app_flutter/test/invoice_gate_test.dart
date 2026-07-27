// GIANT Phase-2 wave-3 (documents) — the invoice button on the manager
// order-detail sheet, gated `orders.invoicing`. Default (opt-in absent) ⇒ the
// sheet has no invoice button (byte-identical). ON ⇒ "🧾 הפק חשבונית" appears.
// The pure builder is covered in invoice_test.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _openFirstOrder(WidgetTester t, OrgConfig cfg) async {
  SharedPreferences.setMockInitialValues({
    'bs.board-auth.v1':
        '{"role":"manager","username":"admin","displayName":"מנהל","demo":false}',
  });
  await t.binding.setSurfaceSize(const Size(440, 1800));
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
  c.read(managerTabProvider.notifier).state = 1; // 📦 הזמנות
  for (var i = 0; i < 4; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
  // Tap the first order row (📦 BS-…) to open its detail sheet.
  await t.tap(find.textContaining('📦 BS-').first);
  for (var i = 0; i < 5; i++) {
    await t.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OFF by default — the order sheet has NO invoice button', (t) async {
    await _openFirstOrder(t, const OrgConfig());
    expect(find.text('סטטוס'), findsOneWidget, reason: 'the detail sheet is open');
    expect(find.text('🧾 הפק חשבונית'), findsNothing);
    expect(find.text('💵 הפק קבלה'), findsNothing);
  });

  testWidgets('ON — "🧾 הפק חשבונית" appears on the order sheet', (t) async {
    await _openFirstOrder(
        t, const OrgConfig(features: {'orders.invoicing': true}));
    expect(find.text('🧾 הפק חשבונית'), findsOneWidget);
    expect(find.text('💵 הפק קבלה'), findsOneWidget,
        reason: 'the receipt shares the invoicing gate');
  });
}
