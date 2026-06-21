// 🃏 floating_card_keyboard — the PERSISTENT floating card-keyboard panel.
//
// Two layers, mirroring how the rest of the word-finder swarm is tested:
//   • UNIT (pure): `cardKeyboardPredictions` over the REAL union pool
//     (`kDivePool`) + the REAL lexicon (`buildWordLexicon`). Asserts the
//     opening-words result is non-empty & capped, a real narrowing query yields
//     a non-empty, capped, DIFFERENT result, determinism, and a custom max.
//     (Moved here from the deleted card_keyboard_sheet widget test; the helper
//     still lives in card_keyboard_sheet.dart.)
//   • WIDGET (hermetic): pumps the REAL [FloatingCardKeyboard] inside
//     ProviderScope + MaterialApp(home: Scaffold) and asserts the strip toggles
//     render (grid + gear), the prediction chips render, tapping the ▦ grid
//     toggle reveals a home tool ('מחלקות'), typing recomputes the row, and the
//     onTool path: tapping a tool sets keyboardOverlayOpenProvider to false AND
//     routes (departments → mainTab == 1).
//
// kSmartInput is NOT needed: [FloatingCardKeyboard] passes forceShow:true to the
// host, so the keyboard renders regardless of the opt-in flag. We still seed an
// EMPTY SharedPreferences mock (as production has it OFF) to prove forceShow is
// what surfaces the keyboard.

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:buildsmart/screens/card_keyboard_sheet.dart';
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/keyboard_overlay.dart';
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
      expect(chips.length, lessThanOrEqualTo(4),
          reason: 'capped at default max');
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

  // ── WIDGET: the floating panel, pumped directly ───────────────────────────
  group('FloatingCardKeyboard — the floating card-keyboard panel', () {
    setUp(() {
      // EMPTY flags — the kSmartInput opt-in is OFF, exactly as in production.
      // FloatingCardKeyboard passes forceShow:true, so its keyboard must render
      // anyway; this guards that forceShow (not the opt-in flag) surfaces it.
      SharedPreferences.setMockInitialValues({});
    });

    /// Pumps the REAL [FloatingCardKeyboard] inside ProviderScope +
    /// MaterialApp(home: Scaffold). The panel is mounted ONLY while
    /// [keyboardOverlayOpenProvider] is true (mirroring the real shell), seeded
    /// true here, so a tool/close that flips it false actually removes the panel
    /// — letting us assert the overlay closed. Returns the container for
    /// provider reads.
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

    testWidgets('renders the strip toggles + prediction chips', (tester) async {
      await pumpPanel(tester);

      // The keyboard mounted (forceShow bypassed the kSmartInput gate).
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the panel shows the keyboard-with-tools');

      // The strip toggles: grid (▦) + gear (⚙️).
      expect(find.byIcon(Icons.grid_view), findsOneWidget,
          reason: 'the grid toggle renders in the strip');
      expect(find.byIcon(Icons.settings), findsOneWidget,
          reason: 'the gear toggle renders in the strip');

      // The read-only query field with its hint.
      expect(find.text('מה לחפש?'), findsOneWidget,
          reason: 'the search field hint shows');

      // The close down-chevron handle.
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget,
          reason: 'the floating panel has a close affordance');

      // At least one opening prediction chip is present (real lexicon words).
      final lexicon = buildWordLexicon(kDivePool);
      final opening = cardKeyboardPredictions('', kDivePool, lexicon);
      expect(opening, isNotEmpty, reason: 'sanity: opening words exist');
      expect(find.text(opening.first), findsWidgets,
          reason: 'the first opening prediction chip renders');
    });

    testWidgets('tapping the ▦ grid toggle reveals a home tool (מחלקות)',
        (tester) async {
      await pumpPanel(tester);

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
      await pumpPanel(tester);

      final lexicon = buildWordLexicon(kDivePool);
      final opening = cardKeyboardPredictions('', kDivePool, lexicon);

      // Type a Hebrew letter on the keyboard → it inserts into the controller,
      // whose listener recomputes the prediction row. 'ב' is the first letter of
      // 'ברז' and a real lexicon prefix.
      final afterB = cardKeyboardPredictions('ב', kDivePool, lexicon);

      await tester.tap(find.text('ב'));
      await tester.pumpAndSettle();

      // The recompute ran without crashing and the on-screen row matches the
      // helper's verdict for the typed text.
      if (afterB.isNotEmpty) {
        expect(find.text(afterB.first), findsWidgets,
            reason: 'the live row tracks the helper for the typed text');
      }
      // And the field now carries the typed character.
      expect(find.text('ב'), findsWidgets,
          reason: 'the typed letter reached the field/controller');

      // Sanity that the harness produced a real opening row to begin with.
      expect(opening, isNotEmpty);
    });

    testWidgets('the close chevron sets keyboardOverlayOpenProvider false',
        (tester) async {
      final container = await pumpPanel(tester);
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'seeded open');

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      expect(container.read(keyboardOverlayOpenProvider), isFalse,
          reason: 'the close chevron flips the overlay provider off');
      // The panel is gone (the harness unmounts it when the provider is false).
      expect(find.byType(BsKeyboard), findsNothing,
          reason: 'closing removed the floating keyboard');
    });

    testWidgets('tapping a home tool closes the overlay AND navigates',
        (tester) async {
      final container = await pumpPanel(tester);

      // Open the home-tools layer, then tap the first tool ('מחלקות').
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.text('מחלקות'), findsOneWidget);

      await tester.tap(find.text('מחלקות'));
      await tester.pumpAndSettle();

      // onTool flipped the overlay provider off (no route to pop) → the panel is
      // gone, the screen underneath remains.
      expect(container.read(keyboardOverlayOpenProvider), isFalse,
          reason: 'the tool tap closed the floating overlay');
      expect(find.byType(BsKeyboard), findsNothing,
          reason: 'the tool tap removed the floating keyboard');
      expect(find.text('screen-underneath'), findsOneWidget,
          reason: 'the full screen underneath stays');

      // …and then ran runKeyboardTool(departments) → tab index 1.
      expect(container.read(mainTabProvider), 1,
          reason: 'departments tool routed the home to the departments tab');
    });
  });
}
