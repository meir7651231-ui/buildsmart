// ─────────────────────────────────────────────────────────────────────────────
// presence — Pillar-3 STUDIO · step 97 — the heartbeat PRESENCE ("who is online
// NOW"), the most privacy-sensitive intel signal, INERT in demo.
//
// THE SHAPE (R1-4 · R1-5): while a CUSTOMER session is live AND the presence
// double-gate holds ([presenceForwardEnabled], consent_gate.dart), the tracker
// re-writes ONE keyed doc `presence/{actorKey}` once per [kHeartbeat] carrying
// ONLY the pseudonymous `actorKey` / `uid` + the `screen` label + a server
// `lastBeat` + `expireAt = serverTs + kPresenceTtl` (MINUTES). NEVER a human name
// / PII — the [PresenceWriter] port has NO such parameter BY CONSTRUCTION, so PII
// physically cannot reach the wire.
//
// LIVENESS BY FRESHNESS (§4): a peer is LIVE only while `now - lastBeat <
// kHeartbeat * 2.5` ([presenceLive]) — a 2.5× tolerance for one dropped beat, NOT
// mere doc-existence (a stuck tab whose beats stopped is correctly "offline").
//
// INERT OFF-BACKEND (the connection_status.dart:82 `if (!_active) return;` idiom,
// expressed here as NON-CONSTRUCTION): the writer provider yields the const
// [NoopPresenceWriter] off-backend / non-customer / pre-consent, and the session
// tracker starts NO [Presence] at all behind the gate — ZERO timer, ZERO
// Firestore, ZERO platform channel on the demo/test path.
//
// FIREBASE-FREE: the Firestore SDK is ISOLATED to the [FirestorePresenceWriter]
// impl in intel_sink.dart (this file defines only the neutral port), exactly as
// actor_key.dart routes its stitch write through intel_sink.dart's writer.
// session_end (paused / idle / logout) DELETES the doc immediately — never relies
// on TTL alone.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:buildsmart/logic/intel/intel_config.dart'
    show kHeartbeat, kPresenceTtl;
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/auth_state.dart' show roleProvider;
import 'package:buildsmart/state/intel/consent_gate.dart'
    show presenceForwardEnabled;
import 'package:buildsmart/state/intel/intel_sink.dart'
    show FirestorePresenceWriter;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The tiny presence-write PORT the heartbeat forwards through. It speaks ONLY
/// neutral scalars — `actorKey` / `screen` / `ttl` / optional `uid` — NOT Firestore
/// types and (deliberately) NO `displayName` parameter, so this file stays
/// Firebase-free AND PII physically cannot travel (R1-4). Only
/// [FirestorePresenceWriter] (intel_sink.dart) speaks the live Firestore SDK. A
/// failure THROWS ([Presence] swallows it — screen-safety).
abstract class PresenceWriter {
  /// Merge-write / refresh `presence/{actorKey}` = {actorKey, uid?, screen,
  /// lastBeat: serverTs, expireAt: serverTs + `ttl`}. Called ONLY behind the
  /// presence double-gate (customer-only).
  Future<void> upsert({
    required String actorKey,
    required String screen,
    required Duration ttl,
    String? uid,
  });

  /// DELETE `presence/{actorKey}` on session_end — immediate, never TTL-only.
  Future<void> remove({required String actorKey});
}

/// The inert presence writer — writes NOTHING. This is what every off-backend /
/// non-customer / pre-consent / demo / test build gets (the gate below yields it),
/// so `presence/{actorKey}` is NEVER touched there (§4 / DoD).
class NoopPresenceWriter implements PresenceWriter {
  /// Const so the gate can return it without allocating.
  const NoopPresenceWriter();

  @override
  Future<void> upsert({
    required String actorKey,
    required String screen,
    required Duration ttl,
    String? uid,
  }) async {}

  @override
  Future<void> remove({required String actorKey}) async {}
}

/// The heartbeat CONTROLLER — a pure Dart object (no widgets, no Firebase) owned
/// by the session tracker (session_tracker.dart) and constructed ONLY behind the
/// presence double-gate. It beats ONCE immediately on [start] (so a live tab
/// appears fast) then every `heartbeat`; [stop] (session_end) cancels the timer
/// AND deletes the doc. All writes are fire-and-forget + guarded — a failed beat
/// never crashes a screen (the firestore_cached_repo.dart guardWrite discipline).
class Presence {
  /// [screenOf] resolves the CURRENT screen key at beat time (read, not captured,
  /// so the doc reflects where the user is now). [heartbeat] / [ttl] are injectable
  /// for a deterministic test; they default to the [kHeartbeat] / [kPresenceTtl]
  /// config.
  Presence(
    this._writer, {
    required this.actorKey,
    required String Function() screenOf,
    this.uid,
    Duration heartbeat = kHeartbeat,
    Duration ttl = kPresenceTtl,
  })  : _screenOf = screenOf,
        _heartbeat = heartbeat,
        _ttl = ttl;

  final PresenceWriter _writer;

  /// The pseudonymous actor key — the doc id + the erasure-sweep join key.
  final String actorKey;

  /// The Firebase uid when signed-in, else null (an anon customer). Pseudonymous.
  final String? uid;

  final String Function() _screenOf;
  final Duration _heartbeat;
  final Duration _ttl;

  Timer? _timer;
  bool _started = false;
  bool _stopped = false;

  /// @visibleForTesting — true while the heartbeat timer is armed (proves INERT).
  @visibleForTesting
  bool get isBeating => _timer != null;

  /// Begin beating: one immediate beat, then a [Timer.periodic] every [_heartbeat].
  /// Idempotent — a second [start] is a no-op.
  void start() {
    if (_started) return;
    _started = true;
    _beat();
    _timer = Timer.periodic(_heartbeat, (_) => _beat());
  }

  void _beat() => unawaited(
        _guard(
          () => _writer.upsert(
            actorKey: actorKey,
            uid: uid,
            screen: _screenOf(),
            ttl: _ttl,
          ),
        ),
      );

  /// session_end (paused / idle / logout): cancel the timer AND DELETE the doc
  /// immediately — never rely on TTL alone (§4). Idempotent: a second [stop] (e.g.
  /// session_end THEN dispose) never re-deletes.
  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    _timer?.cancel();
    _timer = null;
    await _guard(() => _writer.remove(actorKey: actorKey));
  }

  Future<void> _guard(Future<void> Function() op) async {
    try {
      await op();
    } on Object catch (e) {
      // guardWrite: a failed presence write degrades silently, never crashes.
      debugPrint('Presence: write ignored: $e');
    }
  }
}

/// LIVENESS — freshness, NOT doc-existence (§4): a peer is LIVE only while its
/// last beat is younger than [heartbeat] `* 2.5` (a 2.5× tolerance so a single
/// dropped beat does not flip it offline). [now] is INJECTED (never the wall
/// clock) so a manager read is deterministic and a client cannot fake freshness.
bool presenceLive(
  DateTime now,
  DateTime lastBeat, {
  Duration heartbeat = kHeartbeat,
}) =>
    now.difference(lastBeat) < heartbeat * 2.5;

/// The presence-writer DOUBLE-GATE (customer-only) — the [FirestorePresenceWriter]
/// ONLY when [presenceForwardEnabled] holds (own-axis consent + current version +
/// live backend + `kIntelLive` + customer role). Off ANY axis (every demo / test /
/// off-backend / worker / courier build) it is the inert [NoopPresenceWriter], so
/// nothing here touches a platform channel or resolves `FirebaseFirestore.instance`
/// (the connection_status.dart:82 inert idiom, as non-construction). `ref.read` —
/// no reactive consumer (the tracker reads it once per session start).
final presenceWriterProvider = Provider<PresenceWriter>((ref) {
  final settings = ref.read(appSettingsProvider);
  final role = ref.read(roleProvider);
  if (!presenceForwardEnabled(settings, role)) return const NoopPresenceWriter();
  return const FirestorePresenceWriter();
});
