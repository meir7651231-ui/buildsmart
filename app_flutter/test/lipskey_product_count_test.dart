import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

// Guards the fake-data-sweep S4 fix: the "ליפסקי ברקן" supplier tile shows the LIVE
// Lipskey product count (kLipskeyProductCount), not a hardcoded literal — it once
// showed "66", ~14× understated. Pinning the count to the real catalog length means
// a future edit can't silently revert the tile to a stale number, and screens read
// this count instead of kLipskeyCatalog directly (gate 114 / lesson #69).
void main() {
  test('kLipskeyProductCount mirrors the live Lipskey catalog length', () {
    expect(kLipskeyProductCount, kLipskeyCatalog.length);
  });

  test('kLipskeyProductCount is the full catalog, never the old fake "66"', () {
    // ~923 today; a floor well above the old literal (66) ensures the supplier
    // tile can never regress to a small hardcoded number.
    expect(kLipskeyProductCount, greaterThan(900));
  });
}
