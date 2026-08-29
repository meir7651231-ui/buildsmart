// Pins the zero-regression adapter (step 35): fromLegacy → toLegacy reconstructs the
// exact LipskeyCatalogProduct the screens render. LipskeyCatalogProduct has no `==`,
// so we compare field-by-field (incl. dims, the singular/plural images, brand, and
// the derived connectionSizes). A curated set covers dims/images/color/brands; the
// whole catalog is then swept for any silent SKU/dims/brand/connectionSizes drift.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/domain/trade_product_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void expectByteIdentical(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
    expect(b.sku, a.sku, reason: 'sku');
    expect(b.nameHe, a.nameHe, reason: 'nameHe');
    expect(b.nameEn, a.nameEn, reason: 'nameEn');
    expect(b.color, a.color, reason: 'color');
    expect(b.qtyPack, a.qtyPack, reason: 'qtyPack');
    expect(b.qtyPallet, a.qtyPallet, reason: 'qtyPallet');
    expect(b.categoryHe, a.categoryHe, reason: 'categoryHe');
    expect(b.categoryEn, a.categoryEn, reason: 'categoryEn');
    expect(b.categoryEmoji, a.categoryEmoji, reason: 'categoryEmoji');
    expect(b.page, a.page, reason: 'page');
    expect(b.dims, a.dims, reason: 'dims');
    expect(b.imageFile, a.imageFile, reason: 'imageFile');
    expect(b.imageFiles, a.imageFiles, reason: 'imageFiles');
    expect(b.specImageFile, a.specImageFile, reason: 'specImageFile');
    expect(b.specImageFiles, a.specImageFiles, reason: 'specImageFiles');
    expect(b.brand, a.brand, reason: 'brand');
    expect(b.connectionSizes, a.connectionSizes, reason: 'connectionSizes');
  }

  test('round-trips a curated set byte-for-byte (dims/images/color/brands)', () {
    final samples = <LipskeyCatalogProduct>[
      kCatalogProducts.first,
      kCatalogProducts
          .firstWhere((p) => p.dims != null && p.dims!.isNotEmpty),
      kCatalogProducts
          .firstWhere((p) => p.imageFiles != null && p.imageFiles!.isNotEmpty),
      kCatalogProducts.firstWhere(
        (p) => p.color != null,
        orElse: () => kCatalogProducts.first,
      ),
      kCatalogProducts.firstWhere(
        (p) => p.specImageFile != null,
        orElse: () => kCatalogProducts.first,
      ),
      for (final brand in {'ליפסקי', 'פולירול', 'חוליות'})
        kCatalogProducts.firstWhere(
          (p) => p.brand == brand,
          orElse: () => kCatalogProducts.first,
        ),
    ];
    for (final p in samples) {
      expectByteIdentical(p, tradeProductFromLegacy(p).toLegacy());
    }
  });

  test('the WHOLE catalog round-trips with no SKU/dims/brand/size drift', () {
    for (final p in kCatalogProducts) {
      final back = tradeProductFromLegacy(p).toLegacy();
      expect(back.sku, p.sku);
      expect(back.dims, p.dims, reason: 'dims drift @ ${p.sku}');
      expect(back.brand, p.brand, reason: 'brand drift @ ${p.sku}');
      expect(back.connectionSizes, p.connectionSizes,
          reason: 'connectionSizes drift @ ${p.sku}');
    }
    expect(kCatalogProducts, isNotEmpty); // non-vacuous
  });
}
