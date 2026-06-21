// BsKeyboard — the FLAGGED tool strip + the two tool LAYERS (STEP 1).
//
// These cover the new optional surface added on top of the letter keyboard,
// while proving the default (flag-off) keyboard is byte-behaviour-identical to
// before:
//   • flag OFF (no strip, no tool layer) → the Hebrew letters render and there
//     is NO grid/gear toggle anywhere; kBottomRow (send) is present.
//   • showToolStrip:true → the strip renders: the grid toggle (grid_view), the
//     three given predictions, and the gear toggle (settings). The letters are
//     still underneath (toolLayer defaults to none) and kBottomRow is present.
//   • toolLayer:home → the 8 home tiles render (assert a known label 'מחלקות'),
//     the letters are gone, and kBottomRow is still present.
//   • toolLayer:kbd → the 5 kbd tiles render (assert 'קולי'), letters gone,
//     kBottomRow present.
//   • toggles fire onToolGrid / onToolGear; tapping a tile fires onTool with
//     the tile's typed KbTool id ('מחלקות'→departments, 'מצלמה'→camera);
//     tapping a prediction fires onPrediction(text).
//   • switching a tool layer back to none restores the letters.
//
// Tool keys (send) render a Material ICON, so kBottomRow presence is asserted
// via find.byIcon(Icons.send). Tool tiles and predictions carry text, so they
// are located with find.text. The keyboard pins itself to Directionality.ltr,
// so a plain MaterialApp wrap is enough.

import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A representative Hebrew letter that exists ONLY on the letter layer (so its
  // presence/absence proves whether the letters are showing).
  const hebrewLetter = 'ק';

  // Sample predictions this strip-render test feeds BsKeyboard directly (the
  // host now supplies the LIVE finder chips at its mount — see STEP 3).
  const predictions = <String>['ברז כדורי', 'ניפל', 'סיפון'];

  // Pump BsKeyboard with the tool props under test. All keyboard callbacks are
  // wired to no-ops unless a test overrides them.
  Future<void> pump(
    WidgetTester tester, {
    bool showToolStrip = false,
    KbToolLayer toolLayer = KbToolLayer.none,
    List<String> preds = const <String>[],
    Set<String> destinationChips = const <String>{},
    VoidCallback? onToolGrid,
    VoidCallback? onToolGear,
    ValueChanged<KbTool>? onTool,
    ValueChanged<String>? onPrediction,
    List<KbTile>? tiles,
    ValueChanged<int>? onTile,
    bool showBack = false,
    VoidCallback? onBack,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BsKeyboard(
            onKey: (_) {},
            onBackspace: () {},
            onEnter: () {},
            onSend: () {},
            onToggleSymbols: () {},
            onLanguage: () {},
            showToolStrip: showToolStrip,
            toolLayer: toolLayer,
            predictions: preds,
            destinationChips: destinationChips,
            onToolGrid: onToolGrid,
            onToolGear: onToolGear,
            onTool: onTool,
            onPrediction: onPrediction,
            tiles: tiles,
            onTile: onTile,
            showBack: showBack,
            onBack: onBack,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('flag OFF (defaults) leaves the keyboard unchanged', () {
    testWidgets('letters render and NO strip toggles appear', (tester) async {
      await pump(tester); // all tool props at their OFF defaults

      // The Hebrew letters are showing.
      expect(find.text(hebrewLetter), findsOneWidget);

      // No strip → neither toggle icon exists anywhere.
      expect(find.byIcon(Icons.grid_view), findsNothing);
      expect(find.byIcon(Icons.settings), findsNothing);

      // No predictions rendered.
      for (final p in predictions) {
        expect(find.text(p), findsNothing);
      }

      // kBottomRow still renders (the send key is an icon).
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });

  group('showToolStrip:true', () {
    testWidgets('renders grid toggle + the 3 predictions + gear toggle',
        (tester) async {
      await pump(tester, showToolStrip: true, preds: predictions);

      // The two end toggles.
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // The three predictions in the middle, rendered as-is.
      for (final p in predictions) {
        expect(find.text(p), findsOneWidget);
      }

      // The letters are still underneath (toolLayer defaults to none) and the
      // bottom row is present.
      expect(find.text(hebrewLetter), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('grid toggle fires onToolGrid; gear toggle fires onToolGear',
        (tester) async {
      var grid = 0;
      var gear = 0;
      await pump(
        tester,
        showToolStrip: true,
        preds: predictions,
        onToolGrid: () => grid++,
        onToolGear: () => gear++,
      );

      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pump();
      expect(grid, 1);
      expect(gear, 0);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      expect(gear, 1);
      expect(grid, 1);
    });

    testWidgets('tapping a prediction fires onPrediction with its text',
        (tester) async {
      final picked = <String>[];
      await pump(
        tester,
        showToolStrip: true,
        preds: predictions,
        onPrediction: picked.add,
      );

      await tester.tap(find.text('ניפל'));
      await tester.pump();
      expect(picked, <String>['ניפל']);
    });
  });

  group('toolLayer:home', () {
    testWidgets('renders the home tiles; letters gone; kBottomRow present',
        (tester) async {
      await pump(tester, toolLayer: KbToolLayer.home);

      // A known home tile label renders.
      expect(find.text('מחלקות'), findsOneWidget);
      // Another home tile, to be sure the whole set is the home layer.
      expect(find.text('מסלול'), findsOneWidget);

      // The letter grid is replaced — no Hebrew letter key.
      expect(find.text(hebrewLetter), findsNothing);

      // The bottom action row is still there.
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('tapping a home tile fires onTool with its typed id',
        (tester) async {
      final tapped = <KbTool>[];
      await pump(
        tester,
        toolLayer: KbToolLayer.home,
        onTool: tapped.add,
      );

      // The tile still DISPLAYS 'מחלקות', but the callback carries the enum.
      await tester.tap(find.text('מחלקות'));
      await tester.pump();
      expect(tapped, <KbTool>[KbTool.departments]);
    });
  });

  group('toolLayer:kbd', () {
    testWidgets('renders the kbd tiles; letters gone; kBottomRow present',
        (tester) async {
      await pump(tester, toolLayer: KbToolLayer.kbd);

      // A known kbd tile label renders.
      expect(find.text('קולי'), findsOneWidget);
      expect(find.text('מצלמה'), findsOneWidget);

      // Letters replaced.
      expect(find.text(hebrewLetter), findsNothing);

      // Bottom row present.
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('tapping a kbd tile fires onTool with its typed id',
        (tester) async {
      final tapped = <KbTool>[];
      await pump(
        tester,
        toolLayer: KbToolLayer.kbd,
        onTool: tapped.add,
      );

      // 'מצלמה' displays on the tile; the callback carries KbTool.camera.
      await tester.tap(find.text('מצלמה'));
      await tester.pump();
      expect(tapped, <KbTool>[KbTool.camera]);
    });
  });

  testWidgets('switching a tool layer back to none restores the letters',
      (tester) async {
    // Start on the home tool layer: letters are hidden.
    await pump(tester, toolLayer: KbToolLayer.home);
    expect(find.text('מחלקות'), findsOneWidget);
    expect(find.text(hebrewLetter), findsNothing);

    // Re-pump with toolLayer none → the existing letter layer is back, and the
    // home tiles are gone.
    await pump(tester);
    expect(find.text(hebrewLetter), findsOneWidget);
    expect(find.text('מחלקות'), findsNothing);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('kBottomRow (send) is present on every layer', (tester) async {
    await pump(tester); // letters
    expect(find.byIcon(Icons.send), findsOneWidget);

    await pump(tester, showToolStrip: true, preds: predictions); // strip
    expect(find.byIcon(Icons.send), findsOneWidget);

    await pump(tester, toolLayer: KbToolLayer.home); // home tools
    expect(find.byIcon(Icons.send), findsOneWidget);

    await pump(tester, toolLayer: KbToolLayer.kbd); // kbd tools
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  // ── FITTING PREDICTION: destination-chip distinction ───────────────────────
  // A chip whose text is in [destinationChips] is a navigable DESTINATION and
  // gets a leading nav glyph ([Icons.north_east]) + brand accent; every other
  // chip (and EVERY chip while the set is empty — the default) renders as a
  // plain word chip with NO glyph (the byte-identical historical render).
  group('destinationChips (fitting-prediction distinction)', () {
    // Finds the nav glyph that is a DESCENDANT of the chip whose label is
    // [chip] — i.e. the glyph rendered INSIDE that specific prediction chip
    // (its Row sits in the same InkWell as the label Text).
    Finder glyphInChip(String chip) => find.descendant(
          of: find.widgetWithText(InkWell, chip),
          matching: find.byIcon(Icons.north_east),
        );

    testWidgets(
        'a chip in destinationChips shows the nav glyph; a word chip does NOT',
        (tester) async {
      // 'ברז כדורי' is marked a destination; 'ניפל' and 'סיפון' stay words.
      await pump(
        tester,
        showToolStrip: true,
        preds: predictions,
        destinationChips: const <String>{'ברז כדורי'},
      );

      // All three chip labels still render (the text is unchanged).
      for (final p in predictions) {
        expect(find.text(p), findsOneWidget);
      }

      // Exactly one nav glyph exists, and it is INSIDE the destination chip.
      expect(find.byIcon(Icons.north_east), findsOneWidget,
          reason: 'only the destination chip carries the nav glyph');
      expect(glyphInChip('ברז כדורי'), findsOneWidget,
          reason: 'the destination chip ברז כדורי shows the nav glyph');

      // The product-word chips carry NO glyph.
      expect(glyphInChip('ניפל'), findsNothing,
          reason: 'a product word chip must not show the nav glyph');
      expect(glyphInChip('סיפון'), findsNothing,
          reason: 'a product word chip must not show the nav glyph');
    });

    testWidgets(
        'default (destinationChips empty) → no glyph on any chip (byte-identical)',
        (tester) async {
      // The default: destinationChips omitted → empty. The strip renders, the
      // predictions render, and NOT ONE chip shows a nav glyph.
      await pump(tester, showToolStrip: true, preds: predictions);

      for (final p in predictions) {
        expect(find.text(p), findsOneWidget);
      }
      expect(find.byIcon(Icons.north_east), findsNothing,
          reason: 'with no destinations, every chip is the plain word chip');
    });

    testWidgets('tapping a destination chip still fires onPrediction(text)',
        (tester) async {
      // The glyph is purely visual — the tap contract is unchanged.
      final picked = <String>[];
      await pump(
        tester,
        showToolStrip: true,
        preds: predictions,
        destinationChips: const <String>{'ברז כדורי'},
        onPrediction: picked.add,
      );

      await tester.tap(find.text('ברז כדורי'));
      await tester.pump();
      expect(picked, <String>['ברז כדורי'],
          reason: 'a destination chip still reports its text on tap');
    });
  });

  // ── MORPH path (pure tiles) — STEP B ───────────────────────────────────────
  // The new screen-agnostic path: a non-null [tiles] list replaces the grid with
  // those pure tiles (bubbling an opaque int id), takes precedence over both the
  // letters and the legacy [toolLayer], and shows a BACK tile only on request.
  group('tiles (morph path)', () {
    const tiles = <KbTile>[
      KbTile(icon: Icons.account_tree, label: 'אלפא', id: 0),
      KbTile(icon: Icons.route, label: 'בטא', id: 1),
      KbTile(icon: Icons.bolt, label: 'גמא', id: 2),
    ];

    testWidgets('renders the pure tiles; letters gone; kBottomRow present',
        (tester) async {
      await pump(tester, tiles: tiles);

      // Each pure tile's label renders…
      expect(find.text('אלפא'), findsOneWidget);
      expect(find.text('בטא'), findsOneWidget);
      expect(find.text('גמא'), findsOneWidget);

      // …the letter grid is replaced…
      expect(find.text(hebrewLetter), findsNothing);

      // …and the bottom action row stays.
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('tapping a tile fires onTile with its opaque id',
        (tester) async {
      final tapped = <int>[];
      await pump(tester, tiles: tiles, onTile: tapped.add);

      await tester.tap(find.text('בטא'));
      await tester.pump();
      expect(tapped, <int>[1], reason: 'the tile bubbles its KbTile.id');
    });

    testWidgets('tiles override the legacy toolLayer (no home tiles render)',
        (tester) async {
      // Even with toolLayer:home, a non-null tiles list wins — the home tile
      // labels (e.g. 'מחלקות') must NOT appear; the morph tiles do.
      await pump(tester, toolLayer: KbToolLayer.home, tiles: tiles);
      expect(find.text('מחלקות'), findsNothing,
          reason: 'tiles take precedence over the legacy layer');
      expect(find.text('אלפא'), findsOneWidget);
    });

    testWidgets('showBack:false → no back tile; showBack:true → back tile fires',
        (tester) async {
      // No back tile by default.
      await pump(tester, tiles: tiles);
      expect(find.text('חזרה'), findsNothing,
          reason: 'no back affordance at a top tool-view');

      // With showBack, a leading back tile renders and fires onBack.
      var back = 0;
      await pump(tester, tiles: tiles, showBack: true, onBack: () => back++);
      expect(find.text('חזרה'), findsOneWidget,
          reason: 'the back tile leads a drilled view');
      await tester.tap(find.text('חזרה'));
      await tester.pump();
      expect(back, 1, reason: 'tapping back pops one drill level');
    });

    testWidgets('null tiles → the letters render (morph path fully off)',
        (tester) async {
      await pump(tester); // tiles defaults null
      expect(find.text(hebrewLetter), findsOneWidget);
      expect(find.text('חזרה'), findsNothing);
    });
  });
}
