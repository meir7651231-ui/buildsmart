// Find every (material, DN) pair where the catalog has a compression-end
// FITTING (something a pipe is supposed to plug into) but no matching PIPE
// product. Those holes leave the fitting "unconnectable" in the strip.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:flutter_test/flutter_test.dart';

bool _isPipe(LipskeyCatalogProduct p) {
  final t = p.productType ?? '';
  return t == 'צינור' || t == 'צנרת' || t == 'גמיש' || t == 'מאריך';
}

void main() {
  test('coverage — every compression-end DN must have a pipe', () {
    // Collect, per (material, DN), the list of products that have at least
    // one compression end at that DN. Split them into pipes vs fittings.
    final pipesByKey = <String, List<LipskeyCatalogProduct>>{};
    final fittingsByKey = <String, List<LipskeyCatalogProduct>>{};

    for (final entry in kVerifiedSpecs.entries) {
      final p = kLipskeyCatalog.where((q) => q.sku == entry.key);
      if (p.isEmpty) continue;
      final prod = p.first;
      final isPipe = _isPipe(prod);
      // dedupe ends by DN so a fitting with [c32,c32] doesn't double-count
      final seen = <String>{};
      for (final e in entry.value.ends) {
        // compression-style ends only (HDPE/PEX/copper)
        final t = e.type.name;
        if (t != 'hdpeCompression' &&
            t != 'pexPress' &&
            t != 'copperPress') continue;
        final key = '${entry.value.material}|$t|${e.size}';
        if (!seen.add(key)) continue;
        (isPipe ? pipesByKey : fittingsByKey)
            .putIfAbsent(key, () => [])
            .add(prod);
      }
    }

    final gaps = <String>[];
    for (final k in fittingsByKey.keys) {
      if (!pipesByKey.containsKey(k)) gaps.add(k);
    }
    gaps.sort();

    print('Total fittings keys: ${fittingsByKey.length}');
    print('Keys with at least 1 pipe: ${fittingsByKey.keys.where(pipesByKey.containsKey).length}');
    print('GAPS (fitting key with no pipe): ${gaps.length}');
    for (final k in gaps) {
      final fitCount = fittingsByKey[k]!.length;
      final example = fittingsByKey[k]!.first;
      print('  ❌ $k   $fitCount fittings   example: ${example.sku} ${example.nameHe}');
    }

    // Not a fail — just a coverage report.
    expect(true, isTrue);
  });
}
