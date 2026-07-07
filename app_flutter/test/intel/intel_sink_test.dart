// Studio Pillar 3 · step 90 — the consent-gated, BATCHED IntelSink.
//
// PROVED HERE (§5), with a RECORDING FAKE writer (the realtime_wiring_test.dart:34
// `_FakeSource implements <port>` idiom) so the enqueue / flush / requeue logic is
// exercised with ZERO Firebase:
//   1. enqueue is SYNCHRONOUS — it appends + returns immediately, writing nothing;
//   2. flush fires at N (the 25th enqueue) → the fake records ONE batch of 25;
//   3. flush fires on the T timer (an injected short interval, for determinism);
//   4. flush fires on an explicit flush() and on pause() (session_end / logout);
//   5. a FAILED flush RE-QUEUES the batch (it drains on the next attempt) and the
//      call `returnsNormally` — a screen never crashes from analytics (§4);
//   6. the queue cap holds under synthetic overload — length never exceeds the cap;
//   7. NO displayName reaches the wire (planted on the event, absent from the doc)
//      — R1-4: only the pseudonymous actorKey / uid + scalar props are forwarded;
//   8. INERT DOUBLE-GATE: the provider yields NoopIntelSink off-backend AND when
//      consent alone is present (backend + kIntelLive still off) — no writer call.
import 'package:buildsmart/data/legal_texts.dart' show kCurrentPolicyVersion;
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/intel/intel_bus.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_sink.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A recording batch writer — proves the batch shape reaches the wire seam. It
/// records a COPY of each batch; when [fail] is set it THROWS (the sink must
/// re-queue + swallow). No Firestore, no Firebase.
class _RecordingWriter implements IntelBatchWriter {
  final List<List<Map<String, Object?>>> batches =
      <List<Map<String, Object?>>>[];
  bool fail = false;

  @override
  Future<void> writeBatch(List<Map<String, Object?>> docs) async {
    if (fail) throw StateError('write boom');
    batches.add(List<Map<String, Object?>>.of(docs));
  }
}

/// Build a real intel event (a valid `IntelEvents` name), optionally carrying the
/// in-memory-only [displayName] PII the wire path must strip.
IntelEvent _ev(
  String name, {
  String? displayName,
  Map<String, String> props = const <String, String>{},
}) =>
    IntelEvent(
      name: name,
      at: DateTime.now(),
      actorKey: 'ak-1',
      uid: 'u-1',
      displayName: displayName,
      props: props,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(const <String, Object>{});

  group('FirestoreIntelSink — enqueue / batch / flush (fake writer, no Firebase)',
      () {
    test('enqueue is SYNCHRONOUS: appends + returns immediately, writes nothing',
        () {
      final writer = _RecordingWriter();
      final sink = FirestoreIntelSink(writer: writer);
      addTearDown(sink.dispose);

      sink.enqueue(_ev(IntelEvents.addToCart, props: const {'sku': 'BS-1'}));

      // Right after the call, synchronously: queued, and NOT yet written.
      expect(sink.queueLength, 1);
      expect(writer.batches, isEmpty);
    });

    test('flush fires at N (the 25th enqueue) → ONE batch of kIntelBatchSize',
        () async {
      final writer = _RecordingWriter();
      final sink = FirestoreIntelSink(writer: writer);
      addTearDown(sink.dispose);

      for (var i = 0; i < kIntelBatchSize; i++) {
        sink.enqueue(_ev(IntelEvents.productView, props: {'sku': 'BS-$i'}));
      }
      await pumpEventQueue();

      expect(writer.batches, hasLength(1));
      expect(writer.batches.single, hasLength(kIntelBatchSize));
      expect(sink.queueLength, 0);
    });

    test('flush fires on the T timer (kIntelFlushInterval elapsed)', () async {
      final writer = _RecordingWriter();
      final sink = FirestoreIntelSink(
        writer: writer,
        flushInterval: const Duration(milliseconds: 20),
      );
      addTearDown(sink.dispose);

      sink.enqueue(_ev(IntelEvents.cartView)); // < N → waits for the timer
      expect(writer.batches, isEmpty); // not yet — no N trigger

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(writer.batches, hasLength(1));
      expect(writer.batches.single, hasLength(1));
      expect(sink.queueLength, 0);
    });

    test('explicit flush() writes the partial tail immediately', () async {
      final writer = _RecordingWriter();
      final sink = FirestoreIntelSink(writer: writer);
      addTearDown(sink.dispose);

      sink
        ..enqueue(_ev(IntelEvents.checkoutStart))
        ..enqueue(_ev(IntelEvents.checkoutStep));
      await sink.flush();

      expect(writer.batches, hasLength(1));
      expect(writer.batches.single, hasLength(2));
      expect(sink.queueLength, 0);
    });

    test('pause() flushes the tail (session_end / logout, §9)', () async {
      final writer = _RecordingWriter();
      final sink = FirestoreIntelSink(writer: writer);
      addTearDown(sink.dispose);

      sink.enqueue(_ev(IntelEvents.sessionEnd));
      await sink.pause();

      expect(writer.batches, hasLength(1));
      expect(writer.batches.single, hasLength(1));
      expect(sink.queueLength, 0);
    });
  });

  group('FirestoreIntelSink — failure discipline (§4)', () {
    test('a FAILED flush RE-QUEUES the batch, retries next flush, never throws',
        () async {
      final writer = _RecordingWriter()..fail = true;
      final sink = FirestoreIntelSink(writer: writer);
      addTearDown(sink.dispose);

      // Filling to N triggers a flush; the writer throws — enqueue still never
      // surfaces it (screen-safety).
      for (var i = 0; i < kIntelBatchSize; i++) {
        expect(
          () => sink.enqueue(_ev(IntelEvents.addToCart, props: {'sku': '$i'})),
          returnsNormally,
        );
      }
      await pumpEventQueue();

      // The write threw → nothing recorded, and the whole batch is back queued.
      expect(writer.batches, isEmpty);
      expect(sink.queueLength, kIntelBatchSize);

      // The backend recovers: the retry drains the re-queued batch, and flush
      // itself completes normally (never re-raises).
      writer.fail = false;
      await expectLater(sink.flush(), completes);

      expect(writer.batches, hasLength(1));
      expect(writer.batches.single, hasLength(kIntelBatchSize));
      expect(sink.queueLength, 0);
    });

    test('the queue cap holds under synthetic overload (never exceeds the cap)',
        () {
      const cap = 50;
      final writer = _RecordingWriter();
      final sink = FirestoreIntelSink(
        writer: writer,
        queueCap: cap,
        batchSize: 1 << 30, // never auto-flush → exercise the pure enqueue/cap path
      );
      addTearDown(sink.dispose);

      for (var i = 0; i < cap * 4; i++) {
        sink.enqueue(_ev(IntelEvents.screenView));
        expect(sink.queueLength, lessThanOrEqualTo(cap)); // never exceeds, ever
      }

      expect(sink.queueLength, cap); // saturated — oldest dropped, never unbounded
      expect(writer.batches, isEmpty); // nothing flushed (batchSize unreachable)
    });
  });

  group('FirestoreIntelSink — no displayName on the wire (R1-4)', () {
    test('a planted displayName is stripped by toWire — never in the recorded doc',
        () async {
      final writer = _RecordingWriter();
      final sink = FirestoreIntelSink(writer: writer);
      addTearDown(sink.dispose);

      final planted = _ev(
        IntelEvents.productView,
        displayName: 'מאיר כהן', // real PII on the in-memory event…
        props: const {'sku': 'BS-1'},
      );
      expect(planted.displayName, 'מאיר כהן'); // anti-vacuous: it WAS set

      sink.enqueue(planted);
      await sink.flush();

      final doc = writer.batches.single.single;
      // …but never on the wire (R1-4). Only the pseudonymous key travels.
      expect(doc.containsKey('displayName'), isFalse);
      expect(doc.values.contains('מאיר כהן'), isFalse);
      expect(doc['actor_key'], 'ak-1');
      expect(doc['uid'], 'u-1');
      expect(doc['name'], IntelEvents.productView);
    });
  });

  group('intelSinkProvider — the consent + backend DOUBLE-GATE is inert', () {
    test('DEFAULT (unconsented, off-backend) → NoopIntelSink; enqueue is a no-op',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sink = container.read(intelSinkProvider);
      expect(sink, isA<NoopIntelSink>());

      // The inert sink swallows everything — no writer, no throw, no timer.
      expect(
        () => sink.enqueue(
          IntelEvent(name: IntelEvents.productView, at: DateTime.now()),
        ),
        returnsNormally,
      );
    });

    test('CONSENTED but off-backend → STILL NoopIntelSink (consent alone is not '
        'enough — no send when the backend / master-switch are off)', () {
      final container = ProviderContainer(
        overrides: <Override>[
          // Current-version consent recorded (privAnalytics + version together).
          appSettingsProvider.overrideWith(
            (ref) => AppSettingsNotifier()
              ..update(
                (s) => s.copyWith(
                  privAnalytics: true,
                  consentedPolicyVersion: kCurrentPolicyVersion,
                ),
              ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // useFirebaseBackend && kIntelLive are const-false in the test build, so
      // the FULL gate stays shut even with current consent → the demo/test build
      // never forwards (byte-identical, zero platform channel).
      expect(container.read(intelSinkProvider), isA<NoopIntelSink>());
    });
  });
}
