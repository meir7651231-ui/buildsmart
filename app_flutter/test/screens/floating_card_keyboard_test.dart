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

import 'dart:io';

import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/word_lexicon.dart';
import 'package:buildsmart/screens/card_keyboard_sheet.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogSectionProvider;
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show matchDestinations;
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/widgets/smart_input/caret.dart' show insertAtCaret;
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

    testWidgets(
        'tapping a LEAF (מחלקות) navigates AND keeps the overlay floating',
        (tester) async {
      final container = await pumpPanel(tester);

      // Open the home-tools layer (grid toggle pushes the home node-list), then
      // tap the first LEAF ('מחלקות').
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.text('מחלקות'), findsOneWidget);

      await tester.tap(find.text('מחלקות'));
      await tester.pumpAndSettle();

      // STEP B owner model: a LEAF navigates the screen UNDERNEATH (departments
      // → tab 1) but the keyboard KEEPS FLOATING — the overlay stays OPEN and the
      // BsKeyboard is still mounted over the swapped screen.
      expect(container.read(mainTabProvider), 1,
          reason: 'departments LEAF routed the home to the departments tab');
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'a LEAF tap must NOT close the floating overlay');
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the keyboard keeps floating over the swapped screen');
      expect(find.text('screen-underneath'), findsOneWidget,
          reason: 'the full screen underneath stays');
    });

    // ── STEP D — מהירים / הזמנות / קולי wiring ─────────────────────────────────
    testWidgets(
        'drilling the מהירים BRANCH shows its 3 quick-action children',
        (tester) async {
      final container = await pumpPanel(tester);
      final tabBefore = container.read(mainTabProvider);

      // Open the home-tools layer (grid toggle), revealing the מהירים branch.
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.text('מהירים'), findsOneWidget,
          reason: 'the grid toggle opened the home tools (מהירים is a branch)');

      // Tapping the BRANCH morphs IN PLACE to the 3 _QuickTools children — with
      // NO navigation and NO close (matching smart_home_screen _QuickTools).
      await tester.tap(find.text('מהירים'));
      await tester.pumpAndSettle();

      expect(find.text('סריקת תוכנית'), findsOneWidget,
          reason: 'the branch morphed to the scan-plan child');
      expect(find.text('המלאי שלי'), findsOneWidget,
          reason: 'the branch morphed to the my-stock child');
      expect(find.text('משימות'), findsOneWidget,
          reason: 'the branch morphed to the tasks child');
      // The parent label is gone (we drilled in), and nothing navigated.
      expect(find.text('מהירים'), findsNothing,
          reason: 'the view morphed away from the home node-list');
      expect(container.read(mainTabProvider), tabBefore,
          reason: 'morphing the מהירים branch does not navigate');
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'morphing a branch keeps the overlay open');

      // BACK from the children returns to the home node-list (מהירים reappears).
      await tester.tap(find.text('חזרה'));
      await tester.pumpAndSettle();
      expect(find.text('מהירים'), findsOneWidget,
          reason: 'back returned to the home node-list');
      expect(find.text('סריקת תוכנית'), findsNothing,
          reason: 'the branch children are popped away');
    });

    testWidgets(
        'tapping the הזמנות LEAF jumps to the store orders section, floating',
        (tester) async {
      final container = await pumpPanel(tester);
      expect(container.read(mainTabProvider), 0, reason: 'starts on tab 0');

      // Open the home-tools layer and tap the הזמנות LEAF.
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.text('הזמנות'), findsOneWidget);

      await tester.tap(find.text('הזמנות'));
      await tester.pumpAndSettle();

      // הזמנות mirrors the store's own pills: tab 3 (חנות) + orders section. The
      // keyboard KEEPS FLOATING (a section swap under the overlay, no close).
      expect(container.read(mainTabProvider), 3,
          reason: 'הזמנות routed the home to the store tab (3)');
      expect(container.read(storeSectionProvider), StoreSection.orders,
          reason: 'הזמנות selected the orders section');
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'a LEAF tap must NOT close the floating overlay');
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the keyboard keeps floating over the swapped screen');
    });

    testWidgets(
        'the קולי voice node is present and its tap path is wired (crash-safe, '
        'no live mic)', (tester) async {
      final container = await pumpPanel(tester);

      // Open the KBD-tools layer (gear toggle) → the קולי tile is present. This
      // is the field-intercept node (KbToolNode.isVoiceInput): the floating
      // keyboard routes its tap to the mic→insertAtCaret path, NOT a nav action.
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('קולי'), findsOneWidget,
          reason: 'the gear toggle revealed the voice node');

      // Tapping it exercises the REAL _onTile → _startVoiceInput intercept. The
      // speech plugin is not registered in a widget test, so listen() throws a
      // MissingPluginException — which the wiring must swallow into a quiet
      // "בקרוב" WITHOUT crashing the overlay. We assert: no nav happened, the
      // overlay stayed floating, and the keyboard is still mounted.
      final tabBefore = container.read(mainTabProvider);
      await tester.tap(find.text('קולי'));
      await tester.pumpAndSettle();

      expect(container.read(mainTabProvider), tabBefore,
          reason: 'voice does not navigate');
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'the voice tap keeps the overlay floating');
      expect(find.byType(BsKeyboard), findsOneWidget,
          reason: 'the voice tap is crash-safe (keyboard still mounted)');
      // NOTE: we do NOT assert the "בקרוב" SnackBar here — in a widget test the
      // unregistered speech_to_text method channel leaves listen() PENDING (it
      // neither throws nor returns), so the fallback feedback may not fire. The
      // point of THIS test is that the voice tap is crash-safe + keep-floating;
      // the transcript SINK (insertAtCaret) is asserted in the next test.
    });

    // The voice node's SINK (what onFinal does with a transcript) is the same
    // caret-insert the prediction-word path uses. We assert that field-insert
    // behaviour directly on the panel's own controller — proving the wiring's
    // landing point works — without invoking the real mic plugin.
    testWidgets('voice transcript sink: insertAtCaret lands text in the field',
        (tester) async {
      await pumpPanel(tester);

      // The floating panel owns exactly one TextField → one EditableText.
      final controller =
          tester.widget<EditableText>(find.byType(EditableText)).controller;
      expect(controller.text, isEmpty, reason: 'field starts empty');

      // This is EXACTLY what _startVoiceInput's onFinal runs with a transcript.
      insertAtCaret(controller, 'ברז כדורי ');
      await tester.pumpAndSettle();

      expect(controller.text, 'ברז כדורי ',
          reason: 'the spoken transcript lands in the search field');
      // And the live prediction-row listener recomputed without crashing.
      expect(find.byType(BsKeyboard), findsOneWidget);
    });

    testWidgets(
        'tapping the תפריט BRANCH morphs in place (children appear, no nav)',
        (tester) async {
      final container = await pumpPanel(tester);
      final tabBefore = container.read(mainTabProvider);

      // Open the kbd-tools layer (gear toggle), revealing the תפריט branch tile.
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('תפריט'), findsOneWidget,
          reason: 'the gear toggle opened the kbd tools (תפריט is a branch)');

      // Tapping the BRANCH morphs the tool view IN PLACE to its children — the
      // AI hub (בינה) + settings (הגדרות) tiles — with NO navigation and NO close.
      await tester.tap(find.text('תפריט'));
      await tester.pumpAndSettle();

      expect(find.text('בינה'), findsOneWidget,
          reason: 'the branch morphed to its AI-hub child tile');
      expect(find.text('הגדרות'), findsOneWidget,
          reason: 'the branch morphed to its settings child tile');
      // The parent label is gone (we drilled into the branch).
      expect(find.text('תפריט'), findsNothing,
          reason: 'the view morphed away from the parent node-list');

      // No navigation happened, and the overlay is still open.
      expect(container.read(mainTabProvider), tabBefore,
          reason: 'morphing a branch does not navigate');
      expect(container.read(keyboardOverlayOpenProvider), isTrue,
          reason: 'morphing a branch keeps the overlay open');
      expect(find.byType(BsKeyboard), findsOneWidget);
      // No route was pushed (the AI-hub/settings screens are not present yet).
      expect(find.text('screen-underneath'), findsOneWidget);
    });

    testWidgets('BACK pops the branch back to its parent node-list',
        (tester) async {
      await pumpPanel(tester);

      // Drill: gear → תפריט branch → its children.
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('תפריט'));
      await tester.pumpAndSettle();
      expect(find.text('הגדרות'), findsOneWidget, reason: 'drilled in');
      // A BACK tile leads the drilled view.
      expect(find.text('חזרה'), findsOneWidget,
          reason: 'a back affordance leads a tool-view');

      // BACK → pop to the parent (kbd) node-list: the branch tile is back and
      // the children are gone. (A back tile still leads the parent — it is a top
      // tool-view, whose own back returns to the letters.)
      await tester.tap(find.text('חזרה'));
      await tester.pumpAndSettle();
      expect(find.text('תפריט'), findsOneWidget,
          reason: 'back returned to the parent kbd node-list');
      expect(find.text('בינה'), findsNothing,
          reason: 'the branch children are popped away');
    });

    testWidgets('BACK from a top tool-view returns to the letters',
        (tester) async {
      // A representative Hebrew letter present ONLY on the letter layer.
      const hebrewLetter = 'ק';
      await pumpPanel(tester);

      // Open the home base (top) tool-view: the letters are hidden and a BACK
      // tile leads it (the spec's "from a top tool-view, back returns").
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();
      expect(find.text('מחלקות'), findsOneWidget);
      expect(find.text(hebrewLetter), findsNothing);
      expect(find.text('חזרה'), findsOneWidget,
          reason: 'a top tool-view still shows a back tile');

      // BACK from the top tool-view empties the stack → the letters return.
      await tester.tap(find.text('חזרה'));
      await tester.pumpAndSettle();
      expect(find.text(hebrewLetter), findsOneWidget,
          reason: 'back from a top tool-view returns to the letters');
      expect(find.text('מחלקות'), findsNothing,
          reason: 'the tool tiles are gone once back at the letters');
    });

    testWidgets('re-tapping the lit grid toggle also closes back to letters',
        (tester) async {
      const hebrewLetter = 'ק';
      await pumpPanel(tester);

      // The strip's grid toggle is the FIRST grid_view icon (the strip renders
      // above the tiles). Once the home layer opens, the departments tile ALSO
      // draws a grid_view icon, so we always target the toggle via `.first`.
      Finder gridToggle() => find.byIcon(Icons.grid_view).first;

      // Open the home base…
      await tester.tap(gridToggle());
      await tester.pumpAndSettle();
      expect(find.text('מחלקות'), findsOneWidget);

      // …then tap the now-lit grid toggle again → the strip toggle is the
      // secondary close path (legacy parity), also returning to the letters.
      await tester.tap(gridToggle());
      await tester.pumpAndSettle();
      expect(find.text(hebrewLetter), findsOneWidget,
          reason: 'a second tap on the lit toggle clears the tool view');
      expect(find.text('מחלקות'), findsNothing);
    });

    // ── TYPE-TO-NAVIGATE: destinations merged into the prediction row ──────────
    group('type-to-navigate destinations', () {
      testWidgets(
          'typing a destination term surfaces it in the prediction row',
          (tester) async {
        await pumpPanel(tester);

        // Empty field: the prediction row shows product WORDS only — no
        // destination chip yet (matchDestinations('') is empty).
        expect(matchDestinations(''), isEmpty, reason: 'sanity: empty → none');
        expect(find.text('מחלקות'), findsNothing,
            reason: 'no destination chip on the empty field');

        // Type "מח" (two letter taps). matchDestinations('מח') surfaces the
        // 'מחלקות' destination (label contains the typed prefix). The pure
        // matcher's verdict and the on-screen row must agree.
        final hits = matchDestinations('מח').map((d) => d.label).toList();
        expect(hits, contains('מחלקות'),
            reason: 'sanity: the matcher offers מחלקות for "מח"');

        await tester.tap(find.text('מ'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ח'));
        await tester.pumpAndSettle();

        // The destination chip now renders in the prediction row (as plain Text,
        // exactly like a product-word chip — the pure keyboard sees only labels).
        expect(find.text('מחלקות'), findsWidgets,
            reason: 'the destination chip surfaced from typing "מח"');
      });

      testWidgets(
          'the destination chip shows the nav glyph; a product word chip does NOT',
          (tester) async {
        // FITTING PREDICTION (owner: "חיזוי מתאים"): after typing a destination
        // term, the destination chip is visually distinct — a leading
        // Icons.north_east nav glyph — while a query-narrowing product WORD chip
        // stays plain. The floating keyboard feeds _destByChip.keys as the
        // destinationChips, so only the destination chip is tinted.
        await pumpPanel(tester);

        // Empty field: the row is product WORDS only → no nav glyph anywhere.
        expect(find.byIcon(Icons.north_east), findsNothing,
            reason: 'no destination chip (hence no glyph) on the empty field');

        // Type "מח" → surface the מחלקות destination chip.
        await tester.tap(find.text('מ'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ח'));
        await tester.pumpAndSettle();
        expect(find.text('מחלקות'), findsWidgets,
            reason: 'sanity: the destination chip is present');

        // The nav glyph is INSIDE the מחלקות chip (a descendant of the chip's
        // own InkWell, which wraps both the glyph and the label).
        final glyphInDest = find.descendant(
          of: find.widgetWithText(InkWell, 'מחלקות'),
          matching: find.byIcon(Icons.north_east),
        );
        expect(glyphInDest, findsOneWidget,
            reason: 'the destination chip מחלקות shows the nav glyph');

        // Now prove a PRODUCT WORD chip in the SAME row carries NO glyph. Pick a
        // word the pure helpers say is on screen for "מח" and is NOT a
        // destination label (so the floating keyboard left it plain).
        final lexicon = buildWordLexicon(kDivePool);
        final words = cardKeyboardPredictions('מח', kDivePool, lexicon);
        final dests = matchDestinations('מח').map((d) => d.label).toSet();
        var wordOnly = '';
        for (final w in words) {
          if (dests.contains(w)) continue;
          if (find.text(w).evaluate().isNotEmpty) {
            wordOnly = w;
            break;
          }
        }

        // Only assert the negative when such a rendered word chip exists (the
        // reserved word slot makes this the normal case; guard keeps the test
        // robust if the catalogue ever offers none for this prefix).
        if (wordOnly.isNotEmpty) {
          final glyphInWord = find.descendant(
            of: find.widgetWithText(InkWell, wordOnly),
            matching: find.byIcon(Icons.north_east),
          );
          expect(glyphInWord, findsNothing,
              reason:
                  'the product word chip "$wordOnly" must not show the nav glyph');
        }
      });

      testWidgets(
          'tapping a destination chip NAVIGATES and keeps the overlay floating',
          (tester) async {
        final container = await pumpPanel(tester);
        expect(container.read(mainTabProvider), 0, reason: 'starts on tab 0');

        // Type "מח" → surface the מחלקות destination chip.
        await tester.tap(find.text('מ'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ח'));
        await tester.pumpAndSettle();
        expect(find.text('מחלקות'), findsWidgets,
            reason: 'sanity: the destination chip is present to tap');

        // Tap the destination chip. מחלקות runs runKeyboardTool(departments),
        // which sets mainTabProvider = 1 (DepartmentsScreen in the IndexedStack).
        await tester.tap(find.text('מחלקות').first);
        await tester.pumpAndSettle();

        // Owner model: a DESTINATION chip navigates the screen underneath but the
        // keyboard KEEPS FLOATING — the overlay stays OPEN and the keyboard stays
        // mounted (contrast a product WORD, which only appends to the field).
        expect(container.read(mainTabProvider), 1,
            reason: 'the מחלקות destination routed to the departments tab');
        expect(container.read(keyboardOverlayOpenProvider), isTrue,
            reason: 'a destination tap must NOT close the floating overlay');
        expect(find.byType(BsKeyboard), findsOneWidget,
            reason: 'the keyboard keeps floating after navigating');
        expect(find.text('screen-underneath'), findsOneWidget,
            reason: 'the full screen underneath stays');
      });

      testWidgets(
          'tapping a SECTION destination sets the catalog section provider',
          (tester) async {
        final container = await pumpPanel(tester);

        // Type "מאת" → the מאתר destination (catalog 'מאתר' section). Three taps:
        // מ · א · ת. matchDestinations('מאת') offers מאתר.
        expect(matchDestinations('מאת').map((d) => d.label), contains('מאתר'),
            reason: 'sanity: the matcher offers מאתר for "מאת"');

        await tester.tap(find.text('מ'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('א'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ת'));
        await tester.pumpAndSettle();
        expect(find.text('מאתר'), findsWidgets,
            reason: 'sanity: the מאתר destination chip surfaced');

        await tester.tap(find.text('מאתר').first);
        await tester.pumpAndSettle();

        // מאתר routes via runKeyboardTool(finder): tab 0 + catalogSectionProvider
        // == 'מאתר'. The overlay stays open (keep-floating).
        expect(container.read(mainTabProvider), 0,
            reason: 'the finder destination lands on the catalog tab');
        expect(container.read(catalogSectionProvider), 'מאתר',
            reason: 'the catalog section provider switched to מאתר');
        expect(container.read(keyboardOverlayOpenProvider), isTrue,
            reason: 'a section destination keeps the overlay floating');
      });

      testWidgets('a product WORD chip still appends to the field (unchanged)',
          (tester) async {
        final container = await pumpPanel(tester);

        // Type "ב" → the row carries product words (e.g. 'ברז'-family) and NO
        // destination starts with bare "ב" as a leading label, so the first
        // chips are words. We tap a chip that is a product word (absent from the
        // destination map) and assert the field GREW (append behaviour), the tab
        // did NOT change, and the overlay stayed open.
        await tester.tap(find.text('ב'));
        await tester.pumpAndSettle();

        final lexicon = buildWordLexicon(kDivePool);
        final words = cardKeyboardPredictions('ב', kDivePool, lexicon);
        final dests = matchDestinations('ב').map((d) => d.label).toSet();
        // Pick a product word that is NOT a destination AND is actually rendered
        // in the (capped, destinations-lead) row. The reserved word slot
        // guarantees at least one such word is on screen.
        var wordOnly = '';
        for (final w in words) {
          if (dests.contains(w)) continue;
          if (find.text(w).evaluate().isNotEmpty) {
            wordOnly = w;
            break;
          }
        }

        if (wordOnly.isNotEmpty) {
          final tabBefore = container.read(mainTabProvider);

          // Read the read-only field's live text via its EditableText controller
          // (the floating panel owns exactly one TextField → one EditableText).
          String fieldText() =>
              tester.widget<EditableText>(find.byType(EditableText)).controller.text;
          final before = fieldText();

          await tester.tap(find.text(wordOnly).first);
          await tester.pumpAndSettle();

          // Word path: insertAtCaret appended "$wordOnly " → the field GREW and
          // now contains the tapped word; navigation did NOT fire; overlay open.
          final after = fieldText();
          expect(after.length, greaterThan(before.length),
              reason: 'a product word appends to the field (grows it)');
          expect(after.contains(wordOnly), isTrue,
              reason: 'the tapped product word "$wordOnly" reached the field');
          expect(container.read(mainTabProvider), tabBefore,
              reason: 'tapping a product word must NOT navigate');
          expect(container.read(keyboardOverlayOpenProvider), isTrue,
              reason: 'tapping a product word keeps the overlay open');
          expect(find.byType(BsKeyboard), findsOneWidget);
        }
      });
    });

    // ── CONTEXT-FITTING (empty field): the row reflects WHERE I AM + WHAT I
    // PRESSED, not only what I type. Owner mandate: at the letters the empty row
    // is the CURRENT TAB's destinations; drilled it is the current node-list;
    // the TYPED path stays untouched. ───────────────────────────────────────────
    group('context-fitting prediction (empty field)', () {
      /// Like [pumpPanel] but seeds [mainTabProvider] to [tab] so the empty-field
      /// row is computed for that tab (the panel `ref.watch`es it in build). Same
      /// hermetic shell otherwise; returns the container for provider reads.
      Future<ProviderContainer> pumpPanelOnTab(
        WidgetTester tester,
        int tab,
      ) async {
        final container = ProviderContainer(
          overrides: [
            keyboardOverlayOpenProvider.overrideWith((_) => true),
            mainTabProvider.overrideWith((_) => tab),
          ],
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

      /// True when [label] renders as a NAVIGABLE prediction chip — i.e. a
      /// `_PredictionChip` InkWell that contains the `Icons.north_east` nav glyph.
      /// This is exactly how the pure keyboard marks a destination/leaf chip, and
      /// it distinguishes a CHIP from a same-text tool TILE (tiles carry no glyph)
      /// or a product-word chip (also no glyph).
      Finder navChip(String label) => find.descendant(
            of: find.widgetWithText(InkWell, label),
            matching: find.byIcon(Icons.north_east),
          );

      // (a) AT THE LETTERS, the empty row = the CURRENT TAB's destination chips,
      // and flipping the tab swaps the whole set. The tab labels are NOT product
      // opening-words, so their PRESENCE proves the context path fired (not the
      // legacy product row), and the other tab's labels being ABSENT proves the
      // row is tab-scoped — both would break if _rowFor stopped reading the tab.
      testWidgets(
          'empty field, tab 3 → store destination chips (not product words); '
          'tab 1 → the 4 departments', (tester) async {
        // Sanity: these tab labels are destination labels, NOT product
        // opening-words — so finding them can only come from the context path.
        final lexicon = buildWordLexicon(kDivePool);
        final opening = cardKeyboardPredictions('', kDivePool, lexicon).toSet();
        const store = ['הסל שלי', 'ההזמנות שלי', 'שירותים'];
        const depts = [
          'אינסטלציה',
          'ברזים וסניטריים',
          'כלי עבודה ידני',
          'כלי עבודה חשמלי',
        ];
        for (final l in [...store, ...depts]) {
          expect(opening.contains(l), isFalse,
              reason: 'sanity: "$l" is a tab destination, not a product word');
        }

        // TAB 3 (חנות): the store section chips show, each with the nav glyph;
        // the tab-1 department chips do NOT (the row is tab-scoped).
        await pumpPanelOnTab(tester, 3);
        for (final l in store) {
          expect(navChip(l), findsOneWidget,
              reason: 'tab 3 empty row shows the store chip "$l" (navigable)');
        }
        for (final l in depts) {
          expect(find.text(l), findsNothing,
              reason: 'tab 3 must not show a tab-1 department chip ("$l")');
        }

        // TAB 1 (מחלקות): now the 4 departments show; the store chips are gone.
        await pumpPanelOnTab(tester, 1);
        for (final l in depts) {
          expect(navChip(l), findsOneWidget,
              reason: 'tab 1 empty row shows the department chip "$l"');
        }
        for (final l in store) {
          expect(find.text(l), findsNothing,
              reason: 'tab 1 must not show a tab-3 store chip ("$l")');
        }
      });

      // (b) DRILLED with an EMPTY field → owner decision (option 1): the row does
      // NOT mirror the drilled tools as chips (that duplicated them with the body
      // tiles). The drill morphs the BODY; the prediction row keeps the tab
      // context. This guards that drilling adds NO navigable node chip.
      testWidgets(
          'empty field + drilled (grid) → NO node chips (body morphs, row keeps '
          'tab context)', (tester) async {
        final container = await pumpPanel(tester); // tab 0, empty field.
        expect(container.read(mainTabProvider), 0, reason: 'starts on tab 0');

        // Open the home node-list (grid): the BODY now shows the tool tiles, but
        // the prediction row must NOT add a navigable 'מחלקות' chip (option 1).
        await tester.tap(find.byIcon(Icons.grid_view));
        await tester.pumpAndSettle();
        expect(find.text('מחלקות'), findsOneWidget,
            reason: 'the drill shows the tool TILE in the body (morph)');
        expect(navChip('מחלקות'), findsNothing,
            reason: 'option 1: drilling adds NO navigable prediction chip');
        expect(navChip('מהירים'), findsNothing,
            reason: 'no drilled branch chip in the row either');
      });

      // (c) The TYPED-query path is UNCHANGED by the empty-field rework: typing a
      // destination term still surfaces the merged destination chip with its nav
      // glyph (guards that adding the context branches did not regress branch 1).
      testWidgets('typing a query still shows the merged typed destination row',
          (tester) async {
        await pumpPanelOnTab(tester, 3); // start on a NON-zero tab on purpose.

        // Empty field on tab 3 shows the store context chips (not 'מחלקות').
        expect(find.text('מחלקות'), findsNothing,
            reason: 'empty tab-3 row has no מחלקות (that is a typed match)');

        // Type "מח" → the TYPED branch runs (text non-empty), merging the
        // 'מחלקות' destination ahead of product words — exactly as before, even
        // though we began on a non-zero tab.
        final hits = matchDestinations('מח').map((d) => d.label).toList();
        expect(hits, contains('מחלקות'),
            reason: 'sanity: the matcher offers מחלקות for "מח"');

        await tester.tap(find.text('מ'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ח'));
        await tester.pumpAndSettle();

        expect(navChip('מחלקות'), findsOneWidget,
            reason: 'the typed destination chip surfaced with its nav glyph');
      });

      // (d) TAB 2 (עדכונים) empty row = שיחות + התראות, and TAPPING a tab chip
      // dispatches via KbDestination.run (dispatch case ii). Tab 2 is otherwise
      // untested, and no other test taps an EMPTY-FIELD tab chip — a regression
      // that rendered tab chips but failed to persist _destByChip on the tab
      // branch (so the tap fell through to the product-word append) would pass
      // every other test yet FAIL the tab/sub-tab assertions below.
      testWidgets(
          'empty field, tab 2 → שיחות + התראות chips; tapping שיחות routes '
          '(tab 2 + sub-tab) and keeps floating', (tester) async {
        final container = await pumpPanelOnTab(tester, 2);

        // Both updates sub-tab labels show as NAVIGABLE chips (each carries its
        // real run from the registry, sourced by label).
        expect(navChip('שיחות'), findsOneWidget,
            reason: 'tab 2 empty row shows the שיחות chip (navigable)');
        expect(navChip('התראות'), findsOneWidget,
            reason: 'tab 2 empty row shows the התראות chip (navigable)');
        // The row is tab-scoped: a tab-3 store label must NOT leak in.
        expect(find.text('הסל שלי'), findsNothing,
            reason: 'tab 2 must not show a tab-3 store chip');

        // Tap שיחות → its KbDestination.run fires (_openUpdatesSub(1)): tab 2 +
        // updatesSubTabProvider == 1 (שיחות). The pre-feature empty row showed
        // product words, so this navigation is the regression catch. Overlay
        // stays open (a sub-tab swap under the floating keyboard).
        await tester.tap(navChip('שיחות'));
        await tester.pumpAndSettle();
        expect(container.read(mainTabProvider), 2,
            reason: 'the שיחות tab chip ran its action (→ updates tab 2)');
        expect(container.read(updatesSubTabProvider), 1,
            reason: 'שיחות selected the chats sub-tab (1)');
        expect(container.read(keyboardOverlayOpenProvider), isTrue,
            reason: 'an empty-field tab chip tap keeps the overlay floating');
        expect(find.byType(BsKeyboard), findsOneWidget,
            reason: 'the keyboard keeps floating after the tab-chip nav');
      });

      // (e) TAB 0 (בית/catalog) empty field is UNCHANGED: it keeps product
      // opening-words ONLY — NO tab/destination chip, and crucially NO nav glyph
      // anywhere. The spec's "tab 0 keeps product opening-words" invariant. A
      // regression that routed tab 0 into the destination path would surface a
      // 'בית'/'מחלקות' destination chip and a nav glyph on the empty catalog
      // field; this is the only test asserting the tab-0 empty row is glyph-free.
      testWidgets(
          'empty field, tab 0 → product opening-words only (no nav glyph, no '
          'tab destination chip)', (tester) async {
        await pumpPanelOnTab(tester, 0); // explicit tab 0, empty field.

        // No navigable glyph at all — the empty tab-0 row is product words, which
        // are plain (the destination/leaf path is what adds Icons.north_east).
        expect(find.byIcon(Icons.north_east), findsNothing,
            reason: 'tab 0 empty row is product words → no nav glyph');
        // And no tab-destination label leaked into the catalog opening row.
        for (final l in const ['בית', 'מחלקות', 'הסל שלי', 'שיחות']) {
          expect(navChip(l), findsNothing,
              reason: 'tab 0 must not surface a destination chip ("$l")');
        }
        // Positive sanity: the genuine product opening-words DO render here, so
        // the negatives above are about the right (populated) row, not an empty
        // one.
        final lexicon = buildWordLexicon(kDivePool);
        final opening = cardKeyboardPredictions('', kDivePool, lexicon);
        expect(opening, isNotEmpty, reason: 'sanity: opening words exist');
        expect(find.text(opening.first), findsWidgets,
            reason: 'the tab-0 empty row still shows product opening-words');
      });

      // (f) An empty-field TAB chip carries its REAL run sourced BY LABEL — not a
      // no-op. Existing (b) taps a DRILL chip (dispatch i); none proves a TAB
      // chip routes through KbDestination.run to set a SECTION provider. Tap הסל
      // שלי on tab 3 → storeSectionProvider == StoreSection.cart (distinct from
      // the default StoreSection.all), proving the by-label lookup wired the
      // registry's real run. A regression sourcing a wrong/empty run would leave
      // the section unchanged and FAIL here.
      testWidgets(
          'empty field, tab 3 → tapping הסל שלי runs its registry action '
          '(store cart section)', (tester) async {
        final container = await pumpPanelOnTab(tester, 3);

        // הסל שלי is present as a navigable chip on the empty tab-3 row.
        expect(navChip('הסל שלי'), findsOneWidget,
            reason: 'tab 3 empty row shows the cart chip (navigable)');

        await tester.tap(navChip('הסל שלי'));
        await tester.pumpAndSettle();

        // The chip's KbDestination.run (_openStoreSection cart) fired: still tab
        // 3, and the section flipped to cart (NOT the default 'all') — so the
        // chip carried the real registry action, not a stub. Overlay floats on.
        expect(container.read(mainTabProvider), 3,
            reason: 'הסל שלי kept the store tab (3)');
        expect(container.read(storeSectionProvider), StoreSection.cart,
            reason: 'הסל שלי ran its registry action → cart section');
        expect(container.read(keyboardOverlayOpenProvider), isTrue,
            reason: 'the cart tab chip keeps the overlay floating');
      });
    });

    // ── CATALOG (tab 0) LIVE-MIRROR — the flag-OFF obligations (spec §4C) ───────
    // tab 0 is UNIQUE: it has NO labelsByTab entry, so its empty row is the
    // DYNAMIC _buildRow(''). With kKbLiveMirror at its const-default OFF (flutter
    // test never forwards --dart-define to the const, feature_flags.dart) AND
    // featureFlagsProvider empty (kKbLiveMirrorFlag is not force-on), the whole
    // tab==0 mirror branch + the catalogLocationProvider watch fold out / tree-
    // shake, ctx stays null, the _rowFor guard's tab==0 disjunct is dead, and
    // control falls to the UNCHANGED `if (tab==0) return _buildRow('')`. Net
    // flag-OFF diff = ZERO. These tests pin that byte-identity at the on-screen
    // row (we cannot read the private _buildRow/_PredRow, so we compare the
    // rendered chips against the SAME public helpers _buildRow composes —
    // cardKeyboardPredictions over kDivePool + matchDestinations — exactly the
    // discipline the rest of this file uses). The flag-ON catalog LOGIC is proven
    // PURELY in keyboard_catalog_deriver_test.dart, not via a define here.
    group('catalog (tab 0) flag-OFF byte-identity (spec §4C)', () {
      final lexicon = buildWordLexicon(kDivePool);

      /// Seeds [mainTabProvider] to [tab] (and the overlay open) and pumps the
      /// REAL [FloatingCardKeyboard] in the same hermetic RTL shell the other
      /// groups use — a local copy because the sibling group's helper is private
      /// to its own closure. Returns the container for provider reads.
      Future<ProviderContainer> pumpPanelOnTab(
        WidgetTester tester,
        int tab,
      ) async {
        final container = ProviderContainer(
          overrides: [
            keyboardOverlayOpenProvider.overrideWith((_) => true),
            mainTabProvider.overrideWith((_) => tab),
          ],
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

      /// The exact chip set _buildRow(text) would produce: destinations (by
      /// matchDestinations) leading, then product WORDS filling the remaining
      /// slots (reserving one word slot), capped at _kRowCap (5). This re-derives
      /// _buildRow's body from its two public inputs so we can assert the rendered
      /// row equals it WITHOUT importing the private builder.
      List<String> expectedBuildRow(String text) {
        const cap = 5; // _kRowCap
        final words = cardKeyboardPredictions(text, kDivePool, lexicon);
        final reserve = words.isEmpty ? 0 : 1;
        final destCap = cap - reserve;
        final dests = matchDestinations(text, max: destCap);
        final chips = <String>[];
        for (final d in dests) {
          if (chips.length >= destCap) break;
          if (chips.contains(d.label)) continue;
          chips.add(d.label);
        }
        for (final w in words) {
          if (chips.length >= cap) break;
          if (chips.contains(w)) continue;
          chips.add(w);
        }
        return chips;
      }

      // (16) FLAG-OFF BYTE-IDENTITY — empty field at tab 0: the rendered row is
      // EXACTLY _buildRow('') (product opening-words, empty destByChip), NO catalog
      // location chip leaks, and there is no nav glyph (runByChip/destByChip are
      // empty on the legacy empty-catalog row).
      testWidgets(
          'empty field, tab 0, flag OFF → row == _buildRow(\'\') '
          '(product words only, no catalog chip, no nav glyph)', (tester) async {
        await pumpPanelOnTab(tester, 0);

        // matchDestinations('') is empty, so _buildRow('') is product words only.
        expect(matchDestinations(''), isEmpty,
            reason: 'sanity: the empty query surfaces no destination');
        final expected = expectedBuildRow('');
        expect(expected, isNotEmpty,
            reason: 'sanity: the catalog opening row has product words');

        // Every chip _buildRow('') yields is rendered…
        for (final c in expected) {
          expect(find.text(c), findsWidgets,
              reason: 'the flag-OFF tab-0 row shows the _buildRow chip "$c"');
        }
        // …and NO nav glyph anywhere (the legacy empty-catalog row is plain
        // product words; the live-mirror/destination path is what adds the glyph,
        // and it is tree-shaken / inactive with the flag OFF).
        expect(find.byIcon(Icons.north_east), findsNothing,
            reason: 'flag-OFF tab-0 row is product words → no nav glyph');
        // …and no catalog SECTION/drill label leaks into the opening row (a
        // regression that routed tab 0 into the catalog mirror would surface one).
        for (final l in const [
          'קטגוריות',
          'עץ חכם',
          'מועדפים',
          'מאתר',
          '⬆️ חזרה',
        ]) {
          expect(find.text(l), findsNothing,
              reason: 'flag-OFF tab-0 must not surface a catalog chip ("$l")');
        }
      });

      // (16b) Typed field at tab 0: the rendered row is EXACTLY _buildRow(text)
      // (the universal typed path is untouched by the catalog mirror — text non-
      // empty short-circuits to _buildRow BEFORE the mirror guard).
      testWidgets(
          'typed field, tab 0, flag OFF → row == _buildRow(text)',
          (tester) async {
        await pumpPanelOnTab(tester, 0);

        // Type "ב" (a real lexicon prefix). The on-screen row must equal
        // _buildRow('ב') chip-for-chip (those that render as Text).
        await tester.tap(find.text('ב'));
        await tester.pumpAndSettle();

        final expected = expectedBuildRow('ב');
        expect(expected, isNotEmpty, reason: 'sanity: "ב" yields a row');
        for (final c in expected) {
          // The field itself also shows 'ב'; we only assert the predicted chips
          // are present (the typed path is byte-identical to pre-feature).
          expect(find.text(c), findsWidgets,
              reason: 'the typed tab-0 row shows the _buildRow chip "$c"');
        }
      });

      // (17) NO-REORDER — a non-empty text at tab 0 yields the TYPED _buildRow
      // regardless of any catalog context: typing a DESTINATION term surfaces the
      // merged destination chip exactly as on the other tabs (the catalog mirror
      // never reorders the typed row). Guards that adding the tab-0 branch did not
      // perturb the typed path.
      testWidgets(
          'typed destination at tab 0 still merges via _buildRow (no reorder)',
          (tester) async {
        await pumpPanelOnTab(tester, 0);

        // "מח" surfaces the מחלקות destination via the typed path.
        final hits = matchDestinations('מח').map((d) => d.label).toList();
        expect(hits, contains('מחלקות'),
            reason: 'sanity: the matcher offers מחלקות for "מח"');

        await tester.tap(find.text('מ'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ח'));
        await tester.pumpAndSettle();

        // The destination chip surfaces WITH its nav glyph — identical to the
        // pre-feature typed behaviour; the catalog mirror did not reorder it.
        final glyphInDest = find.descendant(
          of: find.widgetWithText(InkWell, 'מחלקות'),
          matching: find.byIcon(Icons.north_east),
        );
        expect(glyphInDest, findsOneWidget,
            reason: 'the typed destination chip is unchanged at tab 0 (no '
                'catalog-mirror reorder of the typed row)');
        // And the rendered chips match _buildRow('מח') exactly (those rendered).
        for (final c in expectedBuildRow('מח')) {
          expect(find.text(c), findsWidgets,
              reason: 'typed tab-0 row tracks _buildRow("מח") — chip "$c"');
        }
      });

      // (18) RELEASE TREE-SHAKE — with KB_LIVE_MIRROR unset, catalogLocationProvider
      // must be ABSENT from a release bundle. We cannot run a release build from a
      // leaf widget test, so we assert the SOURCE-LEVEL invariant that GUARANTEES
      // the tree-shake: in floating_card_keyboard.dart the catalogLocationProvider
      // watch sits INSIDE an `if (live)` block whose `live` is
      // `kKbLiveMirror || …` — and kKbLiveMirror is a `const bool.fromEnvironment`,
      // so with the env unset the `||` is const-false, `live` is const-false, and
      // the whole block (with the watch) is dead code the compiler drops. This is
      // the runnable proxy for "grep the bundle": if a refactor hoisted the watch
      // out of the const guard (breaking the tree-shake), this fails LOUD.
      test(
          'tree-shake guard: catalogLocationProvider watch is nested under the '
          'const kKbLiveMirror `if (live)` (source invariant)', () {
        final src = File(
          'lib/screens/floating_card_keyboard.dart',
        ).readAsStringSync();

        // The watch exists exactly once (the tab-0 mirror branch).
        final watchIdx = src.indexOf('ref.watch(catalogLocationProvider)');
        expect(watchIdx, greaterThan(-1),
            reason: 'sanity: the tab-0 mirror watches catalogLocationProvider');

        // The nearest `if (live)` guard precedes the watch, and the nearest
        // `live = kKbLiveMirror` assignment precedes THAT — i.e. the watch is
        // inside the const-guarded block, never at top level.
        final guardIdx = src.lastIndexOf('if (live)', watchIdx);
        expect(guardIdx, greaterThan(-1),
            reason: 'the catalog watch must be inside an `if (live)` block');
        final liveAssignIdx =
            src.lastIndexOf('final live = kKbLiveMirror', guardIdx);
        expect(liveAssignIdx, greaterThan(-1),
            reason: '`live` must be seeded from the const kKbLiveMirror (so the '
                '`||` short-circuits const-false when KB_LIVE_MIRROR is unset → '
                'the block + the catalogLocationProvider watch tree-shake)');

        // And the const itself is environment-driven (the tree-shake precondition).
        final host = File(
          'lib/widgets/smart_input/keyboard/bs_keyboard_host.dart',
        ).readAsStringSync();
        expect(
          host.contains(
              "const bool kKbLiveMirror = bool.fromEnvironment('KB_LIVE_MIRROR')"),
          isTrue,
          reason: 'kKbLiveMirror is a const bool.fromEnvironment — off unless the '
              'demo define is set, which is what lets the catalog branch shake out',
        );
      });

      // (19) CARRY-OVER — growing the _rowFor :328 guard tab-set to include 0 must
      // NOT regress the existing tabs' flag-OFF rows. With the flag OFF, tabs 1/2/3
      // still render their hardcoded labelsByTab chips (the fallback the guard
      // falls through to), exactly as before the tab-0 disjunct was added.
      testWidgets(
          'carry-over: tabs 1/2/3 flag-OFF rows still render their hardcoded '
          'labels (the tab-0 guard growth did not regress them)', (tester) async {
        // tab 1 — the 4 departments.
        await pumpPanelOnTab(tester, 1);
        for (final l in const [
          'אינסטלציה',
          'ברזים וסניטריים',
          'כלי עבודה ידני',
          'כלי עבודה חשמלי',
        ]) {
          expect(find.text(l), findsWidgets,
              reason: 'tab 1 flag-OFF row still shows department chip "$l"');
        }

        // tab 2 — שיחות + התראות.
        await pumpPanelOnTab(tester, 2);
        expect(find.text('שיחות'), findsWidgets,
            reason: 'tab 2 flag-OFF row still shows שיחות');
        expect(find.text('התראות'), findsWidgets,
            reason: 'tab 2 flag-OFF row still shows התראות');

        // tab 3 — the store sections.
        await pumpPanelOnTab(tester, 3);
        for (final l in const ['הסל שלי', 'ההזמנות שלי', 'שירותים']) {
          expect(find.text(l), findsWidgets,
              reason: 'tab 3 flag-OFF row still shows store chip "$l"');
        }
      });
    });
  });
}
