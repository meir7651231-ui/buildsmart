// Studio Pillar 4 · step 82 — the manual (no-model) builder behavior tests.
//
// Pins the pillar's MVP invariants (§5): a confirmed diff writes ONLY through P1's
// `applyOps`, EXACTLY once (a double-tap can't re-apply); undo reverts through P1's
// undo-stack (the SSOT, not a local reversal); the preview (summarizeDiff rows) is
// shown BEFORE any apply; a typed-arg screen is GREYED / not-selectable in the
// action-picker (never dropped, R1-5); and the builder is fully usable with NO
// Claude gateway (works with kClaudeAi OFF, §8).
import 'package:buildsmart/screens/studio_component_builder.dart';
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
}
