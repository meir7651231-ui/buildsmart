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
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/domain/trade_product_adapter.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';

/// The reserved id for the baked-in plumbing trade.
const String kPlumbingTradeId = 'plumbing';

String _categoryId(String key) => '$kPlumbingTradeId.cat.$key';

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
  out.sort((a, b) => a.id.compareTo(b.id));
  return out;
}

/// Every catalog product, via the byte-faithful adapter, sorted by sku.
List<TradeProduct> plumbingProducts() => kCatalogProducts
    .map((p) => tradeProductFromLegacy(p, tradeId: kPlumbingTradeId))
    .toList()
  ..sort((a, b) => a.id.compareTo(b.id));

/// One [AccessoryRule] per fixture accessory ("אביזרים נלווים"), keyed stably.
List<AccessoryRule> plumbingAccessories() {
  final out = <AccessoryRule>[];
  for (final sp in kSmartProducts) {
    for (var i = 0; i < sp.acc.length; i++) {
      final a = sp.acc[i];
      out.add(
        AccessoryRule(
          id: '$kPlumbingTradeId.acc.${sp.key}.$i',
          tradeId: kPlumbingTradeId,
          appliesToCategoryId: _categoryId(sp.cat),
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
/// links), sorted by id.
List<SmartFixture> plumbingFixtures() => kSmartProducts
    .map(
      (sp) => SmartFixture(
        id: '$kPlumbingTradeId.fixture.${sp.key}',
        tradeId: kPlumbingTradeId,
        categoryId: _categoryId(sp.cat),
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

/// Build the full plumbing [TradesDoc] from the live consts — deterministic, so two
/// calls are equal. Connection types/specs/rules (from the 891 VerifiedSpecs) arrive
/// at step 37.
TradesDoc buildPlumbingSeed() => TradesDoc(
      trades: [plumbingTrade()],
      categories: plumbingCategories(),
      products: plumbingProducts(),
      accessories: plumbingAccessories(),
      fixtures: plumbingFixtures(),
    );
