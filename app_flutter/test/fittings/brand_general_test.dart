// 🔑 Phase A (steps 19+21) — brand-general connectivity, proven via the THREE
// complementary registration paths that all feed kVerifiedSpecs by putIfAbsent:
//   · registerPolyrollSpecs  — PPR built-in (welding sockets)
//   · registerFamilySpecs    — Huliot built-in (category/name INFERENCE)
//   · registerCompanySpecs   — any uploaded catalog (DECLARED spec columns)
// "Every future brand connects" = one of these paths covers it, none overwrites
// another, order-independent. The upload seam (step 21) is already wired into
// hydrateCompanyCatalog; here we prove it composes cleanly and is brand-general.
import 'package:buildsmart/data/company_spec_bridge.dart';
import 'package:buildsmart/data/family_specs.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _uploaded(
  String sku,
  String name,
  String brand, {
  Map<String, dynamic>? dims,
}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: name,
      nameEn: name,
      categoryHe: 'אביזר',
      categoryEn: 'fitting',
      categoryEmoji: '🔧',
      page: 1,
      brand: brand,
      dims: dims,
    );

void main() {
  group('step 21 — upload seam: a company catalog connects via DECLARED columns', () {
    test('an arbitrary brand with declared ends+material gets a spec (brand-general)', () {
      // A made-up brand — proves the seam is brand-general (no hard-coded list).
      final up = _uploaded('UP-1', 'מצמד כלשהו 32', 'AcmePipes', dims: {
        'קצה 1': '32',
        'קצה 2': '32',
        'חומר': 'PEX',
      },);
      final spec = companySpecFor(up);
      expect(spec, isNotNull, reason: 'declared ends+material must derive a spec');
      expect(spec!.material, 'PEX');
      expect(spec.ends.length, 2);
    });

    test('honest-absent: a push-fit end with no material → null (never fabricates M2)', () {
      final up = _uploaded('UP-2', 'x', 'AcmePipes', dims: {'קצה 1': '32'});
      // hdpeCompression end + empty material ⇒ null (material-driven family
      // must not be invented from '').
      expect(companySpecFor(up), isNull);
    });
  });

  group('step 19 — the three paths compose (putIfAbsent, order-independent, no overwrite)', () {
    test('polyroll + family(Huliot) + company all seed without clobbering each other', () {
      // Snapshot the static map identity for a few keys.
      final before = <String, VerifiedSpec>{
        for (final e in kVerifiedSpecs.entries.take(30)) e.key: e.value,
      };

      // Run all three registration paths (any order).
      registerCompanySpecs([
        _uploaded('CO-77', 'מצמד 50', 'AcmePipes',
            dims: {'קצה 1': '50', 'קצה 2': '50', 'חומר': 'PVC'},),
      ]);
      registerFamilySpecs();
      registerPolyrollSpecs();
      // …and again, reversed — idempotent + order-independent.
      registerPolyrollSpecs();
      registerFamilySpecs();

      // No static/earlier spec was overwritten (identity preserved).
      for (final e in before.entries) {
        expect(identical(kVerifiedSpecs[e.key], e.value), isTrue,
            reason: '${e.key}: a pre-existing spec was overwritten',);
      }
      // The uploaded product is present and connects to another PVC-DN50.
      final co = kVerifiedSpecs['CO-77'];
      expect(co, isNotNull);
      expect(co!.material, 'PVC');
    });
  });
}
