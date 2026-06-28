// P6.57-58: the click-mouth switcher — EQUAL tabs swap the opening seed grid
// (word/material/job/category) WITHOUT seeding; tapping a seed then seeds the dive.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations, unnecessary_cast

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardAskWords;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart'
    show WordKeyboard;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> _pump(WidgetTester t) async {
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
  return state;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tapping the material tab swaps the grid WITHOUT seeding',
      (t) async {
    final state = await _pump(t);
    expect(state.crumbs as List, isEmpty);

    await t.tap(find.widgetWithText(ChoiceChip, 'חומר'));
    await t.pumpAndSettle();

    final chip = t.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'חומר'));
    expect(chip.selected, isTrue, reason: 'the material mouth is now active');
    expect(state.crumbs as List, isEmpty, reason: 'a mouth switch never seeds');
    expect(
      find.descendant(
          of: find.byType(WordKeyboard), matching: find.text('נחושת')),
      findsWidgets,
      reason: 'the grid now shows material seeds',
    );
  });

  testWidgets('tapping a material seed seeds the dive by material', (t) async {
    final state = await _pump(t);
    await t.tap(find.widgetWithText(ChoiceChip, 'חומר'));
    await t.pumpAndSettle();

    await t.tap(find.descendant(
        of: find.byType(WordKeyboard), matching: find.text('נחושת')));
    await t.pumpAndSettle();

    expect(state.crumbs as List, contains('נחושת'));
    expect(state.verdict, isNot(isA<CardAskWords>()));
  });
}
