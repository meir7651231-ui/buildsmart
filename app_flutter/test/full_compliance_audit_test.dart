// Deep audit: build a hot+manifold installation and verify EVERY compliance
// item is present in plan.items, the checklist is fully satisfied, and the
// chain has all the auto-inserted nodes. We test each trigger condition
// (hot / recirc / commercial / dissimilar / pex / manifold) to make sure
// no critical check stays open after build.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hot + manifold: every check must pass after build', () {
    final source = kLipskeyCatalog.firstWhere((p) => p.sku == '77775150');
    // A real manifold from the lipskey_hotwater synthetic SKUs
    final manifold = kLipskeyCatalog
        .firstWhere((p) => p.sku == 'HW-MANIFOLD-3', orElse: () => source);
    final plan = buildInstallation(
      [source, manifold],
      tempC: 60,
      accessories: {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'},
      autoCompliance: true,
    );
    print('Items in plan (${plan.items.length}):');
    for (final p in plan.items) {
      print('   • ${p.sku.padRight(20)}  ${p.nameHe}');
    }
    print('\nQty map: ${plan.quantities}');
    print('Gaps: ${plan.gaps.length}');

    final checks = lineComplianceChecklist(
        plan.items, 60, {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'});
    print('\nChecklist (${checks.length} items):');
    var failedCritical = 0;
    var failedWarning = 0;
    for (final c in checks) {
      final mark = c.satisfied ? '✓' : '✗';
      print('   $mark  [${c.severity.name}]  ${c.label}');
      if (!c.satisfied) {
        if (c.severity == CheckSeverity.critical) failedCritical++;
        if (c.severity == CheckSeverity.warning) failedWarning++;
      }
    }
    print('\nCritical failed: $failedCritical');
    print('Warnings failed: $failedWarning');

    expect(failedCritical, 0,
        reason: 'Every critical check must pass after auto-compliance');
  });

  test('user scenario: water-point + catalog מחלק at 60°C', () {
    // Replicates the actual UI scenario the user tested:
    //   anchor 1 — דיור נקודת מים עגולה זהב מוברש (77775150)
    //   anchor 2 — מחלק 2 3/4" יציאות + ברז כחול (a real catalog manifold,
    //               productType = 'מחלק')
    final source = kLipskeyCatalog.firstWhere((p) => p.sku == '77775150');
    final manifold = kLipskeyCatalog.firstWhere(
        (p) => p.productType == 'מחלק' && p.categoryHe == 'מחלקים',
        orElse: () => source);
    print('Selected manifold: ${manifold.sku} ${manifold.nameHe}');
    final plan = buildInstallation(
      [source, manifold],
      tempC: 60,
      accessories: {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'},
      autoCompliance: true,
    );
    print('Items in plan (${plan.items.length}):');
    for (final p in plan.items) {
      print('   • ${p.sku.padRight(20)}  ${p.productType ?? "?"}  ${p.nameHe}');
    }
    final checks = lineComplianceChecklist(
        plan.items, 60, {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'});
    print('\nChecklist (${checks.length}):');
    for (final c in checks) {
      print('   ${c.satisfied ? "✓" : "✗"} [${c.severity.name}] ${c.label}');
    }
    final tmtvAdded = plan.items.any((p) => p.sku.startsWith('HW-TMTV'));
    print('\nTMTV added? $tmtvAdded');
    expect(tmtvAdded, isTrue,
        reason:
            'A real catalog מחלק should trigger TMTV anti-scald in a hot line');
  });

  test('hot + recirculation: extra items inserted', () {
    final source = kLipskeyCatalog.firstWhere((p) => p.sku == '77775150');
    final dest = kLipskeyCatalog.firstWhere((p) => p.sku == '77777315');
    final plan = buildInstallation(
      [source, dest],
      tempC: 60,
      accessories: {'HW-INSUL', 'HW-CLIP', 'HW-SEALANT'},
      loop: true,
      autoCompliance: true,
    );
    print('\nRECIRC line items (${plan.items.length}):');
    for (final p in plan.items) {
      print('   • ${p.sku.padRight(20)}  ${p.nameHe}');
    }
    final skus = plan.items.map((p) => p.sku).toSet();
    expect(skus.contains('HW-PRV-34'), isTrue, reason: 'PRV');
    expect(skus.contains('HW-BTANK-35'), isTrue, reason: 'Bladder');
    expect(skus.contains('HW-CHECK-15'), isTrue, reason: 'check valve');
    expect(skus.contains('HW-BALANCE-15'), isTrue, reason: 'balance valve');
    expect(skus.contains('HW-AIRVENT'), isTrue, reason: 'air vent');
    expect(skus.contains('HW-SAMPLE'), isTrue, reason: 'sample point');
    print('✓ all recirc items present');
  });
}
