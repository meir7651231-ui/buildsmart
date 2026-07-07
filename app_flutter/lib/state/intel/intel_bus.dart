// ─────────────────────────────────────────────────────────────────────────────
// intel_bus — Pillar-3 STUDIO · step 89 — the ONE seam a screen touches.
//
// `track(name, props)` is the single call an instrumented screen (step 92)
// makes. It fans OUT to three independent destinations, each guarded on its
// own, and it NEVER surfaces a failure to the caller — a screen must never
// crash because of analytics:
//
//   (1) intelLogProvider.notifier.record(...)  — the local in-memory ring
//       buffer (step 88). ALWAYS. Drives the demo + the on-device live feed.
//   (2) telemetryProvider.logEvent(...)        — the G4 external seam
//       (telemetry.dart:47). A pure NO-OP without Firebase → zero regression
//       on the demo path.
//   (3) intelSinkProvider.enqueue(...)         — the forward-sink seam. INERT
//       today (NoopIntelSink); step 90 swaps in the consent-gated batched sink.
//
// DISCIPLINE (mirrors FirebaseTelemetrySink, telemetry.dart:110-123):
//   * READ, never subscribe: every provider touch is `_ref.read` — a bus that
//     subscribed would rebuild / jank. There is ZERO reactive subscription in
//     this file (grep-guarded by the test + the §8 DoD).
//   * Fire-and-forget, never re-raise: the whole fan-out is wrapped so any
//     internal failure is swallowed (debugPrint at most) and the caller always
//     returns normally — the same guarded spirit as FirebaseTelemetrySink.
//
// DORMANT: no screen calls track() yet (step 92 wires the call-sites), so this
// bus is inert on the demo path — additive, zero new behavior today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/intel/consent_gate.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:buildsmart/state/intel/intel_sink.dart';
import 'package:buildsmart/state/telemetry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The forward-sink SEAM the bus fans out to as destination (3). Defined here in
/// step 89 as an INERT one-method port; step 90 fills it with the real
/// consent-gated, batched, displayName-stripped sink and overrides
/// [intelSinkProvider]. Kept a tiny port so the bus stays decoupled from the
/// (future) batching machinery.
///
/// A deliberate injectable seam (NoopIntelSink today, the step-90 batched sink
/// tomorrow), NOT an accidental one-method class — hence the lint suppression.
// ignore: one_member_abstracts
abstract class IntelSink {
  /// Hand one event to the forward path. Contract: return immediately and never
  /// re-raise — an implementation is itself non-blocking and swallows its own
  /// failures (the bus additionally wraps this call in its own guard).
  void enqueue(IntelEvent e);
}

/// The default forward sink: a pure no-op. This is what every Firebase-free run
/// (the whole test suite, the demo build) gets, so destination (3) is inert and
/// the bus behaves byte-for-byte as if no forward path existed. Step 90 swaps
/// the [intelSinkProvider] impl for the live batched sink.
class NoopIntelSink implements IntelSink {
  const NoopIntelSink();

  @override
  void enqueue(IntelEvent e) {}
}

/// The forward sink — the CONSENT + BACKEND DOUBLE-GATE (step 90, R1-1). It is
/// the live [FirestoreIntelSink] ONLY when [analyticsForwardEnabled] holds — a
/// PERSISTED consent VERSION (`consentedPolicyVersion >= kCurrentPolicyVersion`,
/// not a floating bool) AND the live Firebase backend (`useFirebaseBackend`) AND
/// the `kIntelLive` master switch. Off ANY axis (every demo / test / off-backend
/// build) it is the inert [NoopIntelSink] — so NOTHING here touches a platform
/// channel, opens a timer, or resolves `FirebaseFirestore.instance`; the forward
/// path is byte-identical to no-forward-at-all (the connection_status.dart:82
/// inert idiom, as non-construction).
///
/// `ref.read` (never `.watch`) — this gate has no reactive consumer (the bus
/// READS it per-`track`), so a read keeps the whole `intel_bus.dart` file
/// subscription-free (the §8 grep guard) while still evaluating the gate on first
/// use. `ref.onDispose` cancels the live sink's flush timer.
final intelSinkProvider = Provider<IntelSink>((ref) {
  final settings = ref.read(appSettingsProvider);
  if (!analyticsForwardEnabled(settings)) return const NoopIntelSink();
  final sink = FirestoreIntelSink(writer: const FirestoreIntelBatchWriter());
  ref.onDispose(sink.dispose);
  return sink;
});

/// The ONE thing a screen touches. See the file header for the 3-way fan-out and
/// the never-re-raise discipline.
class IntelBus {
  IntelBus(this._ref);

  final Ref _ref;

  /// §9 — the minimum spacing between two high-frequency events of the SAME
  /// name, so a chatty screen cannot flood the ring buffer. Simple + pure.
  static const Duration _minInterval = Duration(seconds: 1);

  /// The names subject to the §9 min-interval throttle: only the two
  /// high-frequency signals. Every conversion / funnel event is always recorded.
  static const Set<String> _throttled = <String>{
    IntelEvents.screenView,
    IntelEvents.sessionHeartbeat,
  };

  /// Per-name last-emitted wall-clock, consulted only for [_throttled] names.
  final Map<String, DateTime> _lastEmittedAt = <String, DateTime>{};

  /// Record one intel event. [name] is an `IntelEvents` constant; [props] is a
  /// small scalar map — the call-site passes ONLY name + props, [_context]
  /// stamps every other dimension. Fans out to all three destinations and NEVER
  /// re-raises: a screen keeps working even if analytics is broken.
  void track(
    String name, {
    Map<String, String> props = const <String, String>{},
  }) {
    try {
      // §9 — drop over-frequent screen_view / session_heartbeat entirely so the
      // buffer is not flooded; every other name is always let through.
      if (_isThrottled(name)) return;

      final event = _context(name, props);

      // (1) local ring buffer — ALWAYS (drives demo + live feed).
      _ref.read(intelLogProvider.notifier).record(event);

      // (2) external telemetry seam — no-op without Firebase (zero regression).
      _ref.read(telemetryProvider).logEvent(name, params: props);

      // (3) forward sink — inert (NoopIntelSink) today; step 90 makes it live.
      _ref.read(intelSinkProvider).enqueue(event);
    } on Object catch (e) {
      // Screen-safety: analytics must never take down the UI. Any failure from
      // any destination is swallowed here (debugPrint at most); the caller
      // always returns normally.
      debugPrint('IntelBus.track ignored: $e');
    }
  }

  /// Build the [IntelEvent] for [name] + [props], stamping `at` now and the
  /// dimensions the bus can resolve today. actorKey / uid / sessionId / screen
  /// are left null ON PURPOSE — step 91 fills actorKey, step 97 sessionId, step
  /// 92 screen. The call-site never constructs an [IntelEvent] itself.
  IntelEvent _context(String name, Map<String, String> props) =>
      IntelEvent(name: name, at: DateTime.now(), props: props);

  /// True when [name] is a throttled high-frequency signal that fired more
  /// recently than [_minInterval] ago (so [track] drops it). Records the
  /// pass-through stamp as a side effect. Non-throttled names never throttle.
  bool _isThrottled(String name) {
    if (!_throttled.contains(name)) return false;
    final now = DateTime.now();
    final last = _lastEmittedAt[name];
    if (last != null && now.difference(last) < _minInterval) return true;
    _lastEmittedAt[name] = now;
    return false;
  }
}

/// The bus provider — the ONE thing a screen reads to [IntelBus.track]. Dormant
/// until step 92 wires the call-sites. Reads (never subscribes) its
/// dependencies, so nothing here ever rebuilds.
final intelBusProvider = Provider<IntelBus>(IntelBus.new);
