// Studio Pillar 3 · step 89 — the IntelBus one-line seam.
//
// PROVED HERE (§5 — THE zero-regression proof), in the style of
// test/telemetry_test.dart:65-78 and test/intel/intel_log_test.dart:
//   1. WITHOUT Firebase (the default test env) track() records EXACTLY ONE
//      event into intelLogProvider (right name + props), the telemetry seam
//      resolves to NoopTelemetrySink (does nothing) and the forward sink is the
//      inert NoopIntelSink — and the WHOLE call returnsNormally;
//   2. the 3-way fan-out actually reaches all three destinations (local log +
//      telemetry seam + forward sink), proven with recording fakes;
//   3. a track that hits an internal error (a failing sink) STILL
//      returnsNormally — a screen never crashes from analytics — and the
//      earlier local record still landed (the guard wraps, it does not abort);
//   4. §9 min-interval throttle: two immediate screen_view record ONCE; a
//      non-throttled event is always recorded; throttled names are independent;
//   5. GREP-STYLE guard: the bus source uses NO `ref.watch` / `.watch(` — a
//      read-only bus never rebuilds (§2, §8 DoD).
import 'dart:io';

import 'package:buildsmart/state/intel/intel_bus.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:buildsmart/state/telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A recording TelemetrySink — proves fan-out destination (2) fires. Mirrors
/// test/telemetry_test.dart's _RecordingSink.
class _RecordingTelemetrySink implements TelemetrySink {
  final List<String> recordedNames = <String>[];
  final List<Map<String, Object>?> recordedParams = <Map<String, Object>?>[];

  @override
  bool get enabled => true;

  @override
  void logEvent(String name, {Map<String, Object>? params}) {
    recordedNames.add(name);
    recordedParams.add(params);
  }

  @override
  void recordError(Object error, StackTrace? stack, {String? reason}) {}
}

/// A recording forward sink — proves fan-out destination (3) fires.
class _RecordingIntelSink implements IntelSink {
  final List<IntelEvent> enqueued = <IntelEvent>[];

  @override
  void enqueue(IntelEvent e) => enqueued.add(e);
}

/// A forward sink that always fails — proves the bus swallows an internal error
/// so the caller still returnsNormally (screen-safety, §4).
class _FailingIntelSink implements IntelSink {
  @override
  void enqueue(IntelEvent e) => throw StateError('sink boom');
}

void main() {
  test(
    'without Firebase: track records ONE local event, telemetry + sink are the '
    'inert no-ops, and the whole call returnsNormally (zero regression)',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Default wiring on the demo path: both seams are the inert no-ops.
      expect(container.read(telemetryProvider), isA<NoopTelemetrySink>());
      expect(container.read(intelSinkProvider), isA<NoopIntelSink>());

      final bus = container.read(intelBusProvider);
      expect(container.read(intelLogProvider), isEmpty);

      expect(
        () => bus.track(
          IntelEvents.productView,
          props: const <String, String>{'sku': 'BS-1', 'source': 'grid'},
        ),
        returnsNormally,
      );

      // Grew by EXACTLY one, with the right name + props.
      final log = container.read(intelLogProvider);
      expect(log, hasLength(1));
      expect(log.single.name, IntelEvents.productView);
      expect(log.single.props, <String, String>{
        'sku': 'BS-1',
        'source': 'grid',
      });
      // Dimensions the bus cannot resolve yet are left null (steps 91/97/92).
      expect(log.single.actorKey, isNull);
      expect(log.single.uid, isNull);
      expect(log.single.sessionId, isNull);
      expect(log.single.screen, isNull);
    },
  );

  test(
    'the 3-way fan-out reaches local log + telemetry seam + forward sink',
    () {
      final telemetry = _RecordingTelemetrySink();
      final sink = _RecordingIntelSink();
      final container = ProviderContainer(
        overrides: <Override>[
          telemetryProvider.overrideWithValue(telemetry),
          intelSinkProvider.overrideWithValue(sink),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(intelBusProvider)
          .track(
            IntelEvents.addToCart,
            props: const <String, String>{'sku': 'BS-9', 'qty': '2'},
          );

      // (1) local ring buffer.
      final log = container.read(intelLogProvider);
      expect(log, hasLength(1));
      expect(log.single.name, IntelEvents.addToCart);
      // (2) telemetry seam — name + params forwarded verbatim.
      expect(telemetry.recordedNames, <String>[IntelEvents.addToCart]);
      expect(telemetry.recordedParams.single, <String, String>{
        'sku': 'BS-9',
        'qty': '2',
      });
      // (3) forward sink — enqueued the SAME event.
      expect(sink.enqueued, hasLength(1));
      expect(sink.enqueued.single.name, IntelEvents.addToCart);
      expect(sink.enqueued.single.props, <String, String>{
        'sku': 'BS-9',
        'qty': '2',
      });
    },
  );

  test(
    'a track that hits an internal error STILL returnsNormally (screen-safe)',
    () {
      final container = ProviderContainer(
        overrides: <Override>[
          intelSinkProvider.overrideWithValue(_FailingIntelSink()),
        ],
      );
      addTearDown(container.dispose);
      final bus = container.read(intelBusProvider);

      // The forward sink fails (destination 3) — the caller must NOT see it.
      expect(
        () => bus.track(
          IntelEvents.orderPlaced,
          props: const <String, String>{'order_id': 'BS-1'},
        ),
        returnsNormally,
      );
      // The guard wraps the fan-out; the earlier local record still landed.
      final log = container.read(intelLogProvider);
      expect(log, hasLength(1));
      expect(log.single.name, IntelEvents.orderPlaced);
    },
  );

  test(
    '§9 throttle: two immediate screen_view record ONCE; others unaffected',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final bus =
          container.read(intelBusProvider)
            ..track(
              IntelEvents.screenView,
              props: const <String, String>{'screen': 'home'},
            )
            ..track(
              IntelEvents.screenView,
              props: const <String, String>{'screen': 'cart'},
            );
      // The second screen_view within the min-interval is dropped → only one.
      expect(
        container
            .read(intelLogProvider)
            .where((e) => e.name == IntelEvents.screenView),
        hasLength(1),
      );

      // A different throttled name is independent (heartbeat records once).
      bus.track(
        IntelEvents.sessionHeartbeat,
        props: const <String, String>{'screen': 'home'},
      );
      expect(
        container
            .read(intelLogProvider)
            .where((e) => e.name == IntelEvents.sessionHeartbeat),
        hasLength(1),
      );

      // A non-throttled event is ALWAYS recorded, twice back-to-back.
      bus
        ..track(
          IntelEvents.addToCart,
          props: const <String, String>{'sku': 'A'},
        )
        ..track(
          IntelEvents.addToCart,
          props: const <String, String>{'sku': 'B'},
        );
      expect(
        container
            .read(intelLogProvider)
            .where((e) => e.name == IntelEvents.addToCart),
        hasLength(2),
      );
    },
  );

  test(
    'the bus uses NO ref.watch / .watch( — a read-only bus (grep-style, §8)',
    () {
      // Mirrors intel_log_test.dart's grep-style guard: the bus must never
      // subscribe — a watching bus would rebuild / jank. (cwd == package root.)
      final src = File('lib/state/intel/intel_bus.dart').readAsStringSync();
      // anti-vacuous: prove the file WAS read + it IS the read-only bus.
      expect(src.contains('class IntelBus'), isTrue);
      expect(src.contains('_ref.read('), isTrue);
      expect(
        src.contains('ref.watch'),
        isFalse,
        reason: 'the bus must READ, never subscribe (§2)',
      );
      expect(
        src.contains('.watch('),
        isFalse,
        reason: 'no reactive subscription anywhere in the bus (§8 DoD)',
      );
    },
  );

  test(
    'intelBusProvider resolves to an IntelBus; NoopIntelSink.enqueue is inert',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(intelBusProvider), isA<IntelBus>());
      // The inert seam does nothing + never re-raises.
      expect(
        () => const NoopIntelSink().enqueue(
          IntelEvent(name: IntelEvents.identify, at: DateTime.now()),
        ),
        returnsNormally,
      );
    },
  );
}
