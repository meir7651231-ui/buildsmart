/// RingDive (צלילת-טבעות) — the rotary product-finder surface (owner design
/// handoff, 6/7). A NEW PRESENTATION of the SAME `card_engine` drill-down the
/// smart keyboard renders: the axis options ride a spinning knurled dial; a tap
/// on the center hub "dives" one axis deeper; after ≤6 dives it lands on a
/// single product → quantity → cart. The engine is UNCHANGED — the dial only
/// renders `mergedKeys`'s chips and feeds a chosen chip back as a `NewbieStep`.
///
/// GATED on [kRingDiveFlag] (runtime) — force-enabled for a demo build via
/// `--dart-define=ENABLE_RING_DIVE=true` (`kEnableRingDiveDemo`). OFF by default
/// → renders a zero-height `SizedBox.shrink()` → byte-identical to before, so
/// this file is safe to land dark while the dial is built phase-by-phase.
///
/// PHASE 0 (this): the flag gate + the mounted skeleton (the 320×320 wheel box).
/// Phases 1-3 fill the CustomPainter dial (disc / knurled pads / locked rings /
/// curved labels) + the drag/snap interaction; Phase 4 wires it to `mergedKeys`;
/// Phases 5-6 the qty/cart flow + results footer; Phase 7 the swap seam that
/// makes the smart-keyboard entry open the dial when the flag is on. See
/// BUILD-PLAN.md for the full ladder + the shared-engine wiring notes.
library;

import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Design tokens shared across the dial phases (from the handoff README). Kept
/// here so the CustomPainter (Phase 1) and the hub/labels reference ONE source.
class RingDiveTokens {
  const RingDiveTokens._();

  /// Brand orange (primary) — already the app's brand, so the dial matches.
  static const Color brand = Color(0xFFFF7A18);
  static const Color brandPressed = Color(0xFFF0710C);
  static const Color ink = Color(0xFF1B1B1A);
  static const Color muted = Color(0xFF8C8578);

  /// The design wheel container (320) and the active dial box (236) inside it.
  static const double wheelBox = 320;
  static const double dialBox = 236;
}

/// The RingDive surface. Renders nothing until [kRingDiveFlag] is enabled, so it
/// is safe to embed anywhere (the swap seam, Phase 7) while still dark.
class RingDiveScreen extends ConsumerWidget {
  const RingDiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(featureFlagsProvider).contains(kRingDiveFlag);
    if (!on) return const SizedBox.shrink();
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: _RingDiveSkeleton(),
    );
  }
}

/// Phase-0 placeholder: the wheel container the CustomPainter dial (Phase 1)
/// fills. Present only so the flag-ON path is mountable + testable now.
class _RingDiveSkeleton extends StatelessWidget {
  const _RingDiveSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: RingDiveTokens.wheelBox,
        height: RingDiveTokens.wheelBox,
        child: Center(
          child: Text(
            'צלילת-טבעות',
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: RingDiveTokens.ink,
            ),
          ),
        ),
      ),
    );
  }
}
