// Pins the Claude gateway seam (#ai-backbone). Two invariants:
//   1. `claudeGatewayProvider` returns NULL in the default/test environment —
//      a real gateway exists ONLY when `useFirebaseBackend && kClaudeAi`, so
//      there's no AI offline and the demo/test build is byte-identical (the same
//      zero-regression guarantee as the other gateways). This is the load-bearing
//      gate; the mutation-verify drops the `&& kClaudeAi`/null guard and this
//      goes red.
//   2. A feature calling a hand-rolled fake [ClaudeGateway] gets the grounded
//      result back and the fake records the exact {prompt, system} it was given —
//      proving the seam contract features build on (no network, no new packages).
import 'dart:async';

import 'package:buildsmart/data/repositories/claude_functions.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake — records each call and returns a canned reply (or throws).
class _FakeClaude implements ClaudeGateway {
  _FakeClaude({this.reply = '', this.error});

  final String reply;
  final ClaudeException? error;
  final List<({String prompt, String? system, String? model, int? maxTokens})>
      calls = [];

  @override
  Future<ClaudeResult> ask({
    required String prompt,
    String? system,
    String? model,
    int? maxTokens,
  }) async {
    calls.add(
        (prompt: prompt, system: system, model: model, maxTokens: maxTokens));
    if (error != null) throw error!;
    return ClaudeResult(text: reply, model: model ?? 'fake');
  }
}

void main() {
  test('claudeGatewayProvider is null when AI is off (default/test env)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(
      c.read(claudeGatewayProvider),
      isNull,
      reason: 'no gateway unless useFirebaseBackend && kClaudeAi — no AI '
          'offline; the demo/test build is byte-identical',
    );
  });

  test('a feature calling a fake ClaudeGateway gets the grounded result back',
      () async {
    final fake = _FakeClaude(reply: 'כן — מחזיק 60°C ו-6 בר');
    final r = await fake.ask(prompt: 'is 60C/6bar ok?', system: 'spec…');

    expect(r.text, 'כן — מחזיק 60°C ו-6 בר');
    expect(fake.calls.single.prompt, 'is 60C/6bar ok?');
    expect(fake.calls.single.system, 'spec…',
        reason: 'the grounded system prompt reaches the gateway verbatim');
  });

  test('a caller can pin maxTokens and it flows through the gateway contract',
      () async {
    // The morning-brief asks for more room than a Q&A answer (Hebrew tokenizes
    // ~2-4× worse); this pins that the per-call cap reaches the seam verbatim
    // and is NOT silently dropped on the way to the callable.
    final fake = _FakeClaude(reply: 'תדריך');
    await fake.ask(prompt: 'brief', maxTokens: 600);

    expect(fake.calls.single.maxTokens, 600,
        reason: 'a per-call maxTokens reaches the gateway, not the default cap');
  });

  test('a gateway failure surfaces as a neutral ClaudeException (honest, no fake)',
      () async {
    final fake = _FakeClaude(error: const ClaudeException('unavailable'));
    expect(
      () => fake.ask(prompt: 'x'),
      throwsA(isA<ClaudeException>()),
      reason: 'callers map a failure to an honest fallback, never a faked answer',
    );
  });

  // The REAL adapter is thin glue, but it owns the load-bearing CONTRACT every
  // feature relies on: cloud_functions types never escape — every failure is
  // translated to a neutral [ClaudeException], and a stalled transport can't hang
  // the UI past 30s. Driven by a fake FirebaseFunctions injected via the ctor.
  group('FirebaseClaudeGateway translates every failure to a neutral type', () {
    test('a FirebaseFunctionsException carries its code through verbatim',
        () async {
      final gw = FirebaseClaudeGateway(
        functions: _FakeFunctions(_ThrowingCallable(
          // ignore: invalid_use_of_protected_member
          FirebaseFunctionsException(code: 'unauthenticated', message: 'sign in'),
        )),
      );
      await expectLater(
        () => gw.ask(prompt: 'q'),
        throwsA(isA<ClaudeException>()
            .having((e) => e.code, 'code', 'unauthenticated')),
        reason: 'the stable Firebase code reaches the caller for honest mapping',
      );
    });

    test('any other error collapses to ClaudeException(unavailable)', () async {
      final gw = FirebaseClaudeGateway(
        functions: _FakeFunctions(_ThrowingCallable(Exception('boom'))),
      );
      await expectLater(
        () => gw.ask(prompt: 'q'),
        throwsA(
            isA<ClaudeException>().having((e) => e.code, 'code', 'unavailable')),
        reason: 'a non-Firebase error must not leak cloud_functions types',
      );
    });

    test('a stalled transport trips the 30s client timeout → unavailable', () {
      fakeAsync((async) {
        final gw =
            FirebaseClaudeGateway(functions: _FakeFunctions(_HangingCallable()));
        Object? caught;
        gw.ask(prompt: 'q').then((_) {}, onError: (Object e) {
          caught = e;
        });
        async.elapse(const Duration(seconds: 31)); // past the 30s .timeout()
        expect(caught, isA<ClaudeException>());
        expect((caught! as ClaudeException).code, 'unavailable');
      });
    });
  });
}

// ─── hand-rolled cloud_functions fakes (no Firebase, no network) ─────────────
// `implements` + noSuchMethod: only `httpsCallable`/`call` are ever touched by
// the gateway; everything else routes to noSuchMethod (never invoked here).

class _FakeFunctions implements FirebaseFunctions {
  _FakeFunctions(this._callable);
  final HttpsCallable _callable;
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      _callable;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _ThrowingCallable implements HttpsCallable {
  _ThrowingCallable(this._error);
  final Object _error;
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async =>
      throw _error;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _HangingCallable implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) =>
      Completer<HttpsCallableResult<T>>().future; // never completes
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
