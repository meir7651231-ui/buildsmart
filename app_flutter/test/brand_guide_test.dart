// Roadmap step 16 — brandDecisionGuide. Pure helper over SmartProduct brands.
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guide returns one entry per brand, order-stable', () {
    for (final sp in kSmartProducts) {
      final guide = brandDecisionGuide(sp);
      expect(guide.length, sp.brands.length, reason: sp.key);
      for (var i = 0; i < sp.brands.length; i++) {
        expect(guide[i].brand, sp.brands[i].name);
        expect(guide[i].advice, isNotEmpty);
      }
    }
  });

  test('the recommended brand is always flagged as recommended', () {
    for (final sp in kSmartProducts) {
      if (sp.brands.isEmpty) continue;
      final rec = sp.recBrand;
      final guide = brandDecisionGuide(sp);
      final recEntry = guide.firstWhere((g) => g.brand == rec.name);
      // recBrand may be the first fallback (no rec flag); only assert the
      // label when the brand actually carries the rec flag.
      if (rec.rec) {
        expect(recEntry.advice, contains('מומלץ'));
      }
    }
  });

  test('cheapest brand gets the low-price note when prices differ', () {
    // Find a SmartProduct whose brands have at least two distinct prices.
    SmartProduct? spread;
    for (final sp in kSmartProducts) {
      final prices =
          sp.brands.where((b) => b.price != null).map((b) => b.price!).toSet();
      if (prices.length > 1) {
        spread = sp;
        break;
      }
    }
    if (spread != null) {
      final guide = brandDecisionGuide(spread);
      expect(guide.any((g) => g.advice.contains('המחיר הנמוך ביותר')), isTrue,
          reason: spread.key);
    }
  });
}
