// Roadmap step 68 — deep link per product, and its inclusion in the quote.
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('link starts with the product path and is well-formed for every product',
      () {
    for (final sp in kSmartProducts) {
      final link = deepLinkFor(sp);
      expect(link, startsWith('https://buildsmart.app/p/'));
      // parses as a URI without throwing
      expect(Uri.tryParse(link), isNotNull, reason: sp.key);
    }
  });

  test('brand index adds an encoded brand query param', () {
    final sp = kSmartProducts.firstWhere((s) => s.brands.isNotEmpty);
    final link = deepLinkFor(sp, 0);
    expect(link, contains('?brand='));
    final uri = Uri.parse(link);
    expect(uri.queryParameters['brand'], sp.brands[0].name);
  });

  test('out-of-range brand index → no query param', () {
    final sp = kSmartProducts.first;
    expect(deepLinkFor(sp, 999), isNot(contains('?brand=')));
  });

  test('the quote text embeds the deep link', () {
    for (final sp in kSmartProducts.take(20)) {
      expect(quoteTextFor(sp, 0), contains('https://buildsmart.app/p/'));
    }
  });
}
