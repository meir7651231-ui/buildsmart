// Roadmap step 23 — chainArrowText (inline materialized chain formatting).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty → empty string', () {
    expect(chainArrowText(const []), '');
  });

  test('preserves order and joins with the RTL arrow', () {
    final items = kLipskeyCatalog.take(3).toList();
    final text = chainArrowText(items);
    expect(text, '${items[0].nameHe} ← ${items[1].nameHe} ← ${items[2].nameHe}');
    // arrow count = items - 1
    expect(' ← '.allMatches(text).length, items.length - 1);
  });

  test('formats a real materialized plan without throwing', () {
    LipskeyCatalogProduct? a;
    LipskeyCatalogProduct? b;
    for (final p in kLipskeyCatalog) {
      final c = compatibleProductsFor(p);
      if (c.isNotEmpty) {
        a = p;
        b = c.first;
        break;
      }
    }
    final plan = buildInstallation([a!, b!], tempC: 60);
    final text = chainArrowText(plan.items);
    expect(text, contains(a.nameHe));
    expect(text, isNotEmpty);
  });
}
