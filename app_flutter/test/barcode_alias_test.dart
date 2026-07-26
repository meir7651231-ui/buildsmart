// v2 barcode alias (owner template v2): a company may ship the scannable
// code in a 'ברקוד' spec column — both sku resolvers must match it, with
// OBJECT IDENTITY preserved (the stage3 invariant). Own file on purpose:
// related_info's sku index memoizes the FIRST universe it sees, so this
// isolate installs the overlay before anything touches the index — exactly
// the real app's order (hydrate before runApp).

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/related_info.dart' show catalogProductForSku;
import 'package:buildsmart/data/task_skus_local.dart' show productBySku;
import 'package:flutter_test/flutter_test.dart';

const _p = LipskeyCatalogProduct(
  sku: 'IN-77',
  nameHe: 'מחסום רצפה 50',
  nameEn: '',
  categoryHe: 'ניקוז',
  categoryEn: '',
  categoryEmoji: '🕳️',
  page: 0,
  brand: '',
  dims: {'ברקוד': '7290012345678'},
);

void main() {
  tearDown(() => setCompanyCatalog(null));

  test('both resolvers match the barcode alias — same object, never a copy',
      () {
    setCompanyCatalog(const [_p]);
    expect(identical(productBySku('7290012345678'), _p), isTrue);
    expect(identical(productBySku('IN-77'), _p), isTrue,
        reason: 'the sku itself still wins');
    expect(identical(catalogProductForSku('7290012345678'), _p), isTrue);
    expect(identical(catalogProductForSku('IN-77'), _p), isTrue);
    expect(productBySku('0000000000000'), isNull,
        reason: 'honest null on a genuine miss');
  });
}
