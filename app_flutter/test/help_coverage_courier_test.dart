// #31 wave-2 — "מצב היכרות" coverage for the COURIER board (courier_dashboard).
// The board is gated (auth → docs → vehicle); we seed a courier session + the
// docs test-seam (docsGateOverrideProvider) so it reaches the vehicle gate,
// where the shared AppBar (💡 toggle + bell/profile/settings/exit) and the
// vehicle picker render. Pins: (1) the 💡 toggle exists so a courier can ENTER
// help mode at all, (2) the chrome is HelpTarget-wrapped, and (3) once help
// mode is on, tapping the bell explains it (bubble) instead of acting.
import 'package:buildsmart/screens/courier_dashboard_screen.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder helpTargetWithTitle(String title) =>
      find.byWidgetPredicate((w) => w is HelpTarget && w.title == title);

  Future<void> pumpCourier(WidgetTester t) async {
    // #65 gate: seed a logged-in courier session so the board renders (not the
    // registration gate). #101: bypass the HARD docs-readiness gate.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"courier","username":"dani","displayName":"דני","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(390, 820));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [docsGateOverrideProvider.overrideWith((ref) => true)],
        child: const MaterialApp(home: CourierDashboardScreen()),
      ),
    );
    await t.pump();
    // Let the lazy boardAuthProvider _load() resolve, then rebuild gate→board.
    await t.pump(const Duration(milliseconds: 120));
  }

  testWidgets('courier board exposes a 💡 toggle + covered chrome (#31)',
      (t) async {
    await pumpCourier(t);
    // The courier can ENTER help mode at all (the critical fix — only the
    // contractor board had a 💡 before).
    expect(find.byType(HelpToggleButton), findsOneWidget);
    // AppBar bell + the vehicle picker are explainable.
    expect(helpTargetWithTitle('התראות'), findsOneWidget);
    expect(helpTargetWithTitle('בחירת רכב למשמרת'), findsOneWidget);
  });

  testWidgets('help mode: tapping the bell explains it instead of acting (#31)',
      (t) async {
    await pumpCourier(t);
    // Enter help mode via the 💡 toggle.
    await t.tap(find.byType(HelpToggleButton));
    await t.pump();
    // Tap the (now frozen) bell → its explanation bubble surfaces.
    await t.tap(
      find.byKey(const ValueKey('courier-notifs-bell')),
      warnIfMissed: false,
    );
    await t.pump();
    expect(find.textContaining('פעמון ההתראות'), findsOneWidget);
  });
}
