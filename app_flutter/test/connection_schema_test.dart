// Pins the Pillar-2 connection schema (step 33): every type round-trips through
// JSON with exact value-equality (incl. the R1-3 material-group fields and the
// nested sizeTable), the SizeMatch/RuleSeverity enums round-trip by name (unknown ⇒
// default), and RuleSeverity is name-for-name equivalent to the engine's
// CheckSeverity (the adapter wires the translation at step 39). Pure data.
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/logic/install_engine.dart' show CheckSeverity;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConnectorType + SystemDef + ProductEnd round-trip', () {
    const ct = ConnectorType(
      id: 'ct.bspM',
      tradeId: 'plumbing',
      nameHe: 'תבריג זכר 1/2"',
      sizeValues: ['1/2"', '3/4"'],
      systemId: 'sys.supply',
    );
    expect(ConnectorType.fromJson(ct.toJson()), ct);
    expect(ConnectorType.fromJson(ct.toJson()..remove('systemId')).systemId, isNull);

    const sd = SystemDef(
      id: 'sys.supply',
      tradeId: 'plumbing',
      nameHe: 'אספקה',
      color: 0xFF2196F3,
    );
    expect(SystemDef.fromJson(sd.toJson()), sd);

    const pe = ProductEnd(connectorTypeId: 'ct.bspM', sizeValue: '1/2"');
    expect(ProductEnd.fromJson(pe.toJson()), pe);
  });

  test('ProductConnectorSpec round-trips (envelope + materialGroupId R1-3)', () {
    const s = ProductConnectorSpec(
      productSku: 'SKU1',
      tradeId: 'plumbing',
      ends: [ProductEnd(connectorTypeId: 'ct.bspM', sizeValue: '1/2"')],
      materialId: 'brass',
      ratingHe: 'PN16',
      envelope: {'maxTempC': 40},
      materialGroupId: 'copper-group',
    );
    final back = ProductConnectorSpec.fromJson(s.toJson());
    expect(back, s);
    expect(back.envelope['maxTempC'], 40);
    expect(back.materialGroupId, 'copper-group');
  });

  test('CompatibilityRule round-trips (sizeTable + material fields R1-3)', () {
    const r = CompatibilityRule(
      id: 'r1',
      tradeId: 'electrician',
      aTypeId: 'breaker',
      bTypeId: 'busbar',
      sizeMatch: SizeMatch.tableLookup,
      methodLabelHe: 'הידוק על פס DIN',
      sizeTable: [
        ['16A', '≤63A'],
        ['25A', '≤63A'],
      ],
      onMismatch: RuleSeverity.critical,
      materialGroup: 'copper-group',
      incompatibleMaterialGroups: ['iron-group'],
    );
    final back = CompatibilityRule.fromJson(r.toJson());
    expect(back, r);
    expect(back.sizeTable, [
      ['16A', '≤63A'],
      ['25A', '≤63A'],
    ]);
    expect(back.incompatibleMaterialGroups, ['iron-group']);

    // null sizeTable + null material survive (plumbing thread rule).
    const r2 = CompatibilityRule(
      id: 'r2',
      tradeId: 'plumbing',
      aTypeId: 'bspM',
      bTypeId: 'bspF',
      sizeMatch: SizeMatch.exactSame,
      methodLabelHe: 'תבריג + PTFE',
    );
    final back2 = CompatibilityRule.fromJson(r2.toJson());
    expect(back2, r2);
    expect(back2.sizeTable, isNull);
    expect(back2.materialGroup, isNull);
  });

  test('CompletionRule round-trips (interposer R1-3)', () {
    const c = CompletionRule(
      id: 'c1',
      tradeId: 'plumbing',
      whenInLineHasTypeId: 'copper',
      requireTypeId: 'dielectric',
      whyHe: 'מניעת קורוזיה גלוונית',
      severity: RuleSeverity.critical,
      incompatibleMaterialGroups: ['iron-group'],
      requiredInterposerWhyHe: 'נחושת↔פלדה דורש מתאם דיאלקטרי',
    );
    expect(CompletionRule.fromJson(c.toJson()), c);
  });

  test('SizeMatch + RuleSeverity round-trip by name; unknown ⇒ default', () {
    for (final m in SizeMatch.values) {
      expect(
        CompatibilityRule.fromJson(<String, dynamic>{'sizeMatch': m.name}).sizeMatch,
        m,
      );
    }
    expect(
      CompatibilityRule.fromJson(const {'sizeMatch': 'bogus'}).sizeMatch,
      SizeMatch.exactSame,
    );
    expect(
      CompatibilityRule.fromJson(const {'onMismatch': 'bogus'}).onMismatch,
      RuleSeverity.warning,
    );
  });

  test('RuleSeverity ≡ CheckSeverity name-for-name (both directions)', () {
    for (final r in RuleSeverity.values) {
      expect(
        CheckSeverity.values.any((c) => c.name == r.name),
        isTrue,
        reason: 'RuleSeverity.${r.name} has no CheckSeverity twin',
      );
    }
    for (final c in CheckSeverity.values) {
      expect(
        RuleSeverity.values.any((r) => r.name == c.name),
        isTrue,
        reason: 'CheckSeverity.${c.name} has no RuleSeverity twin',
      );
    }
  });
}
