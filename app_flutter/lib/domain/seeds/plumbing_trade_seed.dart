// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 36 — the plumbing seed
// (trade + categories + products + fixtures + accessories).
//
// DEVIATION FROM THE PLAN (documented): the canonical plan emits a committed seed via
// `scripts/gen_plumbing_seed.dart`. That is BLOCKED — the live consts import
// `package:flutter/foundation.dart`, which transitively references `dart:ui`
// (`ui.Image`/`ui.Picture`), so a plain `dart run` codegen script fails to compile.
// Instead the seed is a RUNTIME BUILDER: `buildPlumbingSeed()` constructs the
// `TradesDoc` from the live consts, deterministically (stable id/sku sort), so it is
// idempotent by construction (no emitted-source byte-drift to guard) and the
// answer-equivalence keystone (step 38) tests it directly. Connection types / specs /
// CompatibilityRules from the 891 VerifiedSpecs are added in step 37.
//
// "plumbing" is supplied here ONLY as a seed; the store starts empty and no live
// read-path imports this yet (step 39 wires the resolver) ⇒ zero regression.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/domain/trade_product_adapter.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';

/// The reserved id for the baked-in plumbing trade.
const String kPlumbingTradeId = 'plumbing';

String _categoryId(String key) => '$kPlumbingTradeId.cat.$key';

// ── connection-seed helpers (step 37) ─────────────────────────────────────────
// Stable id schemes for the authored connection model derived from the 891
// VerifiedSpecs. Keep them deterministic — two buildPlumbingSeed() calls must
// stay byte-equal.
String _systemId(WaterSystem s) => '$kPlumbingTradeId.sys.${s.name}';

String _connTypeId(EndType e) => '$kPlumbingTradeId.conn.${e.name}';

/// The galvanic material group of a plumbing material, or null when the material
/// is galvanically benign (HDPE/PEX/PVC/…). Mirrors install_engine.dart:117
/// `_galvanicallyDissimilar`: copper-group (נחושת/פליז) vs iron-group
/// (פלדה/נירוסטה). A dielectric union is required only between the two groups.
String? _galvanicGroup(String m) {
  const copper = {'נחושת', 'פליז'};
  const iron = {'פלדה', 'נירוסטה'};
  if (copper.contains(m)) return 'copper-group';
  if (iron.contains(m)) return 'iron-group';
  return null;
}

/// The plumbing system an [EndType] belongs to — derived from the verified
/// physics in [ConnectorEnd.system] (size-independent switch on the type), so it
/// can never drift from the engine's mapping.
WaterSystem _systemOfEndType(EndType e) => ConnectorEnd(e, '').system;

/// Fallback category for any reference that resolves to nothing — guarantees every
/// product/fixture/accessory still points at a real [TradeCategory] (FK integrity).
const String kUncategorizedCategoryId = '$kPlumbingTradeId.cat._uncategorized';

// Shared category resolvers, built ONCE from [kCatalogTree] using the SAME
// `_categoryId(node.id)` scheme as [plumbingCategories] — so the ids are identical
// and references can never dangle. A legacy product's `categoryHe` matches a leaf's
// `lipskeyCategory`; a [SmartProduct.key] matches a leaf's `smartKey`.
Map<String, String>? _lipskeyCategoryToIdCache;
Map<String, String>? _smartKeyToIdCache;

void _buildCategoryResolvers() {
  final lipskey = <String, String>{};
  final smart = <String, String>{};
  void walk(CatalogNode n) {
    final lipskeyCategory = n.lipskeyCategory;
    if (lipskeyCategory != null) lipskey[lipskeyCategory] = _categoryId(n.id);
    final smartKey = n.smartKey;
    if (smartKey != null) smart[smartKey] = _categoryId(n.id);
    for (final c in n.children) {
      walk(c);
    }
  }

  for (final n in kCatalogTree) {
    walk(n);
  }
  _lipskeyCategoryToIdCache = lipskey;
  _smartKeyToIdCache = smart;
}

/// `lipskeyCategory` → category id (built from the catalog tree, computed once).
Map<String, String> _lipskeyCategoryToId() {
  if (_lipskeyCategoryToIdCache == null) _buildCategoryResolvers();
  return _lipskeyCategoryToIdCache!;
}

/// `SmartProduct.key` → category id (built from the catalog tree, computed once).
Map<String, String> _smartKeyToId() {
  if (_smartKeyToIdCache == null) _buildCategoryResolvers();
  return _smartKeyToIdCache!;
}

/// The plumbing [Trade] header (persona = the contractor; brandIds from kBrands).
Trade plumbingTrade() => Trade(
      id: kPlumbingTradeId,
      nameHe: 'אינסטלציה',
      emoji: '🔧',
      color: kBrands.isEmpty ? 0xFFFF7A18 : kBrands.first.color,
      personaId: 'contractor',
      published: true,
      brandIds: (kBrands.map((b) => b.id).toList()..sort()),
    );

/// Flatten the const [kCatalogTree] (3-level) into parent-linked [TradeCategory]s.
List<TradeCategory> plumbingCategories() {
  final out = <TradeCategory>[];
  void walk(CatalogNode n, String? parentId, int sortIndex) {
    out.add(
      TradeCategory(
        id: _categoryId(n.id),
        tradeId: kPlumbingTradeId,
        titleHe: n.title,
        emoji: n.emoji,
        parentId: parentId,
        sortIndex: sortIndex,
        smartFixtureId: n.smartKey,
      ),
    );
    for (var i = 0; i < n.children.length; i++) {
      walk(n.children[i], _categoryId(n.id), i);
    }
  }

  for (var i = 0; i < kCatalogTree.length; i++) {
    walk(kCatalogTree[i], null, i);
  }
  // Fallback bucket so any unresolved product/fixture/accessory ref still has a
  // valid target (FK integrity). sortIndex stays stable (appended last, pre-sort).
  out.add(
    TradeCategory(
      id: kUncategorizedCategoryId,
      tradeId: kPlumbingTradeId,
      titleHe: 'ללא קטגוריה',
      emoji: '❓',
      parentId: null,
      sortIndex: out.length,
    ),
  );
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}

/// Every catalog product, via the byte-faithful adapter, sorted by sku. The
/// category id is resolved from the catalog tree (`lipskeyCategory` → id) so it
/// points at a real [TradeCategory]; unmatched products fall back to
/// [kUncategorizedCategoryId].
List<TradeProduct> plumbingProducts() {
  final lipskeyMap = _lipskeyCategoryToId();
  return kCatalogProducts
      .map(
        (p) => tradeProductFromLegacy(
          p,
          tradeId: kPlumbingTradeId,
          categoryId: lipskeyMap[p.categoryHe] ?? kUncategorizedCategoryId,
        ),
      )
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
}

/// One [AccessoryRule] per fixture accessory ("אביזרים נלווים"), keyed stably.
/// `appliesToCategoryId` is resolved from the catalog tree (`SmartProduct.key` →
/// id, the SAME resolution as the parent fixture) so it points at a real
/// [TradeCategory]; unmatched ones fall back to [kUncategorizedCategoryId].
List<AccessoryRule> plumbingAccessories() {
  final smartKeyMap = _smartKeyToId();
  final out = <AccessoryRule>[];
  for (final sp in kSmartProducts) {
    for (var i = 0; i < sp.acc.length; i++) {
      final a = sp.acc[i];
      out.add(
        AccessoryRule(
          id: '$kPlumbingTradeId.acc.${sp.key}.$i',
          tradeId: kPlumbingTradeId,
          appliesToCategoryId:
              smartKeyMap[sp.key] ?? kUncategorizedCategoryId,
          nameHe: a.name,
          emoji: a.emoji,
          whyHe: a.why,
          mustHave: a.must,
          price: a.price,
          linkSku: a.sku,
        ),
      );
    }
  }
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}

/// The curated [SmartProduct]s as [SmartFixture]s (brandRefs + stages + accessory
/// links), sorted by id. `categoryId` is resolved from the catalog tree
/// (`SmartProduct.key` → id) so it points at a real [TradeCategory]; unmatched
/// fixtures fall back to [kUncategorizedCategoryId].
List<SmartFixture> plumbingFixtures() {
  final smartKeyMap = _smartKeyToId();
  return kSmartProducts
      .map(
        (sp) => SmartFixture(
          id: '$kPlumbingTradeId.fixture.${sp.key}',
          tradeId: kPlumbingTradeId,
          categoryId: smartKeyMap[sp.key] ?? kUncategorizedCategoryId,
          nameHe: sp.name,
          emoji: sp.emoji,
          diagramTitleHe: sp.diagramTitle,
          brandRefs: sp.brands
              .map(
                (b) => SmartBrandRef(
                  name: b.name,
                  tag: b.tag,
                  rec: b.rec,
                  sku: b.sku,
                  imageAsset: b.imageAsset,
                  price: b.price,
                ),
              )
              .toList(),
          accessoryRuleIds: [
            for (var i = 0; i < sp.acc.length; i++)
              '$kPlumbingTradeId.acc.${sp.key}.$i',
          ],
          stages: sp.stages
              .map(
                (s) => InstallStage(
                  emoji: s.emoji,
                  labelHe: s.label,
                  subHe: s.sub,
                  isFinal: s.isFinal,
                  matchTokens: s.match,
                ),
              )
              .toList(),
        ),
      )
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
}

// ── step 37 — the authored connection model (seeded from the VerifiedSpecs) ────

/// The two plumbing systems (supply / drainage), sorted by id. These mirror
/// [WaterSystem]; the resolver pins a line to exactly one.
List<SystemDef> plumbingSystems() => <SystemDef>[
      SystemDef(
        id: '$kPlumbingTradeId.sys.supply',
        tradeId: kPlumbingTradeId,
        nameHe: 'אספקה',
        color: 0xFF2196F3,
      ),
      SystemDef(
        id: '$kPlumbingTradeId.sys.drainage',
        tradeId: kPlumbingTradeId,
        nameHe: 'ניקוז',
        color: 0xFF9E9E9E,
      ),
    ]..sort((a, b) => a.id.compareTo(b.id));

/// One [ConnectorType] per [EndType], sorted by id. `sizeValues` is the sorted,
/// distinct set of sizes seen for that end-type across ALL [kVerifiedSpecs].
/// `nameHe` is a NEW descriptive label (the physics never reads it). `systemId`
/// is derived from the verified [ConnectorEnd.system] mapping.
List<ConnectorType> plumbingConnectorTypes() {
  const nameHe = <EndType, String>{
    EndType.hdpeCompression: 'הידוק HDPE',
    EndType.pexPress: 'PEX פרס',
    EndType.copperPress: 'נחושת פרס',
    EndType.bspMale: 'תבריג זכר (BSP)',
    EndType.bspFemale: 'תבריג נקבה (BSP)',
    EndType.drainOpening: 'פתח ניקוז',
  };
  // Collect the distinct sizes per end-type across every verified spec.
  final sizesByType = <EndType, Set<String>>{
    for (final e in EndType.values) e: <String>{},
  };
  for (final spec in kVerifiedSpecs.values) {
    for (final end in spec.ends) {
      sizesByType[end.type]!.add(end.size);
    }
  }
  return <ConnectorType>[
    for (final e in EndType.values)
      ConnectorType(
        id: _connTypeId(e),
        tradeId: kPlumbingTradeId,
        nameHe: nameHe[e]!,
        sizeValues: sizesByType[e]!.toList()..sort(),
        systemId: _systemId(_systemOfEndType(e)),
      ),
  ]..sort((a, b) => a.id.compareTo(b.id));
}

/// One [ProductConnectorSpec] per [kVerifiedSpecs] entry, sorted by sku. The
/// material's galvanic group (R1-3) is derived via [_galvanicGroup]. `pexType`
/// is deferred in v1 — `envelope` is Map<String,num> so it cannot carry the
/// String, and we deliberately do NOT fold it into `ratingHe`.
List<ProductConnectorSpec> plumbingProductSpecs() => <ProductConnectorSpec>[
      for (final spec in kVerifiedSpecs.values)
        ProductConnectorSpec(
          productSku: spec.sku,
          tradeId: kPlumbingTradeId,
          ends: [
            for (final e in spec.ends)
              ProductEnd(
                connectorTypeId: _connTypeId(e.type),
                sizeValue: e.size,
              ),
          ],
          materialId: spec.material,
          ratingHe: spec.pressureRating,
          envelope: {'maxTempC': spec.maxTempC},
          materialGroupId: _galvanicGroup(spec.material),
        ),
    ]..sort((a, b) => a.productSku.compareTo(b.productSku));

/// The 5 same-type joint rules, sorted by id. `methodLabelHe` is KEYSTONE-CRITICAL
/// — each value is byte-identical to install_engine.dart `connectionMethodLabel`
/// (the engine's label for that joint type). A size mismatch on these is a hard
/// (critical) error.
List<CompatibilityRule> plumbingCompatRules() {
  const pairs = <(EndType, EndType, String)>[
    (EndType.bspMale, EndType.bspFemale, 'תבריג + PTFE'),
    (EndType.pexPress, EndType.pexPress, 'Press / טבעת כיווץ'),
    (EndType.copperPress, EndType.copperPress, 'Press / O-ring'),
    (EndType.drainOpening, EndType.drainOpening, 'כיסוי ניקוז'),
    (EndType.hdpeCompression, EndType.hdpeCompression, 'אום הידוק (compression)'),
  ];
  return <CompatibilityRule>[
    for (final (a, b, label) in pairs)
      CompatibilityRule(
        id: '$kPlumbingTradeId.rule.${a.name}__${b.name}',
        tradeId: kPlumbingTradeId,
        aTypeId: _connTypeId(a),
        bTypeId: _connTypeId(b),
        sizeMatch: SizeMatch.exactSame,
        methodLabelHe: label,
        onMismatch: RuleSeverity.critical,
      ),
  ]..sort((a, b) => a.id.compareTo(b.id));
}

/// The single galvanic completion rule. whenInLineHasTypeId/requireTypeId are ''
/// on purpose — galvanic corrosion is MATERIAL-based, not connector-type-
/// triggered; the resolver (step 40) reads [incompatibleMaterialGroups] (the two
/// dissimilar metal groups) rather than a type trigger.
List<CompletionRule> plumbingCompletionRules() => <CompletionRule>[
      CompletionRule(
        id: '$kPlumbingTradeId.completion.galvanic',
        tradeId: kPlumbingTradeId,
        whenInLineHasTypeId: '',
        requireTypeId: '',
        whyHe:
            'מתכות לא-דומות (נחושת/פליז ↔ פלדה/נירוסטה) באותו קו דורשות מתאם דיאלקטרי למניעת קורוזיה גלוונית',
        incompatibleMaterialGroups: ['copper-group', 'iron-group'],
        requiredInterposerWhyHe:
            'מתאם דיאלקטרי (ניתוק גלווני בין קבוצות-מתכת לא-דומות)',
        severity: RuleSeverity.critical,
      ),
    ];

/// Build the full plumbing [TradesDoc] from the live consts — deterministic, so two
/// calls are equal. The authored connection model (connector types / systems /
/// product specs / compat + completion rules) is seeded from the 891 VerifiedSpecs.
TradesDoc buildPlumbingSeed() => TradesDoc(
      trades: [plumbingTrade()],
      categories: plumbingCategories(),
      products: plumbingProducts(),
      accessories: plumbingAccessories(),
      fixtures: plumbingFixtures(),
      connectorTypes: plumbingConnectorTypes(),
      systems: plumbingSystems(),
      productSpecs: plumbingProductSpecs(),
      compatRules: plumbingCompatRules(),
      completionRules: plumbingCompletionRules(),
    );
