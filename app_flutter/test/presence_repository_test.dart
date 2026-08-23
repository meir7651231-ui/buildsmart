// Studio Pillar 5 · Step 67 — the write-only presence heartbeat + the owner's
// SINGLE-DOC summary read (`lib/data/repositories/presence_repository.dart`).
//
// Pins the step-67 presence contract (adapted to the CURRENT Step-66 seam — the
// heartbeat doc is `{role, lastSeen}`, NOT `{online}`; the owner reads the ONE
// rolled `presenceSummary/current` doc, never the `presence/*` collection):
//   1. HEARTBEAT SHAPE — a write is exactly `{role, lastSeen: epoch-ms}` and carries
//      NO `online` field (the Step-66 seam contract; ghost-exclusion is server-side).
//   2. DEBOUNCE ≥30s — repeated `heartbeat()` within the window writes ONCE; a write
//      lands again only after the interval elapses (no per-route write flood).
//   3. NEVER THROWS — a failing sink is swallowed; `heartbeat()` returns normally.
//   4. LIFECYCLE — `goOffline()` suppresses heartbeats; `resume()` re-enables (and
//      resets the debounce so the next heartbeat writes immediately).
//   5. DORMANT — empty uid or a null sink writes NOTHING (byte-identical when unwired).
//   6. OWNER READ (R1-3) — `summary()` does a SINGLE `presenceSummary/current` get and
//      NEVER touches the presence collection; a read failure returns null (never throws).
//   7. STALENESS (R2-12) — the PURE `presenceStatusFor` labels fresh / stale / unknown.
//
// NO Firebase here: the write/read seams are driven by HAND-ROLLED fakes (the
// define-less-fake idiom — no fake_cloud_firestore, no new packages, no dart-define).

import 'package:buildsmart/data/repositories/presence_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [PresenceSink]: records every heartbeat `(uid, data)` and can be
/// flipped to FAIL (a rejected future) to prove the guarded write never throws.
class _FakePresenceSink implements PresenceSink {
  final List<String> uids = <String>[];
  final List<Map<String, dynamic>> writes = <Map<String, dynamic>>[];
  bool fail = false;

  @override
  Future<void> writeHeartbeat(String uid, Map<String, dynamic> data) {
    uids.add(uid);
    writes.add(data);
    return fail
        ? Future<void>.error(Exception('offline'))
        : Future<void>.value();
  }
}

/// A hand-rolled [PresenceSummarySource]: answers the SINGLE `current()` get and
/// counts its calls (so the test proves the owner reads ONE doc, not a collection).
class _FakeSummarySource implements PresenceSummarySource {
  _FakeSummarySource(this._summary, {this.fail = false});
  final PresenceSummary? _summary;
  bool fail;
  int currentCalls = 0;

  @override
  Future<PresenceSummary?> current() {
    currentCalls++;
    return fail
        ? Future<PresenceSummary?>.error(Exception('denied'))
        : Future<PresenceSummary?>.value(_summary);
  }
}

/// Let the fire-and-forget guarded futures settle (so a rejected write is handled).
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('heartbeat write — the Step-66 seam contract {role, lastSeen}', () {
    test('writes exactly {role, lastSeen: epoch-ms} — NO `online` field', () {
      final sink = _FakePresenceSink();
      final repo = FirebasePresenceRepository(
        uid: 'u1',
        roleOf: () => 'store',
        sink: sink,
        nowMs: () => 1000,
      );

      repo.heartbeat();

      final data = sink.writes.single;
      expect(data.keys.toSet(), {'role', 'lastSeen'});
      expect(data['role'], 'store');
      expect(data['lastSeen'], 1000);
      // The adaptation this step's detail predates: there is NO `online` field.
      expect(data.containsKey('online'), isFalse);
      expect(sink.uids.single, 'u1'); // self-scoped write
    });

    test('empty role falls back to "unknown" (byRole-safe)', () {
      final sink = _FakePresenceSink();
      final repo = FirebasePresenceRepository(
        uid: 'u1',
        roleOf: () => '',
        sink: sink,
        nowMs: () => 1,
      );

      repo.heartbeat();

      expect(sink.writes.single['role'], 'unknown');
    });
  });

  group('debounce ≥30s (§3.4)', () {
    test('repeated heartbeats within the window write ONCE; again after it', () {
      var clock = 1000;
      final sink = _FakePresenceSink();
      final repo = FirebasePresenceRepository(
        uid: 'u1',
        roleOf: () => 'courier',
        sink: sink,
        nowMs: () => clock,
      );

      repo.heartbeat(); // t=1000 → write #1 (first is never debounced)
      clock = 1000 + 29000; // +29s — inside the 30s window
      repo.heartbeat(); // debounced
      expect(sink.writes.length, 1);

      clock = 1000 + 30000; // +30s — window elapsed
      repo.heartbeat(); // write #2
      expect(sink.writes.length, 2);
      expect(sink.writes.last['lastSeen'], 1000 + 30000);
    });
  });

  group('never throws (guardWrite spirit)', () {
    test('a failing sink is swallowed — heartbeat() returns normally', () async {
      final sink = _FakePresenceSink()..fail = true;
      final repo = FirebasePresenceRepository(
        uid: 'u1',
        roleOf: () => 'store',
        sink: sink,
        nowMs: () => 1,
      );

      expect(repo.heartbeat, returnsNormally);
      await _settle(); // the rejected write is handled, not unhandled
      expect(sink.writes.length, 1); // it was attempted
    });
  });

  group('lifecycle — goOffline / resume', () {
    test('goOffline() suppresses; resume() re-enables + resets the debounce', () {
      var clock = 1000;
      final sink = _FakePresenceSink();
      final repo = FirebasePresenceRepository(
        uid: 'u1',
        roleOf: () => 'store',
        sink: sink,
        nowMs: () => clock,
      );

      repo.heartbeat(); // write #1
      expect(sink.writes.length, 1);

      repo.goOffline();
      clock = 1000 + 60000; // +60s
      repo.heartbeat(); // suppressed — offline (no `online:false`, just silence)
      expect(sink.writes.length, 1);

      repo.resume(); // clears offline + resets the debounce window
      expect(sink.writes.length, 1); // resume itself writes nothing
      repo.heartbeat(); // now writes immediately → #2
      expect(sink.writes.length, 2);
    });
  });

  group('dormant — nothing written when unwired', () {
    test('empty uid writes nothing (cannot self-scope presence)', () {
      final sink = _FakePresenceSink();
      final repo = FirebasePresenceRepository(
        uid: '',
        roleOf: () => 'store',
        sink: sink,
        nowMs: () => 1,
      );

      repo.heartbeat();

      expect(sink.writes, isEmpty);
    });

    test('null sink no-ops (the deferred-adapter dormant state)', () {
      final repo = FirebasePresenceRepository(
        uid: 'u1',
        roleOf: () => 'store',
        nowMs: () => 1,
      );

      expect(repo.heartbeat, returnsNormally);
    });
  });

  group('owner read — presenceSummary/current only (R1-3)', () {
    test('summary() does ONE current() get; never touches presence writes',
        () async {
      const summary = PresenceSummary(
        count: 3,
        byRole: {'store': 2, 'courier': 1},
        sample: ['a', 'b', 'c'],
        updatedAtMs: 5000,
      );
      final source = _FakeSummarySource(summary);
      final sink = _FakePresenceSink();
      final repo = FirebasePresenceRepository(
        uid: 'owner',
        roleOf: () => 'manager',
        sink: sink,
        summarySource: source,
        nowMs: () => 5000,
      );

      final got = await repo.summary();

      expect(got, summary);
      // R1-3: the owner reads exactly ONE doc — not a `presence/*` collection scan.
      expect(source.currentCalls, 1);
      // Reading the summary must not write presence.
      expect(sink.writes, isEmpty);
    });

    test('summary() returns null on a read failure — never throws (unavailable)',
        () async {
      final source = _FakeSummarySource(null, fail: true);
      final repo = FirebasePresenceRepository(
        uid: 'owner',
        roleOf: () => 'manager',
        summarySource: source,
        nowMs: () => 1,
      );

      expect(await repo.summary(), isNull);
    });

    test('a null summarySource (dormant) returns null', () async {
      final repo = FirebasePresenceRepository(
        uid: 'owner',
        roleOf: () => 'manager',
        nowMs: () => 1,
      );

      expect(await repo.summary(), isNull);
    });
  });

  group('staleness verdict — presenceStatusFor (R2-12, PURE)', () {
    test('fresh: age within the threshold → fresh + secondsAgo', () {
      const now = 100000;
      const summary = PresenceSummary(count: 7, updatedAtMs: now - 10000);

      final status = presenceStatusFor(summary, nowMs: now);

      expect(status.freshness, PresenceFreshness.fresh);
      expect(status.isFresh, isTrue);
      expect(status.count, 7);
      expect(status.secondsAgo, 10);
    });

    test('stale: age past the threshold → stale (shown "לא-זמין")', () {
      const now = 1000000;
      const summary = PresenceSummary(count: 7, updatedAtMs: now - 120000);

      final status = presenceStatusFor(summary, nowMs: now);

      expect(status.freshness, PresenceFreshness.stale);
      expect(status.isFresh, isFalse);
    });

    test('boundary: exactly the threshold is fresh; one ms past is stale', () {
      const now = 1000000;
      final threshold = kPresenceStaleThreshold.inMilliseconds;
      final atEdge = PresenceSummary(count: 1, updatedAtMs: now - threshold);
      final pastEdge =
          PresenceSummary(count: 1, updatedAtMs: now - threshold - 1);

      expect(
        presenceStatusFor(atEdge, nowMs: now).freshness,
        PresenceFreshness.fresh,
      );
      expect(
        presenceStatusFor(pastEdge, nowMs: now).freshness,
        PresenceFreshness.stale,
      );
    });

    test('null summary / updatedAt==0 → unknown (unavailable)', () {
      expect(
        presenceStatusFor(null, nowMs: 100).freshness,
        PresenceFreshness.unknown,
      );
      expect(
        presenceStatusFor(const PresenceSummary(count: 0), nowMs: 100).freshness,
        PresenceFreshness.unknown,
      );
    });

    test('clock skew (negative age) is clamped to fresh, age zero', () {
      const now = 1000;
      const future = PresenceSummary(count: 2, updatedAtMs: now + 5000);

      final status = presenceStatusFor(future, nowMs: now);

      expect(status.freshness, PresenceFreshness.fresh);
      expect(status.age, Duration.zero);
    });
  });

  group('NoopPresenceRepository — the OFF default', () {
    test('every method is a no-op; summary() is null', () async {
      const repo = NoopPresenceRepository();

      expect(repo.heartbeat, returnsNormally);
      expect(repo.goOffline, returnsNormally);
      expect(repo.resume, returnsNormally);
      expect(await repo.summary(), isNull);
    });
  });
}
