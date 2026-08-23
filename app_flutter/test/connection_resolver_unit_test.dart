// Pillar-2 Step 39 — pins the pure trade-agnostic resolver semantics
// (SizeMatch modes · quiet no-rule · deterministic first-match · completion
// material+type shapes · system coherence with offender back-ref) BEFORE any
// live wiring (step 41). Fixtures are tiny in-test rules — deliberately NOT
// the plumbing seed — so this stays a pure unit test of rule evaluation.
import 'package:buildsmart/domain/connection_resolver.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:flutter_test/flutter_test.dart';

ProductEnd _end(String typeId, String size) =>
    ProductEnd(connectorTypeId: typeId, sizeValue: size);

ProductConnectorSpec _spec(
  String sku,
  List<ProductEnd> ends, {
  String? materialGroupId,
}) =>
    ProductConnectorSpec(
      productSku: sku,
      tradeId: 't',
      ends: ends,
      materialGroupId: materialGroupId,
    );

CompatibilityRule _rule({
  required String id,
  required String aTypeId,
  required String bTypeId,
  required SizeMatch sizeMatch,
  required String label,
  List<List<String>>? sizeTable,
  RuleSeverity onMismatch = RuleSeverity.warning,
}) =>
    CompatibilityRule(
      id: id,
      tradeId: 't',
      aTypeId: aTypeId,
      bTypeId: bTypeId,
      sizeMatch: sizeMatch,
      methodLabelHe: label,
      sizeTable: sizeTable,
      onMismatch: onMismatch,
    );

void main() {
  test('exactSame mates only on equal (normalized) sizes', () {
    // The documented normalizeSize contract: trim + strip the inch mark.
    expect(normalizeSize('1/2"'), '1/2');
    expect(normalizeSize(' 1/2 '), '1/2');

    final resolver = ConnectionResolver(
      rules: [
        _rule(
          id: 'r1',
          aTypeId: 'tA',
          bTypeId: 'tB',
          sizeMatch: SizeMatch.exactSame,
          label: 'X',
          onMismatch: RuleSeverity.critical,
        ),
      ],
    );
    final a = _spec('sku-a', [_end('tA', '1/2"')]);

    final ok = resolver.canConnect(a, _spec('sku-b', [_end('tB', '1/2')]));
    expect(ok.mates, isTrue, reason: '1/2" == 1/2 after normalization');
    expect(ok.methodLabelHe, 'X');
    expect(ok.severity, isNull);
    expect(ok.rule, isNotNull, reason: 'explain back-ref to the matched rule');
    expect(ok.rule?.id, 'r1');

    final bad = resolver.canConnect(a, _spec('sku-c', [_end('tB', '3/4')]));
    expect(bad.mates, isFalse);
    expect(
      bad.severity,
      RuleSeverity.critical,
      reason: "size mismatch surfaces the rule's onMismatch",
    );
    expect(bad.methodLabelHe, '');
  });

  test('anyToAny ignores size', () {
    final resolver = ConnectionResolver(
      rules: [
        _rule(
          id: 'r1',
          aTypeId: 'tA',
          bTypeId: 'tB',
          sizeMatch: SizeMatch.anyToAny,
          label: 'X',
        ),
      ],
    );
    final res = resolver.canConnect(
      _spec('sku-a', [_end('tA', '16')]),
      _spec('sku-b', [_end('tB', '110')]),
    );
    expect(res.mates, isTrue, reason: 'anyToAny mates across different sizes');
    expect(res.methodLabelHe, 'X');
    expect(res.severity, isNull);
  });

  test('tableLookup allows only listed pairs (both orientations resolve)', () {
    final resolver = ConnectionResolver(
      rules: [
        _rule(
          id: 'r1',
          aTypeId: 'tA',
          bTypeId: 'tB',
          sizeMatch: SizeMatch.tableLookup,
          label: 'X',
          sizeTable: [
            ['1', '2'],
          ],
        ),
      ],
    );

    final listed = resolver.canConnect(
      _spec('sku-a1', [_end('tA', '1')]),
      _spec('sku-b2', [_end('tB', '2')]),
    );
    expect(listed.mates, isTrue);

    final unlisted = resolver.canConnect(
      _spec('sku-a2', [_end('tA', '2')]),
      _spec('sku-b1', [_end('tB', '1')]),
    );
    expect(unlisted.mates, isFalse, reason: 'rows are ordered [aSize, bSize]');

    // Reverse orientation: the rule matched b→a must look the pair up as
    // [y, x] — the tA end still owns the row's aSize column.
    final reversed = resolver.canConnect(
      _spec('sku-rb', [_end('tB', '2')]),
      _spec('sku-ra', [_end('tA', '1')]),
    );
    expect(reversed.mates, isTrue);
  });

  test('no rule for the pair → quiet no-connect', () {
    final resolver = ConnectionResolver(
      rules: [
        _rule(
          id: 'r1',
          aTypeId: 'tA',
          bTypeId: 'tB',
          sizeMatch: SizeMatch.exactSame,
          label: 'X',
        ),
      ],
    );
    // tX↔tY has no authored rule — must not throw and must not warn.
    final res = resolver.canConnect(
      _spec('sku-x', [_end('tX', '1')]),
      _spec('sku-y', [_end('tY', '1')]),
    );
    expect(res.mates, isFalse);
    expect(res.severity, isNull, reason: 'no pair-rule means no severity');
    expect(res.rule, isNull);
    expect(res.methodLabelHe, '');
  });

  test('first match wins deterministically', () {
    final resolver = ConnectionResolver(
      rules: [
        _rule(
          id: 'first',
          aTypeId: 'tA',
          bTypeId: 'tB',
          sizeMatch: SizeMatch.anyToAny,
          label: 'FIRST',
        ),
        _rule(
          id: 'second',
          aTypeId: 'tA',
          bTypeId: 'tB',
          sizeMatch: SizeMatch.anyToAny,
          label: 'SECOND',
        ),
      ],
    );
    final a = _spec('sku-a', [_end('tA', '1')]);
    final b = _spec('sku-b', [_end('tB', '1')]);

    final res1 = resolver.canConnect(a, b);
    expect(res1.mates, isTrue);
    expect(
      res1.methodLabelHe,
      'FIRST',
      reason: 'rules evaluate in list order — the first mates-match wins',
    );
    expect(res1.rule?.id, 'first');

    // Memo determinism: an identical second query answers identically.
    final res2 = resolver.canConnect(a, b);
    expect(res2.mates, res1.mates);
    expect(res2.methodLabelHe, res1.methodLabelHe);
    expect(res2.severity, res1.severity);
    expect(res2.rule, res1.rule);
  });

  test('completion — material shape (galvanic)', () {
    const galvanic = CompletionRule(
      id: 'c-galv',
      tradeId: 't',
      whenInLineHasTypeId: '',
      requireTypeId: '',
      whyHe: 'base',
      severity: RuleSeverity.critical,
      incompatibleMaterialGroups: ['copper-group', 'iron-group'],
      requiredInterposerWhyHe: 'W',
    );
    final resolver = ConnectionResolver(
      rules: const [],
      completionRules: const [galvanic],
    );

    final copper =
        _spec('sku-cu', [_end('tN', '1')], materialGroupId: 'copper-group');
    final iron =
        _spec('sku-fe', [_end('tN', '1')], materialGroupId: 'iron-group');

    final issues = resolver.completion([copper, iron]);
    expect(issues, hasLength(1));
    expect(
      issues.single.whyHe,
      'W',
      reason: 'the material shape surfaces requiredInterposerWhyHe',
    );
    expect(issues.single.severity, RuleSeverity.critical);
    expect(issues.single.offendingSkus, containsAll(['sku-cu', 'sku-fe']));
    expect(issues.single.rule, galvanic);

    final copper2 =
        _spec('sku-cu2', [_end('tN', '2')], materialGroupId: 'copper-group');
    expect(
      resolver.completion([copper, copper2]),
      isEmpty,
      reason: 'same-group line has no galvanic pair',
    );
  });

  test('completion — type shape', () {
    const needsT2 = CompletionRule(
      id: 'c-t2',
      tradeId: 't',
      whenInLineHasTypeId: 'T1',
      requireTypeId: 'T2',
      whyHe: 'need T2',
    );
    final resolver = ConnectionResolver(
      rules: const [],
      completionRules: const [needsT2],
    );

    final issues = resolver.completion([
      _spec('sku-1', [_end('T1', '1')]),
    ]);
    expect(issues, hasLength(1), reason: 'T1 present, required T2 missing');
    expect(issues.single.whyHe, 'need T2');
    expect(issues.single.severity, needsT2.severity);
    expect(issues.single.rule, needsT2);

    expect(
      resolver.completion([
        _spec('sku-1', [_end('T1', '1')]),
        _spec('sku-2', [_end('T2', '1')]),
      ]),
      isEmpty,
      reason: 'the required type is present in the line',
    );
  });

  test('systemCoherence rejects supply/drainage mixing and names the offender',
      () {
    const supplyType = ConnectorType(
      id: 't-sup',
      tradeId: 't',
      nameHe: 'אספקה',
      systemId: 'sys.supply',
    );
    const drainType = ConnectorType(
      id: 't-drn',
      tradeId: 't',
      nameHe: 'ניקוז',
      systemId: 'sys.drainage',
    );
    const supply = SystemDef(
      id: 'sys.supply',
      tradeId: 't',
      nameHe: 'אספקה',
      color: 0xFF1565C0,
    );
    const drainage = SystemDef(
      id: 'sys.drainage',
      tradeId: 't',
      nameHe: 'ניקוז',
      color: 0xFF6D4C41,
    );
    final resolver = ConnectionResolver(
      rules: const [],
      connectorTypes: const [supplyType, drainType],
      systems: const [supply, drainage],
    );

    final specA = _spec('sku-sup', [_end('t-sup', '1')]);
    final specB = _spec('sku-drn', [_end('t-drn', '1')]);

    final mixed = resolver.systemCoherence([specA, specB]);
    expect(mixed.coherent, isFalse);
    expect(
      mixed.offendingSku,
      'sku-drn',
      reason: 'the first spec deviating from the line system is the offender',
    );
    expect(mixed.offendingSystem?.id, 'sys.drainage');

    final allSupply = resolver.systemCoherence([
      specA,
      _spec('sku-sup2', [_end('t-sup', '2')]),
    ]);
    expect(allSupply.coherent, isTrue);
    expect(allSupply.offendingSystem, isNull);
    expect(allSupply.offendingSku, isNull);
  });
}
