// Unified card-keyboard (#38) Phase 4 — the screen's self-gate.
//
// The critical screen property: with kCardKeyboardFlag OFF (the default), the
// screen renders NOTHING (dark) — so landing it does not touch the live app
// (byte-identical). The verdict→keys→tap wiring sits on top of the exhaustively
// engine-tested mergedKeys (Phases 0-3); a flag-ON widget/tap test is a follow-up
// (it needs the flag seeded + a tap harness).

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardAskWords, MergedKeys;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('flag OFF (default) → renders nothing (dark, byte-identical live)',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: CardKeyboardScreen())),
      ),
    );
    await tester.pump();

    expect(find.byType(CardKeyboardScreen), findsOneWidget);
    // No opening header and no keyboard → the screen self-gated dark.
    expect(find.text('מה אתה מחפש?'), findsNothing,
        reason: 'flag OFF: no opening header');
    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'flag OFF: no keyboard rendered');
  });

  testWidgets('flag ON (forced) → opening renders; tapping a word seeds the dive',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CardKeyboardScreen(forceLiveForTest: true)),
        ),
      ),
    );
    await tester.pump();

    // Suppress the resolve sheet (read at tap-time, so no rebuild needed; no
    // heavy sheet deps in this test). The ON path is forced via the widget param.
    final state = tester.state(find.byType(CardKeyboardScreen)) as dynamic;
    state.openSheetOnResolve = false;

    // Opening: the header + the word keyboard render.
    expect(find.text('מה אתה מחפש?'), findsOneWidget,
        reason: 'flag ON: the opening header shows');
    expect(find.byType(WordKeyboard), findsOneWidget,
        reason: 'flag ON: the keyboard renders the opening words');

    // Tap the first opening word → the engine seeds the pool and the dive moves
    // off the opening word question (its first answered step).
    final opening = state.verdict as CardAskWords;
    expect(opening.words, isNotEmpty, reason: 'sanity: opening words exist');
    final firstWord = opening.words.first.word as String;
    await tester.tap(find.text(firstWord).first);
    await tester.pumpAndSettle();

    expect((state.crumbs as List).contains(firstWord), isTrue,
        reason: 'tapping a word pushes the first dive step');
    expect(state.verdict, isNot(isA<CardAskWords>()),
        reason: 'the dive moved off the opening word question');

    // The opening word must NOT burn the WORD axis (swarm R7): it seeds with a
    // distinct axis label, so 'דגם' (WordSignal.axisName) is NOT answered and the
    // merge can still offer deeper distinguishing words.
    expect((state.answeredAxes as List).contains('דגם'), isFalse,
        reason: 'opening word seeds, it does not answer the word axis');

    // If the dive landed on the merged row, tap the first merged chip → it must
    // decode the 'chip|axisId|displayLabel|value' payload, push a step, and add
    // the chip's VISIBLE displayLabel as the crumb (swarm R2 FIX C: the crumb is
    // displayLabel, never the predicate value).
    final afterWord = state.verdict;
    if (afterWord is MergedKeys && afterWord.chips.isNotEmpty) {
      final chip = afterWord.chips.first;
      final crumbsBefore = (state.crumbs as List).length;
      await tester.tap(find.text(chip.displayLabel).first);
      await tester.pumpAndSettle();
      expect((state.crumbs as List).length, crumbsBefore + 1,
          reason: 'tapping a merged chip pushes a step');
      expect((state.crumbs as List).last, chip.displayLabel,
          reason: 'crumb is the chip displayLabel, never the predicate value');
    }
  });
}
