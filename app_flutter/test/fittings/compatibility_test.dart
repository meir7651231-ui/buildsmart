// 🔑 Phase E-lite slice 2 — compatibility golden (M5: zero build-able over-match).
// The capability delegates to the verified canConnect; the golden pins faithful
// delegation, self-exclusion, and — the safety-critical property — that an
// obviously-incompatible pair is NEVER reported compatible.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/fittings/intel/compatibility.dart';
import 'package:buildsmart/logic/install_engine.dart' show canConnect;
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku, String nameHe) => LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: '',
      categoryHe: 'אביזרי קצה HDPE',
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

void main() {
  final coupler32 = _p('C32', 'מצמד 32');
  final elbow32 = _p('E32', 'ברך 90° 32');
  final coupler50 = _p('C50', 'מצמד 50');

  test('🔑 pairCompatible delegates to canConnect EXACTLY (no loosening)', () {
    for (final a in [coupler32, elbow32, coupler50]) {
      for (final b in [coupler32, elbow32, coupler50]) {
        expect(pairCompatible(a, b), canConnect(a, b),
            reason: 'wrapper must equal canConnect for ${a.sku}↔${b.sku}',);
      }
    }
  });

  test('🛡️ M5 — an obviously-incompatible pair (no size overlap) is NEVER compatible', () {
    // 32mm vs 50mm — no shared connection size ⇒ must not mate (over-match = leak).
    expect(pairCompatible(coupler32, coupler50), isFalse);
    expect(incompatibilityReason(coupler32, coupler50), isNotNull);
  });

  test('self-pairing is never compatible (canConnect rejects equal sku)', () {
    expect(pairCompatible(coupler32, coupler32), isFalse);
  });

  test('incompatibilityReason is null iff the pair is compatible', () {
    for (final a in [coupler32, elbow32, coupler50]) {
      for (final b in [coupler32, elbow32, coupler50]) {
        expect(incompatibilityReason(a, b) == null, canConnect(a, b));
      }
    }
  });

  test('🛡️ compatibleTargets contains ONLY canConnect matches, excludes self', () {
    final universe = [coupler32, elbow32, coupler50];
    final targets = compatibleTargets(coupler32, universe);
    // never contains itself
    expect(targets.any((t) => t.sku == coupler32.sku), isFalse);
    // every returned target genuinely canConnect — zero over-match
    for (final t in targets) {
      expect(canConnect(coupler32, t), isTrue);
    }
    // and a non-matching product (50mm) is excluded
    expect(targets.any((t) => t.sku == coupler50.sku), isFalse);
  });
}
