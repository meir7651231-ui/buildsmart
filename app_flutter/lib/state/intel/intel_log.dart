import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pillar-3 STUDIO · step 88 — the customer-intelligence ring buffer.
///
/// A bounded, in-memory log of [IntelEvent]s that drives BOTH the demo and the
/// on-device live feed / KPI tiles (steps 96, 98). It clones the proven trim
/// invariant of `AnalyticsLogNotifier` (`lib/state/analytics_log.dart:33-38`):
/// every [record] prepends the new event to the FRONT (newest-first) and, once
/// the length exceeds [cap], sublists back down to [cap] — so the OLDEST events
/// fall off and memory stays bounded no matter how long the app runs.
///
/// ── IN-MEMORY ONLY · NEVER PERSISTED (R1 privacy invariant) ───────────────
/// This buffer lives ONLY in RAM. It is NEVER written to disk, NEVER saved to
/// any on-device key-value store, and NEVER forwarded to Firestore. There is NO
/// storage layer here ON PURPOSE: an [IntelEvent] may carry a sensitive
/// [IntelEvent.displayName] (PII) plus rich [IntelEvent.props], none of which
/// may ever land in durable storage from this primitive. Do NOT add a storage
/// import or a durable-write call to this file. The ONLY forwarding path off
/// the device is the consent-gated, displayName-stripped sink (step 90), which
/// serialises via [IntelEvent.toWire] — never from this buffer. [clear] drops
/// the whole thing for the "delete local history" button and the erasure sweep
/// (step 99); there is nothing to flush because nothing was ever saved.
///
/// PURE DART. No Firebase, no widgets. Dormant until step 89 wires the bus.
class IntelLogNotifier extends StateNotifier<List<IntelEvent>> {
  IntelLogNotifier({this.cap = 1000}) : super(const <IntelEvent>[]);

  /// Hard upper bound on retained events. Once exceeded, [record] trims the
  /// OLDEST away. Defaults to ~1000 — ample for a live feed / funnel window
  /// while keeping the on-device footprint bounded.
  final int cap;

  /// Append [e] to the FRONT (newest-first) and trim to [cap].
  ///
  /// Cloned from `analytics_log.dart:33-38`: build `[e, ...state]`, then sublist
  /// back to [cap] only on the overflow path. The prepend is amortised O(1); the
  /// sublist copy runs only when the buffer is already full, so steady-state
  /// recording stays cheap.
  void record(IntelEvent e) {
    final next = <IntelEvent>[e, ...state];
    if (next.length > cap) {
      state = next.sublist(0, cap);
    } else {
      state = next;
    }
  }

  /// The recent slice of the buffer, newest-first (§6). Both filters are
  /// optional and compose:
  ///   * [name] — keep only events whose [IntelEvent.name] equals it;
  ///   * [since] — keep only events that occurred strictly AFTER this instant.
  /// [state] is already newest-first and `where` preserves order, so the result
  /// stays newest-first. Returned unmodifiable so a caller can never mutate the
  /// live buffer through it.
  List<IntelEvent> recent({String? name, DateTime? since}) {
    final window = state.where(
      (e) =>
          (since == null || e.at.isAfter(since)) &&
          (name == null || e.name == name),
    );
    return List<IntelEvent>.unmodifiable(window);
  }

  /// Histogram of event counts keyed by [IntelEvent.name] — a single pass over
  /// the buffer that feeds every KPI tile at once (§10) instead of re-scanning
  /// per tile. A name absent from the buffer is absent from the map (not zero).
  Map<String, int> countByName() {
    final counts = <String, int>{};
    for (final e in state) {
      counts[e.name] = (counts[e.name] ?? 0) + 1;
    }
    return counts;
  }

  /// Drop the entire buffer (§9) — backs the "delete local history" button and
  /// the erasure sweep (step 99). Nothing to flush: it was never persisted.
  void clear() {
    state = const <IntelEvent>[];
  }
}

/// The in-memory intel buffer. The bus (step 89) reads this notifier to [record]
/// every tracked event; the live feed / KPI tiles (steps 96, 98) watch its list.
/// Holds NO durable state — see [IntelLogNotifier]'s never-persisted invariant.
final intelLogProvider =
    StateNotifierProvider<IntelLogNotifier, List<IntelEvent>>(
  (_) => IntelLogNotifier(),
);
