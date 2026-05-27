import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Kaiser faucets all get same dedup key', () {
    final skus = ['779096G','779096B','779096C','779096S','779096F'];
    final products = skus.map((s) => kLipskeyCatalog.firstWhere((p) => p.sku == s)).toList();
    final keys = products.map(productListDedupeKey).toSet();
    print('Keys: $keys');
    for (final p in products) {
      print('${p.sku} "${p.nameHe}" → ${productListDedupeKey(p)}');
    }
    expect(keys.length, 1, reason: 'All Kaiser faucets should have the same dedup key');
  });

  test('attrWordSet contains מוברש and מט', () {
    // indirect: check that מוברש is stripped from key
    final p = kLipskeyCatalog.firstWhere((p) => p.sku == '779096G');
    final key = productListDedupeKey(p);
    print('779096G key: $key');
    expect(key.contains('מוברש'), false);
    expect(key.contains('זהב'), false);
    expect(key.contains('קיסר'), false);
  });
}
