// The BOM sheet's budget estimate, copied list and "add to cart" must count the
// same units: pipes by ceil(metres), everything else by the plan quantity.
// Before the fix the estimate/copy used plan.qtyOf (1 per pipe) while the cart
// added ceil(metres) — a PP pipe at the default 2 m read ~₪42 but cost ₪84.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/bom_quantity.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _firstIn(String cat) =>
    kLipskeyCatalog.firstWhere((p) => p.categoryHe == cat);

void main() {
  final pipe = _firstIn('צינורות PP'); // ₪42 / unit in price_estimate
  final elbow = _firstIn('ברכיים'); // ₪18 / unit, not a pipe

  InstallationPlan plan(Map<String, int> q) =>
      InstallationPlan([pipe, elbow], const [], q);

  test('fixtures: one pipe, one non-pipe', () {
    expect(isPipe(pipe), isTrue);
    expect(isPipe(elbow), isFalse);
  });

  test('bomLineQty — pipe counts ceil(metres), not the plan quantity', () {
    final p = plan({pipe.sku: 1, elbow.sku: 3});
    expect(bomLineQty(pipe, p, (_) => 2.0), 2);
    expect(bomLineQty(pipe, p, (_) => 6.5), 7);
    expect(bomLineQty(pipe, p, (_) => 0.5), 1);
    expect(
      bomLineQty(elbow, p, (_) => 6.5),
      3,
      reason: 'non-pipes ignore metres and use the plan quantity',
    );
  });

  test('estimateBomPrice — default 2 m pipe is priced as 2 units (₪84)', () {
    final p = plan({pipe.sku: 1, elbow.sku: 1});
    final pr = estimateBomPrice(p, (_) => 2.0);
    expect(pr.totalILS, 2 * 42 + 18);
    expect(pr.itemCount, 3);
  });

  test('estimateBomPrice follows the metres stepper', () {
    final p = plan({pipe.sku: 1, elbow.sku: 2});
    final short = estimateBomPrice(p, (_) => 2.0).totalILS;
    final long = estimateBomPrice(p, (_) => 6.5).totalILS;
    expect(long, 7 * 42 + 2 * 18);
    expect(long - short, 5 * 42);
  });

  test('estimate equals the sum the cart is built from', () {
    final p = plan({pipe.sku: 1, elbow.sku: 4});
    double metersOf(String _) => 3.5;
    // _addToCart: brandPrice = estimatePrice([p]).totalILS, qty = bomLineQty.
    final cartSum =
        42 * bomLineQty(pipe, p, metersOf) +
        18 * bomLineQty(elbow, p, metersOf);
    expect(estimateBomPrice(p, metersOf).totalILS, cartSum);
  });

  test('empty plan → zero estimate', () {
    final pr = estimateBomPrice(const InstallationPlan([], [], {}), (_) => 2.0);
    expect(pr.totalILS, 0);
  });
}
