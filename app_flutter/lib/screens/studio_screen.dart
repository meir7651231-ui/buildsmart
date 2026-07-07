// ─────────────────────────────────────────────────────────────────────────────
// StudioScreen — BuildSmart Studio · Pillar 4 · step 81. The manager-only Studio
// CO-EDITOR cockpit: a 3-tab SHELL (🤖 עורך-שפה · 🛠️ בונה ידני · 🔒 כללים),
// reached from the compile-gated `_StudioHero` on the manager dashboard.
//
// This step lands only the SHELL + guards + off-states; the panes are
// PLACEHOLDERS: step 82 fills the manual builder, step 83 wires the NL co-editor.
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

import 'package:buildsmart/logic/studio/co_editor_gate.dart'
    show studioCoEditorProvider;
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart'
    show BoardRole, boardAuthProvider;
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart' show AiOffState;
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
              Text(
                '🎬 סטודיו',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
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
                  const _ManualBuilderPane(),
                  // 🔒 rules — the safety floor (what the Studio may change).
                  const _RulesPane(),
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

/// 🤖 The NL co-editor pane. §4 off-state: when the Claude gateway is null
/// (`ai == false`) it shows an honest [AiOffState] pointing the manager to the
/// always-working manual builder; when the gateway is live it is a "בקרוב"
/// placeholder (step 83 wires ask→parse→safe→preview→confirm).
class _CoEditorPane extends StatelessWidget {
  const _CoEditorPane({required this.ai});

  final bool ai;

  @override
  Widget build(BuildContext context) {
    if (!ai) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(BsTokens.space5),
          child: AiOffState(
            '💡 העורך החכם דורש חיבור לשרת. בינתיים — הבנייה הידנית עובדת תמיד.',
          ),
        ),
      );
    }
    return const _Placeholder(
      emoji: '🤖',
      title: 'עורך שפה-טבעית',
      body: 'תאר בעברית מה לשנות — ואכין תצוגה מקדימה לאישור לפני כל שינוי. בקרוב.',
    );
  }
}

/// 🛠️ The manual (no-model) builder pane. §8: needs NO gateway, so it is ALWAYS
/// usable — the hero deep-link lands here by default. Placeholder for step 82
/// (pick→prop/visibility/component/action→preview→confirm→undo).
class _ManualBuilderPane extends StatelessWidget {
  const _ManualBuilderPane();

  @override
  Widget build(BuildContext context) {
    return const _Placeholder(
      emoji: '🛠️',
      title: 'בונה ידני',
      body: 'בחר אלמנט → טקסט · נראות · רכיב · פעולה → תצוגה מקדימה → אישור. '
          'עובד תמיד, גם בלי חיבור לשרת. בקרוב.',
    );
  }
}

/// 🔒 The rules pane — what the Studio is allowed to change (the safety floor).
/// Placeholder; the live rules view lands alongside the builder panes.
class _RulesPane extends StatelessWidget {
  const _RulesPane();

  @override
  Widget build(BuildContext context) {
    return const _Placeholder(
      emoji: '🔒',
      title: 'כללי בטיחות',
      body: 'מה מותר ומה חסום לעריכה — מחירים ופעולות-ליבה תמיד מוגנים. בקרוב.',
    );
  }
}

/// A centered "בקרוב" placeholder pane — an emoji, a title, a one-line purpose,
/// and a small "בקרוב" pill. Shared by the three shell tabs until steps 82/83
/// fill them. All colors from [BsTokens] (the color-ratchet — zero raw hex).
class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BsTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: BsTokens.space3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: BsTokens.space4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BsTokens.space3,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: BsTokens.surfaceMid,
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              ),
              child: const Text(
                'בקרוב',
                style: TextStyle(
                  color: BsTokens.warnText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
