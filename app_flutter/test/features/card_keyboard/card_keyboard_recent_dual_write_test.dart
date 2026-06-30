// P2.47 dual-write: a product resolution inside the card keyboard must also
// touch recently-viewed (the catalog screen is the other, untouched writer).
// Drives the real dive to a resolution and asserts the touch fired.

// Reaches the screen's @visibleForTesting members on a PRIVATE state class via
// `as dynamic` — the same pattern as card_keyboard_screen_test.dart.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations, unnecessary_cast

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardAskWords;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart'
    show WordKeyboard;
import 'package:buildsmart/state/recently_viewed.dart'
    show recentlyViewedProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('flag-ON: diving to a product resolution touches recently-viewed',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CardKeyboardScreen(forceLiveForTest: true)),
        ),
      ),
    );
    await tester.pump();

    final state = tester.state(find.byType(CardKeyboardScreen)) as dynamic;
    state.openSheetOnResolve = false; // record the touch without opening a sheet

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CardKeyboardScreen)),
    );
    expect(container.read(recentlyViewedProvider), isEmpty,
        reason: 'sanity: nothing viewed yet');

    // Seed the dive off the opening word.
    final opening = state.verdict as CardAskWords;
    await tester.tap(find.text(opening.words.first.word as String).first);
    await tester.pumpAndSettle();

    // Drive: tap the first keyboard key each turn until a product resolves and
    // the dual-write touch fires (or the tap budget is exhausted).
    for (var i = 0;
        i < 40 && container.read(recentlyViewedProvider).isEmpty;
        i++) {
      final keys = find.descendant(
        of: find.byType(WordKeyboard),
        matching: find.byType(InkWell),
      );
      if (keys.evaluate().isEmpty) break;
      await tester.tap(keys.first);
      await tester.pumpAndSettle();
    }

    expect(container.read(recentlyViewedProvider), isNotEmpty,
        reason: 'a card resolution must touch recently-viewed (P2.47)');
  });
}
