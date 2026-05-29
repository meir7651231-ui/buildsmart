// Roadmap step 26 — hotWaterSuitabilityFor. Cross-checked against the engine's
// productSuitableForTemp so the card's count can't drift from the real rule.
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('suitable never exceeds total, total never exceeds brand count', () {
    for (final sp in kSmartProducts) {
      final r = hotWaterSuitabilityFor(sp);
      expect(r.suitable, lessThanOrEqualTo(r.total));
      expect(r.total, lessThanOrEqualTo(sp.brands.length));
      expect(r.tempC, 60);
    }
  });

  test('count matches the engine productSuitableForTemp rule', () {
    for (final sp in kSmartProducts) {
      var expected = 0;
      for (final b in sp.brands) {
        final prod = catalogProductForBrand(b);
        if (prod == null) continue;
        if (productSuitableForTemp(prod, 60)) expected++;
      }
      expect(hotWaterSuitabilityFor(sp).suitable, expected, reason: sp.key);
    }
  });

  test('a higher temperature never increases the suitable count', () {
    for (final sp in kSmartProducts) {
      final at60 = hotWaterSuitabilityFor(sp, tempC: 60).suitable;
      final at95 = hotWaterSuitabilityFor(sp, tempC: 95).suitable;
      expect(at95, lessThanOrEqualTo(at60), reason: sp.key);
    }
  });
}
