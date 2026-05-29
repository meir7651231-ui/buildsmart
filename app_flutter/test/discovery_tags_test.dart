// Roadmap step 67 — discovery tags. Pure helper over SmartProduct + brand.
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tags are unique and never throw, across the whole tree', () {
    var withTags = 0;
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        final tags = discoveryTagsFor(sp, b);
        expect(tags.toSet().length, tags.length, reason: '${sp.key}/${b.name}');
        if (tags.isNotEmpty) withTags++;
      }
    }
    // The tree should surface tags on a meaningful number of brands.
    expect(withTags, greaterThan(0));
  });

  test('the recommended brand always carries the pro-recommended tag', () {
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        if (b.rec) {
          expect(discoveryTagsFor(sp, b), contains('⭐ מומלץ מקצועי'),
              reason: sp.key);
        }
      }
    }
  });

  test('cheapest/priciest tags only appear when prices actually differ', () {
    for (final sp in kSmartProducts) {
      final prices =
          sp.brands.where((b) => b.price != null).map((b) => b.price!).toSet();
      if (prices.length <= 1) {
        for (final b in sp.brands) {
          final tags = discoveryTagsFor(sp, b);
          expect(tags.contains('💰 הכי משתלם'), isFalse);
          expect(tags.contains('👑 פרימיום'), isFalse);
        }
      }
    }
  });
}
