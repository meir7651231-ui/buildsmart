// ─────────────────────────────────────────────────────────────────────────────
// order_functions — A13 (launch server-connect): the injectable CALLABLE seam
// for the two server-canonical order operations whose Cloud Functions already
// EXIST (`functions/src/index.ts` re-exports them):
//
//   • `advanceOrderStage({orderId})` — the SANCTIONED single-step stage advance.
//     Firestore triggers carry no auth context, so the role check (store /
//     courier own their transitions; manager/admin may nudge any single step)
//     lives in the callable, which does the transaction + stamps stageBy/
//     stageRole/stageAt. A companion trigger `revertIllegalOrderStageWrite`
//     REVERTS direct stage writes that are not a single forward step — so the
//     CLIENT must route the persistent stage write THROUGH this callable when
//     the A13 flag is ON (it keeps only an optimistic LOCAL cache update; see
//     orders_engine.dart). Returns `{ok, orderId, from, to}`.
//
//   • `computeCredit({name})` — the server-canonical contractor credit. Mirrors
//     the manager dashboard's client derivation (the `contractorCredit` ceiling
//     + the live `mgrCustomerList` spend fold) but computed authoritatively on
//     the server (the client hash is platform-fragile — dart2js masks 29 bits,
//     native 30 — see functions/src/creditCore.ts). Returns
//     `{ok, name, creditLimit, used, balance, pct, orderCount}`.
//
// THE SEAM (mirrors [AuthGateway] in state/auth_state.dart): every
// FirebaseFunctions touch goes through this injectable port, which speaks in
// NEUTRAL plain-Dart results ([AdvanceStageResult] / [CreditResult]) and a
// neutral [OrderFunctionsException] — NOT in `HttpsCallableResult` /
// `FirebaseFunctionsException`. That keeps the notifier (and its tests)
// Firebase-free: the real adapter ([FirebaseOrderFunctionsGateway]) resolves
// `FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion)` LAZILY (never
// at construction — the same rule [FirebaseAuthGateway] follows for the
// `setRole` callable), and a hand-rolled fake drives the unit tests with zero
// new packages.
//
// The region is reused from [kAuthFunctionsRegion] (me-west1, Tel Aviv) — the
// callables live next to the Firestore data + the existing `setRole` callable.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/auth_state.dart' show kAuthFunctionsRegion;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// The result of a successful `advanceOrderStage` call — the server-canonical
/// `{from, to}` of the single step it performed (it also returns `ok`/`orderId`,
/// echoed back). The client applies an OPTIMISTIC LOCAL update to [to].
@immutable
class AdvanceStageResult {
  const AdvanceStageResult({
    required this.orderId,
    required this.from,
    required this.to,
  });

  /// The order the server advanced.
  final String orderId;

  /// The stage the order was at BEFORE the step (server-reported).
  final String from;

  /// The stage the server advanced the order TO (the canonical new stage the
  /// client mirrors optimistically; the `orders` snapshot reconciles after).
  final String to;
}

/// The result of a successful `computeCredit` call — the server-canonical
/// contractor credit aggregate (the exact field set the manager dashboard
/// derives client-side, now authoritative). All amounts are ₪ ints; [pct] is
/// the credit-utilisation percentage (0–100).
@immutable
class CreditResult {
  const CreditResult({
    required this.name,
    required this.creditLimit,
    required this.used,
    required this.balance,
    required this.pct,
    required this.orderCount,
  });

  final String name;
  final int creditLimit;
  final int used;
  final int balance;
  final int pct;
  final int orderCount;
}

/// The neutral callable failure: a stable [code] (mirrors
/// `FirebaseFunctionsException.code`, e.g. `unauthenticated`,
/// `permission-denied`, `not-found`, or `unavailable` when the function is not
/// deployed) + optional raw message. Nothing above the seam imports
/// cloud_functions exception types — callers map a failure to a graceful
/// fallback / honest surface (never a faked success).
@immutable
class OrderFunctionsException implements Exception {
  const OrderFunctionsException(this.code, [this.message]);

  /// Stable error code (`FirebaseFunctionsException.code` verbatim, or
  /// `unavailable` when no gateway exists / the function is unreachable).
  final String code;

  /// Raw (English) provider message — for logs, never shown to the user.
  final String? message;

  @override
  String toString() =>
      'OrderFunctionsException($code${message == null ? '' : ': $message'})';
}

/// The injectable Cloud Functions seam for the A13 order callables. The notifier
/// touches functions ONLY through this port, so a hand-rolled fake drives every
/// unit test and the real impl ([FirebaseOrderFunctionsGateway]) stays the only
/// thing that resolves a live `FirebaseFunctions` instance.
abstract class OrderFunctionsGateway {
  /// Call `advanceOrderStage({orderId})` — the server advances the order ONE
  /// step (role-checked) and returns the `{from, to}` it performed. Throws
  /// [OrderFunctionsException] on any failure (sign-in required / role denied /
  /// not found / not deployed).
  Future<AdvanceStageResult> advanceOrderStage(String orderId);

  /// Call `computeCredit({name})` — the server computes the canonical credit
  /// aggregate for the contractor [name]. Throws [OrderFunctionsException] on
  /// any failure (a non-manager computing another's credit is `permission-denied`).
  Future<CreditResult> computeCredit(String name);
}

/// The REAL FirebaseFunctions adapter. Resolves the Functions instance LAZILY —
/// never in the constructor — so merely constructing the gateway (e.g. when a
/// provider is read) does NOT require Firebase to be initialised; the instance
/// is only touched on the first call. Translates `FirebaseFunctionsException`
/// (and any other failure) into the neutral [OrderFunctionsException] — the
/// single choke-point that keeps cloud_functions types below the seam (the
/// `FirebaseAuthGateway._guard` shape).
class FirebaseOrderFunctionsGateway implements OrderFunctionsGateway {
  FirebaseOrderFunctionsGateway({FirebaseFunctions? functions})
    : _injectedFunctions = functions;

  /// Optional pre-resolved instance (tests / DI). When null it is resolved
  /// lazily from the singleton on first use.
  final FirebaseFunctions? _injectedFunctions;

  FirebaseFunctions get _functions =>
      _injectedFunctions ??
      FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion);

  /// Run one callable, translating provider exceptions into the neutral
  /// [OrderFunctionsException]. A failure that is NOT a FirebaseFunctionsException
  /// (e.g. Firebase not initialised) becomes `unavailable` — surfaced honestly.
  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on FirebaseFunctionsException catch (e) {
      throw OrderFunctionsException(e.code, e.message);
    } on Object catch (e) {
      throw OrderFunctionsException('unavailable', e.toString());
    }
  }

  @override
  Future<AdvanceStageResult> advanceOrderStage(String orderId) =>
      _guard(() async {
        final res = await _functions
            .httpsCallable('advanceOrderStage')
            .call<dynamic>(<String, String>{'orderId': orderId});
        final m = _asMap(res.data);
        return AdvanceStageResult(
          orderId: _str(m['orderId']) ?? orderId,
          from: _str(m['from']) ?? '',
          to: _str(m['to']) ?? '',
        );
      });

  @override
  Future<CreditResult> computeCredit(String name) => _guard(() async {
    final res = await _functions.httpsCallable('computeCredit').call<dynamic>(
      <String, String>{'name': name},
    );
    final m = _asMap(res.data);
    return CreditResult(
      name: _str(m['name']) ?? name,
      creditLimit: _int(m['creditLimit']),
      used: _int(m['used']),
      balance: _int(m['balance']),
      pct: _int(m['pct']),
      orderCount: _int(m['orderCount']),
    );
  });

  /// The callable payload arrives as a JSON map, but the platform channel may
  /// decode nested maps as `Map<Object?, Object?>` (not `Map<String, dynamic>`)
  /// — normalise to a string-keyed map tolerantly so field reads never throw.
  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return const <String, dynamic>{};
  }

  static String? _str(dynamic v) => v is String ? v : null;

  static int _int(dynamic v) =>
      v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? 0 : 0);
}
