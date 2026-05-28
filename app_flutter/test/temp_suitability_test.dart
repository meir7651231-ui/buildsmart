// Locks the data + logic behind the install-studio "קו חם" heat-rating warning:
// HDPE (capped ~40°C) is unfit for a hot line; PEX/copper/brass (rated ≥80°C)
// are fit. The studio banner flags any plan item where productSuitableForTemp
// is false at the line temperature.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HDPE is unfit for a hot (60°C) line but fine cold (≤40°C)', () {
    final hdpe = kLipskeyCatalog.firstWhere(
        (p) => kVerifiedSpecs[p.sku]?.material == 'HDPE');
    expect(productMaxTempC(hdpe), 40);
    expect(productSuitableForTemp(hdpe, 20), isTrue);
    expect(productSuitableForTemp(hdpe, 40), isTrue);
    expect(productSuitableForTemp(hdpe, 60), isFalse);
  });

  test('a heat-rated material (≥80°C) passes a hot line', () {
    final hot = kLipskeyCatalog.firstWhere(
        (p) => (kVerifiedSpecs[p.sku]?.maxTempC ?? 0) >= 80);
    expect(productSuitableForTemp(hot, 60), isTrue);
    expect(productSuitableForTemp(hot, 80), isTrue);
  });

  test('unknown-spec products are not flagged (no false hot-line alarm)', () {
    // Accessories without a spec must never trip the warning.
    final noSpec = kLipskeyCatalog
        .firstWhere((p) => !kVerifiedSpecs.containsKey(p.sku));
    expect(productSuitableForTemp(noSpec, 90), isTrue);
  });
}
