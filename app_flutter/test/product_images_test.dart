import 'package:buildsmart/data/product_images.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('productImageUrl', () {
    test('strips the assets/ prefix and joins onto the CDN base', () {
      expect(
        productImageUrl('assets/lipskey/products/116635.jpeg'),
        '$kImageBaseUrl/lipskey/products/116635.jpeg',
      );
    });

    test('preserves the nested folder structure for any catalog', () {
      expect(
        productImageUrl('assets/polyroll/pages/p80.jpg'),
        '$kImageBaseUrl/polyroll/pages/p80.jpg',
      );
    });

    test('never leaks an assets/ segment into the URL', () {
      expect(productImageUrl('assets/x.png').contains('assets/'), isFalse);
    });

    test('passes a path through unchanged when it has no assets/ prefix', () {
      expect(
        productImageUrl('lipskey/categories/icon.png'),
        '$kImageBaseUrl/lipskey/categories/icon.png',
      );
    });
  });
}
