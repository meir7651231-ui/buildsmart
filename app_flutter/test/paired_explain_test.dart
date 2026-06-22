// Pins the AI "what else does this install need?" explainer (#ai-paired-explain):
// the prompt is GROUNDED on the product + the REAL paired-type list and forbids
// the model from inventing products or adding types beyond the list. Pure — no
// gateway, no widget pump.
import 'package:buildsmart/screens/paired_explain_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pairedExplainPrompt grounds the model in the product + real types', () {
    final p = pairedExplainPrompt(
      product: 'צינור PEX 16 מ"מ',
      types: const ['מצמדים', 'מחלקים', 'אטמים ופקקים'],
    );
    expect(p, contains('צינור PEX 16 מ"מ'), reason: 'the product is named');
    for (final t in const ['מצמדים', 'מחלקים', 'אטמים ופקקים']) {
      expect(p, contains(t), reason: 'every real paired type is offered: $t');
    }
    expect(p, contains('אל תשכח'),
        reason: 'asks for a "don\'t forget" close — the actual user value');
  });

  test('pairedExplainPrompt forbids invention + extra types', () {
    final p = pairedExplainPrompt(product: 'X', types: const ['A', 'B']);
    expect(p, contains('אל תמציא'),
        reason: 'no invented product names / SKUs / prices');
    expect(p, contains('אל תוסיף סוגים שלא ברשימה'),
        reason: 'the closed type list may not be extended');
  });
}
