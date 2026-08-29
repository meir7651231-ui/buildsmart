// B6 spec-data fixes:
//  E6 — 224156 (PP-MD-ML DN110 drainage pipe) was maxTempC 80, a lone outlier in
//       a family where every identical sibling is 70 → inconsistent accept/reject
//       of physically-identical pipes on a ~71-80°C line.
//  E3 — reducing branch tees had their larger DN ERASED (ends flattened to all
//       DN50), so a DN50 pipe was accepted onto a physically large socket and the
//       real DN110/DN75 joint was rejected. Restore the named DNs.
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:flutter_test/flutter_test.dart';

Set<String> _endSizes(String sku) =>
    kVerifiedSpecs[sku]!.ends.map((e) => e.size).toSet();

void main() {
  group('B6 — spec data: reducing-branch ends + temp outlier', () {
    test('E6: 224156 maxTempC matches its PP DN110 siblings (70, not 80)', () {
      expect(kVerifiedSpecs['224156']!.maxTempC, 70);
      expect(kVerifiedSpecs['224345']!.maxTempC, 70); // identical sibling, reference
      expect(kVerifiedSpecs['224169']!.maxTempC, 70);
    });
    test('E3: reducing branches expose ALL their named DNs (not a single DN)', () {
      // 116558 "מסעף 87° 110/50" — had been flattened to all-DN50.
      expect(_endSizes('116558'), containsAll(['110', '50']));
      // 217533 "75/50" — DN75 had been erased.
      expect(_endSizes('217533'), containsAll(['75', '50']));
      // 218564 "מסעף כפול 110/50/50" — DN110 had been erased.
      expect(_endSizes('218564'), containsAll(['110', '50']));
    });
  });
}
