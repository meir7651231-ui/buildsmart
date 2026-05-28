// Sanity-check the pressure-drop estimator on the 6-hop brass→HDPE chain we
// proved BFS can build. We expect a non-trivial drop because the chain goes
// from BSP 1/2" (~15mm) up through DN25/40 — the narrowest bore dominates.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ΔP on the 6-hop brass→HDPE chain at typical flow', () {
    final from = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');
    final to = kLipskeyCatalog.firstWhere((p) => p.sku == '9106306310');
    final chain = findShortestPath(from, to, maxDepth: 10);
    expect(chain, isNotNull);
    print('Chain (${chain!.length} parts):');
    for (var i = 0; i < chain.length; i++) {
      print('  ${i + 1}. ${chain[i].productType ?? "?"} — ${chain[i].nameHe}');
    }

    final r = estimatePressureDrop(chain, pipeLengthMeters: 5, flowRateLPS: 0.3);
    print('\n$r');
    if (r.warnings.isNotEmpty) {
      print('\nWarnings:');
      for (final w in r.warnings) print('  ⚠️  $w');
    }

    // Validate the numbers fall in a sane engineering range.
    expect(r.dropBar, greaterThan(0));
    expect(r.dropBar, lessThan(20)); // not absurd
    expect(r.minBoreMm, lessThanOrEqualTo(20)); // limited by ½" thread ~15mm
  });

  test('ΔP scales with flow rate and length', () {
    final chain = [
      kLipskeyCatalog.firstWhere((p) => p.sku == '9101601610'),
      kLipskeyCatalog.firstWhere((p) => p.sku == '9102001230'),
      kLipskeyCatalog.firstWhere((p) => p.sku == '9101601610'),
    ];

    final low = estimatePressureDrop(chain, pipeLengthMeters: 2, flowRateLPS: 0.1);
    final high = estimatePressureDrop(chain, pipeLengthMeters: 20, flowRateLPS: 0.5);
    print('Low flow / short run: $low');
    print('High flow / long run: $high');

    expect(high.dropBar, greaterThan(low.dropBar));
  });
}
