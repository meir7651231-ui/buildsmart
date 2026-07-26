// GIANT Phase-2 wave-2d — the RFM tier badge on the manager customer cards,
// gated `manager.scoring`. Default (opt-in absent) ⇒ no badge, the cards are
// byte-identical. ON ⇒ each card carries a tier pill (FM-only for the dateless
// seed, so 'points/4'). The pure tiers/bands are covered in customer_score_test.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester t, OrgConfig cfg) async {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OFF by default — no RFM badge on any card (byte-identical)',
      (t) async {
    await _pump(t, const OrgConfig());
    expect(find.textContaining('/4'), findsNothing);
    for (final label in ['לקוח מוביל', 'לקוח קבוע', 'לקוח מזדמן', 'רדום']) {
      expect(find.text(label), findsNothing, reason: label);
    }
  });

  testWidgets('ON — every seed card carries a tier pill (FM-only ⇒ /4)',
      (t) async {
    await _pump(t, const OrgConfig(features: {'manager.scoring': true}));
    // The 4 dateless seed customers each render an FM-only pill "…· p/4".
    expect(find.textContaining('/4'), findsNWidgets(4));
  });
}
