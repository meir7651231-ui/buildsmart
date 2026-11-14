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
    group('#fx converter never throws / never invents a rate', () {
    test('tiny amounts with exponential toString() are written out', () {
      // 1e-7.toString() == "1e-7" — used to throw a RangeError (no '.').
      expect(fxGroupAmount(0.0000001), '0.0000001');
      expect(fxGroupAmount(-0.0000001), '-0.0000001');
    });

    test('huge and non-finite amounts do not throw', () {
      expect(fxGroupAmount(1e20), '100,000,000,000,000,000,000');
      expect(fxGroupAmount(double.infinity), 'Infinity');
      expect(() => fxGroupAmount(1e300), returnsNormally);
    });

    test('fxConvertIls: rounds and groups the ₪ side', () {
      expect(fxConvertIls(1000, 3.7), '3,700');
      expect(fxConvertIls(0.5, 3.7), '2');
    });

    test('fxConvertIls: no rate → null (no fabricated 1:1)', () {
      expect(fxConvertIls(1000, null), isNull);
      expect(fxConvertIls(1000, 0), isNull);
    });

    test('fxConvertIls: invalid / overflowing amounts → null, never throws', () {
      expect(fxConvertIls(null, 3.7), isNull);
      expect(fxConvertIls(-5, 3.7), isNull);
      expect(fxConvertIls(double.infinity, 3.7), isNull); // "1e999"
      expect(fxConvertIls(1e308, 3.7), isNull); // product overflows
      expect(fxConvertIls(1e300, 3.7), isNotNull); // huge but finite
    });
  });
});
}
