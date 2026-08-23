// P10.96: converging to a product on the live screen records it as a line pick
// (cardPicksProvider). Drives the real screen to a product scan-list, taps a product (its
// key shows the distinct/quick label), and asserts a pick landed.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardResolve, CardShowProducts;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/card_keyboard/card_picks.dart'
    show cardPicksProvider;
import 'package:buildsmart/features/word_finder/distinct_label.dart'
    show distinctSelectionLabels;
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart'
    show quickLabel;
import 'package:buildsmart/features/word_finder/word_keyboard.dart'
    show WordKeyboard;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('converging to a product records it as a line pick', (t) async {
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
    state.openSheetOnResolve = false;

    await t.enterText(find.byType(TextField), 'נחושת');
    await t.pumpAndSettle();

    // Tap chips until the pool collapses to a product / a scan list. A tap that
    // RESOLVEs directly records the pick (via _pushStep); otherwise we tap a product.
    for (var i = 0; i < 8; i++) {
      final v = state.verdict;
      if (v is CardResolve || v is CardShowProducts) break;
      final label = v.chips.first.displayLabel as String;
      await t.tap(find
          .descendant(
            of: find.byType(WordKeyboard),
            matching: find.text(label),
          )
          .first);
      await t.pumpAndSettle();
    }

    final v = state.verdict;
    if (v is CardShowProducts && v.products.isNotEmpty) {
      final labels = distinctSelectionLabels(v.products);
      final p0 = v.products.first;
      final label = labels[p0.sku] ?? quickLabel(p0);
      final key = find.descendant(
        of: find.byType(WordKeyboard),
        matching: find.text(label),
      );
      expect(key, findsWidgets, reason: 'product key "$label" must be on screen');
      await t.tap(key.first);
      await t.pumpAndSettle();
    }

    final container =
        ProviderScope.containerOf(t.element(find.byType(CardKeyboardScreen)));
    expect(container.read(cardPicksProvider), isNotEmpty,
        reason: 'the converged product must be recorded as a line pick');
  });
}
