// Guards the product-image semantics rule (lib/data/product_images.dart):
// an UNLABELLED product image is decorative (the name is shown as text beside
// it) → excluded from semantics so a screen reader doesn't announce a useless
// "image"; a caller that passes a [semanticLabel] gets it announced.
import 'package:buildsmart/data/product_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('productImage semantics', () {
    testWidgets('unlabelled product image is decorative (excluded)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: productImage('assets/lipskey/products/x.jpeg')),
      );
      final img = tester.widget<Image>(find.byType(Image));
      expect(img.excludeFromSemantics, isTrue);
      expect(img.semanticLabel, isNull);
    });

    testWidgets('labelled product image is announced', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: productImage('assets/lipskey/products/x.jpeg',
              semanticLabel: 'מחבר PPR'),
        ),
      );
      final img = tester.widget<Image>(find.byType(Image));
      expect(img.excludeFromSemantics, isFalse);
      expect(img.semanticLabel, 'מחבר PPR');
    });
  });
}
