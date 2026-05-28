// The תאימות carousel shows a "🔗 why it matches" label per product. Invariant:
// every product returned by compatibleProductsFor MUST have a non-empty
// connectionExplainHe — i.e. the explanation logic never falls out of sync with
// the matching logic. (A real mate always has a describable joint.)
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every compat hit has a non-empty connection explanation', () {
    final specced =
        kLipskeyCatalog.where((p) => kVerifiedSpecs.containsKey(p.sku)).toList();
    expect(specced.length, greaterThan(30));

    final samples = <LipskeyCatalogProduct>[];
    final step = (specced.length ~/ 30).clamp(1, 9999);
    for (var i = 0; i < specced.length && samples.length < 30; i += step) {
      samples.add(specced[i]);
    }

    var totalHits = 0;
    final blanks = <String>[];
    final examples = <String>[];
    for (final src in samples) {
      for (final h in compatibleProductsFor(src)) {
        totalHits++;
        final why = connectionExplainHe(src, h);
        if (why.isEmpty) {
          blanks.add('${src.sku} ↔ ${h.sku}');
        } else if (examples.length < 8) {
          examples.add('${src.sku} ↔ ${h.sku}: $why');
        }
      }
    }

    print('Checked $totalHits hits across ${samples.length} sources.');
    print('Sample explanations:');
    for (final e in examples) print('  • $e');
    if (blanks.isNotEmpty) {
      print('\nHits with NO explanation:');
      for (final b in blanks.take(15)) print('  ✗ $b');
    }
    expect(blanks, isEmpty,
        reason: '${blanks.length} compat hits had no connection label');
  });

  test('label format reflects the joint kind', () {
    // A BSP thread mate reads "תבריג …"; a compression mate reads "אום הידוק DN…".
    final brassNipple = kLipskeyCatalog.where((p) =>
        kVerifiedSpecs[p.sku]?.ends
            .any((e) => e.type == EndType.bspMale) ??
        false);
    if (brassNipple.isNotEmpty) {
      final src = brassNipple.first;
      final hits = compatibleProductsFor(src);
      final threaded = hits
          .map((h) => connectionExplainHe(src, h))
          .where((w) => w.startsWith('תבריג'));
      expect(threaded, isNotEmpty,
          reason: 'a threaded product should mate via תבריג at least once');
    }
  });
}
