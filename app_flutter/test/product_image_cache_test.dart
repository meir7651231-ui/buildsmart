// productImage cacheWidth (POLISH P2 perf): a thumbnail cell should cap decode
// size via ResizeImage instead of decoding full-res. Pins that the provider is
// wrapped ONLY when cacheWidth/cacheHeight is set.
import 'package:buildsmart/data/product_images.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cacheWidth ⇒ provider wrapped in ResizeImage', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: productImage('x/y.png', width: 48, height: 48, cacheWidth: 96),
    ));
    final img = tester.widget<Image>(find.byType(Image));
    expect(img.image, isA<ResizeImage>());
    expect((img.image as ResizeImage).width, 96);
  });

  testWidgets('no cacheWidth ⇒ raw provider (full resolution)', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: productImage('x/y.png', width: 48, height: 48),
    ));
    final img = tester.widget<Image>(find.byType(Image));
    expect(img.image, isNot(isA<ResizeImage>()));
  });
}
