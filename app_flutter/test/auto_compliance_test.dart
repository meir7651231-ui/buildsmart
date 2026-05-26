// Regression tests for _autoAddCompliance via autoCompliance:true.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _find(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku);

void main() {
  // Two hot-water anchors: copper ball valve DN20 → Kaiser faucet (BSP ½")
  final ball = _find('HW-BALL-CU-20');
  final faucet = _find('779096G');

  group('auto-compliance (autoCompliance:true) — 10 בדיקות', () {
    test('1. tempC=20 לא מוסיף PRV', () {
      final plan = buildInstallation([ball, faucet],
          tempC: 20, autoCompliance: true);
      expect(plan.quantities.containsKey('HW-PRV-34'), isFalse);
    });

    test('2. tempC=60 מוסיף PRV אוטומטית', () {
      final plan = buildInstallation([ball, faucet],
          tempC: 60, autoCompliance: true);
      expect(plan.quantities.containsKey('HW-PRV-34'), isTrue,
          reason: 'PRV required on every closed hot line');
    });

    test('3. tempC=60 מוסיף Bladder Tank אוטומטית', () {
      final plan = buildInstallation([ball, faucet],
          tempC: 60, autoCompliance: true);
      final hasTank = plan.quantities.containsKey('HW-BTANK-35') ||
          plan.quantities.containsKey('HW-BTANK-18') ||
          plan.quantities.containsKey('HW-EXPVESSEL');
      expect(hasTank, isTrue,
          reason: 'expansion vessel required on every hot line');
    });

    test('4. tempC=60 מוסיף ברז ניתוק אם אין', () {
      // faucet→faucet: no ball valve in path
      final faucet2 = _find('7777113A');
      final plan = buildInstallation([faucet, faucet2],
          tempC: 60, autoCompliance: true);
      final ballSkus = {
        'HW-BALL-INLET-1', 'HW-BALL-INLET-40',
        'HW-BALL-1', 'HW-BALL-15', 'HW-BALL-40', 'HW-BALL-32',
        'HW-BALL-CU-40', 'HW-BALL-CU-32', 'HW-BALL-CU-25', 'HW-BALL-CU-20',
      };
      expect(ballSkus.any(plan.quantities.containsKey), isTrue,
          reason: 'isolation ball valve required');
    });

    test('5. ברז ניתוק קיים → לא מוסיף כפול', () {
      final plan = buildInstallation([ball, faucet],
          tempC: 60, autoCompliance: true);
      // ball is HW-BALL-CU-20 — already present
      final ballCount = plan.quantities.entries
          .where((e) => e.key.startsWith('HW-BALL'))
          .map((e) => e.value)
          .fold(0, (a, b) => a + b);
      // should have exactly 1 ball valve entry (the anchor), not 2
      expect(ballCount, equals(1));
    });

    test('6. PRV מופיע ב-BOM items list', () {
      final plan = buildInstallation([ball, faucet],
          tempC: 60, autoCompliance: true);
      expect(plan.items.any((p) => p.sku == 'HW-PRV-34'), isTrue);
    });

    test('7. autoCompliance=false לא מוסיף PRV', () {
      final plan = buildInstallation([ball, faucet],
          tempC: 60, autoCompliance: false);
      expect(plan.quantities.containsKey('HW-PRV-34'), isFalse);
    });

    test('8. PRV כבר קיים → לא מוסיף כפול', () {
      final prv = _find('HW-PRV-34');
      final plan = buildInstallation([ball, prv, faucet],
          tempC: 60, autoCompliance: true);
      expect(plan.quantities['HW-PRV-34'], equals(1));
    });

    test('9. Bladder Tank כבר קיים → לא מוסיף כפול', () {
      final btank = _find('HW-BTANK-35');
      final plan = buildInstallation([ball, btank, faucet],
          tempC: 60, autoCompliance: true);
      expect(plan.quantities['HW-BTANK-35'], equals(1));
    });

    test('10. buildTreeInstallation עם autoCompliance מוסיף PRV', () {
      final inlet = _find('HW-BALL-INLET-1');
      final manif = _find('HW-MANIFOLD-4');
      final bv1 = _find('HW-BALL-1');
      final bv2 = _find('HW-BALL-15');
      final plan = buildTreeInstallation(
        [inlet, manif], [bv1, bv2],
        tempC: 60, autoCompliance: true,
      );
      expect(plan.quantities.containsKey('HW-PRV-34'), isTrue,
          reason: 'tree hot install must also auto-include PRV');
    });
  });
}
