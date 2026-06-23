// Pins the AI cheaper-alternative explainer (#ai-alt-explain): the prompt is
// GROUNDED on the real swap (both brands, both prices, the savings) and forbids
// invention — Claude only phrases a tradeoff over numbers it was handed. Pure —
// no gateway, no widget pump.
import 'package:buildsmart/screens/alt_explain_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('altExplainPrompt grounds the model in the REAL swap', () {
    final p = altExplainPrompt(
      product: 'דוד שמש 150 ליטר',
      recName: 'כרומגן',
      recPrice: 1800,
      altName: 'אמקור',
      altPrice: 1500,
    );
    expect(p, contains('דוד שמש 150 ליטר'), reason: 'the product is named');
    expect(p, contains('כרומגן'), reason: 'the recommended brand is given');
    expect(p, contains('אמקור'), reason: 'the alternative brand is given');
    expect(p, contains('₪1800'), reason: 'the real recommended price is given');
    expect(p, contains('₪1500'), reason: 'the real alternative price is given');
    expect(p, contains('₪300'),
        reason: 'the savings (1800-1500) is computed from the data, not invented');
  });

  test('altExplainPrompt forbids invention (anti-hallucination)', () {
    final p = altExplainPrompt(
      product: 'X',
      recName: 'A',
      recPrice: 100,
      altName: 'B',
      altPrice: 80,
    );
    expect(p, contains('אל תמציא'),
        reason: 'the model is told not to invent specs/numbers/product names');
    expect(p, contains('ואל תבטיח שהזול תמיד עדיף'),
        reason: 'the model must not claim cheaper is always better');
  });
}
