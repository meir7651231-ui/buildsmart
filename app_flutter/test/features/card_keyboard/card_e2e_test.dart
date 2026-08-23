// P4.59: end-to-end on the REAL screen — type a seed, then tap chip after chip
// until a product surfaces, with no crash. Complements the PURE census/fuzz
// (card_census_test.dart): this proves the widget wiring (seed -> chips -> tap ->
// narrow -> terminal) actually works on the live screen, not just the engine.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardResolve, CardShowProducts;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart'
    show WordKeyboard;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('type a seed, tap chips, reach a product — no crash', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardKeyboardScreen(forceLiveForTest: true, debounceMs: 0),
          ),
        ),
      ),
    );
    await t.pump();
    final state = t.state(find.byType(CardKeyboardScreen)) as dynamic;
    state.openSheetOnResolve = false; // detect resolve via state, no modal

    await t.enterText(find.byType(TextField), 'נחושת');
    await t.pumpAndSettle();

    var terminal = false;
    for (var i = 0; i < 8 && !terminal; i++) {
      final v = state.verdict;
      if (v is CardResolve || v is CardShowProducts) {
        terminal = true; // the pool collapsed to a product / a scan-by-eye list
        break;
      }
      // A MergedKeys row: tap the first chip by its visible label.
      final label = v.chips.first.displayLabel as String;
      final key = find.descendant(
        of: find.byType(WordKeyboard),
        matching: find.text(label),
      );
      expect(key, findsWidgets, reason: 'chip "$label" is on screen');
      await t.tap(key.first);
      await t.pumpAndSettle();
    }

    expect(terminal, isTrue,
        reason: 'the real screen reached a product within 8 taps');
  });
}
