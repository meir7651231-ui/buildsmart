// P4.56: typing into the OpeningSurface seeds the dive via resolveQuery (the
// material-aware funnel), debounced. Reaches private @visibleForTesting state via
// `as dynamic`, the same pattern as card_keyboard_screen_test.dart.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations, unnecessary_cast

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardAskWords;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> _pump(WidgetTester t, {int debounceMs = 0}) async {
  await t.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: CardKeyboardScreen(
            forceLiveForTest: true,
            debounceMs: debounceMs,
          ),
        ),
      ),
    ),
  );
  await t.pump();
  final state = t.state(find.byType(CardKeyboardScreen)) as dynamic;
  state.openSheetOnResolve = false;
  return state;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('typing a query seeds the dive (debounce injected 0)', (t) async {
    final state = await _pump(t);
    expect(state.verdict, isA<CardAskWords>(), reason: 'opens on the word grid');

    await t.enterText(find.byType(TextField), 'נחושת');
    await t.pumpAndSettle();

    expect(state.crumbs as List, contains('נחושת'),
        reason: 'the typed query pushed a seed step');
    expect(state.verdict, isNot(isA<CardAskWords>()),
        reason: 'the dive moved off the opening');
  });

  testWidgets('a fast 3-char burst resolves exactly once', (t) async {
    // A real 300ms debounce window: the burst lands inside it, so each keystroke
    // cancels the prior timer and only the LAST query resolves.
    final state = await _pump(t, debounceMs: 300);
    await t.enterText(find.byType(TextField), 'נ');
    await t.enterText(find.byType(TextField), 'נח');
    await t.enterText(find.byType(TextField), 'נחושת');
    await t.pump(const Duration(milliseconds: 400)); // advance past the window
    expect((state.crumbs as List).length, 1,
        reason: 'the burst debounced to a single resolve');
  });

  testWidgets('empty / whitespace text keeps the opening surface', (t) async {
    final state = await _pump(t);
    await t.enterText(find.byType(TextField), '   ');
    await t.pumpAndSettle();
    expect(state.verdict, isA<CardAskWords>(),
        reason: 'whitespace must not seed a dive');
  });
}
