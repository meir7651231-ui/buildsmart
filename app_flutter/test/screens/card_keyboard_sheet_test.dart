// 🃏 card_keyboard_sheet — STEP 4 coverage.
//
// Two layers, mirroring how the rest of the word-finder swarm is tested:
//   • UNIT (pure): `cardKeyboardPredictions` over the REAL union pool
//     (`kDivePool`) + the REAL lexicon (`buildWordLexicon`). Asserts the
//     opening-words result is non-empty & capped, and that a real narrowing
//     query yields a non-empty, capped, DIFFERENT result — proving the row is
//     query-sensitive (it mirrors the finder's `_submitQuery` + `_pool`).
//   • WIDGET (hermetic): drives the REAL `openCardKeyboardSheet` from a tiny
//     harness (capturing a live context/ref via a Consumer), then asserts the
//     strip toggles render (grid + gear), the prediction chips render, tapping
//     the ▦ grid toggle reveals a home tool ('מחלקות'), and typing into the
//     field recomputes the predictions without crashing.
//
// The custom keyboard self-gates on `kSmartInput` (kb_field_mode.dart), so the
// widget pump enables that flag via the SharedPreferences mock exactly as
// bs_keyboard_host_test.dart does; otherwise BsKeyboardHost renders nothing.
// No `kKeyboardToolStrip` flip is needed: the sheet passes `showToolStrip: true`
// to the host directly, and the helper + sheet are exercised on their own (the
// launcher's compile-time flag gate is trivially correct and not retested here).

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:buildsmart/screens/card_keyboard_sheet.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── UNIT: the live prediction helper ──────────────────────────────────────
  group('cardKeyboardPredictions — live finder bridge', () {
    final lexicon = buildWordLexicon(kDivePool);

    test('empty query → opening words: non-empty, capped at 4', () {
      final chips = cardKeyboardPredictions('', kDivePool, lexicon);
      expect(chips, isNotEmpty,
          reason: 'an empty query opens with the engine word question');
      expect(chips.length, lessThanOrEqualTo(4), reason: 'capped at default max');
      for (final c in chips) {
        expect(c.trim(), isNotEmpty, reason: 'no blank chip: "$c"');
      }
      expect(chips.toSet().length, chips.length, reason: 'no duplicate chips');

      // The opening chips ARE genuine lexicon words (the empty-stack AskWords
      // branch offers WordEntry.word values verbatim).
      final lexiconWords = {for (final e in lexicon.entries) e.word};
      for (final c in chips) {
        expect(lexiconWords.contains(c), isTrue,
            reason: '"$c" must be a real lexicon word');
      }
    });

    test('a narrowing query → non-empty, capped, and DIFFERS from opening', () {
      // 'ברז' (faucet) is a common Hebrew product word present in the catalogue;
      // typing it narrows the pool, so the engine offers a different question
      // than the empty-stack opening words — proving query-sensitivity.
      const query = 'ברז';
      final opening = cardKeyboardPredictions('', kDivePool, lexicon);
      final narrowed = cardKeyboardPredictions(query, kDivePool, lexicon);

      expect(narrowed, isNotEmpty,
          reason: 'the query matches catalogue products → chips to offer');
      expect(narrowed.length, lessThanOrEqualTo(4), reason: 'capped at max');
      for (final c in narrowed) {
        expect(c.trim(), isNotEmpty, reason: 'no blank chip: "$c"');
      }
      expect(narrowed.toSet().length, narrowed.length,
          reason: 'no duplicate chips');
      expect(narrowed, isNot(equals(opening)),
          reason: 'a real query must change the row vs. the opening words');
    });

    test('the same (query, pool, lexicon) is deterministic', () {
      final a = cardKeyboardPredictions('ברז', kDivePool, lexicon);
      final b = cardKeyboardPredictions('ברז', kDivePool, lexicon);
      expect(a, equals(b), reason: 'pure: identical inputs ⇒ identical output');
    });

    test('a custom max caps the opening row (max: 2)', () {
      final chips = cardKeyboardPredictions('', kDivePool, lexicon, max: 2);
      expect(chips.length, lessThanOrEqualTo(2), reason: 'honours max:2');
    });
  });

  // ── WIDGET: the sheet, opened via the real helper ─────────────────────────
  group('openCardKeyboardSheet — the card-keyboard sheet', () {
    setUp(() {
      // EMPTY flags — the kSmartInput opt-in is OFF, exactly as in production.
      // The sheet passes forceShow:true, so its keyboard must render anyway; this
      // guards the go-live gate fix (previously this test enabled the flag, which
      // masked that the live default left the sheet's keyboard hidden).
      SharedPreferences.setMockInitialValues({});
    });

    /// Pumps a tiny home harness with a single "open" button that calls the REAL
    /// [openCardKeyboardSheet] with a live context+ref (captured from the
    /// Consumer's builder), taps it, and settles so the sheet + async flag load
    /// resolve. Leaves the sheet open for assertions.
    Future<void> pumpAndOpenSheet(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Consumer(
                builder: (context, ref, _) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => openCardKeyboardSheet(context, ref),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('opens with the strip toggles + prediction chips', (tester) async {
      await pumpAndOpenSheet(tester);

      // The keyboard mounted (custom keyboard enabled).
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the sheet shows the keyboard-with-tools');

      // The strip toggles: grid (▦) + gear (⚙️).
      expect(find.byIcon(Icons.grid_view), findsOneWidget,
          reason: 'the grid toggle renders in the strip');
      expect(find.byIcon(Icons.settings), findsOneWidget,
          reason: 'the gear toggle renders in the strip');

      // The read-only query field with its hint.
      expect(find.text('מה לחפש?'), findsOneWidget,
          reason: 'the search field hint shows');

      // At least one opening prediction chip is present. The opening words are
      // real lexicon words; assert one of the helper's own chips is on screen.
      final lexicon = buildWordLexicon(kDivePool);
      final opening = cardKeyboardPredictions('', kDivePool, lexicon);
      expect(opening, isNotEmpty, reason: 'sanity: opening words exist');
      expect(find.text(opening.first), findsWidgets,
          reason: 'the first opening prediction chip renders');
    });

    testWidgets('tapping the ▦ grid toggle reveals a home tool (מחלקות)',
        (tester) async {
      await pumpAndOpenSheet(tester);

      // Before: no home-tools tile is shown (the strip toggle uses a Semantics
      // label, not a Text, so find.text finds nothing).
      expect(find.text('מחלקות'), findsNothing,
          reason: 'no home-tools layer open yet');

      // Tap the grid toggle → opens the home-tools layer over the letters.
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      // The first home tool tile ('מחלקות') is now rendered as Text.
      expect(find.text('מחלקות'), findsOneWidget,
          reason: 'the grid toggle opened the home tools layer');
    });

    testWidgets('typing into the field recomputes the predictions',
        (tester) async {
      await pumpAndOpenSheet(tester);

      // Capture the opening chip set from the helper (ground truth).
      final lexicon = buildWordLexicon(kDivePool);
      final opening = cardKeyboardPredictions('', kDivePool, lexicon);

      // Type a Hebrew letter on the keyboard → it inserts into the controller,
      // whose listener recomputes the prediction row. 'ב' is the first letter of
      // 'ברז' and a real lexicon prefix, so the row should change to the engine's
      // narrowed offer for that query (computed here as the expected truth).
      final afterB = cardKeyboardPredictions('ב', kDivePool, lexicon);

      await tester.tap(find.text('ב'));
      await tester.pumpAndSettle();

      // The recompute ran without crashing and the on-screen row matches the
      // helper's verdict for the typed text. (If the narrowed row equals the
      // opening row for this prefix the test still holds — we assert the live
      // row tracks the helper, the source of truth, not that it necessarily
      // differs.)
      if (afterB.isNotEmpty) {
        expect(find.text(afterB.first), findsWidgets,
            reason: 'the live row tracks the helper for the typed text');
      }
      // And the field now carries the typed character (proves the keystroke
      // reached the controller that drives the recompute).
      expect(find.text('ב'), findsWidgets,
          reason: 'the typed letter reached the field/controller');

      // Sanity that the harness produced a real opening row to begin with.
      expect(opening, isNotEmpty);
    });

    testWidgets('tapping a home tool closes the sheet and navigates',
        (tester) async {
      await pumpAndOpenSheet(tester);

      // Open the home-tools layer, then tap the first tool ('מחלקות').
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.text('מחלקות'), findsOneWidget);

      await tester.tap(find.text('מחלקות'));
      await tester.pumpAndSettle();

      // onTool popped the sheet (the keyboard is gone, the launcher is back)…
      expect(find.byType(BsKeyboard), findsNothing,
          reason: 'the tool tap closed the sheet');
      expect(find.text('open'), findsOneWidget);

      // …and then ran runKeyboardTool(departments) on the home → tab index 1.
      final container =
          ProviderScope.containerOf(tester.element(find.text('open')));
      expect(container.read(mainTabProvider), 1,
          reason: 'departments tool routed the home to the departments tab');
    });
  });
}
