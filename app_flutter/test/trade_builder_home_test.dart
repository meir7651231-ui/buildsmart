// Pillar-2 Step 44 (G-authoring) — pins the FIRST authoring UI of the no-code
// trade builder:
//   1. the manager-dashboard entry is GATED — with 'kTradeBuilder' OFF (the
//      default; trade_builder_flags.dart) no בונה-ענפים entry exists ANYWHERE,
//      not even offstage inside the dashboard's IndexedStack;
//   2. TradeBuilderHomeScreen is an RTL scaffold — verbatim title
//      '🏗️ בונה ענפים', the 6-step wizard header on step 1 ('שלב 1 מתוך 6'),
//      the empty state ('עדיין אין ענפים — הוסף את הראשון') and a Semantics
//      BUTTON 'הוסף ענף' that opens TradeDefineStepScreen;
//   3. the screen clamps the ambient textScaler at 1.35 (a11y — RTL layouts
//      stay intact under huge OS Dynamic Type);
//   4. TradeDefineStepScreen's 'שמור טיוטה' writes ONE DRAFT Trade
//      (published:false — never auto-publish) through
//      tradesStoreProvider.notifier.upsertTrade, pops, and the home list shows it.
//
// Harness idioms copied from manager_dashboard_screen_test.dart (board-auth
// seed + bounded settle + the skipOffstage:false IndexedStack sweep),
// active_trade_provider_test.dart (empty-mock-prefs store settling) and
// robustness_test.dart (the ambient MediaQuery textScaler override). The
// analogous screen tests load no fonts, so neither does this one.
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/screens/trade_builder/trade_builder_home.dart';
import 'package:buildsmart/screens/trade_builder/trade_define_step.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/trade_builder_flags.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bounded settle — the manager_dashboard_screen_test idiom (pumpAndSettle
  // can hang on screens that animate forever). 6×120ms outlasts a page
  // transition AND flushes the async SharedPreferences `_load` of
  // tradesStoreProvider / featureFlagsProvider, so a test mutation can never
  // race the load (the active_trade_provider_test settle trick, adapted to
  // fake-async widget time).
  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  /// Pumps the trade-builder HOME over EMPTY mock prefs (⇒ the authored store
  /// settles empty ⇒ the empty state renders) and returns the live container.
  /// Directionality is deliberately NOT supplied by the harness — the screen
  /// must bring its own RTL. [textScaler], when given, wraps the screen in an
  /// ambient MediaQuery override (the robustness_test idiom) so the clamp test
  /// can feed it 2.0.
  Future<ProviderContainer> pumpHome(
    WidgetTester t, {
    TextScaler? textScaler,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: textScaler == null
              ? const TradeBuilderHomeScreen()
              : Builder(
                  builder: (ctx) => MediaQuery(
                    data: MediaQuery.of(ctx).copyWith(textScaler: textScaler),
                    child: const TradeBuilderHomeScreen(),
                  ),
                ),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(
      t.element(find.byType(TradeBuilderHomeScreen)),
    );
  }

  /// The define-step's name field: prefer the TextField labelled 'שם הענף'
  /// (labels/hints render inside the TextField subtree); fall back to the
  /// FIRST TextField — the step-44 contract orders name before emoji.
  Finder nameField() {
    final labelled = find.ancestor(
      of: find.textContaining('שם הענף'),
      matching: find.byType(TextField),
    );
    return labelled.evaluate().isNotEmpty
        ? labelled.first
        : find.byType(TextField).first;
  }

  group('gated manager entry — kTradeBuilder is OFF by default', () {
    testWidgets(
        'flag OFF → the manager dashboard has NO בונה-ענפים entry, not even '
        'offstage in the IndexedStack', (t) async {
      // The exact manager_dashboard_screen_test harness: seed a board session
      // so the board (not the #65 gate) renders. bs.feature-flags.v1 is NOT
      // seeded ⇒ 'kTradeBuilder' stays OFF (its golden default).
      SharedPreferences.setMockInitialValues({
        'bs.board-auth.v1':
            '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
      });
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('he'),
            home: ManagerDashboardScreen(),
          ),
        ),
      );
      await settle(t);

      // The gate really is OFF in this container (never force-enabled)…
      final c = ProviderScope.containerOf(
        t.element(find.byType(ManagerDashboardScreen)),
      );
      expect(
        c.read(featureFlagsProvider.notifier).isOn(kTradeBuilderFlag),
        isFalse,
        reason: 'kTradeBuilder must be OFF by default — owner-staged only',
      );

      // …so the entry is ABSENT everywhere. The dashboard's IndexedStack keeps
      // all four tabs MOUNTED offstage, so the skipOffstage:false sweep covers
      // whichever tab hosts the entry (the same dual idiom the dashboard test
      // uses to pin "בקרוב" gone).
      expect(find.textContaining('בונה ענפים'), findsNothing);
      expect(
        find.textContaining('בונה ענפים', skipOffstage: false),
        findsNothing,
      );
    });
  });

  group('trade-builder HOME — the step-44 authoring shell', () {
    testWidgets(
        'renders RTL with the verbatim title, the empty state and the '
        'הוסף-ענף Semantics button', (t) async {
      await pumpHome(t);

      // Verbatim AppBar title.
      expect(find.text('🏗️ בונה ענפים'), findsOneWidget);

      // Empty authored store ⇒ the empty-state line
      // ('עדיין אין ענפים — הוסף את הראשון').
      expect(find.textContaining('עדיין אין ענפים'), findsOneWidget);

      // RTL comes from the SCREEN itself — the harness supplies none, so a
      // body descendant resolving to rtl pins the screen's own Directionality.
      expect(
        Directionality.of(t.element(find.textContaining('עדיין אין ענפים'))),
        TextDirection.rtl,
      );

      // The add-trade affordance is a real semantic BUTTON (screen readers
      // must announce it as one).
      final handle = t.ensureSemantics();
      expect(find.text('הוסף ענף'), findsWidgets);
      expect(
        t.getSemantics(find.text('הוסף ענף').first),
        containsSemantics(isButton: true),
      );
      handle.dispose();
    });

    testWidgets('textScaler is clamped at 1.35 — an ambient 2.0 never leaks in',
        (t) async {
      await pumpHome(t, textScaler: const TextScaler.linear(2));

      // The EFFECTIVE scaler inside the screen, read off a body descendant
      // (below any screen-level MediaQuery override).
      final scaler = MediaQuery.textScalerOf(
        t.element(find.textContaining('עדיין אין ענפים').first),
      );
      expect(
        scaler.scale(10),
        lessThanOrEqualTo(13.5 + 1e-3),
        reason: 'the screen must clamp the ambient 2.0 scaler to max 1.35',
      );
      // Anti-vacuity: clamping is not DISCARDING — large type still magnifies
      // (a hard-reset to 1.0 would be its own a11y bug).
      expect(
        scaler.scale(10),
        greaterThan(10),
        reason: 'the ambient scaler must be clamped, not thrown away',
      );
    });

    testWidgets('wizard progress shows step 1 of 6 (contract literal '
        'שלב 1 מתוך 6)', (t) async {
      await pumpHome(t);
      expect(find.textContaining('שלב 1 מתוך 6'), findsOneWidget);
    });

    testWidgets('the add-button opens the define step', (t) async {
      await pumpHome(t);
      expect(find.byType(TradeDefineStepScreen), findsNothing);

      await t.tap(find.text('הוסף ענף').first);
      await settle(t);

      expect(find.byType(TradeDefineStepScreen), findsOneWidget);
    });
  });

  group('define step — the draft-Trade write path', () {
    testWidgets(
        'שמור טיוטה writes ONE draft (published:false) via tradesStoreProvider '
        'and pops home, which now lists it', (t) async {
      final c = await pumpHome(t);
      expect(c.read(tradesStoreProvider).trades, isEmpty);

      await t.tap(find.text('הוסף ענף').first);
      await settle(t);
      expect(find.byType(TradeDefineStepScreen), findsOneWidget);

      // Name it; leave emoji / persona / color on their defaults.
      await t.enterText(nameField(), 'חשמלאי');
      await settle(t, 2);
      await t.tap(find.text('שמור טיוטה').first);
      await settle(t);

      // ONE authored trade landed in the store — a DRAFT.
      final trades = c.read(tradesStoreProvider).trades;
      expect(trades, hasLength(1));
      expect(trades.single.nameHe, 'חשמלאי');
      expect(
        trades.single.published,
        isFalse,
        reason: 'שמור טיוטה must save a DRAFT — never auto-publish',
      );
      expect(trades.single.id, isNotEmpty);

      // The define step popped back to home, and the list shows the new draft
      // instead of the empty state.
      expect(find.byType(TradeDefineStepScreen), findsNothing);
      expect(find.byType(TradeBuilderHomeScreen), findsOneWidget);
      expect(find.textContaining('חשמלאי'), findsWidgets);
      expect(find.textContaining('עדיין אין ענפים'), findsNothing);
    });
  });
}
