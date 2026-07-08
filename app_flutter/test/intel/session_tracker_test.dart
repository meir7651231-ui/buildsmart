// Studio Pillar-3 · step 97 — the session tracker + heartbeat presence.
//
// PROVED HERE (§5), with a FAKE clock (fake_async) + a RECORDING presence writer
// (the intel_sink_test.dart:30 `_RecordingWriter implements <port>` idiom) so the
// lifecycle + heartbeat + liveness logic is exercised with ZERO Firebase:
//   1. LOCAL session lifecycle (always-on, like screen_view): session_start on
//      begin, session_end on paused / idle(>= kIdleEnd) / logout — each carrying
//      the sessionId the bus now stamps (was null) + the right reason;
//   2. heartbeat RATE: one immediate beat, then one every kHeartbeat (fake clock);
//   3. liveness 2.5×: fresh lastBeat → live, stale (> kHeartbeat*2.5) → not;
//   4. INERT off-backend (the DEFAULT test env): the real presenceWriterProvider
//      is the Noop, and the tracker starts NO presence — the recording writer gets
//      NOTHING (no upsert, no delete), no heartbeat timer, no Firestore;
//   5. CUSTOMER-ONLY: worker / courier NEVER pass the presence gate, even fully
//      consented (the role axis, isolated from the const backend axes);
//   6. NO displayName on the wire (the port has no such param — R1-4); session_end
//      DELETES the presence doc.
import 'package:buildsmart/data/legal_texts.dart' show kCurrentPolicyVersion;
import 'package:buildsmart/logic/intel/intel_config.dart'
    show kHeartbeat, kIdleEnd, kPresenceTtl;
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/intel/actor_key.dart' show actorKeyProvider;
import 'package:buildsmart/state/intel/consent_gate.dart';
import 'package:buildsmart/state/intel/intel_bus.dart' show intelBusProvider;
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart' show intelLogProvider;
import 'package:buildsmart/state/intel/presence.dart';
import 'package:buildsmart/state/intel/session_tracker.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// One recorded heartbeat write — mirrors the neutral [PresenceWriter.upsert]
/// contract. NOTE the absence of any name/PII field: the port has NO such param,
/// so PII physically cannot be recorded (R1-4).
class _Beat {
  _Beat(this.actorKey, this.uid, this.screen, this.ttl);
  final String actorKey;
  final String? uid;
  final String screen;
  final Duration ttl;

  /// The neutral field set the Firestore doc would carry (minus the server
  /// `last_beat` / `expire_at`) — used to assert NO displayName is representable.
  Map<String, Object?> get fields => <String, Object?>{
        'actor_key': actorKey,
        if (uid != null) 'uid': uid,
        'screen': screen,
      };
}

/// A recording presence writer — proves the heartbeat / delete reach the seam
/// with the right neutral args, Firebase-free.
class _RecordingPresenceWriter implements PresenceWriter {
  final List<_Beat> upserts = <_Beat>[];
  final List<String> removes = <String>[];

  @override
  Future<void> upsert({
    required String actorKey,
    required String screen,
    required Duration ttl,
    String? uid,
  }) async {
    upserts.add(_Beat(actorKey, uid, screen, ttl));
  }

  @override
  Future<void> remove({required String actorKey}) async {
    removes.add(actorKey);
  }
}

/// Build a tracker container with deterministic overrides. [actorKeyProvider] is
/// pinned (avoids the async SharedPreferences mint under fake_async); the tracker
/// drives the app lifecycle by hand ([bindLifecycle] false) unless a test needs
/// the real observer.
ProviderContainer _trackerContainer({
  bool bindLifecycle = false,
  bool armIdle = false,
  DateTime Function()? clock,
  PresenceWriter? presenceWriter,
  StateProvider<String?>? uidCtrl,
}) {
  final overrides = <Override>[
    actorKeyProvider.overrideWithValue('ak-1'),
    sessionTrackerProvider.overrideWith(
      (ref) => SessionTracker(
        ref,
        bindLifecycle: bindLifecycle,
        armIdle: armIdle,
        clock: clock,
      ),
    ),
    if (presenceWriter != null)
      presenceWriterProvider.overrideWithValue(presenceWriter),
    if (uidCtrl != null)
      currentUidProvider.overrideWith((ref) => ref.watch(uidCtrl)),
  ];
  return ProviderContainer(overrides: overrides);
}

Iterable<dynamic> _named(ProviderContainer c, String name) =>
    c.read(intelLogProvider).where((e) => e.name == name);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionTracker — always-on LOCAL session lifecycle (§5)', () {
    test('session_start on begin: sessionId minted, published + stamped on events',
        () async {
      final container = _trackerContainer();
      addTearDown(container.dispose);
      final tracker = container.read(sessionTrackerProvider.notifier);

      // Before the deferred first-emission microtask: no session id yet.
      expect(container.read(sessionIdProvider), isNull);

      await pumpEventQueue();

      final starts = _named(container, IntelEvents.sessionStart).toList();
      expect(starts, hasLength(1));
      final sid = container.read(sessionIdProvider);
      expect(sid, isNotNull);
      expect(tracker.sessionId, sid);
      // the bus now stamps sessionId (was null) — on session_start itself…
      expect(starts.single.sessionId, sid);
      expect(starts.single.props['actor_kind'], 'customer');
      // …and on every SUBSEQUENT tracked event (the _context wiring, both ways).
      container.read(intelBusProvider).track(
        IntelEvents.productView,
        props: const <String, String>{'sku': 'X'},
      );
      final pv = container
          .read(intelLogProvider)
          .firstWhere((e) => e.name == IntelEvents.productView);
      expect(pv.sessionId, sid);
      expect(container.read(sessionTrackerProvider), SessionPhase.active);
    });

    test('session_end(background) on paused — reason + sessionId; idempotent',
        () async {
      final container = _trackerContainer();
      addTearDown(container.dispose);
      final tracker = container.read(sessionTrackerProvider.notifier);
      await pumpEventQueue();
      final sid = container.read(sessionIdProvider);

      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);

      final ends = _named(container, IntelEvents.sessionEnd).toList();
      expect(ends, hasLength(1));
      expect(ends.single.props['reason'], 'background');
      expect(ends.single.sessionId, sid);
      expect(container.read(sessionTrackerProvider), SessionPhase.ended);

      // A second background does NOT double-end (one end per session).
      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(_named(container, IntelEvents.sessionEnd), hasLength(1));
    });

    test('session_end(logout) when the uid goes null', () async {
      final uidCtrl = StateProvider<String?>((_) => 'u-1');
      final container = _trackerContainer(uidCtrl: uidCtrl);
      addTearDown(container.dispose);
      container.read(sessionTrackerProvider.notifier);
      await pumpEventQueue();

      container.read(uidCtrl.notifier).state = null; // sign-out
      await pumpEventQueue();

      final ends = _named(container, IntelEvents.sessionEnd).toList();
      expect(ends, hasLength(1));
      expect(ends.single.props['reason'], 'logout');
    });

    test('session_end(idle) after kIdleEnd of silence (fake clock + armed timer)',
        () {
      fakeAsync((async) {
        var now = DateTime(2026, 1, 1, 12);
        final container = _trackerContainer(armIdle: true, clock: () => now);
        container.read(sessionTrackerProvider.notifier);
        async.flushMicrotasks(); // session_start + arm the idle timer
        expect(_named(container, IntelEvents.sessionStart), hasLength(1));

        now = now.add(kIdleEnd);
        async.elapse(kIdleEnd); // the idle timer fires

        final ends = _named(container, IntelEvents.sessionEnd).toList();
        expect(ends, hasLength(1));
        expect(ends.single.props['reason'], 'idle');
        expect(ends.single.props['dur_s'], '${kIdleEnd.inSeconds}');
        container.dispose();
      });
    });

    test('the real observer is added in ctor + removed in dispose (no throw)',
        () async {
      final container = _trackerContainer(bindLifecycle: true);
      container.read(sessionTrackerProvider.notifier);
      await pumpEventQueue();
      expect(container.read(sessionTrackerProvider), SessionPhase.active);
      // dispose runs removeObserver + cancels — a clean teardown, no leak.
      expect(container.dispose, returnsNormally);
    });
  });

  group('Presence heartbeat — rate + doc shape (fake writer, no Firebase)', () {
    test('one immediate beat, then one every kHeartbeat; stop cancels + deletes',
        () {
      fakeAsync((async) {
        final writer = _RecordingPresenceWriter();
        final presence = Presence(
          writer,
          actorKey: 'ak-1',
          uid: 'u-1',
          screenOf: () => 'home',
        )..start();

        expect(writer.upserts, hasLength(1)); // immediate beat on start
        expect(presence.isBeating, isTrue);

        async.elapse(kHeartbeat);
        expect(writer.upserts, hasLength(2));

        async.elapse(kHeartbeat * 3);
        expect(writer.upserts, hasLength(5)); // exactly one per kHeartbeat

        presence.stop();
        async.flushMicrotasks();
        expect(presence.isBeating, isFalse); // timer cancelled
        expect(writer.removes, <String>['ak-1']); // session_end DELETED the doc
      });
    });

    test('doc carries actorKey/uid/screen/ttl ONLY — no displayName/PII (R1-4)',
        () {
      fakeAsync((async) {
        final writer = _RecordingPresenceWriter();
        Presence(
          writer,
          actorKey: 'ak-9',
          uid: 'u-9',
          screenOf: () => 'store',
          ttl: kPresenceTtl,
        ).start();

        expect(writer.upserts, hasLength(1));
        final beat = writer.upserts.single;
        expect(beat.actorKey, 'ak-9');
        expect(beat.uid, 'u-9');
        expect(beat.screen, 'store');
        // expireAt = serverTs + kPresenceTtl (MINUTES, not the 30-90-DAY events/
        // retention): the ttl is minutes-scale, well under a day.
        expect(beat.ttl, kPresenceTtl);
        expect(beat.ttl.inMinutes, greaterThan(0));
        expect(beat.ttl, lessThan(const Duration(days: 1)));
        // no human label is even representable on the wire (R1-4).
        expect(beat.fields.containsKey('displayName'), isFalse);
        expect(beat.fields.keys,
            containsAll(<String>['actor_key', 'uid', 'screen']));
      });
    });

    test('liveness = freshness within kHeartbeat * 2.5 (fresh live, stale not)',
        () {
      final now = DateTime(2026, 1, 1, 12);
      expect(presenceLive(now, now.subtract(kHeartbeat)), isTrue); // 1×
      expect(presenceLive(now, now.subtract(kHeartbeat * 2)), isTrue); // 2× < 2.5×
      expect(presenceLive(now, now.subtract(kHeartbeat * 3)), isFalse); // 3× stale
      // boundary — just under vs. just over 2.5×.
      expect(
        presenceLive(
          now,
          now.subtract(kHeartbeat * 2.5 - const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        presenceLive(
          now,
          now.subtract(kHeartbeat * 2.5 + const Duration(seconds: 1)),
        ),
        isFalse,
      );
    });
  });

  group('the presence DOUBLE-GATE is inert + customer-only (§5)', () {
    test('INERT off-backend: real provider is Noop; tracker starts NO presence',
        () async {
      // The default (unconsented, off-backend) provider is the inert Noop.
      final probe = ProviderContainer();
      addTearDown(probe.dispose);
      expect(probe.read(presenceWriterProvider), isA<NoopPresenceWriter>());

      // Drive a FULL local session with a recording writer wired in — the gate is
      // shut, so the writer must receive NOTHING (no heartbeat, no delete).
      final writer = _RecordingPresenceWriter();
      final container = _trackerContainer(presenceWriter: writer);
      addTearDown(container.dispose);
      final tracker = container.read(sessionTrackerProvider.notifier);
      await pumpEventQueue();
      tracker.didChangeAppLifecycleState(AppLifecycleState.paused);
      await pumpEventQueue();

      expect(writer.upserts, isEmpty); // zero heartbeat off-backend
      expect(writer.removes, isEmpty); // no Firestore touch at all
      // …yet the always-on LOCAL session still ran (start + end recorded).
      expect(_named(container, IntelEvents.sessionStart), hasLength(1));
      expect(_named(container, IntelEvents.sessionEnd), hasLength(1));
    });

    test('customer-only: worker/courier NEVER pass, even fully consented (R1-5)',
        () {
      final consented = AppSettings.defaults.copyWith(
        privPresence: true,
        consentedPolicyVersion: kCurrentPolicyVersion,
      );
      // anti-vacuous: consent IS present + a customer (null role) IS allowed…
      expect(presenceConsentCurrent(consented), isTrue);
      expect(presenceAllowedForRole(null), isTrue);
      // …but a worker / courier is blocked by the ROLE axis regardless.
      expect(presenceAllowedForRole('worker'), isFalse);
      expect(presenceAllowedForRole('courier'), isFalse);
      expect(presenceForwardEnabled(consented, 'worker'), isFalse);
      expect(presenceForwardEnabled(consented, 'courier'), isFalse);
      // and even a consented customer never forwards in a demo/test build (the
      // const backend + kIntelLive axes stay shut).
      expect(presenceForwardEnabled(consented, null), isFalse);
    });
  });
}
