// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 32 — the core schema.
//
// The trade-AGNOSTIC data model that promotes the hard-coded plumbing catalog into
// an owner-authored, persisted, server-ready document: Trade → TradeCategory →
// AttributeDef/Value → TradeProduct → AccessoryRule → SmartFixture/InstallStage.
// A SUPERSET of `LipskeyCatalogProduct` (lipskey_catalog.dart:4) and
// `SmartProduct`/`SmartStage`/`SmartAcc` (smart_tree.dart); `AttributeKind`
// generalizes `AttrKind` (variant_families.dart:9).
//
// Every type is @immutable, keyed by a STABLE string id (never an index), and
// round-trips through `toJson`/`fromJson` (the Pillar-5 server seam). `fromJson` is
// tolerant (unknown/missing → default; never throws). NOT imported by any live
// screen/logic yet (steps 44+ add the consumers) ⇒ zero regression.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

/// Current schema version stamped on every authored [Trade]. A real
/// `migrate(json, fromVersion)` arrives with the store (step 34 / Step-Eα).
const int kTradeSchemaVersion = 1;

enum AttributeKind { dimension, choice, material, color, freeText, number }

AttributeKind _attrKindFrom(Object? v) => AttributeKind.values.firstWhere(
      (k) => k.name == v,
      orElse: () => AttributeKind.freeText,
    );

// ── small tolerant decoders (no throw; missing/wrong type → default) ──────────
String _str(Object? v) => v is String ? v : '';
String? _strOrNull(Object? v) => v is String ? v : null;
int _int(Object? v) => v is num ? v.toInt() : 0;
int? _intOrNull(Object? v) => v is num ? v.toInt() : null;
bool _bool(Object? v) => v is bool && v;
List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];
Map<String, String> _strMap(Object? v) => v is Map
    ? v.map((k, val) => MapEntry('$k', '$val'))
    : const {};
Map<String, dynamic> _dynMap(Object? v) =>
    v is Map ? v.cast<String, dynamic>() : const {};

@immutable
class Trade {
  const Trade({
    required this.id,
    required this.nameHe,
    required this.emoji,
    required this.color,
    required this.personaId,
    this.published = false,
    this.schemaVersion = kTradeSchemaVersion,
    this.brandIds = const [],
  });

  factory Trade.fromJson(Map<String, dynamic> j) => Trade(
        id: _str(j['id']),
        nameHe: _str(j['nameHe']),
        emoji: _str(j['emoji']),
        color: _int(j['color']),
        personaId: _str(j['personaId']),
        published: _bool(j['published']),
        schemaVersion:
            j['schemaVersion'] is num ? _int(j['schemaVersion']) : kTradeSchemaVersion,
        brandIds: _strList(j['brandIds']),
      );

  final String id;
  final String nameHe;
  final String emoji;
  final int color; // ARGB int, matches Brand.color
  final String personaId;
  final bool published;
  final int schemaVersion;
  final List<String> brandIds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameHe': nameHe,
        'emoji': emoji,
        'color': color,
        'personaId': personaId,
        'published': published,
        'schemaVersion': schemaVersion,
        'brandIds': brandIds,
      };

  @override
  bool operator ==(Object other) =>
      other is Trade &&
      other.id == id &&
      other.nameHe == nameHe &&
      other.emoji == emoji &&
      other.color == color &&
      other.personaId == personaId &&
      other.published == published &&
      other.schemaVersion == schemaVersion &&
      listEquals(other.brandIds, brandIds);

  @override
  int get hashCode => Object.hash(id, nameHe, emoji, color, personaId,
      published, schemaVersion, Object.hashAll(brandIds));
}

@immutable
class TradeCategory {
  const TradeCategory({
    required this.id,
    required this.tradeId,
    required this.titleHe,
    required this.emoji,
    this.parentId,
    this.sortIndex = 0,
    this.attributeSchemaIds = const [],
    this.smartFixtureId,
  });

  factory TradeCategory.fromJson(Map<String, dynamic> j) => TradeCategory(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        titleHe: _str(j['titleHe']),
        emoji: _str(j['emoji']),
        parentId: _strOrNull(j['parentId']),
        sortIndex: _int(j['sortIndex']),
        attributeSchemaIds: _strList(j['attributeSchemaIds']),
        smartFixtureId: _strOrNull(j['smartFixtureId']),
      );

  final String id;
  final String tradeId;
  final String titleHe;
  final String emoji;
  final String? parentId; // null = top level (tree via parent links)
  final int sortIndex;
  final List<String> attributeSchemaIds;
  final String? smartFixtureId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'titleHe': titleHe,
        'emoji': emoji,
        if (parentId != null) 'parentId': parentId,
        'sortIndex': sortIndex,
        'attributeSchemaIds': attributeSchemaIds,
        if (smartFixtureId != null) 'smartFixtureId': smartFixtureId,
      };

  @override
  bool operator ==(Object other) =>
      other is TradeCategory &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.titleHe == titleHe &&
      other.emoji == emoji &&
      other.parentId == parentId &&
      other.sortIndex == sortIndex &&
      listEquals(other.attributeSchemaIds, attributeSchemaIds) &&
      other.smartFixtureId == smartFixtureId;

  @override
  int get hashCode => Object.hash(id, tradeId, titleHe, emoji, parentId,
      sortIndex, Object.hashAll(attributeSchemaIds), smartFixtureId);
}

@immutable
class AttributeValue {
  const AttributeValue({
    required this.id,
    required this.labelHe,
    this.canonical,
    this.sortIndex = 0,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> j) => AttributeValue(
        id: _str(j['id']),
        labelHe: _str(j['labelHe']),
        canonical: _strOrNull(j['canonical']),
        sortIndex: _int(j['sortIndex']),
      );

  final String id;
  final String labelHe;
  final String? canonical;
  final int sortIndex;

  Map<String, dynamic> toJson() => {
        'id': id,
        'labelHe': labelHe,
        if (canonical != null) 'canonical': canonical,
        'sortIndex': sortIndex,
      };

  @override
  bool operator ==(Object other) =>
      other is AttributeValue &&
      other.id == id &&
      other.labelHe == labelHe &&
      other.canonical == canonical &&
      other.sortIndex == sortIndex;

  @override
  int get hashCode => Object.hash(id, labelHe, canonical, sortIndex);
}

@immutable
class AttributeDef {
  const AttributeDef({
    required this.id,
    required this.tradeId,
    required this.nameHe,
    required this.emoji,
    required this.kind,
    this.values = const [],
    this.unitHe,
    this.isVariantAxis = false,
    this.required = false,
    this.matchTokens = const [],
  });

  factory AttributeDef.fromJson(Map<String, dynamic> j) => AttributeDef(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        nameHe: _str(j['nameHe']),
        emoji: _str(j['emoji']),
        kind: _attrKindFrom(j['kind']),
        values: j['values'] is List
            ? (j['values'] as List)
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => AttributeValue.fromJson(e.cast<String, dynamic>()))
                .toList()
            : const [],
        unitHe: _strOrNull(j['unitHe']),
        isVariantAxis: _bool(j['isVariantAxis']),
        required: _bool(j['required']),
        matchTokens: _strList(j['matchTokens']),
      );

  final String id;
  final String tradeId;
  final String nameHe;
  final String emoji;
  final AttributeKind kind;
  final List<AttributeValue> values;
  final String? unitHe;
  final bool isVariantAxis;
  final bool required;

  /// Parser hints so legacy name-parsing reproduces the same variant families
  /// during migration (R1-4; the snapshot test pins the equivalence for step 45).
  final List<String> matchTokens;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'nameHe': nameHe,
        'emoji': emoji,
        'kind': kind.name,
        'values': values.map((v) => v.toJson()).toList(),
        if (unitHe != null) 'unitHe': unitHe,
        'isVariantAxis': isVariantAxis,
        'required': required,
        'matchTokens': matchTokens,
      };

  @override
  bool operator ==(Object other) =>
      other is AttributeDef &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.nameHe == nameHe &&
      other.emoji == emoji &&
      other.kind == kind &&
      listEquals(other.values, values) &&
      other.unitHe == unitHe &&
      other.isVariantAxis == isVariantAxis &&
      other.required == required &&
      listEquals(other.matchTokens, matchTokens);

  @override
  int get hashCode => Object.hash(id, tradeId, nameHe, emoji, kind,
      Object.hashAll(values), unitHe, isVariantAxis, required,
      Object.hashAll(matchTokens));
}

@immutable
class TradeProduct {
  const TradeProduct({
    required this.id,
    required this.tradeId,
    required this.categoryId,
    required this.brandId,
    required this.nameHe,
    required this.nameEn,
    this.attributes = const {},
    this.dims = const {},
    this.imageFiles = const [],
    this.specImageFiles = const [],
    this.qtyPack,
    this.qtyPallet,
    this.page = 0,
  });

  factory TradeProduct.fromJson(Map<String, dynamic> j) => TradeProduct(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        categoryId: _str(j['categoryId']),
        brandId: _str(j['brandId']),
        nameHe: _str(j['nameHe']),
        nameEn: _str(j['nameEn']),
        attributes: _strMap(j['attributes']),
        dims: _dynMap(j['dims']),
        imageFiles: _strList(j['imageFiles']),
        specImageFiles: _strList(j['specImageFiles']),
        qtyPack: _intOrNull(j['qtyPack']),
        qtyPallet: _intOrNull(j['qtyPallet']),
        page: _int(j['page']),
      );

  final String id; // == sku
  final String tradeId;
  final String categoryId;
  final String brandId;
  final String nameHe;
  final String nameEn;
  final Map<String, String> attributes; // attributeDefId -> valueId | freeText
  final Map<String, dynamic> dims; // kept 1:1 for legacy image/spec render parity
  final List<String> imageFiles;
  final List<String> specImageFiles;
  final int? qtyPack;
  final int? qtyPallet;
  final int page;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'categoryId': categoryId,
        'brandId': brandId,
        'nameHe': nameHe,
        'nameEn': nameEn,
        'attributes': attributes,
        'dims': dims,
        'imageFiles': imageFiles,
        'specImageFiles': specImageFiles,
        if (qtyPack != null) 'qtyPack': qtyPack,
        if (qtyPallet != null) 'qtyPallet': qtyPallet,
        'page': page,
      };

  @override
  bool operator ==(Object other) =>
      other is TradeProduct &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.categoryId == categoryId &&
      other.brandId == brandId &&
      other.nameHe == nameHe &&
      other.nameEn == nameEn &&
      mapEquals(other.attributes, attributes) &&
      mapEquals(other.dims, dims) &&
      listEquals(other.imageFiles, imageFiles) &&
      listEquals(other.specImageFiles, specImageFiles) &&
      other.qtyPack == qtyPack &&
      other.qtyPallet == qtyPallet &&
      other.page == page;

  @override
  int get hashCode => Object.hash(
        id,
        tradeId,
        categoryId,
        brandId,
        nameHe,
        nameEn,
        Object.hashAll(attributes.entries.map((e) => '${e.key}=${e.value}')),
        Object.hashAll(dims.keys),
        Object.hashAll(imageFiles),
        Object.hashAll(specImageFiles),
        qtyPack,
        qtyPallet,
        page,
      );
}

@immutable
class AccessoryRule {
  const AccessoryRule({
    required this.id,
    required this.tradeId,
    required this.appliesToCategoryId,
    required this.nameHe,
    required this.emoji,
    required this.whyHe,
    this.appliesToProductId,
    this.mustHave = false,
    this.price,
    this.linkSku,
  });

  factory AccessoryRule.fromJson(Map<String, dynamic> j) => AccessoryRule(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        appliesToCategoryId: _str(j['appliesToCategoryId']),
        appliesToProductId: _strOrNull(j['appliesToProductId']),
        nameHe: _str(j['nameHe']),
        emoji: _str(j['emoji']),
        whyHe: _str(j['whyHe']),
        mustHave: _bool(j['mustHave']),
        price: _intOrNull(j['price']),
        linkSku: _strOrNull(j['linkSku']),
      );

  final String id;
  final String tradeId;
  final String appliesToCategoryId;
  final String? appliesToProductId;
  final String nameHe;
  final String emoji;
  final String whyHe;
  final bool mustHave;
  final int? price;
  final String? linkSku; // ties to a TradeProduct

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'appliesToCategoryId': appliesToCategoryId,
        if (appliesToProductId != null) 'appliesToProductId': appliesToProductId,
        'nameHe': nameHe,
        'emoji': emoji,
        'whyHe': whyHe,
        'mustHave': mustHave,
        if (price != null) 'price': price,
        if (linkSku != null) 'linkSku': linkSku,
      };

  @override
  bool operator ==(Object other) =>
      other is AccessoryRule &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.appliesToCategoryId == appliesToCategoryId &&
      other.appliesToProductId == appliesToProductId &&
      other.nameHe == nameHe &&
      other.emoji == emoji &&
      other.whyHe == whyHe &&
      other.mustHave == mustHave &&
      other.price == price &&
      other.linkSku == linkSku;

  @override
  int get hashCode => Object.hash(id, tradeId, appliesToCategoryId,
      appliesToProductId, nameHe, emoji, whyHe, mustHave, price, linkSku);
}

@immutable
class SmartBrandRef {
  const SmartBrandRef({
    required this.name,
    required this.tag,
    this.rec = false,
    this.sku,
    this.imageAsset,
    this.price,
  });

  factory SmartBrandRef.fromJson(Map<String, dynamic> j) => SmartBrandRef(
        name: _str(j['name']),
        tag: _str(j['tag']),
        rec: _bool(j['rec']),
        sku: _strOrNull(j['sku']),
        imageAsset: _strOrNull(j['imageAsset']),
        price: _intOrNull(j['price']),
      );

  final String name;
  final String tag;
  final bool rec;
  final String? sku;
  final String? imageAsset;
  final int? price;

  Map<String, dynamic> toJson() => {
        'name': name,
        'tag': tag,
        'rec': rec,
        if (sku != null) 'sku': sku,
        if (imageAsset != null) 'imageAsset': imageAsset,
        if (price != null) 'price': price,
      };

  @override
  bool operator ==(Object other) =>
      other is SmartBrandRef &&
      other.name == name &&
      other.tag == tag &&
      other.rec == rec &&
      other.sku == sku &&
      other.imageAsset == imageAsset &&
      other.price == price;

  @override
  int get hashCode => Object.hash(name, tag, rec, sku, imageAsset, price);
}

@immutable
class InstallStage {
  const InstallStage({
    required this.emoji,
    required this.labelHe,
    this.subHe = '',
    this.isFinal = false,
    this.matchTokens = const [],
  });

  factory InstallStage.fromJson(Map<String, dynamic> j) => InstallStage(
        emoji: _str(j['emoji']),
        labelHe: _str(j['labelHe']),
        subHe: _str(j['subHe']),
        isFinal: _bool(j['isFinal']),
        matchTokens: _strList(j['matchTokens']),
      );

  final String emoji;
  final String labelHe;
  final String subHe;
  final bool isFinal;
  final List<String> matchTokens;

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'labelHe': labelHe,
        'subHe': subHe,
        'isFinal': isFinal,
        'matchTokens': matchTokens,
      };

  @override
  bool operator ==(Object other) =>
      other is InstallStage &&
      other.emoji == emoji &&
      other.labelHe == labelHe &&
      other.subHe == subHe &&
      other.isFinal == isFinal &&
      listEquals(other.matchTokens, matchTokens);

  @override
  int get hashCode => Object.hash(
      emoji, labelHe, subHe, isFinal, Object.hashAll(matchTokens));
}

@immutable
class SmartFixture {
  const SmartFixture({
    required this.id,
    required this.tradeId,
    required this.categoryId,
    required this.nameHe,
    required this.emoji,
    this.diagramTitleHe = '',
    this.brandRefs = const [],
    this.accessoryRuleIds = const [],
    this.stages = const [],
  });

  factory SmartFixture.fromJson(Map<String, dynamic> j) => SmartFixture(
        id: _str(j['id']),
        tradeId: _str(j['tradeId']),
        categoryId: _str(j['categoryId']),
        nameHe: _str(j['nameHe']),
        emoji: _str(j['emoji']),
        diagramTitleHe: _str(j['diagramTitleHe']),
        brandRefs: j['brandRefs'] is List
            ? (j['brandRefs'] as List)
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => SmartBrandRef.fromJson(e.cast<String, dynamic>()))
                .toList()
            : const [],
        accessoryRuleIds: _strList(j['accessoryRuleIds']),
        stages: j['stages'] is List
            ? (j['stages'] as List)
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => InstallStage.fromJson(e.cast<String, dynamic>()))
                .toList()
            : const [],
      );

  final String id;
  final String tradeId;
  final String categoryId;
  final String nameHe;
  final String emoji;
  final String diagramTitleHe;
  final List<SmartBrandRef> brandRefs;
  final List<String> accessoryRuleIds;
  final List<InstallStage> stages;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tradeId': tradeId,
        'categoryId': categoryId,
        'nameHe': nameHe,
        'emoji': emoji,
        'diagramTitleHe': diagramTitleHe,
        'brandRefs': brandRefs.map((b) => b.toJson()).toList(),
        'accessoryRuleIds': accessoryRuleIds,
        'stages': stages.map((s) => s.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      other is SmartFixture &&
      other.id == id &&
      other.tradeId == tradeId &&
      other.categoryId == categoryId &&
      other.nameHe == nameHe &&
      other.emoji == emoji &&
      other.diagramTitleHe == diagramTitleHe &&
      listEquals(other.brandRefs, brandRefs) &&
      listEquals(other.accessoryRuleIds, accessoryRuleIds) &&
      listEquals(other.stages, stages);

  @override
  int get hashCode => Object.hash(
        id,
        tradeId,
        categoryId,
        nameHe,
        emoji,
        diagramTitleHe,
        Object.hashAll(brandRefs),
        Object.hashAll(accessoryRuleIds),
        Object.hashAll(stages),
      );
}
