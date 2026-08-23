// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 40 — G-RESOLVER
// PARITY.
//
// The REAL production resolver (step 39 — `ConnectionResolver`,
// lib/domain/connection_resolver.dart), constructed from the SEEDED connection
// matrix (step 37 — `buildPlumbingSeed()`), must reproduce the legacy
// hard-coded engine's answers EXACTLY — before any screen calls it. Green here
// is the PRECONDITION for step 41 (flag-gated wiring).
//
// Successor of the step-38 KEYSTONE (test/trade_seed_equivalence_test.dart):
// the same (kVerifiedSpecs ∩ kCatalogProducts) × one-probe-per-EndType sweep
// and the same non-vacuity guards, but the keystone's thin in-test
// `seedMethod` is replaced by the production `ConnectionResolver`. The legacy
// engine-side pins — test/compat_50_samples_test.dart and
// test/full_compliance_audit_test.dart — remain UNTOUCHED: they keep pinning
// the engine itself while this file pins resolver↔engine equivalence.
//
// NOTE (documented, not softened): the resolver compares sizes via
// `normalizeSize` (strips '"', trims) while the engine's
// `directMatesWith`/`pipeSharedWith` compare RAW size strings. The sweeps
// below surface any seeded pair where that difference matters — a genuine
// failure here is a VALUABLE finding (the resolver or the seed diverges from
// the engine); fix THOSE, never this test. Nothing is softened to pass.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/domain/connection_resolver.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/domain/seeds/plumbing_trade_seed.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final seed = buildPlumbingSeed();

  // The REAL resolver (step 39) over the SEEDED matrix (step 37) — the exact
  // construction step 41 hands to the screens behind the flag.
  final resolver = ConnectionResolver(
    rules: seed.compatRules,
    connectorTypes: seed.connectorTypes,
    systems: seed.systems,
    completionRules: seed.completionRules,
  );

  // sku → seeded connector spec (one per kVerifiedSpecs entry — the faithful
  // projection is itself locked by the step-38 keystone).
  final specsBySku = {for (final s in seed.productSpecs) s.productSku: s};
  // sku → catalog product, so the live engine can be called (it only reads
  // `.sku` off each product).
  final prodBySku = {for (final p in kCatalogProducts) p.sku: p};

  test(
      'the REAL resolver reproduces connectionMethodLabel across the '
      'verified catalog (G-resolver)', () {
    final skus = kVerifiedSpecs.keys.where(prodBySku.containsKey).toList()
      ..sort();
    expect(
      skus,
      isNotEmpty,
      reason: 'no verified-spec sku is present in the unified catalog — '
          'the sweep would be vacuous',
    );

    // One probe per EndType: the FIRST sku (sorted) whose spec carries an end
    // of that type. EndTypes with no product in the (verified ∩ catalog) set
    // are recorded as uncovered — they are NOT faked into a probe.
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
    // Most EndTypes must be exercised — assert ≥5 of the 6 are covered, so
    // the sweep can never silently shrink to a trivial probe set.
    expect(
      coveredTypes.length,
      greaterThanOrEqualTo(5),
      reason: 'probes cover only $coveredTypes of ${EndType.values}',
    );

    // The full sweep: every (verified ∩ catalog) sku × every probe — the REAL
    // resolver vs the live engine, joint label AND mates verdict.
    var sawNonEmpty = false;
    var sawEmpty = false;
    for (final s in skus) {
      for (final p in probes) {
        final engineLabel = connectionMethodLabel(prodBySku[s]!, prodBySku[p]!);
        final r = resolver.canConnect(specsBySku[s]!, specsBySku[p]!);
        expect(r.methodLabelHe, engineLabel, reason: '$s × $p');
        expect(
          r.mates,
          engineLabel.isNotEmpty,
          reason: 'mates parity $s × $p',
        );
        if (engineLabel.isNotEmpty) sawNonEmpty = true;
        if (engineLabel.isEmpty) sawEmpty = true;
      }
    }
    // Non-vacuity: the sweep must exercise BOTH a real mate (non-empty label)
    // and a non-mate ('') — otherwise the parity proves nothing.
    expect(
      sawNonEmpty,
      isTrue,
      reason: 'no pair mated — the sweep never exercised a real joint',
    );
    expect(
      sawEmpty,
      isTrue,
      reason: 'every pair mated — the sweep never exercised a non-joint',
    );
  });

  test(
      'mates parity against the raw physics (directMatesWith/pipeSharedWith) '
      'on dense same-type pairs', () {
    // The resolver works on specs alone, so this sweep uses the FULL
    // kVerifiedSpecs (NOT intersected with the catalog): per EndType, the
    // first (sorted) up-to-3 skus carrying an end of that type, then EVERY
    // ordered pair within that group — dense in real mates because each pair
    // shares an end-type.
    final allSkus = kVerifiedSpecs.keys.toList()..sort();

    // The LEGACY truth, straight from the verified physics: any end of A
    // direct-mates OR pipe-shares with any end of B.
    bool legacyMates(String a, String b) {
      for (final ea in kVerifiedSpecs[a]!.ends) {
        for (final eb in kVerifiedSpecs[b]!.ends) {
          if (ea.directMatesWith(eb) || ea.pipeSharedWith(eb)) return true;
        }
      }
      return false;
    }

    var pairCount = 0;
    var sawMate = false;
    var sawNonMate = false;
    for (final t in EndType.values) {
      final group = <String>[];
      for (final s in allSkus) {
        if (kVerifiedSpecs[s]!.ends.any((e) => e.type == t)) {
          group.add(s);
          if (group.length == 3) break;
        }
      }
      for (final a in group) {
        for (final b in group) {
          final expected = legacyMates(a, b);
          final r = resolver.canConnect(specsBySku[a]!, specsBySku[b]!);
          expect(
            r.mates,
            expected,
            reason: '${t.name}: $a × $b (legacy mates=$expected)',
          );
          pairCount++;
          if (expected) {
            sawMate = true;
          } else {
            sawNonMate = true;
          }
        }
      }
    }
    // Non-vacuity: enough pairs, and BOTH verdicts actually exercised.
    expect(
      pairCount,
      greaterThan(20),
      reason: 'only $pairCount same-type pairs swept — too sparse to prove '
          'mates parity',
    );
    expect(
      sawMate,
      isTrue,
      reason: 'no swept pair mated — the parity never saw a real joint',
    );
    expect(
      sawNonMate,
      isTrue,
      reason: 'every swept pair mated — the parity never saw a non-joint',
    );
  });

  test('galvanic completion parity with the engine grouping', () {
    // VERIFIED against install_engine.dart `_galvanicallyDissimilar` (:117):
    // copperGroup = {'נחושת', 'פליז'}, ironGroup = {'פלדה', 'נירוסטה'} — the
    // literals below are the ENGINE's, byte-for-byte.
    const copperGroupMaterials = {'נחושת', 'פליז'};
    const ironGroupMaterials = {'פלדה', 'נירוסטה'};

    final allSkus = kVerifiedSpecs.keys.toList()..sort();
    String? copperSku;
    String? copperSku2;
    String? ironSku;
    String? benignSku;
    for (final s in allSkus) {
      final m = kVerifiedSpecs[s]!.material;
      if (copperGroupMaterials.contains(m)) {
        if (copperSku == null) {
          copperSku = s;
        } else {
          copperSku2 ??= s;
        }
      } else if (ironGroupMaterials.contains(m)) {
        ironSku ??= s;
      } else {
        benignSku ??= s;
      }
    }
    // Skip-with-fail: a missing material class means this test CANNOT prove
    // the galvanic parity — fail loudly, do NOT silently shrink.
    expect(
      copperSku,
      isNotNull,
      reason: 'no copper-group material (נחושת/פליז) in kVerifiedSpecs',
    );
    expect(
      ironSku,
      isNotNull,
      reason: 'no iron-group material (פלדה/נירוסטה) in kVerifiedSpecs',
    );
    expect(
      benignSku,
      isNotNull,
      reason: 'no galvanically-benign material (HDPE/PEX/PVC/…) in '
          'kVerifiedSpecs',
    );

    final copperSpec = specsBySku[copperSku]!;
    final ironSpec = specsBySku[ironSku]!;
    final benignSpec = specsBySku[benignSku]!;

    // Dissimilar metal groups in one line — the engine raises the dielectric
    // union requirement ('רקורד דיאלקטרי', critical); the resolver must fire
    // the seeded galvanic completion rule with a non-empty authored reason.
    final issues = resolver.completion([copperSpec, ironSpec]);
    expect(
      issues,
      isNotEmpty,
      reason: 'copper-group + iron-group in one line must raise the '
          'dielectric requirement ($copperSku × $ironSku)',
    );
    final dielectric = issues.where((i) => i.whyHe.isNotEmpty).toList();
    expect(
      dielectric,
      isNotEmpty,
      reason: 'the galvanic issue must carry a non-empty authored whyHe '
          '(the dielectric requirement)',
    );
    expect(
      dielectric.first.severity,
      RuleSeverity.critical,
      reason: 'the engine flags the dielectric union as critical',
    );
    expect(
      dielectric.first.offendingSkus,
      containsAll(<String>[copperSku!, ironSku!]),
      reason: 'both metal-group skus must be reported as offenders',
    );

    // Same-group and metal↔benign pairings are galvanically silent in the
    // engine (`_galvanicallyDissimilar` requires BOTH groups present).
    expect(
      resolver.completion([copperSpec, benignSpec]),
      isEmpty,
      reason: 'copper-group + benign ($copperSku × $benignSku) must NOT fire '
          'the galvanic rule',
    );
    final copperPartnerSku = copperSku2 ?? copperSku;
    expect(
      resolver.completion([copperSpec, specsBySku[copperPartnerSku]!]),
      isEmpty,
      reason: 'copper-group + copper-group ($copperSku × $copperPartnerSku) '
          'is galvanically benign in the engine',
    );
  });

  test('system coherence parity (supply vs drainage)', () {
    // WaterSystem members VERIFIED (lipskey_verified_connections.dart:41):
    // { supply, drainage }. Per-end classification via `ConnectorEnd.system` —
    // the SAME size-independent mapping the seed derives its connector-type
    // systemIds from, so the picks below cannot drift from the seed.
    final allSkus = kVerifiedSpecs.keys.toList()..sort();
    String? supplySku;
    String? drainSku;
    for (final s in allSkus) {
      final ends = kVerifiedSpecs[s]!.ends;
      if (ends.isEmpty) continue;
      final systems = ends.map((e) => e.system).toSet();
      if (systems.length != 1) continue;
      if (systems.single == WaterSystem.supply) {
        supplySku ??= s;
      } else {
        drainSku ??= s;
      }
      if (supplySku != null && drainSku != null) break;
    }
    // Guard loudly — do NOT fake a spec if a pure-system product is missing.
    expect(
      supplySku,
      isNotNull,
      reason: 'no pure-supply sku (all ends bspMale/bspFemale/pexPress/'
          'copperPress) in kVerifiedSpecs — coherence cannot be exercised',
    );
    expect(
      drainSku,
      isNotNull,
      reason: 'no pure-drainage sku (all ends hdpeCompression/drainOpening) '
          'in kVerifiedSpecs — incoherence cannot be exercised',
    );

    final supplySpec = specsBySku[supplySku]!;
    final drainSpec = specsBySku[drainSku]!;

    final pure = resolver.systemCoherence([supplySpec]);
    expect(
      pure.coherent,
      isTrue,
      reason: 'a single all-supply product ($supplySku) stays in one system',
    );

    final mixed = resolver.systemCoherence([supplySpec, drainSpec]);
    expect(
      mixed.coherent,
      isFalse,
      reason: 'supply ($supplySku) + drainage ($drainSku) in one line must '
          'be incoherent',
    );
    expect(
      mixed.offendingSku,
      drainSku,
      reason: 'the FIRST off-system sku (line order) must be the drainage one',
    );
    expect(
      mixed.offendingSystem?.id,
      '$kPlumbingTradeId.sys.${WaterSystem.drainage.name}',
      reason: 'the offending system must resolve to the seeded drainage '
          'SystemDef',
    );
  });
}
