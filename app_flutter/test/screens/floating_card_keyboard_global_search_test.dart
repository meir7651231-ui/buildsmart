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
    Future<ProviderContainer> pumpPanel(WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [keyboardOverlayOpenProvider.overrideWith((_) => true)],
      );
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
        'the typed row NEVER shows an "עוד…" overflow chip — the full ranked list '
        'lives in the in-place results panel now (option A), not behind a chip',
        (tester) async {
      if (!kGlobalSearch) {
        markTestSkipped('kGlobalSearch OFF — run with '
            '--dart-define=GLOBAL_SEARCH=true to exercise the global row');
        return;
      }
      await pumpPanel(tester);

      // "ברז" matches far more hits than the row's cap. Before option A that
      // appended an "עוד…" chip; now the whole ranked list always shows in the
      // HomeShell results panel ([GlobalSearchResultsView]) in place, so the row
      // is a pure quick-preview and the chip is gone entirely.
      await tester.tap(find.text('ב'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ר'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ז'));
      await tester.pumpAndSettle();

      expect(find.text('עוד…'), findsNothing,
          reason: 'no "עוד…" chip anymore — the results panel shows the full list '
              'in place, so there is nothing to overflow into');
    });
  });
}
