// ─────────────────────────────────────────────────────────────────────────────
// StudioScreen — BuildSmart Studio · Pillar 4 · step 81. The manager-only Studio
// CO-EDITOR cockpit: a 3-tab SHELL (🤖 עורך-שפה · 🛠️ בונה ידני · 🔒 כללים),
// reached from the compile-gated `_StudioHero` on the manager dashboard.
//
// The SHELL + guards + off-states landed in step 81; step 82 filled the 🛠️ manual
// builder and step 83 wired the 🤖 NL co-editor (ask→parse→safe→preview→confirm).
//
// Three invariants this shell enforces (studio-plan §4/§8/§9/§10):
//   • §10 route guard — fail-CLOSED: a non-manager session never sees the Studio;
//     `build` returns `WelcomeScreen(boardRole: manager)` (mirrors the manager
//     dashboard's own guard, `manager_dashboard_screen.dart:87`), not an error page.
//   • §4 off-state — the 🤖 co-editor pane shows an honest [AiOffState] when the
//     Claude gateway is null (`studioCoEditorProvider.ai == false`).
//   • §8/§9 always-works — the 🛠️ manual-builder pane needs NO gateway, so it is
//     ALWAYS usable; the deep-link (the default tab) opens it FIRST (the path that
//     never disappoints), and the hero carries an "ניסיוני" badge.
//
// NOTE: intentionally distinct from the Pillar-1 owner Studio in
// `screens/studio/studio_screen.dart` (same simple name, different library — the
// two are never co-imported, so there is no name clash).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/logic/studio/co_editor_gate.dart'
    show studioCoEditorProvider;
import 'package:buildsmart/logic/studio/diff_preview.dart'
    show DiffLine, summarizeDiff;
import 'package:buildsmart/logic/studio/edit_intent.dart'
    show parseConfigEdit, scopeHe;
import 'package:buildsmart/logic/studio/edit_prompt.dart'
    show
        classifyScope,
        kStudioEditMaxTokens,
        studioEditPrompt,
        studioEditSystem,
        studioScopePrompt;
import 'package:buildsmart/logic/studio/edit_safety.dart'
    show SafetyVerdict, validateSafe;
import 'package:buildsmart/logic/studio/registry_view.dart'
    show ElementRegistryView, RegistryView;
import 'package:buildsmart/screens/studio_component_builder.dart'
    show StudioComponentBuilder;
import 'package:buildsmart/screens/studio_rules_screen.dart'
    show StudioRulesScreen;
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart'
    show BoardRole, boardAuthProvider;
import 'package:buildsmart/state/studio/config_store.dart'
    show configStoreProvider;
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart' show AiOffState;
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The manager-only Studio cockpit shell (Pillar 4 · step 81).
class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});

  /// The `manager_copilot_screen.dart:32` route idiom — a plain
  /// [MaterialPageRoute] to the const screen. The manager guard lives INSIDE
  /// `build` (fail-closed), so the route itself needs no gate.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const StudioScreen());

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen> {
  // The 3 shell tabs are index-ordered 0:🤖 co-editor · 1:🛠️ manual · 2:🔒 rules
  // (see the IndexedStack below). The MANUAL builder is the DEFAULT (§9): it
  // needs no gateway, so the hero deep-link always lands on a working pane.
  static const int _manualTab = 1;

  int _tab = _manualTab;

  @override
  Widget build(BuildContext context) {
    // §10 — the manager route guard, fail-CLOSED. A non-manager session gets the
    // manager welcome gate (mirrors `manager_dashboard_screen.dart:87`), never an
    // error page. Reactive: a role change (logout) rebuilds into the gate.
    if (ref.watch(boardAuthProvider)?.role != BoardRole.manager) {
      return const WelcomeScreen(boardRole: BoardRole.manager);
    }

    // The `ai` axis (gateway bound?) drives the co-editor off-state; `enabled` /
    // `manager` are decided at the gate/hero (studioCoEditorProvider is the SSOT).
    final gate = ref.watch(studioCoEditorProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CfgText(
                'studio_screen_old.t01',
                '🎬 סטודיו',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              CfgText(
                'studio_screen_old.t02',
                'ערוך את האפליקציה — עורך ניסיוני',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            _StudioTabs(
              active: _tab,
              onSelect: (i) => setState(() => _tab = i),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  // 🤖 co-editor (step 83) — honest off-state when gateway null.
                  _CoEditorPane(ai: gate.ai),
                  // 🛠️ manual builder (step 82) — no gateway, always usable (§8).
                  const StudioComponentBuilder(),
                  // 🔒 rules — closed-set automation rules, read-only advisory (step 84).
                  const StudioRulesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 3 segmented pills (🤖 עורך-שפה · 🛠️ בונה ידני · 🔒 כללים) — mirrors the
/// manager dashboard's `_ManagerToggle` pill style: the selected pill is a
/// [BsTokens.brand] fill with on-accent text; the rest are light [BsTokens.cardLight].
class _StudioTabs extends StatelessWidget {
  const _StudioTabs({required this.active, required this.onSelect});

  final int active;
  final ValueChanged<int> onSelect;

  /// (emoji, label) per tab — index-aligned with the [IndexedStack] children.
  static const List<(String, String)> _tabs = [
    ('🤖', 'עורך-שפה'),
    ('🛠️', 'בונה ידני'),
    ('🔒', 'כללים'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget seg(int i, String emoji, String label) {
      final on = active == i;
      return Expanded(
        child: Padding(
          // Half-gap on each inner edge → an even gap between pills, none at the
          // outer edges. Directional so RTL/LTR both lay out correctly.
          padding: EdgeInsetsDirectional.only(
            start: i == 0 ? 0 : BsTokens.space2 / 2,
            end: i == _tabs.length - 1 ? 0 : BsTokens.space2 / 2,
          ),
          child: Material(
            color: on ? BsTokens.brand : BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              onTap: () => onSelect(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: on ? bsOnAccent(context) : BsTokens.inkLight,
                          fontSize: 13.5,
                          fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: BsTokens.cardLight,
      padding: const EdgeInsetsDirectional.fromSTEB(
        BsTokens.space3,
        BsTokens.space2,
        BsTokens.space3,
        BsTokens.space3,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++) seg(i, _tabs[i].$1, _tabs[i].$2),
        ],
      ),
    );
  }
}

/// 🤖 The NL co-editor pane (step 83). §4 off-state: when the Claude gateway is null
/// (`ai == false`) it shows an honest [AiOffState] pointing the manager to the
/// always-working manual builder. When the gateway is live it wires the full,
/// PREVIEW-FIRST flow — ask → parse → safe → preview → confirm:
///
///   • Stage-A `studioScopePrompt` → the model NAMES one closed scope token, grounded
///     by `classifyScope` (ambiguous → null → "צריך הבהרה", never a guess — R1-7);
///   • Stage-B `studioEditPrompt` + `studioEditSystem` → `parseConfigEdit` drops every
///     invented id/prop/value/action (truncated → "לא הצלחתי", R1-10; 0 ops →
///     "מה התכוונת?" + the dropped count, §9 — never a silent empty box);
///   • `validateSafe` → `summarizeDiff` render the Hebrew preview with the identified
///     scope at the TOP ("מתוך: …", R1-7) so the owner confirms the TARGET first.
///
/// THE ONE INVARIANT (R1-4 · DoD §8): the MODEL never triggers a write. The gateway
/// returns ops; this pane renders them as a PREVIEW only. `applyOps` — the SAME single
/// Pillar-1 write path the step-82 manual builder uses — is called ONLY from the
/// owner's explicit confirm-tap, guarded by a tracked single-tap turn (mirror of
/// `studio_component_builder.dart:108-112`) so a double-tap can never write twice. The
/// `|| _loading` guard + a `mounted`-check after EVERY await close the stale-response
/// race (`describe_to_cart_screen.dart:104`), and a 200-empty reply is an honest retry,
/// never an empty box (`reject_reason_screen.dart:92-93`).
class _CoEditorPane extends ConsumerStatefulWidget {
  const _CoEditorPane({required this.ai});

  final bool ai;

  @override
  ConsumerState<_CoEditorPane> createState() => _CoEditorPaneState();
}

class _CoEditorPaneState extends ConsumerState<_CoEditorPane> {
  // The frozen grounding source (R1-2) — the SAME registry `parseConfigEdit` /
  // `validateSafe` / `summarizeDiff` use, so the model can only ever NAME real ids.
  final RegistryView _registry = ElementRegistryView.builtIn();
  final TextEditingController _controller = TextEditingController();

  bool _loading = false;

  // An honest off-path line (ambiguous / empty / truncated / "מה התכוונת" / failed);
  // [_messageIsError] reddens the hard failures and keeps the soft "didn't understand"
  // lines muted — but it is NEVER an empty box (reject_reason_screen.dart:92-93).
  String? _message;
  bool _messageIsError = false;

  // The landed preview (all pure, zero-model, zero-IO — §9 "preview is free").
  String? _scope; // the grounded Stage-A scope — the "מתוך: …" target (R1-7)
  SafetyVerdict? _verdict;
  List<DiffLine> _preview = const <DiffLine>[];

  // ── the confirm-gate (mirror of step 82's tracked single-tap, studio_component_
  // builder.dart:108-112): each landed preview is a "turn"; a turn already confirmed
  // is a no-op, so a double-tap can never apply twice.
  int _turn = 0;
  final Set<int> _confirmedTurns = <int>{};

  // §10 — a tiny client-side debounce so a tap-burst can't spend the 40/min server cap.
  DateTime? _lastSubmit;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearResult() {
    _message = null;
    _messageIsError = false;
    _scope = null;
    _verdict = null;
    _preview = const <DiffLine>[];
  }

  /// ask → parse → safe → preview. Runs TWO grounded gateway round-trips (scope, then
  /// ops) and lands a PREVIEW — it NEVER writes (that is [_confirm] alone, R1-4).
  Future<void> _submit() async {
    final gw = ref.read(claudeGatewayProvider);
    final text = _controller.text.trim();
    // §4 — `|| _loading` closes the stale-response race (onSubmitted bypasses the
    // button's loading-disable, so a mid-flight re-submit could overwrite a newer
    // preview); the debounce keeps a tap-burst under the 40/min server cap (§10).
    if (gw == null || text.isEmpty || _loading) return;
    final now = DateTime.now();
    if (_lastSubmit != null &&
        now.difference(_lastSubmit!) < const Duration(milliseconds: 400)) {
      return;
    }
    _lastSubmit = now;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _clearResult();
    });
    try {
      // Stage-A — the model NAMES one closed scope token; `classifyScope` grounds it
      // to a real token, or null (AMBIGUOUS → "צריך הבהרה", never a guess — R1-7). The
      // utterance is folded + capped by `promptSafeText` INSIDE `studioScopePrompt`
      // (edit_prompt.dart:214) — the injection-lever defense (§7.9).
      final scopeRes = await gw.ask(
        prompt: studioScopePrompt(_registry, text),
        maxTokens: kStudioEditMaxTokens,
      );
      if (!mounted) return;
      final scope = classifyScope(scopeRes.text, _registry);
      if (scope == null) {
        setState(() {
          _loading = false;
          _message =
              'צריך הבהרה — לא הצלחתי לזהות מה בדיוק לשנות. נסה לתאר את היעד.';
        });
        return;
      }
      // Stage-B — the grounded ops prompt for that scope; a SMALL reply (ops are short).
      final editRes = await gw.ask(
        system: studioEditSystem,
        prompt:
            studioEditPrompt(registry: _registry, utterance: text, scope: scope),
        maxTokens: kStudioEditMaxTokens,
      );
      if (!mounted) return;
      final reply = editRes.text.trim();
      if (reply.isEmpty) {
        // A 200-empty reply → an honest retry, NOT an empty box (reject_reason:92-93).
        setState(() {
          _loading = false;
          _message = 'לא התקבלה תשובה מהשרת — נסה שוב.';
          _messageIsError = true;
        });
        return;
      }
      // `ClaudeResult` carries NO finishReason, so pass null and lean on the parser's
      // brace-balance truncation guard (edit_intent.dart:130-143).
      final parsed = parseConfigEdit(reply, _registry, finishReason: null);
      if (parsed.truncated) {
        // R1-10 — a truncated reply fails AS A UNIT, never a partial preview.
        setState(() {
          _loading = false;
          _message = 'לא הצלחתי לבנות את השינוי, נסה שוב';
          _messageIsError = true;
        });
        return;
      }
      if (parsed.ops.isEmpty) {
        // §9 "מה התכוונת?" — surface the dropped count, not a silent empty box.
        setState(() {
          _loading = false;
          _message = parsed.dropped > 0
              ? 'מה התכוונת? ${parsed.dropped} חלקים לא הובנו — נסה לנסח מחדש.'
              : 'מה התכוונת? לא זוהה שינוי מתאים — נסה לנסח מחדש.';
        });
        return;
      }
      // safe → preview (both pure — §9). `validateSafe` re-checks the backstop; the
      // blocked ops surface with their Hebrew reasons (never silently swallowed).
      final verdict = validateSafe(parsed.ops);
      final preview = summarizeDiff(verdict.applied, _registry, verdict: verdict);
      setState(() {
        _loading = false;
        _scope = scope;
        _verdict = verdict;
        _preview = preview;
        _turn++; // a fresh, re-confirmable preview
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'משהו השתבש — נסה שוב.';
        _messageIsError = true;
      });
    }
  }

  /// confirm-tap → Pillar-1 `applyOps` ONCE (R1-4). THE ONLY write in the pane; the
  /// model never reaches it. Guarded by the tracked turn so a double-tap is a no-op.
  void _confirm() {
    final verdict = _verdict;
    if (verdict == null || verdict.applied.isEmpty) return;
    if (_confirmedTurns.contains(_turn)) return; // double-tap guard (mirror of §82)
    _confirmedTurns.add(_turn);
    // THE single write path (R1-4): Pillar 1 owns `applyOps` + the undo-stack; the
    // Studio never mutates the draft locally and NEVER applies model ops without this
    // explicit tap. Pass ONLY the safe (verdict.applied) ops.
    ref.read(configStoreProvider.notifier).applyOps(verdict.applied);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הוחל — ${verdict.applied.length} שינוי בטיוטה ✓'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.ai) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(BsTokens.space5),
          child: AiOffState(
            '💡 העורך החכם דורש חיבור לשרת. בינתיים — הבנייה הידנית עובדת תמיד.',
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(BsTokens.space4),
      children: [
        const CfgText(
          'studio_screen_old.t03',
          '🤖 תאר בעברית מה לשנות. אכין תצוגה מקדימה — שום דבר לא ישתנה עד שתאשר.',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          key: const Key('studio-nl-input'),
          controller: _controller,
          maxLines: 2,
          textInputAction: TextInputAction.search,
          // onSubmitted bypasses the button's loading-disable → the `|| _loading`
          // guard in [_submit] is the real backstop against a mid-flight re-submit.
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'לדוגמה: שנה את הכיתוב של כפתור ההזמנה ל"הזמן עכשיו"',
            filled: true,
            fillColor: BsTokens.cardLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('studio-nl-submit'),
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: BsTokens.brand,
              disabledBackgroundColor: BsTokens.divider,
              foregroundColor: bsOnAccent(context),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const CfgText(
              'studio_screen_old.t04',
              'נסח שינוי לתצוגה מקדימה',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        if (_loading) ...[
          const SizedBox(height: BsTokens.space4),
          const Center(child: CircularProgressIndicator()),
        ],
        if (_message != null) ...[
          const SizedBox(height: BsTokens.space4),
          _messageCard(),
        ],
        if (_preview.isNotEmpty && _verdict != null) ...[
          const SizedBox(height: BsTokens.space4),
          _previewCard(),
          const SizedBox(height: BsTokens.space3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('studio-nl-confirm'),
              onPressed:
                  (_verdict?.applied.isNotEmpty ?? false) ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: BsTokens.brand,
                disabledBackgroundColor: BsTokens.divider,
                foregroundColor: bsOnAccent(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const CfgText(
                'studio_screen_old.t05',
                'אשר והחל בטיוטה ✓',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _messageCard() {
    return Container(
      key: const Key('studio-nl-message'),
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.surfaceMid,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(
        _message!,
        style: TextStyle(
          color: _messageIsError ? BsTokens.dangerDark : BsTokens.mutedLight,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _previewCard() {
    final scope = _scope;
    final verdict = _verdict!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.surfaceMid,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CfgText(
            'studio_screen_old.t06',
            '👁️ תצוגה מקדימה (לפני החלה)',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          // R1-7 — the identified scope at the TOP, so the owner confirms the TARGET
          // ("מתוך: מסך «cart»") BEFORE reading the changes.
          if (scope != null) ...[
            const SizedBox(height: BsTokens.space2),
            Text(
              'מתוך: ${scopeHe(scope)}',
              key: const Key('studio-nl-scope'),
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: BsTokens.space2),
          for (final row in _preview)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${row.he}',
                style: const TextStyle(color: BsTokens.inkLight, fontSize: 13),
              ),
            ),
          // §4/§6 — every BLOCK carries a Hebrew reason, SHOWN (never silent).
          if (verdict.blocked.isNotEmpty) ...[
            const SizedBox(height: BsTokens.space2),
            for (final b in verdict.blocked)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '⛔ ${b.reasonHe}',
                  style: const TextStyle(
                    color: BsTokens.dangerDark,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// (step 84) The 🔒 rules tab now hosts `StudioRulesScreen` (closed-set automation
// rules, read-only advisory). The step-81 `_RulesPane` / `_Placeholder` "safety
// floor" placeholders were removed when the co-editor (83), manual builder (82),
// and rules (84) panes all landed — no tab is a placeholder any longer.
