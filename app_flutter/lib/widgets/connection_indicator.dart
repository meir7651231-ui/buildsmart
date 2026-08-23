// ─────────────────────────────────────────────────────────────────────────────
// connection_indicator — the ALWAYS-ON, top-of-screen connection pill.
//
// Mounted ONCE in lib/main.dart's MaterialApp.builder Stack (after the debug
// overlay), so it overlays EVERY screen. It watches [connectionStatusProvider]
// and renders one honest, compact pill:
//
//   • connected    → green  · 🟢 מחובר לשרת              (small, unobtrusive)
//   • disconnected → red    · 🔴 מנותק · פעולות לא יישמרו (prominent — a warning)
//   • demo         → grey   · מצב דמו                      (honest, subtle)
//
// POSITIONING: a Positioned at the top, RTL, aligned topCenter. In DEBUG the
// BackendDebugBadge owns top+padding.top+4 (a top-stacked column); this pill is
// pushed DOWN (+kConnectionIndicatorDebugDrop) so the two never collide. In a
// RELEASE/web build the badge is absent (kDebugMode false) and this pill owns the
// top. On the demo/test path [connectionStatusProvider] is the constant `demo`,
// so this stays inert (a subtle grey pill) and never opens a listener.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/connection_status.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extra top offset applied ONLY in debug, so the pill clears the top-stacked
/// BackendDebugBadge (which lives at padding.top + 4). Zero in release — the
/// badge is gone and the pill owns the top.
const double kConnectionIndicatorDebugDrop = 44;

/// The always-on connection pill. Drop this straight into a [Stack] (it returns
/// a [Positioned]); the MaterialApp.builder Stack is its home.
class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);

    // Pill content + colours per honest state.
    final Color bg;
    final String label;
    switch (status) {
      case ConnectionStatus.connected:
        bg = BsTokens.success;
        label = '🟢 מחובר לשרת';
      case ConnectionStatus.disconnected:
        bg = BsTokens.danger;
        label = '🔴 מנותק · פעולות לא יישמרו';
      case ConnectionStatus.demo:
        // Neutral grey — there is no real server to claim connection to.
        // §W0-followup: warm grey (was chainSlate, a COOL blue-grey from the
        // data-viz palette that clashed with the warm light theme).
        bg = BsTokens.mutedLight;
        label = 'מצב דמו';
    }

    // disconnected is the loud one (it's a data-loss warning); connected/demo
    // stay small + subtly translucent so the always-on pill is unobtrusive.
    final prominent = status == ConnectionStatus.disconnected;

    return Positioned(
      top: MediaQuery.of(context).padding.top +
          4 +
          (kDebugMode ? kConnectionIndicatorDebugDrop : 0),
      left: 8,
      right: 8,
      child: IgnorePointer(
        // Status only — it must never swallow taps meant for the screen below
        // (e.g. the BS dial / role-picker logo under RTL topCenter).
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: BsTokens.microIn,
            padding: EdgeInsets.symmetric(
              horizontal: prominent ? 12 : 10,
              vertical: prominent ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: prominent ? bg : bg.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              boxShadow: BsTokens.labelShadow,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: prominent ? FontWeight.w800 : FontWeight.w700,
                fontSize: prominent ? BsTokens.typeMicro : BsTokens.typeCaption,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
