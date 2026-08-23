// Pins the #barcode-plus resolve split (camera_sheet._onDetect): a scanned code
// that matches a catalog SKU resolves to that product (→ the product card opens);
// any unknown/empty/null code resolves to null (→ the honest "not found" toast).
// This is the exact found/not-found branch that drives sheet-vs-toast — tested
// against the pure `catalogProductForSku`, no scanner/widget pump needed.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a real catalog SKU round-trips to its product', () {
    final realSku = kLipskeyCatalog.first.sku;
    final p = catalogProductForSku(realSku);
    expect(p, isNotNull, reason: 'a scanned real SKU opens the product card');
    expect(p!.sku, realSku, reason: 'resolves to the SAME product (no mismatch)');
  });

  test('an unknown / empty / null code resolves to null (→ honest miss)', () {
    expect(catalogProductForSku('NOPE-12345'), isNull);
    expect(catalogProductForSku(''), isNull);
    expect(catalogProductForSku(null), isNull,
        reason: 'the not-found branch drives the "לא נמצא במק\\"ט" toast');
  });
}
