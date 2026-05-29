// Roadmap step 20 — manufacturer + part-number.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('part number equals the SKU; manufacturer is non-empty', () {
    var checked = 0;
    for (final p in kLipskeyCatalog) {
      final info = manufacturerInfoFor(p);
      if (p.sku.isEmpty) {
        expect(info, isNull);
        continue;
      }
      expect(info, isNotNull, reason: p.sku);
      expect(info!.partNumber, p.sku);
      expect(info.manufacturer, isNotEmpty);
      checked++;
    }
    expect(checked, greaterThan(0));
  });

  test('blank brand falls back to the house manufacturer', () {
    final blank =
        kLipskeyCatalog.where((p) => p.brand.trim().isEmpty && p.sku.isNotEmpty);
    for (final p in blank) {
      expect(manufacturerInfoFor(p)!.manufacturer, 'לפסקי-ברקן');
    }
  });
}
