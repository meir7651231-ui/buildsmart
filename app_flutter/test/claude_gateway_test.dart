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
import 'package:buildsmart/data/repositories/claude_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake — records each call and returns a canned reply (or throws).
class _FakeClaude implements ClaudeGateway {
  _FakeClaude({this.reply = '', this.error});

  final String reply;
  final ClaudeException? error;
  final List<({String prompt, String? system, String? model})> calls = [];

  @override
  Future<ClaudeResult> ask({
    required String prompt,
    String? system,
    String? model,
    int? maxTokens,
  }) async {
    calls.add((prompt: prompt, system: system, model: model));
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

  test('a gateway failure surfaces as a neutral ClaudeException (honest, no fake)',
      () async {
    final fake = _FakeClaude(error: const ClaudeException('unavailable'));
    expect(
      () => fake.ask(prompt: 'x'),
      throwsA(isA<ClaudeException>()),
      reason: 'callers map a failure to an honest fallback, never a faked answer',
    );
  });
}
