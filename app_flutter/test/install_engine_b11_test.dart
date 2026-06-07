// B11 / D4 — flow directionality (warning increment). Check valves (אל-חזור /
// אלחוזר) and sewage backflow preventers (category 'אל חזור') are one-way devices,
// but the model stores their two ends identically, so the (undirected) engine
// cannot reject a backwards orientation. Until a directed-search model lands, the
// checklist WARNS that a line contains a directional valve whose orientation must
// be verified by hand. (Full orientation ENFORCEMENT is a separate design task.)
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((q) => q.sku == sku);

bool _orientationFlagged(List<LipskeyCatalogProduct> chain) =>
    lineComplianceChecklist(chain, 20, const {})
        .any((c) => c.label.contains('כיוון התקנה'));

void main() {
  group('D4 — directional valve orientation warning', () {
    test('a check valve (אל-חזור) flags the line for orientation', () {
      expect(_orientationFlagged([_p('77777201'), _p('77004401')]), isTrue);
    });
    test('a sewage backflow preventer (אל חזור ביוב) flags the line', () {
      expect(_orientationFlagged([_p('777D0481')]), isTrue);
    });
    test('the angled check valve variant (אלחוזר, no space) is detected', () {
      expect(_orientationFlagged([_p('77004416')]), isTrue);
    });
    test('a line without a directional device is NOT flagged', () {
      expect(_orientationFlagged([_p('77777201'), _p('779096G')]), isFalse);
    });
    test('the orientation check is a warning (manual verification, no enforcement)',
        () {
      final c = lineComplianceChecklist([_p('77004401')], 20, const {})
          .firstWhere((c) => c.label.contains('כיוון התקנה'));
      expect(c.severity, CheckSeverity.warning); // never critical
      expect(c.satisfied, isFalse); // can't be auto-satisfied — manual check
    });
  });
}
