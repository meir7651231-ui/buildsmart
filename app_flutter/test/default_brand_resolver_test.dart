// Roadmap step 51 — default-brand resolver (precedence: selection → history → rec).
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/state/default_brand_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

SmartProduct _testProduct() {
  // Pick any SmartProduct that has ≥ 2 brands so we can exercise the
  // selection/history paths meaningfully.
  return kSmartProducts.firstWhere((sp) => sp.brands.length >= 2);
}

void main() {
  test('cardSelection wins when it names a real brand', () {
    final sp = _testProduct();
    final b1 = sp.brands[1].name;
    final i = resolveDefaultBrandIndex(
      sp: sp,
      cardSelection: b1,
      brandHistoryFav: sp.brands[0].name, // would otherwise win
    );
    expect(sp.brands[i].name, b1);
  });

  test('brand-history fallback when cardSelection is null', () {
    final sp = _testProduct();
    final b1 = sp.brands[1].name;
    final i = resolveDefaultBrandIndex(
      sp: sp,
      cardSelection: null,
      brandHistoryFav: b1,
    );
    expect(sp.brands[i].name, b1);
  });

  test('recommended brand is the final default', () {
    final sp = _testProduct();
    final i = resolveDefaultBrandIndex(
      sp: sp,
      cardSelection: null,
      brandHistoryFav: null,
    );
    final recIdx = sp.brands.indexWhere((b) => b.rec);
    if (recIdx >= 0) expect(i, recIdx);
    else expect(i, 0);
  });

  test('unknown brand names are skipped (no crash, falls through)', () {
    final sp = _testProduct();
    final i = resolveDefaultBrandIndex(
      sp: sp,
      cardSelection: 'NOT A REAL BRAND',
      brandHistoryFav: 'ALSO NOT REAL',
    );
    final recIdx = sp.brands.indexWhere((b) => b.rec);
    expect(i, recIdx >= 0 ? recIdx : 0);
  });

  test('history wins when selection names an unknown brand', () {
    final sp = _testProduct();
    final histName = sp.brands[1].name;
    final i = resolveDefaultBrandIndex(
      sp: sp,
      cardSelection: 'GHOST BRAND',
      brandHistoryFav: histName,
    );
    expect(sp.brands[i].name, histName);
  });
}
