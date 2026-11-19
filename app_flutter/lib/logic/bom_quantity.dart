// One quantity rule for every BOM line — the budget estimate, the copied
// shopping list and "add to cart" must all count the SAME units.
//
// Pipes are sold by length: the BOM sheet's metres stepper (default 2.0 m)
// decides how many units go to the cart (`ceil(metres)`). The on-sheet
// "הערכת תקציב" and the copied BOM text used `plan.qtyOf` instead (1 for a
// pipe), so a PP pipe at the default 2 m showed ~₪42 while the cart charged
// 2 × ₪42 = ₪84 — and stepping the length to 6.5 m never moved the estimate.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/price_estimate.dart';

/// Units of [p] the BOM puts in the cart: `ceil(metres)` for a pipe (sold by
/// length, [metersOf] is the sheet's stepper value), else the plan quantity.
int bomLineQty(
  LipskeyCatalogProduct p,
  InstallationPlan plan,
  double Function(String sku) metersOf,
) => isPipe(p) ? metersOf(p.sku).ceil() : plan.qtyOf(p.sku);

/// Budget estimate of the whole BOM, counted with [bomLineQty] — the same
/// units "add to cart" adds.
PriceEstimate estimateBomPrice(
  InstallationPlan plan,
  double Function(String sku) metersOf,
) {
  final expanded = <LipskeyCatalogProduct>[];
  for (final p in plan.items) {
    final q = bomLineQty(p, plan, metersOf);
    for (var i = 0; i < q; i++) {
      expanded.add(p);
    }
  }
  return estimatePrice(expanded);
}
