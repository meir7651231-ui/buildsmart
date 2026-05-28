// Stress-test the BFS: can it build a chain of N products?
// We deliberately pick distant endpoints so the path must traverse many
// adapters/reducers.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BFS — longest chain it can build with maxDepth=20', () {
    // Cross-material supply chain: 1/2" brass nipple → HDPE 63×63 coupling.
    // After the water-system fix this should now find a path (brass + HDPE
    // are both supply, joined by HDPE↔BSP threaded adapters).
    final from = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');
    final to = kLipskeyCatalog.firstWhere((p) => p.sku == '9106306310');

    for (final depth in [3, 6, 10, 15, 20]) {
      final path = findShortestPath(from, to, maxDepth: depth);
      print('maxDepth=$depth → ${path == null ? "no path" : "${path.length} hops"}');
      if (path != null) {
        for (var i = 0; i < path.length; i++) {
          final p = path[i];
          final mat = kVerifiedSpecs[p.sku]?.material ?? '?';
          final ends = kVerifiedSpecs[p.sku]?.ends.map((e) => '${e.type.name}|${e.size}').join(',') ?? '';
          print('   ${i + 1}. ${p.sku.padRight(12)} [$mat]  $ends   ${p.nameHe}');
        }
      }
    }

    // Also try a deliberately CRAZY long path: faucet to garden hose nozzle.
    print('\n--- Stress: faucet → garden tap ---');
    final faucet = kLipskeyCatalog.firstWhere((p) => p.sku == '77777315');
    final gardenTap = kLipskeyCatalog.firstWhere(
        (p) => kVerifiedSpecs[p.sku] != null && p.productType == 'ברז גן',
        orElse: () => kLipskeyCatalog.firstWhere((p) => p.sku == '77777316'));
    print('from: ${faucet.sku} ${faucet.nameHe}');
    print('to:   ${gardenTap.sku} ${gardenTap.nameHe}');
    final p = findShortestPath(faucet, gardenTap, maxDepth: 20);
    print(p == null ? 'no path' : '${p.length} hops');
  });
}
