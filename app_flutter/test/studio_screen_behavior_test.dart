// Studio Pillar 4 · steps 82-83 — the Studio screen behavior tests.
//
// step 82 (the manual, no-model builder) pins the pillar's MVP invariants (§5): a
// confirmed diff writes ONLY through P1's `applyOps`, EXACTLY once (a double-tap can't
// re-apply); undo reverts through P1's undo-stack (the SSOT, not a local reversal);
// the preview (summarizeDiff rows) is shown BEFORE any apply; a typed-arg screen is
// GREYED / not-selectable in the action-picker (never dropped, R1-5); and the builder
// is fully usable with NO Claude gateway (works with kClaudeAi OFF, §8).
//
// step 83 (the NL co-editor pane, wired into StudioScreen's 🤖 tab) pins the
// zero-hallucination invariants (§5/§8): gateway-null → an honest `AiOffState` (the
// manual builder still usable); the MODEL NEVER calls `applyOps` (a fake gateway
// returning ops renders a PREVIEW only — 0 applies after ask, 1 after the explicit
// confirm-tap, R1-4); the identified scope ("מתוך: …") sits at the TOP of the preview
// (R1-7); a truncated reply → "לא הצלחתי" (not a partial preview, R1-10); a 200-empty
// reply → an honest retry (not an empty box); an ambiguous scope → "צריך הבהרה" (never
// a guess); and the `|| _loading` race guard blocks a mid-flight double-submit.
import 'dart:async';

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show ClaudeGateway, ClaudeResult, claudeGatewayProvider;
import 'package:buildsmart/screens/studio_component_builder.dart';
import 'package:buildsmart/screens/studio_screen.dart' show StudioScreen;
import 'package:buildsmart/state/board_auth.dart'
    show BoardAuthNotifier, BoardRole, boardAuthProvider;
import 'package:buildsmart/state/studio/config_doc.dart' show ConfigDoc;
import 'package:buildsmart/state/studio/config_store.dart'
    show ConfigOp, ConfigSink, ConfigStore, configStoreProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A no-op sink (no SharedPreferences) — the store persists nothing in the test.
class _FakeSink implements ConfigSink {
  @override
  Future<void> save(ConfigDoc doc) async {}
  @override
  Future<ConfigDoc?> load() async => null;
  @override
  Stream<ConfigDoc>? watch() => null;
}

/// A ConfigStore that COUNTS `applyOps` calls — the spy that proves the write path
/// is hit exactly once. It still calls `super.applyOps` (the real P1 write), so the
/// draft + undo-stack behave exactly as production.
class _SpyStore extends ConfigStore {
  _SpyStore(super.sink);

  int calls = 0;

  @override
  int applyOps(
    List<ConfigOp> ops, {
    String? persona,
    Set<String> criticalIds = const {},
  }) {
    calls++;
    return super.applyOps(ops, persona: persona, criticalIds: criticalIds);
  }
}

/// A hand-rolled [ClaudeGateway] fake (the `claude_functions.dart:56` port) — returns
/// model output with NO network. Stage-A (the scope prompt, the only one that lists
/// "טווחי-עריכה") is answered with [scopeReply]; every other prompt (Stage-B, the ops
/// prompt) is answered with [opsJson]. [gate], when supplied, holds every `ask` open
/// until the test completes it — the lever that keeps `_loading` true across a second
/// (guarded) submit. It NEVER writes: the whole point is proving the model returning
/// ops can't reach `applyOps` without an explicit confirm-tap (R1-4).
class _FakeGateway implements ClaudeGateway {
  _FakeGateway({
    required this.opsJson,
    this.scopeReply = 'scope:screen:cart',
    this.gate,
  });

  final String opsJson;
  final String scopeReply;
  final Completer<void>? gate;

  int calls = 0;

  @override
  Future<ClaudeResult> ask({
    required String prompt,
    String? system,
    String? model,
    int? maxTokens,
  }) async {
    calls++;
    if (gate != null) await gate!.future;
    final text = prompt.contains('טווחי-עריכה') ? scopeReply : opsJson;
    return ClaudeResult(text: text, model: 'fake-haiku');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget host({ConfigStore? store}) => ProviderScope(
        overrides: [
          if (store != null) configStoreProvider.overrideWith((ref) => store),
        ],
        child: const MaterialApp(
          home: Scaffold(body: StudioComponentBuilder()),
        ),
      );

  // ── step 83 — pump the WHOLE StudioScreen as a signed-in MANAGER (its route guard
  // fail-closes for anyone else), with the Claude gateway overridden to [gateway]
  // (null → the honest off-state; a fake → the wired NL pane) and, optionally, a spy
  // ConfigStore that counts `applyOps` (the write-path spy for the R1-4 invariant).
  Widget studioHost({ConfigStore? store, ClaudeGateway? gateway}) => ProviderScope(
        overrides: [
          boardAuthProvider.overrideWith((ref) {
            // a manager session; enterDemo sets _userTouched=true → the async _load
            // can't clobber it back to logged-out.
            return BoardAuthNotifier(ref, bindFirebase: false)
              ..enterDemo(BoardRole.manager);
          }),
          claudeGatewayProvider.overrideWithValue(gateway),
          if (store != null) configStoreProvider.overrideWith((ref) => store),
        ],
        child: const MaterialApp(home: StudioScreen()),
      );

  // Switch to the 🤖 co-editor tab (index 0 — the manual builder is the default tab).
  Future<void> openCoEditor(WidgetTester t) async {
    await t.tap(find.text('עורך-שפה'));
    await t.pumpAndSettle();
  }

  // Pick the first registry element (cart.cta) via the dropdown, then the טקסט
  // category, then type — the shortest path to a confirmable SetText.
  Future<void> pickTextEdit(WidgetTester t, String text) async {
    await t.tap(find.byKey(const Key('studio-el-picker')));
    await t.pumpAndSettle();
    await t.tap(find.text('כפתור הזמנה (עגלה)').last);
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('studio-cat-text')));
    await t.pump();
    await t.enterText(find.byKey(const Key('studio-text-field')), text);
    await t.pump();
  }

  testWidgets(
      'preview shown BEFORE apply; confirm calls applyOps EXACTLY once; '
      'a double-tap does NOT apply twice (the confirm-gate)', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final spy = _SpyStore(_FakeSink());
    await t.pumpWidget(host(store: spy));
    await t.pumpAndSettle();

    await pickTextEdit(t, 'הזמן עכשיו');

    // PREVIEW is shown BEFORE any apply (summarizeDiff row) — and nothing written.
    expect(find.textContaining('שינוי טקסט'), findsWidgets);
    expect(spy.calls, 0);

    // Confirm ONCE → P1 applyOps called exactly once, draft changed.
    await t.tap(find.byKey(const Key('studio-confirm')));
    await t.pump();
    expect(spy.calls, 1);
    expect(spy.state.draft.global['cart.cta']?.text, 'הזמן עכשיו');

    // Double-tap the SAME pending selection → the guard blocks a second write.
    await t.pump(const Duration(milliseconds: 1300)); // let the snackbar clear
    await t.tap(find.byKey(const Key('studio-confirm')));
    await t.pump();
    expect(spy.calls, 1); // NOT re-applied
  });

  testWidgets('undo reverts through P1 undo-stack (not a local reversal)',
      (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final spy = _SpyStore(_FakeSink());
    await t.pumpWidget(host(store: spy));
    await t.pumpAndSettle();

    await pickTextEdit(t, 'טקסט חדש');
    await t.tap(find.byKey(const Key('studio-confirm')));
    await t.pump();

    // Applied → P1's undo-stack now has a frame.
    expect(spy.state.draft.global['cart.cta']?.text, 'טקסט חדש');
    expect(spy.canUndo, isTrue);

    // The builder's undo button calls P1.undo() — the draft reverts via the SSOT.
    await t.pump(const Duration(milliseconds: 1300)); // clear the snackbar
    await t.tap(find.byKey(const Key('studio-undo')));
    await t.pump();
    expect(spy.state.draft.global['cart.cta'], isNull); // reverted by P1
  });

  testWidgets(
      'a typed-arg screen in the action-picker is GREYED / not selectable '
      '(never dropped, R1-5)', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    await t.pumpWidget(host()); // real store (no gateway) — the manual path
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('studio-el-picker')));
    await t.pumpAndSettle();
    await t.tap(find.text('כפתור הזמנה (עגלה)').last);
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('studio-cat-action')));
    await t.pump();
    await t.tap(find.byKey(const Key('studio-action-nav.screen')));
    await t.pump();

    // The typed-arg screen is PRESENT (not dropped) and GREYED-disabled.
    final typedArg = find.byKey(const Key('studio-nav-AiFinderScreen'));
    expect(typedArg, findsOneWidget);
    final tile = t.widget<ListTile>(typedArg);
    expect(tile.enabled, isFalse);
    expect(tile.onTap, isNull);
    expect(find.text('צריך פרמטרים — לא זמין'), findsWidgets);

    // ...while a no-arg screen (in kNavScreenIds) IS selectable.
    final navTile = t.widget<ListTile>(
      find.byKey(const Key('studio-nav-ProfileScreen')),
    );
    expect(navTile.enabled, isTrue);
    expect(navTile.onTap, isNotNull);
  });

  testWidgets(
      'the builder is fully usable with NO Claude gateway (kClaudeAi OFF, §8)',
      (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    // No claudeGatewayProvider override anywhere → the gateway is null. The builder
    // must still pick → preview → confirm → write.
    final spy = _SpyStore(_FakeSink());
    await t.pumpWidget(host(store: spy));
    await t.pumpAndSettle();

    await pickTextEdit(t, 'עובד בלי שרת');
    await t.tap(find.byKey(const Key('studio-confirm')));
    await t.pump();

    expect(spy.calls, 1);
    expect(spy.state.draft.global['cart.cta']?.text, 'עובד בלי שרת');
  });

  // ── step 83 · the NL co-editor pane (wired into StudioScreen's 🤖 tab) ──

  testWidgets(
      'gateway null → the 🤖 co-editor shows an honest AiOffState, and the '
      '🛠️ manual builder tab is STILL fully usable (§8 off-state)', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    await t.pumpWidget(studioHost()); // no gateway bound (default null) → off-state
    await t.pumpAndSettle();

    await openCoEditor(t);
    // The off-state line (AiOffState) — NOT the NL input (which never mounts off).
    expect(find.textContaining('העורך החכם דורש חיבור לשרת'), findsOneWidget);
    expect(find.byKey(const Key('studio-nl-input')), findsNothing);

    // The manual builder tab is unaffected — its element picker is present.
    await t.tap(find.text('בונה ידני'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('studio-el-picker')), findsOneWidget);
  });

  testWidgets(
      'the MODEL never calls applyOps — a fake gateway returning ops renders a '
      'PREVIEW only (scope at TOP); applyOps fires ONLY on the confirm-tap, once '
      '(R1-4 · the critical defect-class)', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final spy = _SpyStore(_FakeSink());
    final fake = _FakeGateway(
      opsJson: '[{"op":"setText","id":"cart.cta","text":"הזמן עכשיו"}]',
    );
    await t.pumpWidget(studioHost(store: spy, gateway: fake));
    await t.pumpAndSettle();
    await openCoEditor(t);

    await t.enterText(
      find.byKey(const Key('studio-nl-input')),
      'שנה את הכיתוב של כפתור ההזמנה',
    );
    await t.tap(find.byKey(const Key('studio-nl-submit')));
    await t.pumpAndSettle();

    // The gateway was asked (both stages) and returned ops — but NOTHING is written.
    expect(fake.calls, 2);
    expect(spy.calls, 0); // the model's ops are a PREVIEW, not a write (R1-4)

    // The preview is shown: the scope row + the grounded diff row.
    expect(find.byKey(const Key('studio-nl-scope')), findsOneWidget);
    expect(find.textContaining('מתוך:'), findsOneWidget);
    expect(find.textContaining('שינוי טקסט: cart.cta'), findsOneWidget);

    // R1-7 — the scope row sits ABOVE the diff row (confirm the target first).
    final scopeDy = t.getTopLeft(find.byKey(const Key('studio-nl-scope'))).dy;
    final diffDy =
        t.getTopLeft(find.textContaining('שינוי טקסט: cart.cta')).dy;
    expect(scopeDy, lessThan(diffDy));

    // The explicit confirm-tap is the ONLY write — applyOps fires exactly once.
    await t.ensureVisible(find.byKey(const Key('studio-nl-confirm')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('studio-nl-confirm')));
    await t.pump();
    expect(spy.calls, 1);
    expect(spy.state.draft.global['cart.cta']?.text, 'הזמן עכשיו');

    // A double-tap on the same preview → the turn guard blocks a second apply.
    await t.pump(const Duration(milliseconds: 1300)); // let the snackbar clear
    await t.tap(find.byKey(const Key('studio-nl-confirm')));
    await t.pump();
    expect(spy.calls, 1); // NOT re-applied
  });

  testWidgets(
      'a truncated reply → "לא הצלחתי" — NOT a partial preview, and applyOps '
      'is never reached (R1-10)', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final spy = _SpyStore(_FakeSink());
    // An opened-but-never-closed JSON array — the parser's brace-balance guard fails
    // it AS A UNIT (finishReason is null; ClaudeResult carries none).
    final fake = _FakeGateway(
      opsJson: '[{"op":"setText","id":"cart.cta","text":"היי',
    );
    await t.pumpWidget(studioHost(store: spy, gateway: fake));
    await t.pumpAndSettle();
    await openCoEditor(t);

    await t.enterText(find.byKey(const Key('studio-nl-input')), 'שנה טקסט');
    await t.tap(find.byKey(const Key('studio-nl-submit')));
    await t.pumpAndSettle();

    expect(find.textContaining('לא הצלחתי'), findsOneWidget);
    expect(find.byKey(const Key('studio-nl-scope')), findsNothing); // no preview
    expect(find.byKey(const Key('studio-nl-confirm')), findsNothing);
    expect(spy.calls, 0);
  });

  testWidgets(
      'a 200-empty reply → an honest retry line, not an empty box', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final spy = _SpyStore(_FakeSink());
    final fake = _FakeGateway(opsJson: ''); // Stage-B returns an empty body
    await t.pumpWidget(studioHost(store: spy, gateway: fake));
    await t.pumpAndSettle();
    await openCoEditor(t);

    await t.enterText(find.byKey(const Key('studio-nl-input')), 'שנה טקסט');
    await t.tap(find.byKey(const Key('studio-nl-submit')));
    await t.pumpAndSettle();

    expect(find.byKey(const Key('studio-nl-message')), findsOneWidget);
    expect(find.textContaining('לא התקבלה תשובה'), findsOneWidget);
    expect(find.byKey(const Key('studio-nl-scope')), findsNothing);
    expect(spy.calls, 0);
  });

  testWidgets(
      'an ambiguous scope → "צריך הבהרה"; Stage-B is NEVER asked and nothing is '
      'written (R1-7 — never a guessed scope)', (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final spy = _SpyStore(_FakeSink());
    // A scope reply that grounds to NO closed token → classifyScope returns null.
    final fake = _FakeGateway(
      opsJson: '[{"op":"setText","id":"cart.cta","text":"x"}]',
      scopeReply: 'לא ברור בכלל',
    );
    await t.pumpWidget(studioHost(store: spy, gateway: fake));
    await t.pumpAndSettle();
    await openCoEditor(t);

    await t.enterText(find.byKey(const Key('studio-nl-input')), 'תעשה משהו');
    await t.tap(find.byKey(const Key('studio-nl-submit')));
    await t.pumpAndSettle();

    expect(find.textContaining('צריך הבהרה'), findsOneWidget);
    expect(fake.calls, 1); // only Stage-A — no ops round-trip on an ungrounded scope
    expect(find.byKey(const Key('studio-nl-scope')), findsNothing);
    expect(spy.calls, 0);
  });

  testWidgets(
      'the || _loading race guard blocks a mid-flight double-submit (§4)',
      (t) async {
    await t.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final spy = _SpyStore(_FakeSink());
    final gate = Completer<void>();
    final fake = _FakeGateway(
      opsJson: '[{"op":"setText","id":"cart.cta","text":"הזמן עכשיו"}]',
      gate: gate, // every ask hangs until the test releases it
    );
    await t.pumpWidget(studioHost(store: spy, gateway: fake));
    await t.pumpAndSettle();
    await openCoEditor(t);

    await t.enterText(find.byKey(const Key('studio-nl-input')), 'שנה טקסט');

    // First submit via the keyboard action — Stage-A is now in flight, _loading=true.
    await t.testTextInput.receiveAction(TextInputAction.search);
    await t.pump();
    expect(fake.calls, 1);

    // A second action mid-flight — onSubmitted bypasses the disabled button, but the
    // `|| _loading` guard drops it: NO second ask is fired.
    await t.testTextInput.receiveAction(TextInputAction.search);
    await t.pump();
    expect(fake.calls, 1); // NOT 2 — the race guard held

    // Release the gate → the single submit finishes its two stages; still 0 applies.
    gate.complete();
    await t.pumpAndSettle();
    expect(fake.calls, 2);
    expect(spy.calls, 0);
  });
}
