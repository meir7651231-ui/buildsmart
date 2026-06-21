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
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogSectionProvider;
import 'package:buildsmart/screens/floating_card_keyboard.dart';
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show matchDestinations;
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
  });
}
