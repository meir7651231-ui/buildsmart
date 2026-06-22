// Pins the spec co-pilot's ZERO-HALLUCINATION design (#ai-spec-copilot): the
// temperature verdict is computed in Dart from the product's VerifiedSpec, and the
// Claude prompt is HANDED that pre-computed verdict (so the model only phrases it,
// never decides/invents). Pure — no widget pump, no gateway.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/screens/spec_copilot_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A real catalog product that carries a verified spec (the verdict's source).
  final product =
      kLipskeyCatalog.firstWhere((p) => kVerifiedSpecs.containsKey(p.sku));
  final spec = kVerifiedSpecs[product.sku]!;
  final maxT = spec.maxTempC.toInt();

  test('specTempVerdict is deterministic from VerifiedSpec.maxTempC (<=)', () {
    expect(specTempVerdict(product, maxT).ok, isTrue,
        reason: 'temp == max → suitable (suitableForTemp uses <=)');
    expect(specTempVerdict(product, maxT + 10).ok, isFalse,
        reason: 'above the verified max → not suitable');
    expect(specTempVerdict(product, maxT).maxTempC, spec.maxTempC);
  });

  test('no verified spec → ok is null (no claim is made)', () {
    final noSpec =
        kLipskeyCatalog.firstWhere((p) => !kVerifiedSpecs.containsKey(p.sku));
    expect(specTempVerdict(noSpec, 60).ok, isNull);
  });

  test('the prompt hands Claude the pre-computed verdict + numbers (grounded)',
      () {
    final hot = maxT + 20; // guaranteed a "no"
    final prompt = specCopilotPrompt(product, hot, spec);
    expect(prompt, contains('$hot'),
        reason: 'the asked temperature is in the prompt');
    expect(prompt, contains('${spec.maxTempC}'),
        reason: 'the verified max temp is in the prompt');
    expect(prompt, contains('לא'),
        reason: 'the DART-computed verdict (לא) is handed to the model, '
            'so it phrases — never decides');
    expect(prompt, contains('אל תמציא'),
        reason: 'the model is explicitly told not to invent data');
  });
}
