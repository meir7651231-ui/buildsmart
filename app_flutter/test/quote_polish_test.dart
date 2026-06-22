// Pins the AI quote-polish feature (#ai-quote-polish): the prompt HANDS Claude the
// raw quote and forbids changing/adding/removing any number — Claude may only
// re-phrase. A quote that mutates a price is a business disaster, so this guard is
// the whole safety story. Pure — no gateway, no widget pump.
import 'package:buildsmart/screens/quote_polish_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quotePolishPrompt carries the raw quote verbatim', () {
    const raw = 'הצעת מחיר — ברז כיור\n'
        'מותג: עודד\n'
        'מוצר: ~₪280\n'
        'אביזרים: ~₪45\n'
        'עבודה (משוער): ~₪120\n'
        'סה"כ משוער: ~₪445';
    final p = quotePolishPrompt(raw);
    // Every line of the real quote must reach the model unchanged.
    for (final line in raw.split('\n')) {
      expect(p, contains(line), reason: 'raw quote line preserved: $line');
    }
  });

  test('quotePolishPrompt forbids changing/inventing numbers', () {
    final p = quotePolishPrompt('סה"כ משוער: ~₪445');
    expect(p, contains('שמור על כל מספר'),
        reason: 'every number must be preserved exactly');
    expect(p, contains('אל תשנה'),
        reason: 'the model may not change a price/amount');
    expect(p, contains('ואל תמציא'),
        reason: 'the model may not invent details');
  });
}
