// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 49b — the optional
// per-trade PHYSICS config (plan step-49 §9, R1-2 canonical).
//
// Plumbing NEVER reads this class: its hand-written physics constants (the 2%
// ת"י-1205 slope minimum at install_studio_screen.dart's drainage panel, the
// 1-bar ΔP threshold of the pressure panel) are PERMANENT and stay hard-coded —
// the config-read exists only so an AUTHORED trade may supply its own numbers.
// v1 ships NO authoring UI for physics, so every authored trade carries a null
// config → the physics panels are HIDDEN for that trade (an electrician must
// not see a water-slope panel); plumbing keeps its panels verbatim.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

/// Optional flow-physics numbers an authored trade MAY supply. A null field
/// means "this trade has no such physics" — the matching studio panel hides.
///
/// R1-2: plumbing never constructs or reads one of these; its hand-written
/// constants are the permanent source of truth for the reserved trade.
@immutable
class TradePhysicsConfig {
  const TradePhysicsConfig({
    this.minSlopePercent,
    this.pressureDropBarThreshold,
  });

  /// Minimum gravity-drain slope (percent) — plumbing's hand-written 2%
  /// (ת"י 1205) equivalent. Null → the slope panel hides for the trade.
  final double? minSlopePercent;

  /// Pressure-drop warning threshold (bar) — plumbing's hand-written 1-bar
  /// equivalent. Null → the pressure panel hides for the trade.
  final double? pressureDropBarThreshold;

  @override
  bool operator ==(Object other) =>
      other is TradePhysicsConfig &&
      other.minSlopePercent == minSlopePercent &&
      other.pressureDropBarThreshold == pressureDropBarThreshold;

  @override
  int get hashCode => Object.hash(minSlopePercent, pressureDropBarThreshold);
}
