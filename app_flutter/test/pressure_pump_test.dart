// Pins the booster-pump auto-fix + guards the whole HW-PUMP-40 catalog-resolution
// bug class (loop round-3): autoFlowFix resolved HW-PUMP-40 against kLipskeyCatalog
// (where it doesn't exist) → the pump was NEVER prepended (a dead auto-fix). The
// same SKU is the only `addProductSku` the BOM-sheet recommended-add consumes.
import 'package:buildsmart/data/lipskey_catalog.dart' show kLipskeyCatalog;
import 'package:buildsmart/data/lipskey_hotwater.dart' show kCompatCatalog;
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A connectable supply pair (proven in install_plan_coverage). High pipe
  // length / flow / vertical rise force ΔP well over the 1-bar pump threshold.
  final chain = [
    kCompatCatalog.firstWhere((p) => p.sku == '779096G'),
    kCompatCatalog.firstWhere((p) => p.sku == '77778071'),
  ];

  test('autoFlowFix prepends the booster pump on high ΔP (HW-PUMP-40 resolved)', () {
    final fixed = autoFlowFix(chain,
        pipeLengthMeters: 1000, flowRateLPS: 5, verticalRiseMeters: 50);
    expect(fixed.chain.any((p) => p.sku == 'HW-PUMP-40'), isTrue,
        reason: 'the previously-dead auto-fix now actually prepends the pump');
    expect(fixed.changes.any((c) => c.contains('משאבת הגברה')), isTrue);
  });

  test('estimatePressureDrop offers the pump add-suggestion on high ΔP', () {
    final pd = estimatePressureDrop(chain,
        pipeLengthMeters: 1000, flowRateLPS: 5, verticalRiseMeters: 50);
    expect(pd.suggestions.any((s) => s.addProductSku == 'HW-PUMP-40'), isTrue,
        reason: 'the suggestion the BOM-sheet add path consumes points at the pump');
  });

  test('HW-PUMP-40 is reachable ONLY via kCompatCatalog (guards both swaps)', () {
    expect(kCompatCatalog.any((p) => p.sku == 'HW-PUMP-40'), isTrue);
    expect(kLipskeyCatalog.any((p) => p.sku == 'HW-PUMP-40'), isFalse,
        reason: 'reverting any HW-PUMP-40 resolve to kLipskeyCatalog drops it → red');
  });
}
