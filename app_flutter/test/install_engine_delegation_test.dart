// Pillar-2 Step 41 — pins the flag-gated delegation seam in install_engine
// BEFORE the builder wires it: plumbing's hand-written physics is FOREVER
// (R1-2 — the fake-throwing specOf proves the delegation is never even
// consulted for plumbing), authored trades evaluate their AUTHORED rules
// through the step-39 resolver, the kill-switch falls back to the legacy
// answer quietly, and nothing live passes `trade` yet — the kTradeStudioFlag
// gate arrives with the s43 provider layer, so these tests carry the seam by
// hand.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/domain/connection_resolver.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// One authored anyToAny pair-rule (typeX↔typeX) carrying [label] — the whole
/// "physics" of the fake trades below, so any delegated answer is exactly
/// this authored label and can never be confused with a legacy joint name.
CompatibilityRule _anyToAnyRule({
  required String tradeId,
  required String label,
}) =>
    CompatibilityRule(
      id: '$tradeId.rule.typex',
      tradeId: tradeId,
      aTypeId: 'typeX',
      bTypeId: 'typeX',
      sizeMatch: SizeMatch.anyToAny,
      methodLabelHe: label,
    );

/// A fake authored spec whose single end is a typeX connector — mates with
/// any other [_typeXSpec] under [_anyToAnyRule].
ProductConnectorSpec _typeXSpec(String sku, {String? materialGroupId}) =>
    ProductConnectorSpec(
      productSku: sku,
      tradeId: 'electric',
      ends: const [ProductEnd(connectorTypeId: 'typeX', sizeValue: '1')],
      materialGroupId: materialGroupId,
    );

/// The FIRST mating pair among the sorted kVerifiedSpecs ∩ kCatalogProducts
/// skus, decided by the engine itself: `connectionMethodLabel` with NO
/// `trade` argument is the legacy branch BY DEFINITION, so the derived
/// (a, b, label) triple is a pure legacy fact — robust to catalog edits, no
/// hard-coded pair to rot.
({LipskeyCatalogProduct a, LipskeyCatalogProduct b, String label})
    _deriveLegacyMatingPair() {
  final bySku = <String, LipskeyCatalogProduct>{
    for (final p in kCatalogProducts) p.sku: p,
  };
  final skus = kVerifiedSpecs.keys.where(bySku.containsKey).toList()..sort();
  for (final sA in skus) {
    for (final sB in skus) {
      if (sA == sB) continue;
      final a = bySku[sA]!;
      final b = bySku[sB]!;
      final label = connectionMethodLabel(a, b);
      if (label.isNotEmpty) return (a: a, b: b, label: label);
    }
  }
  throw StateError(
    'no mating pair in sorted kVerifiedSpecs ∩ kCatalogProducts — '
    'the delegation-seam tests need one legacy joint to pin against',
  );
}

void main() {
  final legacy = _deriveLegacyMatingPair();

  test('plumbing NEVER consults the delegation (R1-2 keystone contract)', () {
    expect(legacy.label, isNotEmpty, reason: 'the derived pair must mate');

    var consulted = false;
    ProductConnectorSpec? throwingSpecOf(String _) {
      consulted = true;
      throw StateError('R1-2 violated: specOf consulted for plumbing');
    }

    final trade = TradeResolution(
      tradeId: 'plumbing',
      resolver: ConnectionResolver(
        rules: [_anyToAnyRule(tradeId: 'plumbing', label: 'לא-אמור-להופיע')],
      ),
      specOf: throwingSpecOf,
    );

    // Must not throw AND must return the verbatim legacy answer: for
    // tradeId 'plumbing' the legacy branch runs and the delegation is
    // never even called.
    final label = connectionMethodLabel(legacy.a, legacy.b, trade: trade);
    expect(
      label,
      legacy.label,
      reason: 'plumbing keeps its hand-written physics verbatim (R1-2)',
    );
    expect(
      consulted,
      isFalse,
      reason: 'plumbing must never CALL specOf — not even behind the '
          'kill-switch (a swallowed throw would still flip this flag)',
    );
  });

  test('a non-plumbing trade delegates to the resolver', () {
    final specs = <String, ProductConnectorSpec>{
      legacy.a.sku: _typeXSpec(legacy.a.sku),
      legacy.b.sku: _typeXSpec(legacy.b.sku),
    };
    final trade = TradeResolution(
      tradeId: 'electric',
      resolver: ConnectionResolver(
        rules: [_anyToAnyRule(tradeId: 'electric', label: 'חיבור-בדיקה')],
      ),
      specOf: (sku) => specs[sku],
    );

    final label = connectionMethodLabel(legacy.a, legacy.b, trade: trade);
    expect(
      label,
      'חיבור-בדיקה',
      reason: 'the authored rule, not plumbing physics, names the joint',
    );
    expect(
      label,
      isNot(legacy.label),
      reason: 'the delegated answer really replaced the legacy one',
    );
  });

  test('unknown authored spec → quiet no-connect', () {
    final aSpec = _typeXSpec(legacy.a.sku);
    final trade = TradeResolution(
      tradeId: 'electric',
      resolver: ConnectionResolver(
        rules: [_anyToAnyRule(tradeId: 'electric', label: 'חיבור-בדיקה')],
      ),
      // Only sku-a has an authored spec; sku-b is unknown to the trade.
      specOf: (sku) => sku == legacy.a.sku ? aSpec : null,
    );
    expect(
      connectionMethodLabel(legacy.a, legacy.b, trade: trade),
      '',
      reason: 'a sku without an authored spec quietly does not connect — '
          'no legacy leak-through, no exception',
    );
  });

  test('kill-switch: a throwing delegation falls back to legacy', () {
    ProductConnectorSpec? throwingSpecOf(String _) =>
        throw StateError('authored trade data unavailable');
    final trade = TradeResolution(
      tradeId: 'electric',
      resolver: ConnectionResolver(
        rules: [_anyToAnyRule(tradeId: 'electric', label: 'חיבור-בדיקה')],
      ),
      specOf: throwingSpecOf,
    );
    expect(
      connectionMethodLabel(legacy.a, legacy.b, trade: trade),
      legacy.label,
      reason: 'plan addition-B robustness: a broken delegation must never '
          'take the answer down with it — quiet fallback to the legacy label',
    );
  });

  test('legacy checklist untouched for plumbing/null', () {
    final chain = [legacy.a, legacy.b];
    final baseline = lineComplianceChecklist(chain, 25, const <String>{});
    expect(
      baseline,
      isNotEmpty,
      reason: 'clips/sealant checks are unconditional — a legacy checklist '
          'is never empty, so the comparison below is non-vacuous',
    );

    var consulted = false;
    ProductConnectorSpec? throwingSpecOf(String _) {
      consulted = true;
      throw StateError('R1-2 violated: checklist consulted specOf for plumbing');
    }

    final viaPlumbingTrade = lineComplianceChecklist(
      chain,
      25,
      const <String>{},
      trade: TradeResolution(
        tradeId: 'plumbing',
        resolver: ConnectionResolver(
          rules: [_anyToAnyRule(tradeId: 'plumbing', label: 'לא-אמור-להופיע')],
        ),
        specOf: throwingSpecOf,
      ),
    );

    expect(
      consulted,
      isFalse,
      reason: 'a plumbing-tagged TradeResolution must be ignored outright',
    );
    expect(viaPlumbingTrade.length, baseline.length);
    for (var i = 0; i < baseline.length; i++) {
      expect(
        viaPlumbingTrade[i].label,
        baseline[i].label,
        reason: 'check #$i label',
      );
      expect(
        viaPlumbingTrade[i].satisfied,
        baseline[i].satisfied,
        reason: 'check #$i satisfied',
      );
      expect(
        viaPlumbingTrade[i].why,
        baseline[i].why,
        reason: 'check #$i why',
      );
      expect(
        viaPlumbingTrade[i].severity,
        baseline[i].severity,
        reason: 'check #$i severity',
      );
    }
  });

  test('authored-trade checklist = rule violations', () {
    // Galvanic-style MATERIAL rule: groups g1 + g2 present together need an
    // interposer. whyHe deliberately differs from requiredInterposerWhyHe so
    // the assertion also pins that the MATERIAL shape surfaces the authored
    // interposer reason (requiredInterposerWhyHe ?? whyHe).
    const galvanicStyle = CompletionRule(
      id: 'electric.done.galvanic-style',
      tradeId: 'electric',
      whenInLineHasTypeId: '',
      requireTypeId: '',
      whyHe: 'נימוק-גיבוי-שלא-בשימוש',
      severity: RuleSeverity.critical,
      incompatibleMaterialGroups: ['g1', 'g2'],
      requiredInterposerWhyHe: 'צריך-מתאם',
    );
    final resolver = ConnectionResolver(
      rules: [_anyToAnyRule(tradeId: 'electric', label: 'חיבור-בדיקה')],
      completionRules: const [galvanicStyle],
    );

    final mixed = <String, ProductConnectorSpec>{
      legacy.a.sku: _typeXSpec(legacy.a.sku, materialGroupId: 'g1'),
      legacy.b.sku: _typeXSpec(legacy.b.sku, materialGroupId: 'g2'),
    };
    final checks = lineComplianceChecklist(
      [legacy.a, legacy.b],
      25,
      const <String>{},
      trade: TradeResolution(
        tradeId: 'electric',
        resolver: resolver,
        specOf: (sku) => mixed[sku],
      ),
    );
    expect(
      checks,
      hasLength(1),
      reason: 'exactly the one authored violation — the legacy plumbing '
          'checklist (clips/sealant/…) must NOT leak into an authored trade',
    );
    final check = checks.single;
    expect(check.satisfied, isFalse, reason: 'a fired rule is unsatisfied');
    expect(
      check.severity,
      CheckSeverity.critical,
      reason: 'RuleSeverity.critical maps to CheckSeverity.critical by NAME',
    );
    expect(
      '${check.label} ${check.why}',
      contains('צריך-מתאם'),
      reason: 'the authored interposer reason is the check text the user sees',
    );

    // Same trade, all-g1 line: the MATERIAL shape needs ≥2 distinct groups,
    // the type fields are empty, and the coherence probe sees no authored
    // systems — so nothing fires and the checklist is EMPTY (in particular,
    // no legacy items appear either).
    final allG1 = <String, ProductConnectorSpec>{
      legacy.a.sku: _typeXSpec(legacy.a.sku, materialGroupId: 'g1'),
      legacy.b.sku: _typeXSpec(legacy.b.sku, materialGroupId: 'g1'),
    };
    expect(
      lineComplianceChecklist(
        [legacy.a, legacy.b],
        25,
        const <String>{},
        trade: TradeResolution(
          tradeId: 'electric',
          resolver: resolver,
          specOf: (sku) => allG1[sku],
        ),
      ),
      isEmpty,
    );
  });
}
