// Regression tests for zone-tagging (ב) and TMTV auto-per-branch (ג).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _find(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku);

void main() {
  group('zone-tagging + TMTV auto-per-branch — 10 בדיקות', () {
    // trunk: ball-inlet 1" → manifold-4 (DN20 Cu inlet, 4× ½" BSP-F outlets)
    final inlet  = _find('HW-BALL-INLET-1');
    final manif4 = _find('HW-MANIFOLD-4');
    // branch targets (½" BSP-Male faucets)
    final faucet1 = _find('779096G');  // Kaiser kitchen faucet ½" BSP-M
    final faucet2 = _find('77777316'); // ball valve 2" — find a ½" one
    // use two verified ½" ball valves as branch targets
    final bv1 = _find('HW-BALL-1');
    final bv2 = _find('HW-BALL-15');

    test('1. tree plan מחזיר zones לא ריק', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 20,
      );
      expect(plan.zones, isNotEmpty,
          reason: 'tree installation must carry zone labels');
    });

    test('2. zones מכיל "גזע"', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 20,
      );
      expect(plan.zones.containsKey('גזע'), isTrue);
    });

    test('3. zones מכיל "ענף א"', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 20,
      );
      expect(plan.zones.containsKey('ענף א'), isTrue,
          reason: 'first branch must be labelled ענף א');
    });

    test('4. zones מכיל "ענף ב" לשני ענפים', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 20,
      );
      expect(plan.zones.containsKey('ענף ב'), isTrue);
    });

    test('5. גזע מכיל את ה-SKU של המחלק', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 20,
      );
      expect(plan.zones['גזע'], contains(manif4.sku));
    });

    test('6. ענף א מכיל את הברז הראשון', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 20,
      );
      expect(plan.zones['ענף א'], contains(bv1.sku));
    });

    test('7. TMTV-15 לא מתווסף כשקר (tempC=20)', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 20,
      );
      expect(plan.quantities.containsKey('HW-TMTV-15'), isFalse,
          reason: 'TMTV must not appear for cold lines');
    });

    test('8. TMTV-15 מתווסף אוטומטית לחם (tempC=60)', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 60,
      );
      expect(plan.quantities.containsKey('HW-TMTV-15'), isTrue,
          reason: 'TMTV must be auto-added for hot lines');
    });

    test('9. כמות TMTV = מספר ענפים', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 60,
      );
      expect(plan.qtyOf('HW-TMTV-15'), equals(2),
          reason: 'one TMTV per branch: 2 branches → qty 2');
    });

    test('10. TMTV נמצא בזונה של הענף (לא גזע)', () {
      final plan = buildTreeInstallation(
        [inlet, manif4],
        [bv1, bv2],
        tempC: 60,
      );
      final inTrunk = (plan.zones['גזע'] ?? []).contains('HW-TMTV-15');
      final inBranchA = (plan.zones['ענף א'] ?? []).contains('HW-TMTV-15');
      expect(inTrunk, isFalse, reason: 'TMTV belongs in branches, not trunk');
      expect(inBranchA, isTrue, reason: 'TMTV must appear in branch-A zone');
    });
  });
}
