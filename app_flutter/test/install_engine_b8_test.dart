// B8 — broad flattened-DN class. A set of reducers / couplers / caps had their
// ends lazily defaulted to a single DN (mostly [_c('50'),_c('50')]) regardless of
// the product name, so the engine accepted wrong-size joints and rejected the real
// ones. Restored from the product names. (Two ambiguous cases — ברך 40/49 and the
// thread-side elbow 32/32 — were intentionally left for human confirmation.)
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:flutter_test/flutter_test.dart';

Set<String> _sizes(String sku) =>
    kVerifiedSpecs[sku]!.ends.map((e) => e.size).toSet();
int _ends(String sku) => kVerifiedSpecs[sku]!.ends.length;

void main() {
  group('B8 — flattened-DN reducers/couplers expose their named DNs', () {
    test('reducers carry both named sizes', () {
      expect(_sizes('218568'), containsAll(['50', '40'])); // מצרה 50/40
      expect(_sizes('220316'), containsAll(['40', '32'])); // מצרה 40/32
      expect(_sizes('116680'), containsAll(['50', '32'])); // מצרה תבריג 50/32
      expect(_sizes('194897'), contains('110')); // מצרה לתיקון 110/100
      expect(_sizes('218567'), contains('160')); // מחבר כפול 160/160
    });
  });

  group('B8 — caps are single-ended at their named DN', () {
    test('a cap terminates ONE pipe (not a 2-ended pass-through)', () {
      expect(_ends('218569'), 1);
      expect(_sizes('218569'), {'110'}); // פקק חיצוני 110
      expect(_ends('218460'), 1);
      expect(_sizes('218460'), {'50'}); // פקק שקע-תקע 50
      expect(_ends('218560'), 1);
      expect(_sizes('218560'), {'160'}); // פקק שקע-תקע 160
      expect(_ends('220315'), 1);
      expect(_sizes('220315'), {'40'}); // פקק שקע-תקע 40
    });
  });
}
