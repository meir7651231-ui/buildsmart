// GLOBAL SEARCH (phase 3) — the KEYBOARD-INTEGRATION proof for the unified
// "search everything" typed row. The feature is behind [kGlobalSearch] (a const,
// default OFF), so these tests are GATED: under the ordinary gate run
// (kGlobalSearch OFF) they mark themselves skipped, and they assert real
// behaviour ONLY under
//
//     flutter test test/screens/floating_card_keyboard_global_search_test.dart \
//       --dart-define=GLOBAL_SEARCH=true
//
// The flag-OFF byte-identity is proven separately: the UNCHANGED
// floating_card_keyboard_test.dart runs green WITHOUT the define, because the
// legacy typed path (_buildRow) is exactly what runs when the flag is off — the
// whole _globalRow branch + its imports fold out (const-false ⇒ tree-shaken).
//
// Under the define, _rowFor's typed branch compiles to `return _globalRow(text)`,
// so the legacy _buildRow is NOT reachable for a typed query — any chip in the
// typed row can ONLY have come from _globalRow. That is what makes the screen-nav
// test below a genuine end-to-end proof of the wiring (row build → dispatch).

import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/features/global_search/global_search_sources.dart'
    show productSource;
import 'package:buildsmart/screens/catalog_screen.dart'
    show keyboardDiveQueryProvider;
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/keyboard_overlay.dart'
    show keyboardOverlayOpenProvider;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart'
    show BsKeyboard;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatingCardKeyboard — global search typed row (kGlobalSearch)', () {
    setUp(() {
      // Production has the kSmartInput opt-in OFF; FloatingCardKeyboard passes
      // forceShow:true so it renders anyway (same discipline as the sibling test).
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    /// Pumps the REAL [FloatingCardKeyboard] in the same hermetic RTL shell the
    /// sibling test uses (the panel is mounted only while
    /// [keyboardOverlayOpenProvider] is true, seeded true). Returns the container.
    Future<ProviderContainer> pumpPanel(WidgetTester tester,
        {int tab = 0}) async {
      final container = ProviderContainer(
        overrides: [keyboardOverlayOpenProvider.overrideWith((_) => true)],
      );
      // Seed the active tab BEFORE mount so the first build reads it (no tab
      // CHANGE fires — the keyboard opens in typing mode on this tab).
      if (tab != 0) container.read(mainTabProvider.notifier).state = tab;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    final open = ref.watch(keyboardOverlayOpenProvider);
                    return Stack(
                      children: [
                        const Center(child: Text('screen-underneath')),
                        if (open)
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: FloatingCardKeyboard(),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets(
        'typing routes through _globalRow: a SCREEN result surfaces and, on tap, '
        'navigates while the overlay keeps floating', (tester) async {
      if (!kGlobalSearch) {
        markTestSkipped('kGlobalSearch OFF — run with '
            '--dart-define=GLOBAL_SEARCH=true to exercise the global row');
        return;
      }
      final container = await pumpPanel(tester);
      expect(container.read(mainTabProvider), 0, reason: 'starts on tab 0');

      // Type "מח" (two letter keys). The global index's screen source
      // (matchDestinations) surfaces the מחלקות screen. Under the flag the legacy
      // _buildRow is compiled out of the typed branch, so this chip can ONLY have
      // come from _globalRow.
      await tester.tap(find.text('מ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ח'));
      await tester.pumpAndSettle();

      expect(find.text('מחלקות'), findsWidgets,
          reason: 'the unified global row surfaced the מחלקות screen result');

      // Tapping it dispatches via runByChip (the result carries the destination's
      // own nav closure), routing to the departments tab (1) and KEEPING the
      // overlay floating — the same keep-floating contract every chip honours.
      await tester.ensureVisible(find.text('מחלקות').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('מחלקות').first);
      await tester.pumpAndSettle();

      expect(container.read(mainTabProvider), 1,
          reason: 'the global screen result ran its nav (→ departments tab 1)');
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'a global-result tap must NOT close the floating overlay');
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the keyboard keeps floating after the global-result nav');
      expect(find.text('screen-underneath'), findsOneWidget,
          reason: 'the full screen underneath stays');
    });

    testWidgets(
        'typing a catalog term surfaces a real PRODUCT result in the row '
        '(the products source is wired into _globalRow)', (tester) async {
      if (!kGlobalSearch) {
        markTestSkipped('kGlobalSearch OFF — run with '
            '--dart-define=GLOBAL_SEARCH=true to exercise the global row');
        return;
      }
      await pumpPanel(tester);

      // Type "ברז" (three letter keys) — a common catalogue term. The products
      // source scans kDivePool by name; its top hits are what productSource
      // returns here, so at least one of them must be rendered as a row chip.
      await tester.tap(find.text('ב'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ר'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ז'));
      await tester.pumpAndSettle();

      final productHits = productSource('ברז', 5).map((r) => r.title).toList();
      expect(productHits, isNotEmpty,
          reason: 'sanity: the catalogue has ברז products');
      final shown =
          productHits.where((t) => find.text(t).evaluate().isNotEmpty).toList();
      expect(shown, isNotEmpty,
          reason: 'a global PRODUCT result renders in the typed row — proving '
              'the products source feeds _globalRow (not just screens)');
    });

    testWidgets(
        'on the catalog tab a broad query does NOT append "עוד…" — the unified '
        'search window is already open below the keyboard', (tester) async {
      if (!kGlobalSearch) {
        markTestSkipped('kGlobalSearch OFF — run with '
            '--dart-define=GLOBAL_SEARCH=true to exercise the global row');
        return;
      }
      final container = await pumpPanel(tester); // tab 0 = catalog
      expect(container.read(mainTabProvider), 0, reason: 'starts on the catalog');

      // "ברז" matches many products (the row would overflow), but on the catalog
      // tab the dive window ([_DiveResultsView], extended to every domain) already
      // shows the full unified results below — so an overflow "עוד…" chip (a dead
      // jump to where you already are) is deliberately omitted.
      await tester.tap(find.text('ב'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ר'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ז'));
      await tester.pumpAndSettle();

      expect(find.text('עוד…'), findsNothing,
          reason: 'no overflow chip on the catalog tab — that search window is '
              'already open under the keyboard');
    });

    testWidgets(
        'off the catalog tab "עוד…" opens the ONE existing search window: it '
        'switches to the catalog tab and seeds the dive query (no bespoke sheet)',
        (tester) async {
      if (!kGlobalSearch) {
        markTestSkipped('kGlobalSearch OFF — run with '
            '--dart-define=GLOBAL_SEARCH=true to exercise the global row');
        return;
      }
      final container = await pumpPanel(tester, tab: 3); // 3 = store
      expect(container.read(mainTabProvider), 3, reason: 'starts on the store tab');

      // Off the catalog tab that window is NOT open below, so the overflow chip is
      // appended (results > row cap) as the one-tap way to reach the full results.
      await tester.tap(find.text('ב'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ר'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ז'));
      await tester.pumpAndSettle();

      expect(find.text('עוד…'), findsOneWidget,
          reason: 'off the catalog tab a broad query shows the overflow chip');

      // Tapping it opens the EXISTING search window (the catalog dive), NOT a
      // sheet: switch to the catalog tab (0, where [_DiveResultsView] lives) and
      // seed its [keyboardDiveQueryProvider] so it renders the full unified list.
      await tester.ensureVisible(find.text('עוד…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('עוד…'));
      await tester.pumpAndSettle();

      expect(container.read(mainTabProvider), 0,
          reason: '"עוד…" navigates to the catalog tab where the search window is');
      expect(container.read(keyboardDiveQueryProvider), 'ברז',
          reason: '"עוד…" seeds the dive query so the window shows the results');
    });
  });
}
