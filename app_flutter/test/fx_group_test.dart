// FX converter thousands-grouping (finance_hub_sheets _FxCalc). Regression
// (POLISH run-3, LOW): the amount echo lost comma grouping on FRACTIONAL input
// (`v.toString()`), so "1234567.5" rendered ungrouped. fxGroupAmount now groups
// the integer part and keeps the fractional tail.
import 'package:buildsmart/screens/finance_hub_sheets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#fx thousands grouping', () {
    test('integers group with commas', () {
      expect(fxGroupInt(1234567), '1,234,567');
      expect(fxGroupInt(0), '0');
      expect(fxGroupInt(999), '999');
      expect(fxGroupInt(-1234567), '-1,234,567');
    });

    test('fractional amounts keep grouping on the integer part (the bug)', () {
      expect(fxGroupAmount(1234567.5), '1,234,567.5');
      expect(fxGroupAmount(1000.25), '1,000.25');
      expect(fxGroupAmount(0.5), '0.5');
      expect(fxGroupAmount(-1234.5), '-1,234.5');
    });

    test('integer-valued doubles drop the trailing .0', () {
      expect(fxGroupAmount(1234567), '1,234,567');
      expect(fxGroupAmount(1000000), '1,000,000');
    });

    // Nightly 2026-11-26 — crash guards. "0.0000001" passes the number keyboard
    // and validPositiveAmount, but `toString()` is "1e-7" (no '.') →
    // substring(0, -1) threw a RangeError inside build().
    test('tiny fractions in exponential form never throw', () {
      expect(fxGroupAmount(0.0000001), '0');
      expect(fxGroupAmount(0.0000015), '0.0000015');
      expect(fxGroupAmount(-0.0000001), '-0');
    });

    test('non-finite / huge values never throw', () {
      expect(fxGroupAmount(double.infinity), 'Infinity');
      expect(fxGroupAmount(double.nan), 'NaN');
      expect(() => fxGroupAmount(1e300), returnsNormally);
    });
  });

  group('#fx converter result line', () {
    const rates = {'USD': 3.72, 'EUR': 4.05};

    test('converts at the shown rate, grouped', () {
      expect(fxCalcResult('1000', 'USD', rates), '1,000 USD = ₪3,720');
      expect(fxCalcResult(' 2500.5 ', 'EUR', rates), '2,500.5 EUR = ₪10,127');
    });

    test('missing rate (live backend: no FX feed) → honest, NOT a 1:1 rate',
        () {
      // The bug: `rate ?? 1` showed "1,000 USD = ₪1,000" to real users.
      final line = fxCalcResult('1000', 'USD', const {});
      expect(line, '1,000 USD = אין שער זמין');
      expect(line.contains('₪'), isFalse);
    });

    test('NaN / Infinity / exponent / tiny input never throws', () {
      for (final raw in ['NaN', '1e999', '-1e999', '0.0000001', '1e300', '']) {
        expect(() => fxCalcResult(raw, 'USD', rates), returnsNormally,
            reason: 'input "$raw"');
        expect(() => fxCalcResult(raw, 'USD', const {}), returnsNormally,
            reason: 'input "$raw" (no rate)');
      }
      expect(fxCalcResult('NaN', 'USD', rates), '0 USD = ₪0');
    });
  });
}
