// Roadmap step 65 — brandSuitableForHot (quick "hot-water only" brand filter).
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches the engine rule for every resolvable brand', () {
    var checked = 0;
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        final prod = catalogProductForBrand(b);
        if (prod == null) {
          expect(brandSuitableForHot(b), isTrue, reason: 'spec-less → kept');
          continue;
        }
        final t = kVerifiedSpecs[prod.sku]?.maxTempC;
        final expected = t == null || 60 <= t;
        expect(brandSuitableForHot(b), expected, reason: '${sp.key}/${b.name}');
        checked++;
      }
    }
    expect(checked, greaterThan(0));
  });

  test('a higher temperature filter is never more permissive', () {
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        if (brandSuitableForHot(b, tempC: 95)) {
          // if it passes at 95, it must also pass at 60
          expect(brandSuitableForHot(b, tempC: 60), isTrue);
        }
      }
    }
  });

  test('brandIsMetallic: spec-less kept; non-metal rejected; metal kept', () {
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        final prod = catalogProductForBrand(b);
        if (prod == null) {
          expect(brandIsMetallic(b), isTrue, reason: 'spec-less → kept');
          continue;
        }
        final mat = kVerifiedSpecs[prod.sku]?.material;
        final expected =
            mat == null || const {'נחושת', 'פליז', 'פלדה'}.contains(mat);
        expect(brandIsMetallic(b), expected, reason: '${sp.key}/${b.name}');
      }
    }
  });
}
