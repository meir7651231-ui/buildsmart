// ─────────────────────────────────────────────────────────────────────────────
// AnalyticsRepository — Studio Pillar 5 · Step 67 (R1-3 canonical, analytics half).
//
// WHAT THIS IS: the WRITE-ONLY analytics event append. A call-site logs an event;
// the repo (a) records it into the in-app 500-ring buffer (`state/analytics_log.dart`,
// step 91 — the offline buffer the detail names) and (b) fire-and-forgets a create
// into the `analyticsEvents` collection. The write is create-AS-SELF: the event map
// carries `uid == auth.uid`, exactly what the Step-65 rule allows
// (`request.resource.data.uid == request.auth.uid`); events are IMMUTABLE + manager-
// read (no update/delete from any client), and the daily rollup (analytics.ts) sums
// them server-side. NOTHING here reads analytics back — reads are the owner's
// server-rolled `analyticsDaily`/`presenceSummary` docs, never the raw stream (R1-3).
//
// NEVER THROWS (fire-and-forget): an analytics blip must never break a business
// flow, so every append is guarded (the `guardWrite` spirit,
// `firestore_cached_repo.dart:344`) — a failure is swallowed+logged, the event stays
// BUFFERED, and [flushPending] retries it on reconnect (the §6 coalescing flush).
// The retry ring is BOUNDED (drop-oldest, §10b): a long offline spell can never grow
// memory without bound.
//
// DORMANT / byte-identical when OFF (no writes when OFF): [analyticsRepositoryProvider]
// returns the [NoopAnalyticsRepository] unless BOTH `kStudioLive` AND the live backend
// are on (`kStudioLive && useFirebaseBackend`, both OFF by default) — the
// `telemetry.dart` NoopTelemetrySink posture. NOTHING wires this yet, so the shipped
// build is byte-identical by NON-CONSUMPTION. Even the ON branch is DORMANT until the
// real Firestore adapter lands: the [AnalyticsEventSink] port is null here, so
// `logEvent` only fills the in-app ring (NO server write) until a later wiring step
// supplies it — the search_firebase.dart "null index → degrade" idiom.
//
// FIREBASE-FREE by construction: this file imports NO `cloud_firestore`. The append
// reaches Firestore only through the NEUTRAL [AnalyticsEventSink] port, whose real
// adapter (the one file allowed to touch `cloud_firestore`) lands in a later wiring
// step — so this seam file, and the hand-rolled-fake test that drives it, need no
// Firebase.
//
// Comment density/voice mirrors `telemetry.dart` / `search_firebase.dart`.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async' show unawaited;

import 'package:buildsmart/data/repositories/backend.dart'
    show kStudioLive, useFirebaseBackend;
import 'package:buildsmart/state/analytics_log.dart'
    show AnalyticsLogNotifier, analyticsLogProvider;
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The default cap on the retry ring — the same 500 as the in-app
/// `AnalyticsLogNotifier` buffer, so a long offline spell holds at most this many
/// unacked events before the OLDEST is dropped (§10b).
const int kMaxPendingAnalyticsEvents = 500;

/// The NEUTRAL append WRITE port — one question: create one immutable
/// `analyticsEvents` doc. The real adapter (DORMANT — a later wiring step, inside a
/// `*_firebase` adapter, the only file allowed to import `cloud_firestore`) does an
/// `add`/`set` of the event map; the map MUST carry `uid == auth.uid` (the Step-65
/// create-as-self rule), which the repo stamps.
// A deliberate one-member seam — an event append answers exactly one question.
// ignore: one_member_abstracts
abstract class AnalyticsEventSink {
  Future<void> append(Map<String, dynamic> event);
}

/// The write-only analytics surface. Records to the in-app ring AND fire-and-forgets
/// a server append; NEVER throws.
abstract class AnalyticsRepository {
  /// Record + forward one event. Buffers to the in-app ring always; appends to the
  /// server when live. A write failure is swallowed (the event stays buffered).
  void logEvent(String name, {Map<String, String> props = const {}});

  /// Retry the BUFFERED (unacked) events — the coalescing flush on reconnect (§6).
  /// Guarded per event; stops at the first still-failing write (still offline).
  Future<void> flushPending();

  /// Events still awaiting a successful server append (tests / a "syncing" chip).
  int get pendingCount;
}

/// The OFF / dormant default — a pure no-op (the `telemetry.dart` NoopTelemetrySink
/// posture). Every Firebase-free run + flags-OFF build gets this, so behaviour is
/// byte-for-byte as before.
class NoopAnalyticsRepository implements AnalyticsRepository {
  const NoopAnalyticsRepository();

  @override
  void logEvent(String name, {Map<String, String> props = const {}}) {}

  @override
  Future<void> flushPending() async {}

  @override
  int get pendingCount => 0;
}

/// The live implementation. Buffers every event to the in-app ring, stamps it
/// create-as-self, and fire-and-forgets a guarded append; unacked events queue in a
/// bounded retry ring for [flushPending]. DORMANT until the real port is wired: a
/// null [AnalyticsEventSink] fills only the in-app ring (no server write), so a
/// premature flag-flip is honest, never a crash.
class FirebaseAnalyticsRepository implements AnalyticsRepository {
  FirebaseAnalyticsRepository({
    required this.uid,
    AnalyticsEventSink? sink,
    AnalyticsLogNotifier? log,
    int maxPending = kMaxPendingAnalyticsEvents,
    int Function() nowMs = _epochNow,
  })  : assert(maxPending > 0, 'the retry ring must hold at least one event'),
        _sink = sink,
        _log = log,
        _maxPending = maxPending,
        _now = nowMs;

  /// The signed-in uid stamped on every event (`uid == auth.uid`, the create-as-self
  /// rule). Empty ⇒ no server append (the rule would deny a spoofed/absent actor).
  final String uid;

  final AnalyticsEventSink? _sink;
  final AnalyticsLogNotifier? _log;
  final int _maxPending;
  final int Function() _now;

  /// The bounded retry ring of events not yet server-acked (drop-oldest, §10b).
  final List<Map<String, dynamic>> _pending = <Map<String, dynamic>>[];

  static int _epochNow() => DateTime.now().millisecondsSinceEpoch;

  @override
  int get pendingCount => _pending.length;

  @override
  void logEvent(String name, {Map<String, String> props = const {}}) {
    // 1) the in-app 500-ring buffer — ALWAYS, offline-safe, the detail's buffer.
    _log?.record(name, props: props);
    final sink = _sink;
    if (sink == null || uid.isEmpty) return; // dormant / no self-scope → buffer only
    // 2) stamp create-as-self, enqueue for at-least-once delivery, fire the append.
    final event = _event(name, props);
    _enqueue(event);
    unawaited(_append(sink, event));
  }

  Map<String, dynamic> _event(String name, Map<String, String> props) =>
      <String, dynamic>{
        'uid': uid, // create-as-self (Step-65 rule)
        'name': name,
        'at': _now(), // epoch ms
        if (props.isNotEmpty) 'props': props,
      };

  void _enqueue(Map<String, dynamic> event) {
    _pending.add(event);
    // Bounded — drop the OLDEST so an offline spell can't grow memory (§10b).
    while (_pending.length > _maxPending) {
      _pending.removeAt(0);
    }
  }

  /// Guarded background append (the `guardWrite` spirit): a failure is swallowed and
  /// the event STAYS in [_pending] for the next [flushPending]; success drops it.
  Future<void> _append(AnalyticsEventSink sink, Map<String, dynamic> event) async {
    try {
      await sink.append(event);
      _pending.remove(event); // acked → drop from the retry ring (identity match)
    } on Object catch (e) {
      debugPrint('FirebaseAnalyticsRepository: append failed (buffered): $e');
    }
  }

  @override
  Future<void> flushPending() async {
    final sink = _sink;
    if (sink == null || uid.isEmpty) return;
    // Snapshot the queue so a concurrent logEvent doesn't mutate what we iterate.
    final batch = List<Map<String, dynamic>>.of(_pending);
    for (final event in batch) {
      try {
        await sink.append(event);
        _pending.remove(event);
      } on Object catch (e) {
        // Still offline — keep this (and the rest) buffered; retry next reconnect.
        debugPrint('FirebaseAnalyticsRepository: flush retry failed (kept): $e');
        break;
      }
    }
  }
}

/// The analytics repository provider — DORMANT until `kStudioLive && useFirebaseBackend`
/// (both OFF by default → [NoopAnalyticsRepository], byte-identical + no writes). A
/// `Provider` is lazy: until a consumer reads it, it is never even constructed.
/// Mirrors `searchRepositoryProvider` / `telemetryProvider` with the extra Studio-live
/// gate. Even ON, the sink is null (the real `cloud_firestore` `analyticsEvents`
/// adapter lands in a later wiring step) — so `logEvent` only fills the in-app ring
/// until then; no server write happens prematurely.
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  if (!(kStudioLive && useFirebaseBackend)) {
    return const NoopAnalyticsRepository();
  }
  final uid = ref.watch(currentUidProvider) ?? '';
  return FirebaseAnalyticsRepository(
    uid: uid,
    log: ref.watch(analyticsLogProvider.notifier),
    // sink: the real cloud_firestore analyticsEvents adapter is deferred to a
    // later wiring step (the only file allowed to import cloud_firestore).
  );
});
