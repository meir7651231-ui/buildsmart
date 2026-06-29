// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 33 — the connection model.
//
// Plumbing today encodes joints as a CLOSED enum (`EndType`,
// lipskey_verified_connections.dart:24) with hand-coded mating math
// (`directMatesWith`). To let an owner author "which breaker fits which panel" with
// no code, we replace the closed enum with authored connector TYPES + an authored
// COMPATIBILITY MATRIX — while keeping plumbing byte-identical by SEEDING the matrix
// from the existing 891 specs (step 38, the keystone). The engine stops knowing
// physics and starts evaluating authored rules.
//
// R1-3: a rule must carry MATERIAL info, or it can't express HDPE↔PVC or galvanic
// copper-group↔iron-group (`_galvanicallyDissimilar`, install_engine.dart:117).
//
// All @immutable + toJson/fromJson (tolerant) + value ==/hashCode. `RuleSeverity`
// maps name-for-name to the engine's `CheckSeverity` (the adapter wires it at step
// 39). `EndType`/`WaterSystem` stay UNTOUCHED (they become seed types at step 37).
// NOT imported by any live screen/logic yet ⇒ zero regression.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

enum SizeMatch { exactSame, anyToAny, tableLookup }

/// Maps name-for-name to `CheckSeverity` (install_engine.dart:77) — the adapter
/// (step 39) translates between them; the equivalence is pinned by the test.
enum RuleSeverity { info, warning, critical }

// ── tolerant decoders (no throw; missing/wrong type → default) ────────────────
String _str(Object? v) => v is String ? v : '';
String? _strOrNull(Object? v) => v is String ? v : null;
int _int(Object? v) => v is num ? v.toInt() : 0;
List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];
List<String>? _strListOrNull(Object? v) =>
    v is List ? v.whereType<String>().toList() : null;
Map<String, num> _numMap(Object? v) =>
    v is Map ? {for (final e in v.entries) '${e.key}': e.value as num} : const {};
List<List<String>>? _sizeTable(Object? v) => v is List
    ? v
        .whereType<List<dynamic>>()
        .map((row) => row.whereType<String>().toList())
        .toList()
    : null;
SizeMatch _sizeMatchFrom(Object? v) =>
    SizeMatch.values.firstWhere((e) => e.name == v, orElse: () => SizeMatch.exactSame);
RuleSeverity _ruleSeverityFrom(Object? v) => RuleSeverity.values
    .firstWhere((e) => e.name == v, orElse: () => RuleSeverity.warning);

bool _sizeTableEq(List<List<String>>? a, List<List<String>>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!listEquals(a[i], b[i])) return false;
  }
  return true;
}

int _sizeTableHash(List<List<String>>? t) =>
    t == null ? 0 : Object.hashAll(t.map(Object.hashAll));

@immutable
class ConnectorType {
  const ConnectorType({
    required this.id,
    required this.tradeId,
    required this.nameHe,
    this.sizeValues = const [],
    this.systemId,
  });

  factory ConnectorType.fromJson(Map<String, dynamic> j) => ConnectorType(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        nameHe: _str(j['nameHe']),
        sizeValues: _strList(j['sizeValues']),
        systemId: _strOrNull(j['systemId']),
      );

  final String id;
  final String tradeId;
  final String nameHe;
  final List<String> sizeValues;
  final String? systemId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'nameHe': nameHe,
        'sizeValues': sizeValues,
        if (systemId != null) 'systemId': systemId,
      };

  @override
  bool operator ==(Object other) =>
      other is ConnectorType &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.nameHe == nameHe &&
      listEquals(other.sizeValues, sizeValues) &&
      other.systemId == systemId;

  @override
  int get hashCode =>
      Object.hash(id, tradeId, nameHe, Object.hashAll(sizeValues), systemId);
}

@immutable
class SystemDef {
  const SystemDef({
    required this.id,
    required this.tradeId,
    required this.nameHe,
    required this.color,
  });

  factory SystemDef.fromJson(Map<String, dynamic> j) => SystemDef(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        nameHe: _str(j['nameHe']),
        color: _int(j['color']),
      );

  final String id;
  final String tradeId;
  final String nameHe;
  final int color;

  Map<String, dynamic> toJson() =>
      {'id': id, 'tradeId': tradeId, 'nameHe': nameHe, 'color': color};

  @override
  bool operator ==(Object other) =>
      other is SystemDef &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.nameHe == nameHe &&
      other.color == color;

  @override
  int get hashCode => Object.hash(id, tradeId, nameHe, color);
}

@immutable
class ProductEnd {
  const ProductEnd({required this.connectorTypeId, required this.sizeValue});

  factory ProductEnd.fromJson(Map<String, dynamic> j) => ProductEnd(
        connectorTypeId: _str(j['connectorTypeId']),
        sizeValue: _str(j['sizeValue']),
      );

  final String connectorTypeId;
  final String sizeValue;

  Map<String, dynamic> toJson() =>
      {'connectorTypeId': connectorTypeId, 'sizeValue': sizeValue};

  @override
  bool operator ==(Object other) =>
      other is ProductEnd &&
      other.connectorTypeId == connectorTypeId &&
      other.sizeValue == sizeValue;

  @override
  int get hashCode => Object.hash(connectorTypeId, sizeValue);
}

@immutable
class ProductConnectorSpec {
  const ProductConnectorSpec({
    required this.productSku,
    required this.tradeId,
    this.ends = const [],
    this.materialId,
    this.ratingHe,
    this.envelope = const {},
    this.materialGroupId, // R1-3 (derived galvanic group)
  });

  factory ProductConnectorSpec.fromJson(Map<String, dynamic> j) =>
      ProductConnectorSpec(
        productSku: _str(j['productSku']),
        tradeId: _str(j['tradeId']),
        ends: j['ends'] is List
            ? (j['ends'] as List)
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => ProductEnd.fromJson(e.cast<String, dynamic>()))
                .toList()
            : const [],
        materialId: _strOrNull(j['materialId']),
        ratingHe: _strOrNull(j['ratingHe']),
        envelope: _numMap(j['envelope']),
        materialGroupId: _strOrNull(j['materialGroupId']),
      );

  final String productSku;
  final String tradeId;
  final List<ProductEnd> ends;
  final String? materialId;
  final String? ratingHe;
  final Map<String, num> envelope; // trade-defined keys: {maxTempC:40}|{maxAmp:16}
  final String? materialGroupId;

  Map<String, dynamic> toJson() => {
        'productSku': productSku,
        'tradeId': tradeId,
        'ends': ends.map((e) => e.toJson()).toList(),
        if (materialId != null) 'materialId': materialId,
        if (ratingHe != null) 'ratingHe': ratingHe,
        'envelope': envelope,
        if (materialGroupId != null) 'materialGroupId': materialGroupId,
      };

  @override
  bool operator ==(Object other) =>
      other is ProductConnectorSpec &&
      other.productSku == productSku &&
      other.tradeId == tradeId &&
      listEquals(other.ends, ends) &&
      other.materialId == materialId &&
      other.ratingHe == ratingHe &&
      mapEquals(other.envelope, envelope) &&
      other.materialGroupId == materialGroupId;

  @override
  int get hashCode => Object.hash(
        productSku,
        tradeId,
        Object.hashAll(ends),
        materialId,
        ratingHe,
        Object.hashAll(envelope.keys),
        materialGroupId,
      );
}

@immutable
class CompatibilityRule {
  const CompatibilityRule({
    required this.id,
    required this.tradeId,
    required this.aTypeId,
    required this.bTypeId,
    required this.sizeMatch,
    required this.methodLabelHe,
    this.sizeTable, // for tableLookup: allowed [aSize, bSize] pairs
    this.onMismatch = RuleSeverity.warning,
    this.materialGroup, // R1-3
    this.incompatibleMaterialGroups, // R1-3
  });

  factory CompatibilityRule.fromJson(Map<String, dynamic> j) => CompatibilityRule(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        aTypeId: _str(j['aTypeId']),
        bTypeId: _str(j['bTypeId']),
        sizeMatch: _sizeMatchFrom(j['sizeMatch']),
        methodLabelHe: _str(j['methodLabelHe']),
        sizeTable: _sizeTable(j['sizeTable']),
        onMismatch: _ruleSeverityFrom(j['onMismatch']),
        materialGroup: _strOrNull(j['materialGroup']),
        incompatibleMaterialGroups:
            _strListOrNull(j['incompatibleMaterialGroups']),
      );

  final String id;
  final String tradeId;
  final String aTypeId; // documented order: [a, b]; sizeTable rows are [aSize, bSize]
  final String bTypeId;
  final SizeMatch sizeMatch;
  final List<List<String>>? sizeTable;
  final String methodLabelHe;
  final RuleSeverity onMismatch;
  final String? materialGroup;
  final List<String>? incompatibleMaterialGroups;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'aTypeId': aTypeId,
        'bTypeId': bTypeId,
        'sizeMatch': sizeMatch.name,
        'methodLabelHe': methodLabelHe,
        if (sizeTable != null) 'sizeTable': sizeTable,
        'onMismatch': onMismatch.name,
        if (materialGroup != null) 'materialGroup': materialGroup,
        if (incompatibleMaterialGroups != null)
          'incompatibleMaterialGroups': incompatibleMaterialGroups,
      };

  @override
  bool operator ==(Object other) =>
      other is CompatibilityRule &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.aTypeId == aTypeId &&
      other.bTypeId == bTypeId &&
      other.sizeMatch == sizeMatch &&
      _sizeTableEq(other.sizeTable, sizeTable) &&
      other.methodLabelHe == methodLabelHe &&
      other.onMismatch == onMismatch &&
      other.materialGroup == materialGroup &&
      listEquals(other.incompatibleMaterialGroups, incompatibleMaterialGroups);

  @override
  int get hashCode => Object.hash(
        id,
        tradeId,
        aTypeId,
        bTypeId,
        sizeMatch,
        _sizeTableHash(sizeTable),
        methodLabelHe,
        onMismatch,
        materialGroup,
        Object.hashAll(incompatibleMaterialGroups ?? const []),
      );
}

@immutable
class CompletionRule {
  const CompletionRule({
    required this.id,
    required this.tradeId,
    required this.whenInLineHasTypeId,
    required this.requireTypeId,
    required this.whyHe,
    this.severity = RuleSeverity.warning,
    this.incompatibleMaterialGroups, // R1-3
    this.requiredInterposerWhyHe, // R1-3
  });

  factory CompletionRule.fromJson(Map<String, dynamic> j) => CompletionRule(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        whenInLineHasTypeId: _str(j['whenInLineHasTypeId']),
        requireTypeId: _str(j['requireTypeId']),
        whyHe: _str(j['whyHe']),
        severity: _ruleSeverityFrom(j['severity']),
        incompatibleMaterialGroups:
            _strListOrNull(j['incompatibleMaterialGroups']),
        requiredInterposerWhyHe: _strOrNull(j['requiredInterposerWhyHe']),
      );

  final String id;
  final String tradeId;
  final String whenInLineHasTypeId; // trigger
  final String requireTypeId;
  final String whyHe;
  final RuleSeverity severity;
  final List<String>? incompatibleMaterialGroups;
  final String? requiredInterposerWhyHe;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'whenInLineHasTypeId': whenInLineHasTypeId,
        'requireTypeId': requireTypeId,
        'whyHe': whyHe,
        'severity': severity.name,
        if (incompatibleMaterialGroups != null)
          'incompatibleMaterialGroups': incompatibleMaterialGroups,
        if (requiredInterposerWhyHe != null)
          'requiredInterposerWhyHe': requiredInterposerWhyHe,
      };

  @override
  bool operator ==(Object other) =>
      other is CompletionRule &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.whenInLineHasTypeId == whenInLineHasTypeId &&
      other.requireTypeId == requireTypeId &&
      other.whyHe == whyHe &&
      other.severity == severity &&
      listEquals(
          other.incompatibleMaterialGroups, incompatibleMaterialGroups) &&
      other.requiredInterposerWhyHe == requiredInterposerWhyHe;

  @override
  int get hashCode => Object.hash(
        id,
        tradeId,
        whenInLineHasTypeId,
        requireTypeId,
        whyHe,
        severity,
        Object.hashAll(incompatibleMaterialGroups ?? const []),
        requiredInterposerWhyHe,
      );
}
