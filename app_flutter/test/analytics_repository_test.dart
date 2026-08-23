// Studio Pillar 5 · Step 67 — the write-only analytics event append
// (`lib/data/repositories/analytics_repository.dart`).
//
// Pins the step-67 analytics contract:
//   1. BUFFER + APPEND — `logEvent` records to the in-app 500-ring
//      (`state/analytics_log.dart`, the offline buffer) AND fire-and-forgets a
//      create-AS-SELF append (`uid == auth.uid`, name, at, props) — the Step-65 rule.
//   2. NEVER THROWS — a failing sink is swallowed; the event STAYS buffered in the
//      retry ring (pendingCount), the in-app log still records it.
//   3. FLUSH ON RECONNECT (§6) — `flushPending` drains the buffered events once the
//      sink recovers; while still offline it keeps them.
//   4. BOUNDED RING (§10b) — the retry ring drops the OLDEST past its cap.
//   5. DORMANT — empty uid or a null sink buffers to the ring only (no server write).
//   6. NOOP — the OFF default does nothing.
//
// NO Firebase here: the append seam is a HAND-ROLLED fake (the define-less-fake
// idiom — no fake_cloud_firestore, no new packages, no dart-define). The in-app ring
// is the real `AnalyticsLogNotifier` (pure Dart).

import 'package:buildsmart/data/repositories/analytics_repository.dart';
import 'package:buildsmart/state/analytics_log.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled [AnalyticsEventSink]: records appended events, or FAILS (a rejected
/// future) to prove the guarded append never throws and keeps the event buffered.
class _FakeAnalyticsSink implements AnalyticsEventSink {
  final List<Map<String, dynamic>> appended = <Map<String, dynamic>>[];
  bool fail = false;

  @override
  Future<void> append(Map<String, dynamic> event) {
    if (fail) return Future<void>.error(Exception('offline'));
    appended.add(event);
    return Future<void>.value();
  }
}

/// Let the fire-and-forget guarded append settle.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('logEvent — buffer to the ring + append create-as-self', () {
    test('records to the in-app ring AND appends {uid, name, at, props}', () async {
      final log = AnalyticsLogNotifier();
      final sink = _FakeAnalyticsSink();
      final repo = FirebaseAnalyticsRepository(
        uid: 'u1',
        sink: sink,
        log: log,
        nowMs: () => 5000,
      );

      repo.logEvent('order_placed', props: {'sku': 'x'});

      // The in-app buffer records synchronously (offline-safe).
      expect(log.countByName('order_placed'), 1);

      await _settle();

      final event = sink.appended.single;
      expect(event['uid'], 'u1'); // create-as-self (Step-65 rule)
      expect(event['name'], 'order_placed');
      expect(event['at'], 5000);
      expect(event['props'], {'sku': 'x'});
      expect(repo.pendingCount, 0); // acked → drained from the retry ring
    });

    test('omits an empty props map from the event', () async {
      final sink = _FakeAnalyticsSink();
      final repo = FirebaseAnalyticsRepository(uid: 'u1', sink: sink);

      repo.logEvent('view');
      await _settle();

      expect(sink.appended.single.containsKey('props'), isFalse);
    });
  });

  group('never throws + stays buffered on failure', () {
    test('a failing append is swallowed; the event stays in the retry ring',
        () async {
      final log = AnalyticsLogNotifier();
      final sink = _FakeAnalyticsSink()..fail = true;
      final repo = FirebaseAnalyticsRepository(uid: 'u1', sink: sink, log: log);

      expect(() => repo.logEvent('e'), returnsNormally);
      await _settle();

      expect(sink.appended, isEmpty); // never landed
      expect(repo.pendingCount, 1); // buffered for retry
      expect(log.countByName('e'), 1); // in-app log still recorded it
    });
  });

  group('flushPending — the coalescing reconnect flush (§6)', () {
    test('drains buffered events once the sink recovers', () async {
      final sink = _FakeAnalyticsSink()..fail = true;
      final repo = FirebaseAnalyticsRepository(uid: 'u1', sink: sink);

      for (final name in ['a', 'b']) {
        repo.logEvent(name);
      }
      await _settle();
      expect(repo.pendingCount, 2);

      sink.fail = false; // reconnected
      await repo.flushPending();

      expect(repo.pendingCount, 0);
      expect(sink.appended.map((e) => e['name']).toList(), ['a', 'b']);
    });

    test('keeps events buffered while still offline', () async {
      final sink = _FakeAnalyticsSink()..fail = true;
      final repo = FirebaseAnalyticsRepository(uid: 'u1', sink: sink);

      repo.logEvent('a');
      await _settle();
      await repo.flushPending(); // still failing

      expect(repo.pendingCount, 1);
      expect(sink.appended, isEmpty);
    });
  });

  group('bounded retry ring (§10b — drop-oldest)', () {
    test('never retains more than maxPending; keeps the NEWEST', () async {
      final log = AnalyticsLogNotifier();
      final sink = _FakeAnalyticsSink()..fail = true;
      final repo = FirebaseAnalyticsRepository(
        uid: 'u1',
        sink: sink,
        log: log,
        maxPending: 3,
      );

      for (var i = 0; i < 5; i++) {
        repo.logEvent('e$i');
      }
      await _settle();

      expect(repo.pendingCount, 3); // bounded
      // The in-app ring (default 500) still holds every event.
      expect(log.state.length, 5);

      // The 3 retained are the NEWEST (e2, e3, e4) — drop-oldest.
      sink.fail = false;
      await repo.flushPending();
      expect(sink.appended.map((e) => e['name']).toList(), ['e2', 'e3', 'e4']);
    });
  });

  group('dormant — buffer only when unwired', () {
    test('empty uid buffers to the ring but never appends (no self-scope)',
        () async {
      final log = AnalyticsLogNotifier();
      final sink = _FakeAnalyticsSink();
      final repo = FirebaseAnalyticsRepository(uid: '', sink: sink, log: log);

      repo.logEvent('x');
      await _settle();

      expect(sink.appended, isEmpty);
      expect(repo.pendingCount, 0);
      expect(log.countByName('x'), 1);
    });

    test('null sink (deferred adapter) buffers to the ring, no write', () async {
      final log = AnalyticsLogNotifier();
      final repo = FirebaseAnalyticsRepository(uid: 'u1', log: log);

      expect(() => repo.logEvent('y'), returnsNormally);
      await _settle();

      expect(repo.pendingCount, 0);
      expect(log.countByName('y'), 1);
    });
  });

  group('NoopAnalyticsRepository — the OFF default', () {
    test('logEvent no-ops, pendingCount 0, flushPending completes', () async {
      const repo = NoopAnalyticsRepository();

      expect(() => repo.logEvent('z', props: {'k': 'v'}), returnsNormally);
      expect(repo.pendingCount, 0);
      await expectLater(repo.flushPending(), completes);
    });
  });
}
