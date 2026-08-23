// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · הקמת המערכת — the unified manager-only two-phase setup flow.
//
// One entry, one place: the manager FIRST builds the trade (Pillar-2 trade
// builder — categories/products/rules) and THEN configures the org (giant-system
// V5 org-setup wizard — vertical/modules/terms/screens). "קודם מקימים מערכת ואז
// מגדירים אותה."
//
// HOSTING CONTRACT (audited): both phase screens are full `Scaffold`s that bring
// their own `AppBar` (and phase-1 its own `bottomNavigationBar`), so this host
// deliberately adds NO `Scaffold`/`AppBar`/`bottomNavigationBar` of its own — it
// just SWAPS which child screen is shown. The swap uses a plain `switch` (NOT an
// `IndexedStack`), so phase-2 is CONSTRUCTED only when the manager advances —
// its `initState` then reads `orgConfigProvider` fresh at entry, not stale at
// host-mount.
//
// The two child screens are reused VERBATIM; the only seam is phase-1's optional
// `onContinue` callback (null-default, so it stays standalone-route-able), which
// this host wires to advance to phase-2.
//
// Reached only from the manager dashboard's 🛠️ ניהול tab, gated by the
// compile-const `kOrgConfigFlag` (armed in the live build, off in define-less
// test builds ⇒ the manager tab stays byte-identical there). Phase-1 is pushed
// DIRECTLY (the trade-builder screens do not self-gate), so `kTradeBuilder` stays
// owner-staged-OFF and its pinned tests are untouched.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/screens/org_setup_wizard_screen.dart';
import 'package:buildsmart/screens/trade_builder/trade_builder_home.dart';
import 'package:flutter/material.dart';

/// 🔌 הקמת המערכת — the unified two-phase setup host (בונה-ענף → הגדרת-ארגון).
class SystemSetupHostScreen extends StatefulWidget {
  const SystemSetupHostScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const SystemSetupHostScreen(),
      );

  @override
  State<SystemSetupHostScreen> createState() => _SystemSetupHostScreenState();
}

class _SystemSetupHostScreenState extends State<SystemSetupHostScreen> {
  /// 0 = build the trade (phase 1), 1 = configure the org (phase 2). Local
  /// widget state; no engine/global write.
  int _phase = 0;

  @override
  Widget build(BuildContext context) {
    // A plain switch (NOT IndexedStack): phase-2 constructs on advance, so its
    // initState reads orgConfigProvider fresh at entry (audited hazard #4).
    switch (_phase) {
      case 0:
        // Phase 1 — build the trade. Its own Scaffold/AppBar/bottom-bar; the
        // host only injects the "המשך" affordance via onContinue.
        return TradeBuilderHomeScreen(
          onContinue: () => setState(() => _phase = 1),
        );
      case 1:
      default:
        // Phase 2 — configure the org. Terminal phase: the manager exits via
        // the wizard's own AppBar back.
        return const OrgSetupWizardScreen();
    }
  }
}
