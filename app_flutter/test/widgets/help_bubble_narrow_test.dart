// The "מצב היכרות" tail-bubble on narrow screens.
//
// THE BUG: `_HelpBubble` clamped its left edge with
// `clamp(12, screen.width - 270 - 12)`. On a screen narrower than 294px the
// upper bound fell below the lower one and `clamp` threw an ArgumentError in
// build, so tapping any highlighted element crashed the overlay.
//
// Also pinned here: the bubble always fits inside the screen with a margin,
// a long explanation scrolls inside the card instead of running off-screen,
// the card text is readable in dark mode, and the dismiss layer is named
// for screen readers.
import 'dart:async';

import 'package:buildsmart/state/help_mode.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpTarget(
    WidgetTester t, {
    required Size screen,
    Alignment align = Alignment.topCenter,
    String body = 'מה הכפתור עושה',
    ThemeData? theme,
  }) async {
    // The bubble reads MediaQuery, which follows the VIEW size (setSurfaceSize
    // alone leaves MediaQuery at 800×600).
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = screen;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [helpModeProvider.overrideWith((ref) => true)],
        child: MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Align(
              alignment: align,
              child: HelpTarget(
                title: 'כפתור',
                body: body,
                child: const SizedBox(width: 40, height: 40),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.byType(HelpTarget));
    await t.pump();
  }

  Rect bubbleCard(WidgetTester t) => t.getRect(
    find
        .ancestor(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Container),
        )
        .first,
  );

  group('bubbleWidthFor', () {
    test('keeps the 270 design width when the screen has room', () {
      expect(helpBubbleWidthForTest(390), 270);
      expect(helpBubbleWidthForTest(294), 270);
    });

    test('shrinks to keep a 12px margin on both sides below 294px', () {
      expect(helpBubbleWidthForTest(280), 256);
      expect(helpBubbleWidthForTest(240), 216);
    });

    test('never goes negative', () {
      expect(helpBubbleWidthForTest(10), 0);
    });
  });

  for (final w in <double>[390, 294, 280, 240]) {
    testWidgets('tapping a target on a ${w.toInt()}px screen opens a bubble '
        'that fits inside the screen', (t) async {
      await pumpTarget(t, screen: Size(w, 640));
      expect(t.takeException(), isNull, reason: 'clamp(min>max) used to throw');
      expect(find.text('מה הכפתור עושה'), findsOneWidget);
      final card = bubbleCard(t);
      expect(card.left, greaterThanOrEqualTo(12 - 0.01));
      expect(card.right, lessThanOrEqualTo(w - 12 + 0.01));
    });
  }

  testWidgets('a target near the edge still gets an on-screen bubble', (
    t,
  ) async {
    await pumpTarget(t, screen: const Size(260, 640), align: Alignment.topLeft);
    expect(t.takeException(), isNull);
    final card = bubbleCard(t);
    expect(card.left, greaterThanOrEqualTo(12 - 0.01));
    expect(card.right, lessThanOrEqualTo(260 - 12 + 0.01));
  });

  testWidgets('a long explanation scrolls inside the card, no overflow', (
    t,
  ) async {
    final longBody = List.filled(80, 'הסבר ארוך מאוד על הכפתור.').join(' ');
    await pumpTarget(
      t,
      screen: const Size(300, 420),
      align: Alignment.bottomCenter,
      body: longBody,
    );
    expect(t.takeException(), isNull, reason: 'no RenderFlex overflow');
    final card = bubbleCard(t);
    expect(card.top, greaterThanOrEqualTo(0));
    expect(card.bottom, lessThanOrEqualTo(420));
  });

  testWidgets('dark mode: the card text uses the dark ink, not the light one', (
    t,
  ) async {
    await pumpTarget(
      t,
      screen: const Size(390, 640),
      theme: ThemeData(brightness: Brightness.dark),
    );
    final title = t.widget<Text>(find.text('כפתור').last);
    final body = t.widget<Text>(find.text('מה הכפתור עושה'));
    expect(title.style?.color, BsTokens.inkDark);
    expect(body.style?.color, BsTokens.mutedDark);
  });

  testWidgets('light mode keeps the exact former ink', (t) async {
    await pumpTarget(t, screen: const Size(390, 640));
    final title = t.widget<Text>(find.text('כפתור').last);
    final body = t.widget<Text>(find.text('מה הכפתור עושה'));
    expect(title.style?.color, BsTokens.inkLight);
    expect(body.style?.color, BsTokens.mutedLight);
  });

  testWidgets('the outside-tap layer is a named button and closes the bubble', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    await pumpTarget(t, screen: const Size(390, 640));
    expect(find.bySemanticsLabel('סגירת ההסבר'), findsOneWidget);
    await t.tapAt(const Offset(20, 600));
    await t.pump();
    expect(find.text('מה הכפתור עושה'), findsNothing);
    handle.dispose();
  });

  Color tailColor(WidgetTester t) {
    final paint = t
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .firstWhere((c) => c.painter.runtimeType.toString() == '_TailPainter');
    // The painter is private to help_target.dart; read its colour reflectively.
    // ignore: avoid_dynamic_calls
    return (paint.painter! as dynamic).color as Color;
  }

  testWidgets('the tail matches the card: dark card → dark tail', (t) async {
    await pumpTarget(
      t,
      screen: const Size(390, 640),
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(surface: BsTokens.cardDark),
      ),
    );
    expect(tailColor(t), BsTokens.cardDark, reason: 'was a fixed white tail');
  });

  testWidgets('light mode tail stays white', (t) async {
    await pumpTarget(
      t,
      screen: const Size(390, 640),
      theme: ThemeData(colorScheme: const ColorScheme.light()),
    );
    expect(tailColor(t), BsTokens.cardLight);
  });

  testWidgets('safe-area: the card stays below the status bar', (t) async {
    t.view.padding = const FakeViewPadding(top: 60);
    addTearDown(t.view.resetPadding);
    final longBody = List.filled(80, 'הסבר ארוך מאוד על הכפתור.').join(' ');
    await pumpTarget(
      t,
      screen: const Size(300, 420),
      align: Alignment.bottomCenter,
      body: longBody,
    );
    expect(t.takeException(), isNull);
    expect(bubbleCard(t).top, greaterThanOrEqualTo(60));
  });

  group('the bubble never outlives its element', () {
    Widget target() => const HelpTarget(
      title: 'כפתור',
      body: 'מה הכפתור עושה',
      child: SizedBox(width: 40, height: 40),
    );

    testWidgets('turning help mode off closes an open bubble', (t) async {
      final container = ProviderContainer(
        overrides: [helpModeProvider.overrideWith((ref) => true)],
      );
      addTearDown(container.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: Scaffold(body: Center(child: target()))),
        ),
      );
      await t.tap(find.byType(HelpTarget));
      await t.pump();
      expect(find.text('מה הכפתור עושה'), findsOneWidget);

      container.read(helpModeProvider.notifier).state = false;
      await t.pump();
      await t.pump();
      expect(find.text('מה הכפתור עושה'), findsNothing);
    });

    testWidgets('a back pop closes the bubble (it used to float over the '
        'previous screen)', (t) async {
      final nav = GlobalKey<NavigatorState>();
      await t.pumpWidget(
        ProviderScope(
          overrides: [helpModeProvider.overrideWith((ref) => true)],
          child: MaterialApp(
            navigatorKey: nav,
            home: const Scaffold(body: Text('בית')),
          ),
        ),
      );
      unawaited(
        nav.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(body: Center(child: target())),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.byType(HelpTarget));
      await t.pump();
      expect(find.text('מה הכפתור עושה'), findsOneWidget);

      nav.currentState!.pop();
      await t.pumpAndSettle();
      expect(find.text('בית'), findsOneWidget);
      expect(find.text('מה הכפתור עושה'), findsNothing);
    });

    testWidgets('pushing a route over the element closes the bubble', (
      t,
    ) async {
      final nav = GlobalKey<NavigatorState>();
      await t.pumpWidget(
        ProviderScope(
          overrides: [helpModeProvider.overrideWith((ref) => true)],
          child: MaterialApp(
            navigatorKey: nav,
            home: Scaffold(body: Center(child: target())),
          ),
        ),
      );
      await t.tap(find.byType(HelpTarget));
      await t.pump();
      unawaited(
        nav.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const Scaffold()),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('מה הכפתור עושה'), findsNothing);
    });

    testWidgets('a second tap replaces the bubble — never two stacked', (
      t,
    ) async {
      await pumpTarget(t, screen: const Size(390, 640));
      // The dismiss layer covers the element now; close and reopen.
      await t.tapAt(const Offset(20, 600));
      await t.pump();
      await t.tap(find.byType(HelpTarget));
      await t.pump();
      expect(find.text('מה הכפתור עושה'), findsOneWidget);
    });

    testWidgets(
      // Guard, not a reproduction: in a widget test the Overlay builds the new
      // entry before the element is disposed, so this was green before the
      // `_close` fix too. It pins the end state if that order ever changes.
      'element removed in the SAME frame as the tap: no stuck bubble',
      (t) async {
        final show = ValueNotifier<bool>(true);
        addTearDown(show.dispose);
        await t.pumpWidget(
          ProviderScope(
            overrides: [helpModeProvider.overrideWith((ref) => true)],
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: show,
                    builder: (_, v, __) => v ? target() : const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.tap(find.byType(HelpTarget)); // inserts, not yet built
        show.value = false; // element leaves before the next frame
        await t.pump();
        await t.pump();
        expect(find.text('מה הכפתור עושה'), findsNothing);
        expect(find.bySemanticsLabel('סגירת ההסבר'), findsNothing);
      },
    );
  });
}
