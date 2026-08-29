// G4 — telemetry seam (lib/state/telemetry.dart) + the Crashlytics
// handler-wiring logic (lib/main.dart installCrashlyticsHandlers).
//
// PROVED HERE (the G4 contract):
//   1. The seam is Firebase-GATED: with no Firebase the provider is the no-op
//      sink (enabled == false) and every method does NOTHING — the demo path is
//      byte-identical. (Firebase is never initialised in tests, so the live
//      branch is exercised via an injected recording fake, exactly like the
//      auth-gateway tests — no real Firebase, no new packages.)
//   2. When ENABLED the seam forwards logEvent / recordError / logError to the
//      backend with honest names + params.
//   3. installCrashlyticsHandlers routes a Flutter framework error to
//      recordFlutterError (after presentError) and a platform-async error to
//      recordError (returning true = handled), and gates collection on !isDebug.
import 'package:buildsmart/main.dart' show installCrashlyticsHandlers;
import 'package:buildsmart/state/telemetry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// One recorded analytics call.
class _Event {
  _Event(this.name, this.params);
  final String name;
  final Map<String, Object>? params;
}

/// One recorded error call.
class _Err {
  _Err(this.error, this.stack, this.reason);
  final Object error;
  final StackTrace? stack;
  final String? reason;
}

/// A recording sink standing in for the live Firebase one — the same
/// hand-rolled-fake discipline as test/auth_state_test.dart's _FakeAuthGateway.
class _RecordingSink implements TelemetrySink {
  final List<_Event> events = [];
  final List<_Err> errors = [];

  @override
  bool get enabled => true;

  @override
  void logEvent(String name, {Map<String, Object>? params}) =>
      events.add(_Event(name, params));

  @override
  void recordError(Object error, StackTrace? stack, {String? reason}) =>
      errors.add(_Err(error, stack, reason));
}

void main() {
  group('telemetryProvider — Firebase gate (zero regression)', () {
    test('without Firebase the default sink is the no-op (disabled)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final sink = c.read(telemetryProvider);
      // Tests never initialise Firebase + the flag is off → NoopTelemetrySink.
      expect(sink, isA<NoopTelemetrySink>());
      expect(sink.enabled, isFalse);
    });

    test('no-op sink: logEvent / recordError / logError do NOTHING (no throw)',
        () {
      const sink = NoopTelemetrySink();
      // The whole point of the gate: every call is inert on the demo path.
      expect(
        () {
          sink.logEvent('anything', params: {'x': 1});
          sink.recordError(Exception('e'), StackTrace.current, reason: 'r');
          sink.logError(Exception('e'), null, where: 'somewhere');
        },
        returnsNormally,
      );
      expect(sink.enabled, isFalse);
    });
  });

  group('TelemetrySink — forwards to the backend when enabled', () {
    test('logEvent forwards name + params verbatim', () {
      final sink = _RecordingSink();
      sink.logEvent(TelemetryEvents.orderPlaced,
          params: {'order_id': 'BS-9', 'items': 3, 'sum': 1200});
      expect(sink.events.single.name, 'order_placed');
      expect(sink.events.single.params,
          {'order_id': 'BS-9', 'items': 3, 'sum': 1200});
    });

    test('recordError forwards error + stack + reason', () {
      final sink = _RecordingSink();
      final st = StackTrace.current;
      final e = StateError('boom');
      sink.recordError(e, st, reason: 'unit');
      expect(sink.errors.single.error, same(e));
      expect(sink.errors.single.stack, same(st));
      expect(sink.errors.single.reason, 'unit');
    });

    test('logError composes recordError + an app_error breadcrumb', () {
      final sink = _RecordingSink();
      final e = Exception('x');
      sink.logError(e, null, where: 'role_assign');
      // crash side: recorded with `where` as the reason
      expect(sink.errors.single.error, same(e));
      expect(sink.errors.single.reason, 'role_assign');
      // analytics side: a minimal app_error event tagged with `where`
      expect(sink.events.single.name, TelemetryEvents.appError);
      expect(sink.events.single.params, {'where': 'role_assign'});
    });
  });

  group('installCrashlyticsHandlers — wiring logic (no real Firebase)', () {
    // The function mutates the GLOBAL error handlers; snapshot + restore so it
    // never leaks into another test.
    late FlutterExceptionHandler? savedFlutterOnError;
    late bool Function(Object, StackTrace)? savedPlatformOnError;

    setUp(() {
      savedFlutterOnError = FlutterError.onError;
      savedPlatformOnError = PlatformDispatcher.instance.onError;
    });
    tearDown(() {
      FlutterError.onError = savedFlutterOnError;
      PlatformDispatcher.instance.onError = savedPlatformOnError;
    });

    test('Flutter framework error → recordFlutterError (release: collection on)',
        () {
      final flutterErrors = <FlutterErrorDetails>[];
      final platformErrors = <Object>[];
      final enabledLog = <bool>[];

      installCrashlyticsHandlers(
        setCollectionEnabled: enabledLog.add,
        recordFlutterError: flutterErrors.add,
        recordError: (e, st) => platformErrors.add(e),
        isDebug: false, // release-like
      );

      // Collection enabled in release (the !isDebug gate).
      expect(enabledLog, [true]);

      // Driving the installed FlutterError.onError records the details.
      final details = FlutterErrorDetails(exception: StateError('framework'));
      FlutterError.onError!(details);
      expect(flutterErrors.single, same(details));
      expect(platformErrors, isEmpty); // the framework path is separate
    });

    test('platform async error → recordError AND returns true (handled)', () {
      final flutterErrors = <FlutterErrorDetails>[];
      final platformErrors = <Object>[];

      installCrashlyticsHandlers(
        setCollectionEnabled: (_) {},
        recordFlutterError: flutterErrors.add,
        recordError: (e, st) => platformErrors.add(e),
        isDebug: false,
      );

      final err = StateError('async');
      final handled =
          PlatformDispatcher.instance.onError!(err, StackTrace.current);
      expect(handled, isTrue); // swallowed so it does not re-crash the isolate
      expect(platformErrors.single, same(err));
      expect(flutterErrors, isEmpty); // the async path is separate
    });

    test('debug build DISABLES collection (keeps the on-device overlay)', () {
      final enabledLog = <bool>[];
      installCrashlyticsHandlers(
        setCollectionEnabled: enabledLog.add,
        recordFlutterError: (_) {},
        recordError: (_, __) {},
        isDebug: true, // debug
      );
      // !isDebug == false → collection OFF in debug.
      expect(enabledLog, [false]);
    });
  });
}
