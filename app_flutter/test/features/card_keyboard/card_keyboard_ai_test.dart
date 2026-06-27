// P5.60: the AI mouth — submitting free text ("find me") routes through the AI
// interpreter (the 4th input), not the live keyword path. Reaches private state
// via `as dynamic`, the pattern of the other card_keyboard widget tests.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations, unnecessary_cast

import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/word_finder/ai_interpret.dart'
    show AiInterpret;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // A LONG debounce so the live onChanged (literal) never seeds before we submit;
  // the submit's query is fired explicitly by [submit] pumping past the debounce.
  Future<dynamic> pumpScreen(WidgetTester t, {AiInterpret? ai}) async {
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardKeyboardScreen(
              forceLiveForTest: true,
              debounceMs: 5000,
              aiInterpret: ai,
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

  Future<void> submit(WidgetTester t, String text) async {
    await t.enterText(find.byType(TextField), text); // onChanged -> 5s timer
    await t.testTextInput.receiveAction(TextInputAction.search); // -> _onAiQuery
    await t.pump(); // _onAiQuery's await resolves -> _onOpeningQuery queues + cancels literal
    await t.pump(const Duration(seconds: 6)); // fire the queued seed
  }

  testWidgets('submit routes through the AI interpreter (injected)', (t) async {
    // The literal 'תביא לי משהו אדום' could never normalise to נחושת, so a נחושת
    // crumb proves the SUBMIT path ran the interpreter, not the live path.
    final state = await pumpScreen(t, ai: (_) async => 'נחושת');
    await submit(t, 'תביא לי משהו אדום');
    expect(state.crumbs as List, contains('נחושת'),
        reason: 'the AI seeded the dive, not the literal text');
  });

  testWidgets('offline submit uses the default literal interpreter', (t) async {
    // No injected AI: defaultAiInterpret strips 'אני צריך' -> 'נחושת' offline.
    final state = await pumpScreen(t);
    await submit(t, 'אני צריך נחושת');
    expect(state.crumbs as List, contains('נחושת'));
  });

  testWidgets('a throwing gateway degrades to the literal interpreter',
      (t) async {
    // The injected "online" AI fails (ClaudeException / no network). The mouth must
    // NOT dead-end or fabricate — it falls back to the offline literal path (P5.47).
    final state = await pumpScreen(
      t,
      ai: (_) async => throw Exception('gateway down'),
    );
    await submit(t, 'אני צריך נחושת'); // literal fallback strips filler -> נחושת
    expect(state.crumbs as List, contains('נחושת'),
        reason: 'a failed gateway must degrade to literal, never dead-end');
  });
}
