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
    VoidCallback? onToolGrid,
    VoidCallback? onToolGear,
    ValueChanged<KbTool>? onTool,
    ValueChanged<String>? onPrediction,
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
            onToolGrid: onToolGrid,
            onToolGear: onToolGear,
            onTool: onTool,
            onPrediction: onPrediction,
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
}
