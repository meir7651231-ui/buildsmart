// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 38 — THE KEYSTONE.
//
// Proves the generated plumbing seed (`buildPlumbingSeed()`, step 36/37) is
// ANSWER-EQUIVALENT to the live hard-coded plumbing engine. The seed must lose
// no physics: a THIN in-test resolver built only from the seed's authored
// connector data (productSpecs + compatRules) must reproduce
// `install_engine.connectionMethodLabel` EXACTLY, byte-for-byte, across the
// whole verified catalogue — and the galvanic completion rule must match the
// engine's copper-group↔iron-group grouping.
//
// The real resolver lands in a later step (39/40); this test stands up its own
// minimal resolver so the equivalence is locked NOW, before the engine is
// retired. A genuine failure here is a VALUABLE finding: it means the seed
// diverges from the engine and step 37 needs a fix. Nothing is softened to pass.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/domain/seeds/plumbing_trade_seed.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final seed = buildPlumbingSeed();

  // sku → seeded connector spec (built from ALL kVerifiedSpecs entries).
  final Map<String, ProductConnectorSpec> specsBySku = {
    for (final s in seed.productSpecs) s.productSku: s,
  };
  // sku → catalog product (so we can call the live engine, which only reads
  // `.sku` off each LipskeyCatalogProduct).
  final Map<String, LipskeyCatalogProduct> prodBySku = {
    for (final p in kCatalogProducts) p.sku: p,
  };

  // A THIN resolver over the seed that MIRRORS connectionMethodLabel
  // byte-for-byte: eA outer, eB inner, FIRST match wins. No package:collection —
  // the plain loop returns on the first matching (end, end, rule).
  String seedMethod(String skuA, String skuB) {
    final a = specsBySku[skuA];
    final b = specsBySku[skuB];
    if (a == null || b == null) return '';
    for (final eA in a.ends) {
      for (final eB in b.ends) {
        for (final r in seed.compatRules) {
          final pair = (r.aTypeId == eA.connectorTypeId &&
                  r.bTypeId == eB.connectorTypeId) ||
              (r.aTypeId == eB.connectorTypeId &&
                  r.bTypeId == eA.connectorTypeId);
          final sizeOk = r.sizeMatch == SizeMatch.exactSame
              ? eA.sizeValue == eB.sizeValue
              : true;
          if (pair && sizeOk) return r.methodLabelHe;
        }
      }
    }
    return '';
  }

  test('seed reproduces install_engine.connectionMethodLabel (THE keystone)',
      () {
    final skus = kVerifiedSpecs.keys.where(prodBySku.containsKey).toList()
      ..sort();
    expect(skus, isNotEmpty,
        reason: 'no verified-spec sku is present in the seeded catalog — '
            'the sweep would be vacuous');

    // One probe per EndType: the FIRST sku (sorted) whose spec carries an end of
    // that type. EndTypes with no product in the (verified ∩ catalog) set are
    // recorded as uncovered — they are NOT faked into a probe.
    final probes = <String>[];
    final coveredTypes = <EndType>{};
    for (final t in EndType.values) {
      for (final s in skus) {
        final hasEnd = kVerifiedSpecs[s]!.ends.any((e) => e.type == t);
        if (hasEnd) {
          probes.add(s);
          coveredTypes.add(t);
          break;
        }
      }
    }
    expect(probes, isNotEmpty);
    // Most EndTypes must be exercised — assert ≥5 of the 6 are covered. If one
    // genuinely has no product in the intersection that is acceptable (noted via
    // coveredTypes), but the keystone must not silently shrink to a trivial set.
    expect(coveredTypes.length, greaterThanOrEqualTo(5),
        reason: 'probes cover only $coveredTypes of ${EndType.values}');

    // The full sweep: every verified sku × every probe, seed vs engine.
    var sawNonEmpty = false;
    var sawEmpty = false;
    for (final s in skus) {
      for (final p in probes) {
        final fromSeed = seedMethod(s, p);
        final fromEngine =
            connectionMethodLabel(prodBySku[s]!, prodBySku[p]!);
        expect(fromSeed, fromEngine, reason: '$s × $p');
        if (fromEngine.isNotEmpty) sawNonEmpty = true;
        if (fromEngine.isEmpty) sawEmpty = true;
      }
    }
    // Non-vacuity: the sweep must actually exercise BOTH a real mate (non-empty
    // label) and a non-mate ('') — otherwise the equivalence proves nothing.
    expect(sawNonEmpty, isTrue,
        reason: 'no pair mated — the keystone never exercised a real joint');
    expect(sawEmpty, isTrue,
        reason: 'every pair mated — the keystone never exercised a non-joint');
  });

  test('every VerifiedSpec is faithfully projected (no info loss)', () {
    expect(kVerifiedSpecs, isNotEmpty);
    kVerifiedSpecs.forEach((sku, spec) {
      final ps = specsBySku[sku];
      expect(ps, isNotNull, reason: 'spec $sku missing from the seed');
      expect(ps!.materialId, spec.material, reason: '$sku material');
      expect(ps.envelope['maxTempC'], spec.maxTempC, reason: '$sku maxTempC');
      expect(ps.ends.length, spec.ends.length, reason: '$sku end count');
      for (var i = 0; i < spec.ends.length; i++) {
        expect(ps.ends[i].connectorTypeId,
            'plumbing.conn.${spec.ends[i].type.name}',
            reason: '$sku end $i type');
        expect(ps.ends[i].sizeValue, spec.ends[i].size,
            reason: '$sku end $i size');
      }
    });
  });

  test('galvanic rule matches the engine grouping', () {
    // The seed must carry the dielectric-union completion rule whose
    // incompatible groups are exactly the engine's copper-group↔iron-group
    // (install_engine `_galvanicallyDissimilar`).
    expect(
      seed.completionRules.any((c) =>
          c.incompatibleMaterialGroups
              ?.toSet()
              .containsAll({'copper-group', 'iron-group'}) ??
          false),
      isTrue,
      reason: 'no completion rule pairs copper-group with iron-group',
    );

    // Per-spec grouping sanity over ALL verified specs (a superset of "sample a
    // few"): copper/brass → copper-group; steel/stainless → iron-group; and the
    // galvanically-benign materials (HDPE/PEX/PVC/…) carry no group at all.
    const copperGroupMaterials = {'נחושת', 'פליז'};
    const ironGroupMaterials = {'פלדה', 'נירוסטה'};
    var sawCopper = false;
    var sawIron = false;
    kVerifiedSpecs.forEach((sku, spec) {
      final ps = specsBySku[sku]!;
      if (copperGroupMaterials.contains(spec.material)) {
        expect(ps.materialGroupId, 'copper-group',
            reason: '$sku (${spec.material}) → copper-group');
        sawCopper = true;
      } else if (ironGroupMaterials.contains(spec.material)) {
        expect(ps.materialGroupId, 'iron-group',
            reason: '$sku (${spec.material}) → iron-group');
        sawIron = true;
      } else {
        expect(ps.materialGroupId, isNull,
            reason: '$sku (${spec.material}) is galvanically benign');
      }
    });
    // Non-vacuity: at least one of each metal group must exist in the data, so
    // the grouping assertions above are actually exercised.
    expect(sawCopper, isTrue, reason: 'no copper-group material in the specs');
    expect(sawIron, isTrue, reason: 'no iron-group material in the specs');
  });
}
