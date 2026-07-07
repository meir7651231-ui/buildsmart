// ─────────────────────────────────────────────────────────────────────────────
// PresenceRepository — Studio Pillar 5 · Step 67 (R1-3 / R2-12 canonical).
//
// WHAT THIS IS: the WRITE-ONLY presence heartbeat + the owner's SINGLE-DOC read of
// the server-rolled online summary. Two halves, both cheap-right:
//   • EVERY client writes ONLY its own `presence/{uid}` heartbeat (self-scoped,
//     fire-and-forget). The doc it writes matches the Step-66 seam contract EXACTLY
//     — `{ role: string, lastSeen: number /* epoch ms */ }` — nothing else.
//   • The OWNER dashboard reads the ONE server-rolled `presenceSummary/current` doc
//     (step 66) — it NEVER opens a listener over the `presence/*` collection. That
//     is the R1-3 rule: O(users) reads, not O(users × owners), and no "who's
//     online" collection leak. This seam offers NO way to list/stream `presence/*`
//     — the absence is the guarantee.
//
// ⚠️ DETAIL-vs-SEAM RECONCILIATION (the detail predates the Step-66 seam contract):
// the step-67 detail says "write `online:false` in `dispose`/`AppLifecycleState.
// paused`". The LANDED Step-66 presence contract has NO `online` field — a client's
// liveness is its `lastSeen` freshness, and the server rollup (analytics.ts
// `summarizePresence`, `kPresenceStaleMs = 120_000`) EXCLUDES a ghost whose
// `lastSeen` is older than 2 min. So "go offline" here is simply CEASING to
// heartbeat ([goOffline] stops the writes); the server ages the silent client out.
// Writing a non-existent `online:false` field would be dead data the rollup ignores.
//
// R2-12 STALENESS (never a stale count shown as live): [presenceStatusFor] is a PURE
// verdict the owner UI renders — it compares `now − presenceSummary.updatedAt` to
// [kPresenceStaleThreshold]; past it the dashboard shows "לא-זמין" (unavailable),
// within it "עודכן לפני Xs" (updated Xs ago). A missing / never-rolled summary is
// [PresenceFreshness.unknown] → also "unavailable". The count is NEVER labelled live
// when the roll is stale.
//
// DORMANT / byte-identical when OFF (no writes when OFF): [presenceRepositoryProvider]
// returns the [NoopPresenceRepository] unless BOTH `kStudioLive` AND the live backend
// are on (`kStudioLive && useFirebaseBackend`, both OFF by default) — the
// `telemetry.dart` NoopTelemetrySink posture. NOTHING wires this yet, so the shipped
// build is byte-identical by NON-CONSUMPTION. Even the ON branch is DORMANT until the
// real Firestore adapter lands: the ports ([PresenceSink]/[PresenceSummarySource]) are
// null here, so `heartbeat()` no-ops and `summary()` returns null (→ "unavailable")
// until a later wiring step supplies them — exactly the search_firebase.dart "null
// index → degrade" idiom.
//
// FIREBASE-FREE by construction: this file imports NO `cloud_firestore`. The write /
// read reach Firestore only through the NEUTRAL ports, whose real adapter (the one
// file allowed to touch `cloud_firestore`) lands in a later wiring step — so this
// seam file, and the hand-rolled-fake test that drives it, need no Firebase.
//
// Comment density/voice mirrors `telemetry.dart` / `search_firebase.dart`.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async' show unawaited;

import 'package:buildsmart/data/repositories/backend.dart'
    show kStudioLive, useFirebaseBackend;
import 'package:buildsmart/state/auth_state.dart'
    show currentUidProvider, roleProvider;
import 'package:flutter/foundation.dart'
    show debugPrint, immutable, listEquals, mapEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The canonical single summary doc — `presenceSummary/current` (step 66). The
/// owner reads THIS ONE doc, never the `presence/*` collection (R1-3).
const String kPresenceSummaryDocId = 'current';

/// The CLIENT-side staleness threshold for the owner dashboard (R2-12): once the
/// server roll (`presenceSummary.updatedAt`) is older than this, the count is
/// shown as "לא-זמין" (unavailable), never as a live number. Kept just above the
/// server's ~1-min presence-rollup cadence (analytics.ts `kPresenceRollupSchedule`)
/// so a healthy roll always reads fresh, and a stalled rollup surfaces honestly.
const Duration kPresenceStaleThreshold = Duration(seconds: 90);

/// The minimum spacing between two heartbeat writes (§3.4 — debounce ≥30s). A
/// client that fires `heartbeat()` on every route-change/foreground writes at most
/// once per this window, so presence can never become a per-keystroke write flood.
const Duration kHeartbeatMinInterval = Duration(seconds: 30);

/// One rolled presence summary — the neutral value-object the read seam speaks in
/// (the `presenceSummary/current` doc mapped down). Mirrors the server shape the
/// rollup writes (`analytics.ts` `PresenceSummary` + `updatedAt`).
@immutable
class PresenceSummary {
  const PresenceSummary({
    required this.count,
    this.byRole = const {},
    this.sample = const [],
    this.updatedAtMs = 0,
  });

  /// Online clients the server counted (ghosts already excluded server-side).
  final int count;

  /// Online counts grouped by role.
  final Map<String, int> byRole;

  /// A bounded list of online uids — the owner sees WHO from ONE doc.
  final List<String> sample;

  /// Epoch-ms of the server roll (`updatedAt`). `0` = unknown / never rolled →
  /// [PresenceFreshness.unknown] (the dashboard shows "unavailable").
  final int updatedAtMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresenceSummary &&
          other.count == count &&
          other.updatedAtMs == updatedAtMs &&
          mapEquals(other.byRole, byRole) &&
          listEquals(other.sample, sample);

  @override
  int get hashCode => Object.hash(
        count,
        updatedAtMs,
        Object.hashAll(sample),
        Object.hashAllUnordered(byRole.keys),
      );
}

/// The R2-12 freshness verdict for the owner dashboard.
enum PresenceFreshness {
  /// The roll is recent — the count is safe to show as live.
  fresh,

  /// The roll is older than [kPresenceStaleThreshold] — show "לא-זמין".
  stale,

  /// No summary / never rolled (`updatedAt == 0`) — show "לא-זמין".
  unknown,
}

/// The rendered presence status the owner UI reads: the [freshness] verdict, the
/// online [count] (meaningful only when [isFresh]) and the [age] since the roll.
@immutable
class PresenceStatus {
  const PresenceStatus({
    required this.freshness,
    required this.count,
    required this.age,
  });

  final PresenceFreshness freshness;
  final int count;
  final Duration age;

  /// True only when the roll is recent enough to trust the [count] as live.
  bool get isFresh => freshness == PresenceFreshness.fresh;

  /// Whole seconds since the server roll — the "עודכן לפני Xs" number.
  int get secondsAgo => age.inSeconds;
}

/// PURE R2-12 staleness verdict (no I/O — offline-testable, like analytics.ts's
/// `summarizePresence`). Maps a [summary] + the current [nowMs] to a [PresenceStatus]:
///   • null / `updatedAt == 0`            → [PresenceFreshness.unknown]
///   • `now − updatedAt` > [staleAfter]   → [PresenceFreshness.stale]
///   • otherwise                          → [PresenceFreshness.fresh]
/// A negative age (client clock behind the server) is clamped to zero and treated
/// as fresh — a just-rolled doc is never mislabelled stale by skew.
PresenceStatus presenceStatusFor(
  PresenceSummary? summary, {
  required int nowMs,
  Duration staleAfter = kPresenceStaleThreshold,
}) {
  if (summary == null || summary.updatedAtMs <= 0) {
    return const PresenceStatus(
      freshness: PresenceFreshness.unknown,
      count: 0,
      age: Duration.zero,
    );
  }
  final deltaMs = nowMs - summary.updatedAtMs;
  final age = Duration(milliseconds: deltaMs < 0 ? 0 : deltaMs);
  final fresh = age <= staleAfter;
  return PresenceStatus(
    freshness: fresh ? PresenceFreshness.fresh : PresenceFreshness.stale,
    count: summary.count,
    age: age,
  );
}

/// The NEUTRAL heartbeat WRITE port — one question: write the caller's own
/// `presence/{uid}` doc. The real adapter (DORMANT — a later wiring step, inside a
/// `*_firebase` adapter, the only file allowed to import `cloud_firestore`) does a
/// merge `set` of `{role, lastSeen}` (matching the Step-65 self-write rule). Merge
/// so the doc is created-or-updated idempotently by the natural uid key.
// A deliberate one-member seam — a heartbeat answers exactly one question.
// ignore: one_member_abstracts
abstract class PresenceSink {
  Future<void> writeHeartbeat(String uid, Map<String, dynamic> data);
}

/// The NEUTRAL summary READ port — one question: GET the single
/// `presenceSummary/current` doc (R1-3). There is DELIBERATELY no list/stream of
/// `presence/*` here: the owner can only ever read the ONE rolled doc, so the
/// "who's online" collection can never be fanned out to a client.
// A deliberate one-member seam — the owner reads exactly one doc.
// ignore: one_member_abstracts
abstract class PresenceSummarySource {
  /// GET `presenceSummary/current`, or null when missing / never rolled.
  Future<PresenceSummary?> current();
}

/// The write-only presence heartbeat + owner summary-read surface. Reads are the
/// SINGLE rolled doc (never the collection); writes are self-scoped, debounced and
/// fire-and-forget (never thrown).
abstract class PresenceRepository {
  /// Record a liveness heartbeat (call on foreground / route-change). Debounced to
  /// [kHeartbeatMinInterval]; a write failure is swallowed, never thrown.
  void heartbeat();

  /// Stop heartbeating (call on `AppLifecycleState.paused` / dispose). Per the
  /// Step-66 contract there is NO `online:false` write — the server ages a silent
  /// client out as a ghost (`lastSeen` > 120s). See the file header.
  void goOffline();

  /// Resume heartbeating after a [goOffline] (foreground) — the next [heartbeat]
  /// writes immediately (the debounce window is reset).
  void resume();

  /// OWNER: read the single server-rolled `presenceSummary/current` doc (R1-3).
  /// Returns null on any failure (→ "unavailable"); never throws.
  Future<PresenceSummary?> summary();
}

/// The OFF / dormant default — a pure no-op (the `telemetry.dart` NoopTelemetrySink
/// posture). Every Firebase-free run (the whole test suite, the demo build) and
/// every flags-OFF build gets this, so behaviour is byte-for-byte as before.
class NoopPresenceRepository implements PresenceRepository {
  const NoopPresenceRepository();

  @override
  void heartbeat() {}

  @override
  void goOffline() {}

  @override
  void resume() {}

  @override
  Future<PresenceSummary?> summary() async => null;
}

/// The live implementation. Debounced self-scoped heartbeat + single-doc summary
/// read, both guarded so a failure can never surface in the UI. DORMANT until the
/// real ports are wired: a null [PresenceSink] no-ops `heartbeat()` and a null
/// [PresenceSummarySource] makes `summary()` return null — a premature flag-flip is
/// honest (no writes, "unavailable"), never a crash.
class FirebasePresenceRepository implements PresenceRepository {
  FirebasePresenceRepository({
    required this.uid,
    required this.roleOf,
    PresenceSink? sink,
    PresenceSummarySource? summarySource,
    Duration minInterval = kHeartbeatMinInterval,
    int Function() nowMs = _epochNow,
  })  : _sink = sink,
        _summarySource = summarySource,
        _minIntervalMs = minInterval.inMilliseconds,
        _now = nowMs;

  /// The signed-in uid — the `presence/{uid}` doc-id + self-scope. Empty ⇒ no
  /// heartbeat (a self-scoped presence write is impossible without an identity).
  final String uid;

  /// A LATE role read (persona can change between heartbeats) — resolved at each
  /// write so the `role` field always reflects the current persona.
  final String Function() roleOf;

  final PresenceSink? _sink;
  final PresenceSummarySource? _summarySource;
  final int _minIntervalMs;
  final int Function() _now;

  /// Epoch-ms of the last heartbeat write (the debounce anchor). `null` = never
  /// written / just resumed → the next heartbeat writes immediately (the FIRST
  /// heartbeat is never debounced).
  int? _lastWriteMs;

  /// True between [goOffline] and the next [resume] — heartbeats are suppressed.
  bool _offline = false;

  static int _epochNow() => DateTime.now().millisecondsSinceEpoch;

  @override
  void heartbeat() {
    if (_offline) return; // paused — the server ages us out as a ghost
    if (uid.isEmpty) return; // no identity → cannot self-write presence
    final sink = _sink;
    if (sink == null) return; // dormant — no adapter wired yet
    final now = _now();
    final last = _lastWriteMs;
    if (last != null && now - last < _minIntervalMs) return; // debounce ≥30s
    _lastWriteMs = now;
    final role = roleOf();
    // The EXACT Step-66 seam contract — {role, lastSeen}. No `online` field.
    final data = <String, dynamic>{
      'role': role.isEmpty ? 'unknown' : role,
      'lastSeen': now,
    };
    unawaited(_writeHeartbeat(sink, data));
  }

  @override
  void goOffline() {
    _offline = true;
  }

  @override
  void resume() {
    _offline = false;
    _lastWriteMs = null; // let the next heartbeat write immediately
  }

  @override
  Future<PresenceSummary?> summary() async {
    final source = _summarySource;
    if (source == null) return null; // dormant → "unavailable"
    try {
      return await source.current();
    } on Object catch (e) {
      // A read failure must never surface — the owner UI shows "unavailable".
      debugPrint('FirebasePresenceRepository: summary read failed (ignored): $e');
      return null;
    }
  }

  /// The guarded background write — mirrors `FirestoreCachedRepo.guardWrite`
  /// (`firestore_cached_repo.dart:344`): a heartbeat failure is swallowed+logged,
  /// NEVER thrown into the UI.
  Future<void> _writeHeartbeat(
    PresenceSink sink,
    Map<String, dynamic> data,
  ) async {
    try {
      await sink.writeHeartbeat(uid, data);
    } on Object catch (e) {
      debugPrint('FirebasePresenceRepository: heartbeat failed (ignored): $e');
    }
  }
}

/// The presence repository provider — DORMANT until `kStudioLive && useFirebaseBackend`
/// (both OFF by default → [NoopPresenceRepository], byte-identical + no writes). A
/// `Provider` is lazy: until a consumer reads it, it is never even constructed.
/// Mirrors `searchRepositoryProvider` / `telemetryProvider` with the extra Studio-live
/// gate. Even ON, the ports are null (the real `cloud_firestore` adapter lands in a
/// later wiring step) — so `heartbeat()` no-ops and `summary()` reads "unavailable"
/// until then; no writes happen prematurely.
final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  if (!(kStudioLive && useFirebaseBackend)) {
    return const NoopPresenceRepository();
  }
  final uid = ref.watch(currentUidProvider) ?? '';
  final role = ref.watch(roleProvider) ?? 'contractor';
  return FirebasePresenceRepository(
    uid: uid,
    roleOf: () => role,
    // sink / summarySource: the real cloud_firestore adapter is deferred to a
    // later wiring step (the only file allowed to import cloud_firestore).
  );
});
