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
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/word_lexicon.dart'
    show buildWordLexicon;
import 'package:buildsmart/screens/card_keyboard_sheet.dart'
    show cardKeyboardPredictions;
import 'package:buildsmart/screens/catalog_screen.dart'
    show keyboardDiveQueryProvider;
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/keyboard_job_context.dart'
    show keyboardJobSkusProvider;
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
        'OPTION B — the typed row shows the finder engine\'s NARROWER WORDS '
        '(typing help), and tapping one APPENDS it to narrow the query; it does '
        'NOT navigate (results live in the panel, not the row)', (tester) async {
      if (!kGlobalSearch) {
        markTestSkipped('kGlobalSearch OFF — run with '
            '--dart-define=GLOBAL_SEARCH=true to exercise the global row');
        return;
      }
      final container = await pumpPanel(tester);
      expect(container.read(mainTabProvider), 0, reason: 'starts on tab 0');

      // Type "ברז". The row is now TYPING HELP: the finder engine's most-decisive
      // next WORDS (via cardKeyboardPredictions), not the result titles. Compute
      // those words to know what the row renders.
      await tester.tap(find.text('ב'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ר'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ז'));
      await tester.pumpAndSettle();
      expect(container.read(keyboardDiveQueryProvider), 'ברז');

      final words = cardKeyboardPredictions(
          'ברז', kDivePool, buildWordLexicon(kDivePool), max: 5);
      expect(words, isNotEmpty,
          reason: 'sanity: the finder engine offers narrower words for ברז');
      final shown =
          words.where((w) => find.text(w).evaluate().isNotEmpty).toList();
      expect(shown, isNotEmpty,
          reason: 'the row renders the engine\'s narrower WORDS (typing help), '
              'not result titles');

      // Tapping a word APPENDS it (dispatch case iii) → the query GROWS and
      // narrows; it must NOT navigate — the row no longer carries result jumps.
      // (The row scrolls horizontally, so bring the chip on-screen before tapping.)
      final word = shown.first;
      await tester.ensureVisible(find.text(word).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(word).first);
      await tester.pumpAndSettle();
      expect(container.read(keyboardDiveQueryProvider), contains(word),
          reason: 'tapping a word appended it → the query narrowed step-by-step');
      expect(container.read(keyboardDiveQueryProvider), startsWith('ברז'),
          reason: 'the original query is kept; the word is added after it');
      expect(container.read(mainTabProvider), 0,
          reason: 'a word tap is typing help — it does NOT navigate anywhere');
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'the keyboard keeps floating');
      expect(find.byType(BsKeyboard), findsOneWidget);
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

    testWidgets(
        'a JOB in focus adds the "החלקים לעבודה" OPTION chip; tapping it opens a '
        'sheet of the job parts — an option, NOT a catalog replacement',
        (tester) async {
      if (!kGlobalSearch) {
        markTestSkipped('kGlobalSearch OFF — run with '
            '--dart-define=GLOBAL_SEARCH=true');
        return;
      }
      final container = await pumpPanel(tester);
      // No job in focus → no option chip (the catalog surface is untouched).
      expect(find.textContaining('החלקים לעבודה'), findsNothing);

      // Open a job: seed its parts (task 1 = the hot-water PEX couplers).
      container.read(keyboardJobSkusProvider.notifier).state =
          const <String>['77401622', '77402222'];
      await tester.pumpAndSettle();

      final chip = find.textContaining('החלקים לעבודה');
      expect(chip, findsOneWidget,
          reason: 'an open job adds the option chip to the search row');

      await tester.ensureVisible(chip.first);
      await tester.pumpAndSettle();
      await tester.tap(chip.first);
      await tester.pumpAndSettle();

      // The kit sheet lists the job's OWN parts (both couplers are "מקשר …").
      expect(find.textContaining('מקשר'), findsWidgets,
          reason: 'tapping the option reveals the job parts');
    });
  });
}
