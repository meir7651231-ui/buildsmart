// Pins the UNIFIED manager-only "🔌 הקמת המערכת" two-phase setup host:
//   1. phase 1 shows the trade builder (verbatim '🏗️ בונה ענפים') WITH the
//      host-only 'המשך להגדרת החברה' advance button (the onContinue seam);
//   2. tapping it advances to phase 2 — the org-setup wizard
//      ('🔌 אשף הקמת חברה') — proving the switch (not IndexedStack) constructs
//      phase 2 lazily on advance;
//   3. the trade-builder screen used STANDALONE (onContinue == null) shows NO
//      advance button — the byte-identical guarantee for its own route.
//
// Harness idiom (empty mock prefs + bounded settle + own-RTL) copied from
// trade_builder_home_test.dart / org_setup_wizard_test.dart.
import 'package:buildsmart/screens/org_setup_wizard_screen.dart';
import 'package:buildsmart/screens/trade_builder/system_setup_host_screen.dart';
import 'package:buildsmart/screens/trade_builder/trade_builder_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> pump(WidgetTester t, Widget home) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(locale: const Locale('he'), home: home),
      ),
    );
    await settle(t);
  }

  group('SystemSetupHostScreen — the unified two-phase setup flow', () {
    testWidgets('phase 1 = trade builder + the host advance button', (t) async {
      await pump(t, const SystemSetupHostScreen());

      // Phase 1 is the trade builder (its verbatim AppBar title).
      expect(find.text('🏗️ בונה ענפים'), findsOneWidget);
      // The host injects the advance affordance (absent on the standalone route).
      expect(find.text('המשך להגדרת החברה ←'), findsOneWidget);
      // Phase 2 is NOT mounted yet (lazy switch, not IndexedStack).
      expect(find.byType(OrgSetupWizardScreen), findsNothing);
    });

    testWidgets('tapping המשך advances to phase 2 = the org wizard', (t) async {
      await pump(t, const SystemSetupHostScreen());

      await t.tap(find.text('המשך להגדרת החברה ←'));
      await settle(t);

      // Phase 2 — the org-setup wizard (its verbatim AppBar title).
      expect(find.text('🔌 אשף הקמת חברה'), findsOneWidget);
      expect(find.byType(OrgSetupWizardScreen), findsOneWidget);
      // Phase 1 is gone (the switch swapped the child).
      expect(find.text('🏗️ בונה ענפים'), findsNothing);
    });

    testWidgets('standalone trade builder (onContinue null) has NO advance '
        'button — byte-identical', (t) async {
      await pump(t, const TradeBuilderHomeScreen());

      expect(find.text('🏗️ בונה ענפים'), findsOneWidget);
      expect(find.text('המשך להגדרת החברה ←'), findsNothing);
    });
  });
}
