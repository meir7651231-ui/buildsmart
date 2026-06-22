// ─────────────────────────────────────────────────────────────────────────────
// claude_functions — the injectable CALLABLE seam for the `askClaude` Cloud
// Function (functions/src/claude.ts). Mirrors order_functions.dart exactly: a
// neutral [ClaudeResult] + [ClaudeException], an abstract [ClaudeGateway] port,
// and a real [FirebaseClaudeGateway] that resolves `FirebaseFunctions` LAZILY
// (never at construction) and translates provider exceptions into the neutral
// type — so the seam keeps cloud_functions types out of features + tests.
//
// HOW FEATURES USE IT: a feature builds a GROUNDED prompt (verified data — a
// VerifiedSpec, a compliance checklist, a closed recipe set — placed in
// `system`/`prompt`) and calls [ask]; the model REASONS OVER TRUTH and never
// invents catalog parts. A hand-rolled fake drives unit tests with zero new
// packages. Gated by `kClaudeAi` (backend.dart) — OFF / no gateway → the AI entry
// points show an honest "requires connection" state; the demo build is unchanged.
//
// Region reused from [kAuthFunctionsRegion] (me-west1) — next to the other
// callables (setRole / computeCredit / getUploadUrl).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart'
    show kClaudeAi, useFirebaseBackend;
import 'package:buildsmart/state/auth_state.dart' show kAuthFunctionsRegion;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The result of a successful `askClaude` call — the model's concatenated text
/// blocks + the model id that served it.
@immutable
class ClaudeResult {
  const ClaudeResult({required this.text, required this.model});

  final String text;
  final String model;
}

/// The neutral callable failure: a stable [code] (`FirebaseFunctionsException.code`
/// verbatim — e.g. `unauthenticated`, `failed-precondition` for App Check, or
/// `unavailable` when the function isn't deployed / unreachable) + optional raw
/// message (logs only). Callers map a failure to an honest fallback, never a fake.
@immutable
class ClaudeException implements Exception {
  const ClaudeException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() =>
      'ClaudeException($code${message == null ? '' : ': $message'})';
}

/// The injectable Cloud Functions seam for the `askClaude` callable. Features
/// touch functions ONLY through this port, so a hand-rolled fake drives every
/// unit test and the real impl is the only thing resolving a live instance.
abstract class ClaudeGateway {
  /// Call `askClaude({prompt, system?, model?, maxTokens?})`. The caller supplies
  /// a GROUNDED [prompt] (and optional [system]); a feature may pin a [model] or
  /// [maxTokens]. Throws [ClaudeException] on any failure (sign-in / App Check /
  /// not deployed / network).
  Future<ClaudeResult> ask({
    required String prompt,
    String? system,
    String? model,
    int? maxTokens,
  });
}

/// The REAL FirebaseFunctions adapter. Resolves the Functions instance LAZILY —
/// never in the constructor — so merely constructing the gateway does NOT require
/// Firebase to be initialised; the instance is only touched on the first call.
class FirebaseClaudeGateway implements ClaudeGateway {
  FirebaseClaudeGateway({FirebaseFunctions? functions})
      : _injectedFunctions = functions;

  /// Optional pre-resolved instance (tests / DI). Null → resolved lazily.
  final FirebaseFunctions? _injectedFunctions;

  FirebaseFunctions get _functions =>
      _injectedFunctions ??
      FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion);

  @override
  Future<ClaudeResult> ask({
    required String prompt,
    String? system,
    String? model,
    int? maxTokens,
  }) async {
    try {
      final res = await _functions.httpsCallable('askClaude').call<dynamic>(
        <String, dynamic>{
          'prompt': prompt,
          if (system != null) 'system': system,
          if (model != null) 'model': model,
          if (maxTokens != null) 'maxTokens': maxTokens,
        },
      );
      final m = _asMap(res.data);
      return ClaudeResult(
        text: _str(m['text']) ?? '',
        model: _str(m['model']) ?? (model ?? ''),
      );
    } on FirebaseFunctionsException catch (e) {
      throw ClaudeException(e.code, e.message);
    } on Object catch (e) {
      throw ClaudeException('unavailable', e.toString());
    }
  }

  /// Tolerant string-keyed normalisation (the platform channel may hand back
  /// `Map<Object?, Object?>`), mirroring `FirebaseOrderFunctionsGateway._asMap`.
  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return const <String, dynamic>{};
  }

  static String? _str(dynamic v) => v is String ? v : null;
}

/// The injected gateway — a real [FirebaseClaudeGateway] ONLY when the backend is
/// live AND [kClaudeAi] is on; otherwise null (the AI entry points then show an
/// honest "requires connection" state, and the demo/test build is byte-identical).
/// Tests override this with a hand-rolled fake.
final claudeGatewayProvider = Provider<ClaudeGateway?>((ref) {
  if (useFirebaseBackend && kClaudeAi) return FirebaseClaudeGateway();
  return null;
});
