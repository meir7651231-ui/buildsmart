// Behaviour-lock for the Co-Pilot SCREEN (#manager-copilot). The off-state is
// pinned in manager_copilot_screen_test.dart; THIS file drives the live path by
// overriding `claudeGatewayProvider` with a hand-rolled fake and exercising every
// shipping branch the swarm's test-quality lens found uncovered:
//   • success → the assistant bubble shows the model's text
//   • empty model text → the honest "couldn't phrase an answer" fallback
//   • gateway throws → the honest "something went wrong" retry bubble
//   • a request in flight DISABLES the input (the _loading race-guard)
//   • the morning-brief asks for maxTokens:600, a Q&A asks for 420
//   • a suggestion chip's text AND the live grounded context reach the prompt
import 'dart:async';

import 'package:buildsmart/data/repositories/claude_functions.dart';
import 'package:buildsmart/logic/manager_copilot.dart' show managerCopilotSystem;
import 'package:buildsmart/screens/manager_copilot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A controllable fake gateway — records every call, returns canned text, throws,
/// or (when [gate] is set) blocks until the test releases it (for the race test).
class _FakeGateway implements ClaudeGateway {
  _FakeGateway({this.reply = 'תשובה', this.error, this.gate});

  final String reply;
  final ClaudeException? error;
  final Completer<void>? gate;
  final List<({String prompt, String? system, String? model, int? maxTokens})>
      calls = [];

  @override
  Future<ClaudeResult> ask({
    required String prompt,
    String? system,
    String? model,
    int? maxTokens,
  }) async {
    calls.add(
        (prompt: prompt, system: system, model: model, maxTokens: maxTokens));
    if (gate != null) await gate!.future;
    if (error != null) throw error!;
    return ClaudeResult(text: reply, model: model ?? 'fake');
  }
}

void main() {
  const kChip = 'מה בוער עכשיו?'; // first real suggestion

  Future<_FakeGateway> pump(WidgetTester t, _FakeGateway fake) async {
    await t.binding.setSurfaceSize(const Size(440, 1200));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        overrides: [claudeGatewayProvider.overrideWith((ref) => fake)],
        child: const MaterialApp(home: ManagerCopilotScreen()),
      ),
    );
    await t.pump();
    return fake;
  }

  // Let the (non-blocking) ask future resolve + the setState repaint — never
  // pumpAndSettle while loading (the _Typing spinner animates forever).
  Future<void> drain(WidgetTester t) async {
    for (var i = 0; i < 5; i++) {
      await t.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('SUCCESS — the model answer renders as the assistant bubble',
      (t) async {
    final fake = await pump(t, _FakeGateway(reply: 'יש 4 הזמנות פתוחות'));
    await t.tap(find.text(kChip));
    await drain(t);
    expect(find.text('יש 4 הזמנות פתוחות'), findsOneWidget);
    expect(find.text(kChip), findsOneWidget,
        reason: 'the tapped question echoes as the owner bubble');
  });

  testWidgets('EMPTY answer → the honest "couldn\'t phrase" fallback bubble',
      (t) async {
    await pump(t, _FakeGateway(reply: '   ')); // whitespace → trims to empty
    await t.tap(find.text(kChip));
    await drain(t);
    expect(find.text('לא הצלחתי לנסח תשובה — נסה לשאול אחרת.'), findsOneWidget);
  });

  testWidgets('ERROR — a gateway throw shows the honest retry bubble', (t) async {
    await pump(t,
        _FakeGateway(error: const ClaudeException('unavailable', 'down')));
    await t.tap(find.text(kChip));
    await drain(t);
    expect(find.text('משהו השתבש בחיבור — נסה שוב עוד רגע.'), findsOneWidget);
  });

  testWidgets('RACE-GUARD — while a request is in flight the input is disabled',
      (t) async {
    final gate = Completer<void>();
    final fake = await pump(t, _FakeGateway(gate: gate));
    await t.tap(find.text(kChip));
    await t.pump(); // user turn added, _loading=true, ask awaiting the gate
    // Exactly one call, the typing indicator is up, and the field is locked.
    expect(fake.calls.length, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(t.widget<TextField>(find.byType(TextField)).enabled, isFalse,
        reason: 'no second submit can race the in-flight request');
    // Release → the answer lands and the input re-enables.
    gate.complete();
    await drain(t);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(t.widget<TextField>(find.byType(TextField)).enabled, isTrue);
  });

  testWidgets('the ☀️ morning-brief asks for maxTokens:600 (anti-truncation)',
      (t) async {
    final fake = await pump(t, _FakeGateway());
    await t.tap(find.text('תדריך-בוקר'));
    await drain(t);
    expect(fake.calls.single.maxTokens, 600);
  });

  testWidgets('a Q&A keeps the default maxTokens:420', (t) async {
    final fake = await pump(t, _FakeGateway());
    await t.tap(find.text(kChip));
    await drain(t);
    expect(fake.calls.single.maxTokens, 420);
  });

  testWidgets('a chip folds BOTH its question AND the live context + system',
      (t) async {
    final fake = await pump(t, _FakeGateway());
    await t.tap(find.text(kChip));
    await drain(t);
    final call = fake.calls.single;
    expect(call.prompt, contains(kChip), reason: 'the chip text is the question');
    expect(call.prompt, contains('מצב-העסק כעת'),
        reason: 'the live grounded context is folded into the prompt');
    expect(call.system, managerCopilotSystem,
        reason: 'the anti-invention grounding system prompt reaches the gateway');
  });
}
