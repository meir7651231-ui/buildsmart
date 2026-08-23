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
  });
}
