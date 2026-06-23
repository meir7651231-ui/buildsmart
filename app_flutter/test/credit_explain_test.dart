// Pins the AI credit explainer (#ai-credit-explain): the prompt HANDS Claude the
// real credit figures (limit / used / balance / %) and forbids inventing or
// changing any number — a credit call is a money decision. Pure — no gateway,
// no widget pump.
import 'package:buildsmart/screens/credit_explain_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creditExplainPrompt carries the customer + every real figure', () {
    final p = creditExplainPrompt(
      name: 'יוסי כהן',
      creditLimit: 80000,
      used: 72000,
      balance: 8000,
      pct: 90,
    );
    expect(p, contains('יוסי כהן'), reason: 'the customer is named');
    expect(p, contains('₪80000'), reason: 'the real credit limit is given');
    expect(p, contains('₪72000'), reason: 'the real used amount is given');
    expect(p, contains('₪8000'), reason: 'the real balance is given');
    expect(p, contains('90%'), reason: 'the real utilisation % is given');
  });

  test('creditExplainPrompt forbids inventing or changing numbers', () {
    final p = creditExplainPrompt(
      name: 'X',
      creditLimit: 1,
      used: 1,
      balance: 0,
      pct: 100,
    );
    expect(p, contains('אך ורק במספרים שניתנו'),
        reason: 'must use only the given numbers');
    expect(p, contains('אל תמציא'),
        reason: 'the model may not invent a number');
  });
}
