// ─────────────────────────────────────────────────────────────────────────────
// telemetry — G4 (server-hardening): the external-telemetry seam that the
// in-memory primitives (state/analytics_log.dart step 91 + state/crash_log.dart
// step 90) always promised was "a separate wall-step". It forwards the key
// funnel events to FirebaseAnalytics and errors to FirebaseCrashlytics — but
// ONLY when Firebase is actually initialised. On the demo / no-Firebase path it
// is a pure NO-OP, so `main()` and every call-site behave EXACTLY as before
// (the G4 zero-regression invariant).
//
// THE SEAM ([TelemetrySink]): every Firebase{Analytics,Crashlytics}.instance
// touch goes through this injectable port. That keeps the providers + their
// tests Firebase-free: the real adapter ([FirebaseTelemetrySink]) resolves the
// singletons LAZILY (never at construction — the same rule as
// [FirebaseAuthGateway] / [FirestoreCollectionSource]), a recording fake drives
// the unit tests with zero new packages, and the default is [NoopTelemetrySink].
//
// HARD RULES (violating any breaks the G4 contract):
//   1. NOTHING here may touch a `Firebase*.instance` when Firebase is not
//      initialised — the whole existing suite must stay Firebase-free. The
//      provider switch is the SAME `Firebase.apps.isNotEmpty` gate the S1/S2/S3
//      seams use (auth_state.dart / backend.dart).
//   2. Firebase-absent behavior is EXACTLY today's app: a no-op sink, so every
//      call-site (place-order, role-assign, error) keeps its current behavior
//      byte-for-byte. Telemetry is additive.
//   3. The in-memory logs (analytics_log / crash_log) are NOT replaced — the
//      call-sites that already record into them keep doing so; this seam is the
//      ADDITIONAL forward to the real SDK. The two are independent.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart' show useFirebaseBackend;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The injectable telemetry port. Call-sites log key events / errors ONLY
/// through this seam, so a hand-rolled fake can drive every unit test and the
/// real impl ([FirebaseTelemetrySink]) stays the only thing that resolves a live
/// `FirebaseAnalytics`/`FirebaseCrashlytics` instance.
abstract class TelemetrySink {
  /// True when this sink forwards to a real backend (vs. the no-op). Tests and
  /// call-sites can read it; it is what the error-handler path checks.
  bool get enabled;

  /// Log one analytics event. [name] follows GA naming (snake_case, <=40 chars);
  /// [params] are flat scalar values (String/num/bool) — kept honest + minimal.
  void logEvent(String name, {Map<String, Object>? params});

  /// Record a non-fatal error to the crash backend, with optional [reason]
  /// context. A `null` [stack] is acceptable (the SDK captures the current one).
  void recordError(Object error, StackTrace? stack, {String? reason});
}

/// G4 — the generic handled-error funnel: a single helper a call-site uses for
/// a CAUGHT (swallowed) error it wants visible in telemetry. It both records
/// the error to Crashlytics ([TelemetrySink.recordError]) AND drops a minimal
/// [TelemetryEvents.appError] analytics breadcrumb tagged with the `where`
/// context label (NOT raw user data). A no-op sink does nothing — so a
/// Firebase-free run is byte-identical. Lives as an extension so [TelemetrySink]
/// stays a tiny port (analytics + crash) and this composition is shared.
extension TelemetryErrorLogging on TelemetrySink {
  void logError(Object error, StackTrace? stack, {required String where}) {
    recordError(error, stack, reason: where);
    logEvent(TelemetryEvents.appError, params: {'where': where});
  }
}

/// The default sink: a pure NO-OP. This is what every Firebase-free run (the
/// whole test suite, the demo build) gets, so call-sites behave byte-for-byte
/// as before telemetry existed.
class NoopTelemetrySink implements TelemetrySink {
  const NoopTelemetrySink();

  @override
  bool get enabled => false;

  @override
  void logEvent(String name, {Map<String, Object>? params}) {}

  @override
  void recordError(Object error, StackTrace? stack, {String? reason}) {}
}

/// The REAL adapter. Resolves `FirebaseAnalytics.instance` /
/// `FirebaseCrashlytics.instance` LAZILY — never in the constructor — so merely
/// constructing the sink (e.g. when a provider is read) does NOT require
/// Firebase to be initialised; the instance is only touched on the first log.
/// A failed forward is swallowed (telemetry must NEVER crash the app it watches
/// — the same guarded-write spirit as the S2 cache base).
class FirebaseTelemetrySink implements TelemetrySink {
  FirebaseTelemetrySink({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  })  : _injectedAnalytics = analytics,
        _injectedCrashlytics = crashlytics;

  final FirebaseAnalytics? _injectedAnalytics;
  final FirebaseCrashlytics? _injectedCrashlytics;

  FirebaseAnalytics get _analytics =>
      _injectedAnalytics ?? FirebaseAnalytics.instance;

  FirebaseCrashlytics get _crashlytics =>
      _injectedCrashlytics ?? FirebaseCrashlytics.instance;

  @override
  bool get enabled => true;

  @override
  void logEvent(String name, {Map<String, Object>? params}) {
    // Fire-and-forget — the analytics future is not awaited at any call-site,
    // and a failure must never surface in the UI.
    _analytics.logEvent(name: name, parameters: params).catchError(
      (Object e) => debugPrint('FirebaseTelemetrySink.logEvent ignored: $e'),
    );
  }

  @override
  void recordError(Object error, StackTrace? stack, {String? reason}) {
    _crashlytics.recordError(error, stack, reason: reason).catchError(
          (Object e) =>
              debugPrint('FirebaseTelemetrySink.recordError ignored: $e'),
        );
  }
}

/// The telemetry sink — a [FirebaseTelemetrySink] ONLY when the live Firebase
/// backend is up (the same `useFirebaseBackend` = flag AND `Firebase.apps`
/// non-empty gate every other seam uses), else the [NoopTelemetrySink]. Without
/// Firebase (the whole Firebase-free suite + the demo build) telemetry is a
/// no-op → zero regression. Tests override this with a recording fake.
final telemetryProvider = Provider<TelemetrySink>((ref) {
  if (useFirebaseBackend) return FirebaseTelemetrySink();
  return const NoopTelemetrySink();
});

/// G4 canonical event names — one source of truth so the call-sites and the
/// tests agree, and the dashboard funnel stays honest (no drifting strings).
abstract final class TelemetryEvents {
  /// A contractor completed checkout (the `placeOrder` success funnel step).
  static const String orderPlaced = 'order_placed';

  /// A manager assigned a server role to a user (auth/role funnel step).
  static const String roleAssigned = 'role_assigned';

  /// A generic handled application error surfaced through the error seam.
  static const String appError = 'app_error';
}
