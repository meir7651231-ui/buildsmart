/// RingDive (צלילת-טבעות) — the rotary product-finder surface (owner design
/// handoff, 6/7). A NEW PRESENTATION of the SAME `card_engine` drill-down the
/// smart keyboard renders: the axis options ride a spinning knurled dial; a tap
/// on the center hub "dives" one axis deeper; after ≤6 dives it lands on a
/// single product → quantity → cart. The engine is UNCHANGED — the dial only
/// renders `mergedKeys`'s chips and feeds a chosen chip back as a `NewbieStep`.
///
/// GATED on `kRingDiveFlag` (runtime) — force-enabled for a demo build via
/// `--dart-define=ENABLE_RING_DIVE=true` (`kEnableRingDiveDemo`). OFF by default
/// → renders a zero-height `SizedBox.shrink()` → byte-identical to before, so
/// this file is safe to land dark while the dial is built phase-by-phase.
///
/// PHASE 1 (this): the flag gate + the static [RingDiveDial] (disc / knurled
/// pads / center groove / 12:00 pointer). Phases 2-3 add curved labels +
/// drag/snap; Phase 4 wires it to `mergedKeys`; Phases 5-6 the qty/cart flow +
/// results footer; Phase 7 the swap seam. See BUILD-PLAN.md.
library;

import 'package:buildsmart/features/ring_dive/ring_dive_dial.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The RingDive surface. Renders nothing until `kRingDiveFlag` is enabled, so it
/// is safe to embed anywhere (the swap seam, Phase 7) while still dark.
class RingDiveScreen extends ConsumerWidget {
  const RingDiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(featureFlagsProvider).contains(kRingDiveFlag);
    if (!on) return const SizedBox.shrink();
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: RingDiveDial(
          // P2 preview options — replaced by the engine's live chips in P4.
          labels: <String>['ברז', 'מחסום', 'צינור', 'ברך', 'מסנן', 'שסתום'],
        ),
      ),
    );
  }
}
