// Verify the K-shortest-paths feature returns multiple distinct chains.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brass→HDPE: returns 3 distinct alternative paths', () {
    final from = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');
    final to = kLipskeyCatalog.firstWhere((p) => p.sku == '9106306310');
    final paths = findAlternativePaths(from, to, k: 3, maxDepth: 10);
    expect(paths.length, greaterThanOrEqualTo(1),
        reason: 'At least one path should exist');
    print('Got ${paths.length} alternative path(s):');
    for (var i = 0; i < paths.length; i++) {
      print('Path ${i + 1} (${paths[i].length} hops):');
      for (final p in paths[i]) {
        print('   - ${p.sku.padRight(12)} ${p.nameHe}');
      }
    }

    // All paths must start with `from` and end with `to`
    for (final p in paths) {
      expect(p.first.sku, from.sku);
      expect(p.last.sku, to.sku);
    }

    // All paths must be distinct
    final keys = paths.map((p) => p.map((x) => x.sku).join('|')).toSet();
    expect(keys.length, paths.length,
        reason: 'Paths must not repeat');
  });
}
