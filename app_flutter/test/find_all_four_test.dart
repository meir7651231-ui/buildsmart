// One-shot scan: find catalog products whose product sheet would show ALL
// four info strips (finder + compat + kit + variants). Run via:
//   flutter test test/find_all_four_test.dart
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog products with all four info strips', () {
    final winners = <(LipskeyCatalogProduct, int)>[];
    for (final p in kLipskeyCatalog) {
      if (finderGroupFor(p) == null) continue;
      if (compatibleProductsCount(p) == 0) continue;
      if (smartProductForSku(p.sku) == null) continue;
      final sibs = variantSiblingsCountFor(p);
      if (sibs <= 1) continue;
      winners.add((p, sibs));
    }
    winners.sort((a, b) => b.$2.compareTo(a.$2));
    print('Total with all 4: ${winners.length}');
    for (final (p, sibs) in winners.take(10)) {
      final compat = compatibleProductsCount(p);
      final sp = smartProductForSku(p.sku)!;
      final must = sp.acc.where((a) => a.must).length;
      final opt = sp.acc.length - must;
      print(
          'SKU ${p.sku}  finder=${finderGroupFor(p)!.label}  compat=$compat  kit=$must/$opt  siblings=$sibs');
      print('   ${p.nameHe}');
    }
  });
}
