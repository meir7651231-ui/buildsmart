// Count exactly how many products in the catalog have a bspFemale 1/2" end —
// that's the set that should physically receive the brass nipple #77777641.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brass 1/2 nipple compat audit', () {
    final src = kLipskeyCatalog.firstWhere((p) => p.sku == '77777641');
    final hits = compatibleProductsFor(src);
    print('Total compat hits for 77777641 (1/2" double brass nipple): ${hits.length}');

    // bucket by material/category so we can see what we're showing
    final byMaterial = <String, int>{};
    final byCat = <String, int>{};
    for (final p in hits) {
      final m = kVerifiedSpecs[p.sku]!.material;
      byMaterial[m] = (byMaterial[m] ?? 0) + 1;
      byCat[p.categoryHe] = (byCat[p.categoryHe] ?? 0) + 1;
    }
    print('by material:');
    for (final e in byMaterial.entries) print('  ${e.key}: ${e.value}');
    print('by category (top 10):');
    final sorted = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted.take(10)) print('  ${e.key}: ${e.value}');

    // What ends do the source have?
    final spec = kVerifiedSpecs['77777641']!;
    print('source ends: ${spec.ends.map((e) => "${e.type}|${e.size}").toList()}');

    // Sanity: every hit must have at least one bspFemale 1/2" end (since the
    // source is 2× bspMale 1/2" and that's the only direct mate)
    var wrong = 0;
    for (final p in hits) {
      final sp = kVerifiedSpecs[p.sku]!;
      final hasF12 = sp.ends.any((e) => e.type.name == 'bspFemale' && e.size == '1/2"');
      if (!hasF12) {
        wrong++;
        print('  ❌ unexpected hit: ${p.sku} ${p.nameHe} — ends ${sp.ends.map((e) => "${e.type}|${e.size}").toList()}');
        if (wrong > 5) break;
      }
    }
    print('hits without bspFemale 1/2": $wrong');
  });
}
