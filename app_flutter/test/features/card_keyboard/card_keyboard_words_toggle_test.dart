// P6.59: the word mouth's "more…/less" toggle expands the grid to the full tail,
// NEVER seeds, and shows ONLY for the word mouth.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations, unnecessary_cast

import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> _pump(WidgetTester t) async {
  await t.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          // The production host (catalog_screen) wraps the screen in a
          // SingleChildScrollView so the expanded grid scrolls; mirror it.
          body: SingleChildScrollView(
            child: CardKeyboardScreen(forceLiveForTest: true, debounceMs: 0),
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

  testWidgets('the more toggle expands the word grid WITHOUT seeding', (t) async {
    final state = await _pump(t);
    final more = find.widgetWithText(TextButton, 'עוד…');
    expect(more, findsOneWidget);

    await t.ensureVisible(more);
    await t.tap(more);
    await t.pumpAndSettle();

    expect(state.crumbs as List, isEmpty, reason: 'a more-toggle never seeds');
    expect(find.widgetWithText(TextButton, 'פחות'), findsOneWidget,
        reason: 'the grid is now expanded (the label flipped)');
  });

  testWidgets('the more toggle shows ONLY for the word mouth', (t) async {
    await _pump(t);
    expect(find.widgetWithText(TextButton, 'עוד…'), findsOneWidget);

    await t.tap(find.widgetWithText(ChoiceChip, 'חומר'));
    await t.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'עוד…'), findsNothing,
        reason: 'non-word mouths have a fixed seed set — no toggle');
  });
}
