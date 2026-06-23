# Pillar #2 — The No-Code Domain / Vertical Builder

> ⚠️ קנוני = מקטע 🔧 תיקוני Red-Team R1 (בסוף) + RED-TEAM-R1/R2.md. ה-appendix גובר.

### "תוסיף חשמלאי מחר, בעצמי" — a grounded, phased Flutter build-plan

> **Scope owner:** the **Trade → Category → Attribute/Variant → Product → Accessory → CompatibilityRule data model** + the Hebrew **no-code authoring UX** for it + the **migration of the existing plumbing catalog** into that model with **zero regression** + **bulk import** + the **trade-agnostic connection-planning engine**.
> **Branch:** `claude/whats-happening-LyY9G`. **Stack:** Flutter 3.29 / Dart 3.7 / Riverpod. RTL/Hebrew/a11y. Server-ready. 100-gate protocol. Gated, default-OFF, byte-identical fallback.
> **Coordinate (do NOT design here):** Pillar 1 = config-engine/Studio (reuse its inline-edit `R9` + persisted-notifier authoring patterns); Pillar 5 = scale/backend/import-pipeline/search-at-scale (10Ks products, indexed search, virtualization, Firestore sharding).

---

## 0. The hard truth: what is hard-coded plumbing today (grounded inventory)

Everything below is a **single-trade, compile-time const** today. The whole pillar is: *promote each of these from a Dart const into an owner-authored, persisted, server-ready document — without changing a byte of the plumbing build.*

| Concept | Today (file:line) | Shape | Why it's plumbing-locked |
|---|---|---|---|
| **Catalog product** | `lib/data/lipskey_catalog.dart:4` `class LipskeyCatalogProduct` | const class: `sku, nameHe, nameEn, color, qtyPack, qtyPallet, categoryHe, categoryEn, categoryEmoji, page, dims:Map, imageFile(s), specImageFile(s), brand` | `dims` keys are plumbing (`'DN'`, `'di קוטר פנימי'`, `'PN'`); `brand` defaults `'ליפסקי'`; image dir hard-switches by brand (`:49-53`) |
| **Unified product list** | `lib/data/polyroll_catalog.dart:1513` `kCatalogProducts = [...kLipskeyCatalog, ...kPolyrollCatalog]` | top-level const list (Huliot appended likewise) | three plumbing brands concatenated at compile time |
| **Category tree** | `lib/data/catalog_tree.dart:10` `class CatalogNode {id,title,emoji,children,brandIds,lipskeyCategory,smartKey}` + `:36 kCatalogTree` | const 3-level tree, leaves carry `lipskeyCategory` + `smartKey` | titles `'ניקוז וצנרת'`, `'סיפונים'`… are plumbing |
| **Top catalog categories** | `lib/data/catalog.dart:5` `kCatalogCats` (11 `Section`) | const list | `'ברזים וכיורים'`, `'אסלות'`, `'ניקוז וצנרת'`… |
| **Curated "smart product"** (fixture card: brands + accessories + install stages) | `lib/data/smart_tree.dart:114` `class SmartProduct {key,name,emoji,cat,brands:[SmartBrand],acc:[SmartAcc],diagramTitle,stages:[SmartStage]}` + `:153 kSmartProducts` | const list (~30 fixtures) | `cat` is a plumbing category string; stages/acc are plumbing tasks |
| **Install stages** | `lib/data/smart_tree.dart:4` `class SmartStage {emoji,label,sub,isFinal,match:[String]}` (`_strap,_sf,_st,_ss,_sb,_si,_sw,_stile,_sprof` `:23-76`) | const sequences | "סיפון", "מיכל הדחה", "PEX חם/קר" |
| **Required accessories ("אביזרים נלווים")** | `lib/data/smart_tree.dart:97` `class SmartAcc {name,emoji,why,must,price,sku}` | per-fixture const list | "סרט טפלון", "אטם דו צדדי 32/50" |
| **Attribute / Variant schema** | `lib/data/variant_families.dart:9` `enum AttrKind {size,color,model,subtype}` + `:46 variantValue()` + `:77 allVariantFamilies()` | **inferred at runtime by parsing `nameHe` with regex** (`_isSizeToken :25`, `kLipskeyColors/Models/Subtypes`) | size token regex is DN/inch; colors/models are plumbing vocab sets |
| **Compatibility / connection rules** | `lib/data/lipskey_verified_connections.dart:24` `enum EndType {hdpeCompression,pexPress,copperPress,bspMale,bspFemale,drainOpening}` · `:41 enum WaterSystem {supply,drainage}` · `:43 class ConnectorEnd` · `:77 class VerifiedSpec {sku,ends:[ConnectorEnd],material,pressureRating,pexType,maxTempC,systemOverride}` · `kVerifiedSpecs` (**891 specs**) | const map sku→spec; `directMatesWith`/`pipeSharedWith`/`compatibleWith` are **hand-coded plumbing physics** | the entire enum is plumbing joints; BSP male⟺female; `kBspInchToMm :32`; galvanic groups |
| **Install kit (tools/sealants)** | `lib/logic/install_kit.dart:15` `class KitItem {kind:KitKind,label,reason,severity}` · `recommendedKitForProduct :42` / `recommendedKitFor :155` | per-joint hand-coded | PTFE tape, PEX crimper, dielectric union, PPR welder |
| **Compatibility engine** | `lib/logic/install_engine.dart` (~70 KB): `chainProvider :38`, `lineMaxTempProvider :42`, `lineComplianceChecklist :151`, `connectionMethodLabel :90`, `_galvanicallyDissimilar :117` | Riverpod + pure logic | hot-water threshold 60°C, isolation-valve SKUs, supply/drainage |
| **Brand metadata** | `lib/data/brands.dart:4` `class Brand {id,name,emoji,color,tagline,productCount}` + `:25 kBrands` (8 brands) | const list | all plumbing brands |
| **Brand→behavior switches** | `related_info.dart:53,54,446,449,500,527,624,645` + `lipskey_catalog.dart:50-51` `if (p.brand=='פולירול'/'חוליות')` | hard `if` ladders | a new trade's brand falls through to the Lipskey default |
| **Chip hierarchy (name decomposition)** | `lib/data/chip_hierarchy.dart:154 class ChipPath` + `kChipTypes/kChipLevel1Connection/…:7-99` | const vocab sets + parser | "ברך", "מסעף", "45°", materials — 100% plumbing tokens |
| **Lay-finder taxonomy** | `related_info.dart:21 _kFinderGroups` (🚰ברזים, 🔗מחברים, 📏צינורות, 🕳️ניקוז, 🚿מקלחת, 🚽אסלות) | const | maps plumbing categories to lay groups |
| **Search synonyms** | `catalog_screen.dart:103-113 kSearchSynonyms` | const map | 'ניקוז'→['מחסום','סיפון',…] |
| **Navigation search index** | `lib/data/search_index.dart:45 kSearchIndex` (~290 `SearchEntry`) | const list of **nav/breadcrumb** nodes (NOT product full-text) | breadcrumbs are plumbing categories |

**Two precedents already in the repo that we mirror:**
1. **Server-ready repository seam already exists.** `lib/data/repositories/catalog_local.dart:44 LocalCatalogRepository` implements `CatalogRepository` and returns the const lists verbatim; `catalogRepositoryProvider :103` is the single read seam *"a future remote impl swaps in behind"*. **This is exactly where the multi-trade data source plugs in.**
2. **A multi-trade shape already exists for a *different* concept.** `lib/data/contractor_seeds.dart:84 class PlanType` already enumerates **תברואה / חשמל / אדריכלות / מיזוג אוויר** as scan-blueprint seeds — proof the codebase already thinks "a trade is data". We generalize that idea to the *catalog/variant/compat* model (which `PlanType` does **not** cover).

**Infra to reuse (do not reinvent):**
- `lib/state/feature_flags.dart:36 FeatureFlagsNotifier` — persisted `Set<String>` of ON flags, `isOn/enable/disable`, default-OFF, `_forcedOnFlags` for demo builds. **Every step here gates behind one of these.**
- `lib/state/catalog_settings.dart` — the `SharedPreferences`-backed notifier idiom (`_kStorageKey`, async `_load`, `_persist`) we copy for the new authored-trade store.
- `MANAGER-BUILD-PLAN.md` §M3 (steps 31-44) — the **single-trade** god-mode CRUD (rename category, add/edit brand, edit accessory tree, add product, inline `R9`, undo, server-ready provider). **Our pillar is the multi-trade superset of M3** and must not duplicate its single-trade editors but *generalize the data they write into.*

---

## 1. The generalized data model (the heart of this pillar)

A new layer `lib/domain/` holds **trade-agnostic schema types** + an **authored-document model**. Plumbing becomes *one* `Trade` whose documents are produced by the migration (Phase B) and read through the same repository the screens already use.

### 1.1 New schema types — `lib/domain/trade_schema.dart`
All `@immutable`, all `toJson/fromJson` (server-ready), all keyed by stable string ids (never indexes).

```
class Trade {
  final String id;            // 'plumbing' (reserved) | 'electrician' | …
  final String nameHe;        // 'אינסטלציה' / 'חשמל'
  final String emoji;         // 🔧 / ⚡
  final int color;            // brand color (int ARGB, matches Brand.color)
  final String personaId;     // links to kPersonas (👷 etc.) — see §6
  final bool published;       // draft vs live
  final int schemaVersion;
  final List<String> brandIds;
}

// A node in this trade's category tree — the data-driven CatalogNode.
class TradeCategory {
  final String id; final String tradeId;
  final String titleHe; final String emoji;
  final String? parentId;     // null = top level (tree via parent links, not nesting)
  final int sortIndex;
  final List<String> attributeSchemaIds;   // which AttributeDefs apply at this leaf
  final String? smartFixtureId;            // optional curated card (the new SmartProduct)
}

// The AUTHORED replacement for the inferred AttrKind/variant_families heuristics.
class AttributeDef {
  final String id; final String tradeId;
  final String nameHe;                 // 'אמפר' / 'מספר קטבים' / 'צבע' / 'קוטר'
  final String emoji;                  // 📐 🎨 …
  final AttributeKind kind;            // dimension | choice | material | color | freeText | number
  final List<AttributeValue> values;  // authored enum OR empty for free/number
  final String? unitHe;               // 'A' / 'mm' / '"' 
  final bool isVariantAxis;           // does varying THIS spawn a variant family?
  final bool required;
  // Optional parser hints so legacy name-parsing still works during migration:
  final List<String> matchTokens;     // e.g. ['16A','25A'] or DN tokens
}
class AttributeValue { final String id; final String labelHe; final String? canonical; final int sortIndex; }
enum AttributeKind { dimension, choice, material, color, freeText, number }

// The data-driven product. A SUPERSET of LipskeyCatalogProduct (see §1.4 adapter).
class TradeProduct {
  final String id;            // == sku
  final String tradeId; final String categoryId; final String brandId;
  final String nameHe; final String nameEn;
  final Map<String,String> attributes;   // attributeDefId -> valueId|freeText  (replaces ad-hoc dims)
  final Map<String,dynamic> dims;        // kept for legacy image/spec render parity
  final List<String> imageFiles; final List<String> specImageFiles;
  final int? qtyPack; final int? qtyPallet; final int page;
}

// Required accessories per product/category — the authored "אביזרים נלווים".
class AccessoryRule {
  final String id; final String tradeId;
  final String appliesToCategoryId;     // OR appliesToProductId (one of)
  final String? appliesToProductId;
  final String nameHe; final String emoji; final String whyHe;
  final bool mustHave; final int? price; final String? linkSku;  // ties to a TradeProduct
}

// The data-driven SmartProduct (curated fixture card + install stages).
class SmartFixture {
  final String id; final String tradeId; final String categoryId;
  final String nameHe; final String emoji; final String diagramTitleHe;
  final List<SmartBrandRef> brandRefs;   // sku + tag + rec + image (== SmartBrand)
  final List<String> accessoryRuleIds;   // -> AccessoryRule
  final List<InstallStage> stages;       // == SmartStage, authored
}
class InstallStage { final String emoji; final String labelHe; final String subHe; final bool isFinal; final List<String> matchTokens; }
```

### 1.2 The connection model — `lib/domain/connection_schema.dart` (the make-or-break generalization)
Plumbing today encodes joints as a **closed enum** (`EndType`) with **hand-coded mating math** (`directMatesWith`). To let an owner add "which breaker fits which panel" with no code, we replace the closed enum with **authored connector *types* + an authored *compatibility matrix*** — while keeping the plumbing rules byte-identical by *seeding the matrix from the existing 891 specs* (Phase B).

```
// An authored connector TYPE for a trade (replaces the EndType enum members).
class ConnectorType {
  final String id; final String tradeId;
  final String nameHe;                 // 'תבריג זכר 1/2"' / 'מודול DIN 35mm' / 'שקע C13'
  final List<String> sizeValues;       // the discrete sizes this type comes in
  final String? systemId;              // SystemDef.id (supply/drainage  →  e.g. 230V/data)
}

// A trade's "systems" — the supply/drainage generalization.
// A line/circuit must stay within ONE system (kept from WaterSystem semantics).
class SystemDef { final String id; final String tradeId; final String nameHe; final int color; }

// Each product's physical ends (the authored VerifiedSpec).
class ProductConnectorSpec {
  final String productSku; final String tradeId;
  final List<ProductEnd> ends;         // (connectorTypeId, sizeValue)
  final String? materialId; final String? ratingHe;
  final Map<String,num> envelope;      // {'maxTempC':40} plumbing | {'maxAmp':16} electric — trade-defined keys
}
class ProductEnd { final String connectorTypeId; final String sizeValue; }

// THE no-code rule the owner authors: "type A (size s) mates with type B (size s)".
class CompatibilityRule {
  final String id; final String tradeId;
  final String aTypeId; final String bTypeId;
  final SizeMatch sizeMatch;           // exactSame | anyToAny | tableLookup
  final List<List<String>>? sizeTable; // for tableLookup: allowed [aSize,bSize] pairs
  final String methodLabelHe;          // 'תבריג + PTFE' / 'הידוק על פס DIN'
  final RuleSeverity onMismatch;       // info|warning|critical (== CheckSeverity)
}
enum SizeMatch { exactSame, anyToAny, tableLookup }
enum RuleSeverity { info, warning, critical }

// Authored "what completes what" / required-companions (generalizes hot-water compliance).
class CompletionRule {
  final String id; final String tradeId; final String whenInLineHasTypeId; // trigger
  final String requireTypeId; final String whyHe; final RuleSeverity severity;
}
```

**Why this shape works for both trades:** plumbing's `bspMale⟺bspFemale @ same size` becomes a `CompatibilityRule(aType=מתבריג_זכר, bType=תבריג_נקבה, sizeMatch=exactSame, method='תבריג + PTFE')`; electrician's "16A breaker fits a 16A-rated panel busbar" becomes `CompatibilityRule(aType=מאמ"ת, bType=פס_צבירה, sizeMatch=tableLookup, sizeTable=[['16A','≤63A']…])`. The **engine stops knowing physics and starts evaluating authored rules.**

### 1.3 The authored-trade store — `lib/state/trades_store.dart`
A `StateNotifier<TradesDoc>` over `SharedPreferences` (key `bs.trades.v1`, JSON), copying the `catalog_settings.dart` idiom exactly (async `_load`, `_persist`, idempotent mutators). It holds the **owner-authored deltas only**; plumbing is supplied by a baked seed (§1.5) so authored storage starts empty → byte-identical. Server swap (Pillar 5) replaces the persistence backend behind the same notifier, mirroring `firestore_cached_repo.dart`.

### 1.4 The compatibility adapter (zero-regression linchpin) — `lib/domain/trade_product_adapter.dart`
The screens read `LipskeyCatalogProduct`. We do **not** rewrite 8 011 lines of `catalog_screen.dart`. Instead:
- `TradeProduct.toLegacy()` → a `LipskeyCatalogProduct` (1:1 field map; `attributes`→`dims` where legacy keys expected). Plumbing products keep their exact `LipskeyCatalogProduct` representation (they ARE the seed), so `==` and rendering are unchanged.
- `LipskeyCatalogProduct.connectionSizes` (`lipskey_catalog.dart:110`) and `kVerifiedSpecs` lookups are wrapped by a `ConnectionResolver` that returns the **same answer from the seeded matrix** for plumbing, and from authored `CompatibilityRule`s for new trades.

### 1.5 The plumbing seed — `lib/domain/seeds/plumbing_trade_seed.dart` (generated, not authored)
A build step (`scripts/gen_plumbing_seed.dart`) reads the existing consts (`kCatalogTree`, `kCatalogCats`, `kSmartProducts`, `kVerifiedSpecs`, `kBrands`) and emits the equivalent `Trade('plumbing', …)` document + `CompatibilityRule`s derived from the 891 `VerifiedSpec` mating pairs. **The seed is asserted byte-equivalent to the live consts by a gate test (§9).** This keeps plumbing as "just another trade" *without* re-authoring it by hand.

---

## 2. The Hebrew no-code authoring UX (the "מ-המסך הזה" experience)

Lives in the **manager dashboard** (`manager_dashboard_screen.dart`) under a new gated tab/section **"🏗️ בונה ענפים"**, beside the existing M3 god-mode CRUD. Pure RTL, inline-edit (`R9`, no modal/prompt), `textScaler` clamp 1.35, semantics labels, highContrast — same a11y contract as the manager plan §4.

New files under `lib/screens/trade_builder/`:

1. **`trade_builder_home.dart`** — list of trades (cards with emoji/color/published badge) + "➕ ענף חדש". The 6-step wizard launcher. Reuses the manager KPI-tile/card components.
2. **`trade_define_step.dart`** — Step 1 "הגדרת ענף": name (Hebrew), emoji picker, color, persona dropdown (from `kPersonas`). Writes `Trade` draft.
3. **`category_tree_editor.dart`** — Step 2 "עץ קטגוריות": drag-reorderable RTL tree (add/rename/move/delete `TradeCategory`), inline rename. Generalizes M3 step 32 (`category rename`) to *create whole trees*. Long-press = context menu (the catalog_screen `_SectionChipsRow:710` long-press idiom).
4. **`attribute_schema_editor.dart`** — Step 3 "מאפיינים ווריאנטים": define `AttributeDef`s (kind dropdown, value chips, "ציר וריאנט?" toggle, unit). This is the **authored replacement for `variant_families.dart`'s name-parsing**. Live preview pane shows how a sample product name decomposes (parity with the chip-hierarchy UI).
5. **`product_authoring_screen.dart`** — Step 4 "מוצרים": manual add/edit (generalizes M3 steps 35-36) **+ the bulk-import entry point** (§4). Virtualized list (Pillar 5 owns >10K perf). Each row edits `attributes` against the trade's schema.
6. **`accessory_rule_editor.dart`** — Step 5 "אביזרים נלווים": per-category/per-product `AccessoryRule`s (name/why/must/price/linkSku). Generalizes M3 step 34 (accessory tree).
7. **`connection_rule_studio.dart`** — Step 6 "כללי חיבור" (the no-code rule authoring): define `ConnectorType`s, `SystemDef`s, then a **visual matrix** ("מה מתחבר למה") where the owner taps cells A×B to set `SizeMatch` + method label + severity, and `CompletionRule`s ("מה משלים מה"). A **live test bench** lets the owner drop two products and see "✅ מתחבר / ❌ לא" — the same answer the real install-studio will give.
8. **`trade_publish_sheet.dart`** — validation checklist (every category has ≥1 product? every variant axis has values? no orphan compat rule?) → "פרסם" flips `Trade.published=true`, which (gated) makes the trade appear in the catalog/persona/install-studio.

**Authoring writes go through `tradesEditProvider`** (a `Notifier` over `trades_store.dart`), never to the const files — exactly the M3 "כל כתיבה → provider משותף (server-ready)" rule.

---

## 3. Making the catalog & install-studio trade-agnostic (surgical refactors, all gated)

The strategy is **inject a `tradeId` filter at the existing read seams** and **resolve trade-specific data via the repository** — never fork the screens. With the flag OFF, the seam returns the plumbing seed = today's bytes.

### 3.1 Catalog (`catalog_screen.dart`, 8 011 lines) — seams to thread `tradeId` through
- **`activeTradeProvider`** (new) defaults to `'plumbing'`. When only plumbing is published, the trade-switcher UI is hidden → zero visible change.
- Replace the **direct const reads** with repository calls already routed through `catalogRepositoryProvider` (`catalog_local.dart`): `allProducts()`, `catalogCategories()`, `smartTreeCats()` gain a `tradeId` param; `LocalCatalogRepository` filters the seed by trade (plumbing seed == `kCatalogProducts`, so identical).
  - Direct hits to refactor (from the map): tree iteration `catalog_screen.dart:2669 for (final n in kCatalogTree)` → `repo.categoryTree(tradeId)`; product scans `:367,506,624,804` → `repo.allProducts(tradeId)`; root node `:448` → trade-scoped root.
- **De-hard-code the trade strings** (move to the active trade's authored data, OFF-path returns the same literals):
  - section list `:81 kCatalogSectionsList`, smart-tree emoji map `:3705-3716`, synonyms `:103-113 kSearchSynonyms`, facet spec `:477-483 kProductFacets`, supplier label `:2836 'ליפסקי ברקן'`.
- **Variants section** (`:7264-8011`): swap the `AttrKind`-driven facets for the trade's authored `AttributeDef`s when `tradeId != 'plumbing'`; plumbing keeps the existing `allVariantFamilies()` path (the seed declares the same axes).

### 3.2 Install-studio (`install_studio_screen.dart`, 3 485 lines) — abstract the baked physics
The agent map confirms plumbing is baked in 8 places. Each becomes a **trade-config read** (OFF/plumbing → identical constants):
- **picker categories** `:100-124` → `trade.smartFixtures` / category tree.
- **compliance label map** `:137-183` (anti-scald, Legionella, PEX expansion, galvanic, PRV…) → authored `CompletionRule.whyHe` + severity per trade. Plumbing's are seeded verbatim.
- **temperature pills/thresholds** `:439-447,476-477` → `SystemDef`/`AttributeDef` "envelope" (electric trade would surface "אמפר" not "°C"). Render the trade's envelope axis generically.
- **system colors** `:37-40` (supply blue / drainage amber) → `SystemDef.color`.
- **`canConnect`** `:558` → `ConnectionResolver.canConnect(a,b)` reading `CompatibilityRule`s.
- **kit** `:2438` `recommendedKitFor` → trade-aware kit (plumbing keeps `install_kit.dart`; new trades author kit items as `AccessoryRule`s tagged tool/sealant/safety = `KitKind`).
- **physics params** (2% slope `:2319`, 1-bar ΔP `:2261`) → optional `TradePhysicsConfig` (null for trades without flow physics; the panel hides). Pillar 5 not involved; this is pure config.
- **engine** (`install_engine.dart`): `chainProvider`'s element type stays `LipskeyCatalogProduct` (via the adapter) so the chain/BOM code is untouched; `lineComplianceChecklist :151` delegates to authored `CompletionRule`s for non-plumbing trades, keeps its hand-coded plumbing branch for `'plumbing'`.

**Result:** the install-studio becomes "drop parts → engine evaluates the active trade's authored rules → ✅/❌ + what-completes-what + kit", identical to today for plumbing, and *fully functional for the electrician trade the owner just authored — with no code.*

### 3.3 Brand-switch hard-codes (`related_info.dart` ×8 + `lipskey_catalog.dart:50-51`)
Replace `if (p.brand=='פולירול')` ladders with a **`BrandProfile`** lookup (`Brand` gains `imageDir`, `kitStrategy`, `finderEmoji`). Plumbing brands seed the exact current behavior; a new trade's brand supplies its own profile → no fall-through to the Lipskey default. Guard with `kTradeBuilderFlag`; OFF keeps the literal `if` ladder live (delete only after the seed gate is green).

---

## 4. Bulk import (authoring to tens of thousands)

UX in `product_authoring_screen.dart`; the heavy pipeline (parsing 10Ks rows, dedup at scale, Firestore batch writes, indexed search build) is **Pillar 5** — this pillar owns the **mapping & validation contract**:
1. **Template export** — generate a CSV/XLSX header from the trade's `AttributeDef`s (columns = sku, nameHe, categoryId, brandId, then one column per attribute). Owner fills it (the no-coder's spreadsheet).
2. **Column-mapping UI** — on upload, auto-match headers to `AttributeDef`s; owner confirms/remaps unknown columns (RTL stepper). Reuse the existing extraction scripts' shape (`scripts/extract_lipskey.py` produced today's catalog — the import is the in-app equivalent).
3. **Dry-run validation** — per-row: required attributes present? values in the authored enum (or auto-add)? sku unique? Show a "✅ 9 842 · ⚠️ 137 · ❌ 21" summary with downloadable error rows. **No write until owner confirms.**
4. **Commit** — stages `TradeProduct`s into the draft trade via `tradesEditProvider` (batched). Pillar 5 swaps the persistence to Firestore batches + builds the at-scale index.
5. **Variant auto-grouping** — after import, the engine groups by the authored variant axes (no more name regex) and the owner reviews families before publish.

---

## 5. Connection-planning rule engine — `lib/domain/connection_resolver.dart`

A pure, trade-agnostic engine (testable, no UI), the generalization of `install_engine.dart` + `VerifiedSpec.compatibleWith`:
- `canConnect(TradeProduct a, b, ruleSet)` — for each `(endA,endB)`, find a `CompatibilityRule(aType,bType)`; apply `SizeMatch` (`exactSame`/`anyToAny`/`tableLookup`). Returns method label + severity. **Plumbing seed reproduces all 891 specs' answers** (asserted in `:9`).
- `completion(line, ruleSet)` — evaluates `CompletionRule`s → "the line has a 16A breaker but no RCD" (generalizes hot-water compliance `:151`).
- `systemCoherence(line)` — a line must stay in one `SystemDef` (kept from supply/drainage).
- **Determinism** — pure functions over authored data, so it's unit-testable per trade and snapshot-stable (Pillar 5 owns >1K-part perf; this owns correctness).

---

## 6. Persona / trade go-live wiring

A published `Trade` carries `personaId`. On publish (gated):
- The trade appears as a **catalog trade-switcher** entry (hidden while count==1).
- Its persona surfaces in the BS dial (`kPersonas` model) — *reuse* Pillar 1's visibility config; do not build a new persona system.
- Search synonyms, finder groups, and the nav index gain the trade's authored terms (the const `kSearchIndex`/`kSearchSynonyms` become "seed + authored union"). Product full-text search at 10K scale is **Pillar 5**.

---

## 7. New files & existing seams (consolidated)

**New (`lib/domain/`):** `trade_schema.dart`, `connection_schema.dart`, `trade_product_adapter.dart`, `connection_resolver.dart`, `seeds/plumbing_trade_seed.dart`.
**New (`lib/state/`):** `trades_store.dart`, `trade_builder_flags.dart` (`kTradeBuilderFlag`, `kTradeStudioFlag`, `kTradeImportFlag` — all default OFF via `feature_flags.dart`).
**New (`lib/screens/trade_builder/`):** the 8 authoring files in §2.
**New (`scripts/`):** `gen_plumbing_seed.dart`, import-template generator.
**Refactor (seams, all gated):** `repositories/catalog_local.dart` (+`catalog_repository.dart` interface) add `tradeId`; `catalog_screen.dart` (`:81,103,367,448,477,2669,2836,3705,7264`); `install_studio_screen.dart` (`:37,100,137,439,558,2438,2319`); `install_engine.dart:151`; `related_info.dart` ×8; `lipskey_catalog.dart:50`; `brands.dart` (+`BrandProfile`); `manager_dashboard_screen.dart` (add gated "🏗️ בונה ענפים" entry).

---

## 8. Risks & mitigations

1. **Zero-regression on plumbing (paramount).** *Mitigation:* the seed-equivalence gate (`plumbing_trade_seed` ↔ live consts byte-for-byte), every flag default-OFF, the adapter keeps `LipskeyCatalogProduct` as the screen-facing type. The existing `knowledge_protocol_test.dart` (dark-surface + wired-helper guards) and `catalog_regression_test`/`compat_*`/`install_engine_*` suites must stay green untouched.
2. **Closed-enum → authored-matrix is the hardest leap.** *Mitigation:* keep `EndType`/`WaterSystem` alive *as the plumbing seed's connector types*; the resolver runs authored rules for all trades but is seeded to match the 891 specs. Land §5 behind a flag and prove parity against `compat_50_samples_test`/`full_compliance_audit_test` before touching the studio UI.
3. **Catalog screen is 8 011 lines — refactor blast radius.** *Mitigation:* never fork; only redirect existing const reads to the (already-present) repository seam with a `tradeId` param whose default reproduces today.
4. **Name-parsing variant heuristics vs authored axes drift.** *Mitigation:* `AttributeDef.matchTokens` lets the seed declare the same tokens the regex found, so plumbing variant families are identical; new trades skip parsing entirely.
5. **Owner authors an inconsistent trade (orphan rules, empty categories).** *Mitigation:* publish-time validation checklist (§2.8) blocks go-live; drafts never affect the live app.
6. **Scale (10Ks products / authored index).** *Mitigation:* explicitly delegated to Pillar 5 (Firestore sharding, indexed search, list virtualization). This pillar keeps the model server-shaped (string ids, JSON, repository seam) so Pillar 5 swaps persistence without touching schema.
7. **Hebrew/RTL authoring correctness.** *Mitigation:* reuse manager-plan a11y contract; every new screen gets a widget test asserting RTL directionality + semantics + textScaler clamp.

## 9. Gate / test strategy (100-gate protocol)

Per the project rule: **`flutter analyze` (0 errors) + `flutter test` (incl. `knowledge_protocol_test`) + update `WIRING.md`** on every step, plus:
- **G-seed (the keystone):** `trade_seed_equivalence_test` — assert the generated plumbing seed reproduces `kCatalogProducts`, `kCatalogTree`, `kCatalogCats`, `kSmartProducts`, and every `kVerifiedSpecs` mating answer **byte/semantics-identical**. Red = regression.
- **G-flag-off:** with all `kTrade*` flags OFF, catalog + install-studio render byte-identical (golden/snapshot diff against current) — the manager-plan "כל דגל OFF → המסך זהה" rule.
- **G-resolver:** `connection_resolver_test` runs the 50-sample + full-compliance fixtures through the *new* engine and matches the *old* `kVerifiedSpecs` results.
- **G-roundtrip:** `trades_store` JSON `toJson/fromJson` roundtrip + persistence (mirror `persistence_roundtrip_test`).
- **G-authoring:** widget tests for each of the 8 screens (add trade → tree → attributes → product → accessory → compat rule → publish), RTL + a11y assertions.
- **G-import:** `bulk_import_test` — template→map→dry-run→commit on a synthetic 10K CSV; validates dedup/required/enum, asserts no write on error.
- **G-newtrade (acceptance):** author a minimal "חשמלאי" trade in-test (2 categories, 1 variant axis, 2 products, 1 compat rule), publish, and assert catalog+install-studio function for it — the literal "add an electrician myself" proof.
- **WIRING.md / knowledge sync:** add every new wired helper symbol so `knowledge_protocol_test`'s contract check passes.

## 10. Phasing (100 steps, condensed)

- **Phase A — schema + seam (steps 1-20):** flags; `trade_schema`/`connection_schema`; `trades_store`; repository `tradeId` params (default plumbing); `activeTradeProvider`; G-flag-off green.
- **Phase B — plumbing seed + adapter + zero-regression (21-40):** `gen_plumbing_seed`; `trade_product_adapter`; route catalog reads through repo by trade; **G-seed + G-roundtrip green** (gate to proceed).
- **Phase C — resolver (41-55):** `connection_resolver`; seed compat matrix from 891 specs; **G-resolver parity green**; wire `install_engine`/studio `canConnect` behind flag.
- **Phase D — authoring UX (56-78):** the 8 `trade_builder/` screens + manager entry; `tradesEditProvider`; per-screen a11y tests (G-authoring).
- **Phase E — bulk import (79-88):** template/map/dry-run/commit contract (G-import); hand the at-scale pipeline to Pillar 5.
- **Phase F — install-studio trade-agnostic (89-96):** abstract the 8 baked-physics seams; new-trade studio works (part of G-newtrade).
- **Phase G — publish + go-live + lock (97-100):** publish validation; persona/search wiring; **G-newtrade acceptance**; `analyze` clean + suite green + `WIRING.md` + this doc updated; per-trade rollout default-OFF until owner approval (manager-plan §step 100 idiom).

---

## 🔧 תיקוני Red-Team R1 (מחייב — מחליף סעיפים סותרים)

> מקור: `knowledge/studio-plan/RED-TEAM-R1.md` (9 עדשות, 2026-06-23). הסעיפים כאן **גוברים** על כל ניסוח סותר במסמך הזה ובקובץ הצעדים העמוק (`detail/031-050.md`). כל פריט = **מה משתנה · §-מוחלף · שלב-מושפע**. מספרי-השלבים מתייחסים לתוכנית-האב 100-step (Pillar 2 = 31–50); אותיות-הפאזה (§10) נשארות כקיבוץ-על.

### R1-1 — לא byte-identical · ההוכחה = answer-equivalent מול fixtures (תמה B, ממצא #4)
**מה משתנה:** מוחקים את הטענה "seed ≡ const **byte-identical**" מכל המסמך. `kCatalogProducts` הוא `final` (אין בייטים לבדוק זה-מול-זה משמעותית), ותאימות אינה זוגות-דאטה אלא **לוגיקת-galvanic**. ההוכחה החדשה = **answer-equivalent**: ה-seed מריץ את אותם תרחישים ומחזיר את אותן תשובות כמו הקבועים החיים, מאומת מול ה-fixtures הקיימים — `compat_50_samples_test`, `full_compliance_audit_test`, `catalog_regression_test`. בכל מקום שכתוב "byte-identical" / "byte/semantics-identical" / "byte-equivalent" → **"answer-equivalent מול fixtures קיימים"** (מותר "render-field identity" רק לשדות-תצוגה של מוצר בודד דרך ה-adapter, לא ל-compat).
- **§-מוחלף:** §1.5 (משפט "asserted **byte-equivalent** to the live consts") · §8.1 ("seed-equivalence gate … **byte-for-byte**") · §8.2 ("seeded to match the 891 specs") · §9 G-seed ("**byte/semantics-identical**") · ה-`> Gated … byte-identical fallback` בכותרת-המסמך (משאירים "gated default-OFF", מוחקים "byte-identical").
- **שלב מושפע:** **שלב-38 (KEYSTONE) מנוסח מחדש** — מ-"אסרט seed ≡ קבועים חיים byte/semantics-identical" ל-: *"אסרט seed **answer-equivalent**: `trade_seed_equivalence_test` מזרים את `compat_50_samples`+`full_compliance_audit`+`catalog_regression` דרך נתיב-ה-seed ומאשר תשובה-זהה (mates?/method/severity/compliance-list) + ספירת products/categories/specs (891) + render-field identity למוצר בודד. אדום = רגרסיה."* ה-DoD של 38 מאבד את "אפס diff בקבצי const (git)" כ-**הוכחת-תאימות** (הוא נשאר רק כ-side-check שהקבועים לא נגעו), וה-hard-gate-to-proceed נמדד בירוק-fixtures. נגזרת: שלב-37 תוספת-ב ("galvanic-groups → CompletionRule") ושלב-40 (G-resolver) הם מקורות-האמת ל-answer-equivalence — לא השוואת-בייטים.

### R1-2 — פיזיקת-אינסטלציה נשארת קשיחה לנצח (תמה B, ממצא #5)
**מה משתנה:** פיזיקת-האינסטלציה היא **לוגיקה-מותנית**, לא דאטה שטוחה (if-חם 60°C · dissimilar-metals · recirc · isolation-count). לכן ענף-`'plumbing'` ב-`install_engine.dart` — `lineComplianceChecklist:151` (כולל `_galvanicallyDissimilar:117`, anti-scald/TMTV, Legionella-sampling, dielectric-union, recirc isolation≥3) + `connectionMethodLabel:90` + כל ה-`ConnectorEnd.directMatesWith`/`pipeSharedWith` (`lipskey_verified_connections.dart:49/:61) — **נשאר חי לנצח, כתוב-ביד, verbatim**. ה-resolver המחובר (`CompatibilityRule`/`CompletionRule`) משמש **רק** ל-`tradeId != 'plumbing'`. למחוק את הניסוח "seeded **verbatim**" / "seeded to match" כאילו הפיזיקה הופכת לדאטה: ל-`'plumbing'` שום דבר לא "מוזרע" — הוא פשוט **לא עובר** דרך ה-resolver. רק תחומים-חדשים = `CompatibilityRule`/`CompletionRule` authored.
- **§-מוחלף:** §3.2 bullet "compliance label map … Plumbing's are **seeded verbatim**" → *"ל-`'plumbing'` נשאר ה-`lineComplianceChecklist` הכתוב-ביד; רק תחום-חדש מקבל `CompletionRule.whyHe`+severity authored"* · §3.2 bullet engine ("keeps its hand-coded plumbing branch for `'plumbing'`" — נשאר, אך מתחזק ל-**"לנצח, אינו ניתן-למחיקה"**) · §1.2 משפט "keeping the plumbing rules byte-identical by *seeding the matrix from the existing 891 specs*" → *"שומר את תשובות-האינסטלציה ע"י כך שאינסטלציה **כלל לא עוברת** במטריצה — הענף-הקשיח מחזיר את התשובה; ה-891 specs מזינים רק את ה-fixtures שמולם מאמתים answer-equivalence לתחומים-חדשים"* · §8.2 mitigation ("the resolver runs authored rules for **all** trades but is seeded to match") → *"ה-resolver רץ ל-authored-trades בלבד; אינסטלציה נשארת בענף-הקשיח"*.
- **שלב מושפע:** **שלב-41** — להסיר כל רמז ש-`'plumbing'` "מוזרע" למטריצה; הניסוח: *"branch מאצולה ל-resolver רק כש-`tradeId!='plumbing'` **וגם** `kTradeStudioFlag` ON; `'plumbing'` **לעולם** לא נכנס ל-resolver (תוספת-א של 41 = assertion שזה אכן כך — מתחזק ל-DoD מחייב)."* · **שלב-49** — בענף-הפיזיקה (compliance-labels:137, temp-pills, slope:2319), "אינסטלציה מזריעה את הערכים" מתוקן ל-: *"אינסטלציה ממשיכה לקרוא את הקבועים/הענף הכתוב-ביד; רק ה-config-read של תחום-חדש מחליף אותם"*. ה-`'plumbing'` branch אינו "seed" — הוא הקוד.

### R1-3 — `CompatibilityRule` חסר material/galvanic-family (תמה B, ממצא #4)
**מה משתנה:** המודל `CompatibilityRule` (§1.2) **אינו יכול לבטא HDPE↔PVC** או galvanic-mismatch כי אין בו שדה-material. galvanic הוא דרישה-קריטית של הפיזיקה (`_galvanicallyDissimilar:117` = copper-group{נחושת,פליז} ↔ iron-group{פלדה,נירוסטה}). לכן `CompatibilityRule` (וגם `CompletionRule`) **מקבל שדה material/galvanic-group** כדי שתחום-חדש יוכל לבטא "חומר A אינו תואם חומר B ללא מתאם", ושה-answer-equivalence של אינסטלציה תהיה אפילו *מבטאת* (גם אם בפועל אינסטלציה רצה בענף-הקשיח, ה-fixtures חייבים שדה זה כדי לתאר את התשובה). שדה מוצע: `final String? materialGroupA; final String? materialGroupB;` (או `galvanicGroupId`) ב-`CompatibilityRule`, ו-`final List<String> incompatibleMaterialGroups;`/`requiredInterposerWhyHe` ב-`CompletionRule`; `ProductConnectorSpec.materialId` כבר קיים — מוסיפים `materialGroupId` נגזר.
- **§-מוחלף:** §1.2 בלוק-הקוד של `CompatibilityRule` — הוספת שדה material/galvanic-group (ותיקון המשפט "type A (size s) mates with type B (size s)" כך שיכלול ממד-חומר) · §1.2 משפט-ההצדקה ("plumbing's `bspMale⟺bspFemale`…") — להוסיף דוגמת galvanic ("נחושת↔פלדה דורש dielectric-union → `CompletionRule` עם `incompatibleMaterialGroups`").
- **שלב מושפע:** **שלב-33** (schema של חיבורים) — להוסיף את שדה-החומר ל-`CompatibilityRule`/`CompletionRule` כבר ב-shape, אחרת אינו ניתן-לביטוי; **שלב-37/38** — ה-fixtures של answer-equivalence נשענים על שדה זה לתיאור תשובת-ה-galvanic.

### R1-4 — וריאנטים: snapshot לפני מחיקת ה-regex (תמה B, שכן ל-#6/#4)
**מה משתנה:** לפני שמוחקים את ה-regex של `variant_families.dart` (`_isSizeToken:25`, `kindOf:32`, `allVariantFamilies:77`) ומחליפים ב-`AttributeDef.matchTokens` authored — **חובה snapshot של כל המשפחות שה-regex מייצר כיום** (frame+kind+brand+category+products), ואז **assert שה-`matchTokens` ה-authored משחזר את אותה חלוקה בדיוק** (אותן משפחות, אותם חברים). בלי זה, מעבר ל-authored-axes עלול לאחד/לפצל משפחות בשקט (drift), ולשנות את מקטע ה"וריאנטים" של הקטלוג גם ב-OFF/אינסטלציה.
- **§-מוחלף:** §3.1 bullet "Variants section … plumbing keeps the existing `allVariantFamilies()` path (the seed declares the same axes)" — להוסיף תנאי: *"+ snapshot-test שמאשר שה-`matchTokens` המוזרעים מייצרים חלוקת-משפחות זהה ל-`allVariantFamilies()` הנוכחי"* · §8 risk #4 (name-parsing drift) mitigation — לחזק מ-"lets the seed declare the same tokens" ל-: *"snapshot את כל המשפחות → assert שחזור-זהה לפני מחיקת ה-regex; אינסטלציה שומרת את `allVariantFamilies()` עד שה-snapshot ירוק"*.
- **שלב מושפע:** **שלב-45** (attribute-schema editor — תחליף `variant_families`) — DoD חדש: `variant_families_snapshot_test` חייב לתפוס את החלוקה הנוכחית, וה-authored-axes חייב לעבור אותו לפני שה-regex נמחק; **שלב-38** מקבל את ה-snapshot כחלק מ-answer-equivalence (וריאנטים = חלק מהקטלוג).

### R1-5 — BrandProfile lossy: מיפוי כל ה-if-ladders לפני מחיקה (תמה B, ממצא #4 + §3.3)
**מה משתנה:** מחיקת ה-`if (p.brand=='פולירול'/'חוליות')` ladders מסוכנת — הן נושאות **התנהגות לא-טריוויאלית** שתיעלם אם `BrandProfile` לא ממפה הכל. חובה למפות **כל** ההסתעפויות הבאות ל-`BrandProfile` לפני מחיקה, אחרת רגרסיית-spec ל-Polyroll/Huliot:
1. **spec-envelope temps** — Polyroll `maxTempC:90` (`related_info.dart:500-521`, `lipskey_product_sheet.dart` strip) · Huliot `maxTempC:95` (`related_info.dart:527-537`). → `BrandProfile.specEnvelope` (maxTempC + waterSystem-label + endsSummary + materialLabel + pressure-presence).
2. **bore-parse** — Polyroll: max מטווח-`di קוטר פנימי` ("13.6–14.7"→14.7, `related_info.dart:501-513`) · Huliot: `DN`→double (`:528-529`). → `BrandProfile.boreParse` strategy (diRangeMax | dnDirect).
3. **image-dir** — `lipskey_catalog.dart:49-53 _brandDir` (פולירול→`polyroll`, חוליות→`huliot_smartlock`, else→`lipskey`) + fallback `page_*` תחת `pages/`. → `BrandProfile.imageDir`.
4. **finder emoji/label** — `related_info.dart:53-54` (פולירול→🚰"אספקת מים" · חוליות→🟢"דלוחין SmartLock"). → `BrandProfile.finderEmoji`+`finderLabel`.
5. **kit-count** — `related_info.dart:446-454` (פולירול/חוליות → `recommendedKitForProduct(p).length`) + `install_kit.dart:48,91` + `system_division.dart:25` (פולירול → `{supply}`) + `lipskey_product_sheet.dart:2055-2077` (info/hygiene strips). → `BrandProfile.kitStrategy`+`systemHint`+`specStrips`.
- **§-מוחלף:** §3.3 — להחליף "Plumbing brands seed the exact current behavior" ב-טבלת-המיפוי הזו (5 הקבוצות + file:line), ולחזק "delete only after the seed gate is green" ל-: *"delete only after (a) G-seed/answer-equivalence ירוק **וגם** (b) `brand_profile_parity_test` מאשר שה-`BrandProfile` של 3 המותגים מחזיר תשובה-זהה ל-if-ladder לכל 5 הקבוצות"* · §7 ("`brands.dart` (+`BrandProfile`)") — להרחיב את שדות-ה-`BrandProfile` הנדרשים.
- **שלב מושפע:** **שלב-49** — DoD מחייב: ה-5 קבוצות ממופות ב-`BrandProfile` + `brand_profile_parity_test` ירוק **לפני** מחיקת if-ladders; ה-`G-flag-off` golden מכסה את ה-strips/finder/image-dir.

### R1-6 — שלבים-חסרים: schemaVersion+migrate · archive/tombstone · fan-out cleanup (תמה E, ממצאים #16/#18)
**מה משתנה:** שלושה פערי-שלמות שאינם מכוסים ב-31–50, נוספים כשלבים-אדיטיביים (Phase G/חדש):
1. **`Trade.schemaVersion` + `migrate()` אמיתי** — כיום `schemaVersion` הוא שדה (§1.1) אך ה-migrate הוא 💡-בלבד (שלב-32 תוספת-א, שלב-34 תוספת-ב "no-op v1→v1"). נדרש **`migrate(json, fromVersion)` ממשי** ב-`trades_store.dart` עם מסלול-שדרוג בָּדוּק (לא no-op סמלי), + `migration_test` שמעלה doc-ישן ל-current. (R1 ממצא #18 "trade-schema `migrate()`".)
2. **archive/tombstone לתחום ולמוצר** — מחיקת-תחום/מוצר משאירה יתומים (overrides · rules · search-index · orders/carts). נדרש **מודל tombstone/archive** (`Trade.archivedAt`/`TradeProduct.archivedAt` או רשומת-tombstone נפרדת) שמסתיר מ-live אך שומר ל-audit/migrate.
3. **ניקוי-fan-out + migrate-map ל-id שנמחק** — בעת archive, **fan-out cleanup** על כל ההפניות ל-id: `AccessoryRule.linkSku`/`appliesToProductId`, `CompatibilityRule.aTypeId/bTypeId`, `CompletionRule.*TypeId`, search-index/synonyms (§6), ו-orders/carts; + **migrate-map** (`{deletedId → replacementId|null}`) כדי שהפניה-תלויה תופנה-מחדש או תסומן-יתומה במקום לקרוס.
- **§-מוחלף:** §2.8 (publish validation "no orphan compat rule?") — להרחיב ל-archive-flow (orphan-on-delete, לא רק orphan-on-publish) · §6 (search/finder union) — להוסיף הסרה-מ-union ב-archive · §8 risk #5 — להוסיף orphan-on-delete למיטיגציה · §9 — gate חדש `archive_fanout_test` + `trade_migration_test`.
- **שלב מושפע:** **שלבים חדשים בפאזה G** (אדיטיביים, אחרי 50 או בתוך 97–100 של האב): *Step-Eα* `migrate()` אמיתי + `migration_test` · *Step-Eβ* tombstone/archive model · *Step-Eγ* fan-out cleanup + migrate-map + `archive_fanout_test`. כולם default-OFF/דרך `tradesEditProvider`, אינסטלציה (reserved) אינה ניתנת-ל-archive (שומר keystone).

### R1-7 — מאמץ: השלבים-הענקים מפוצלים ל-sub-commits (תמה B, ממצא #9)
**מה משתנה:** "100 שלבים שווים" = בדיה; שלבי-Pillar-2 הענקים הם 3–25 commits כל-אחד. **מסמנים מפורשות** שהם מפוצלים, וה-"100" הוא **task-taxonomy ולא effort-estimate**:
- **שלב-37** (גזירת seed + `CompatibilityRule`s מ-891 specs) → **מפוצל ל-N sub-commits** (≈4–6): (a) `ConnectorType`/`SystemDef` מ-`EndType`/`WaterSystem` · (b) direct-mate rules · (c) pipe-shared (HDPE) rules · (d) galvanic/material-group + envelope (`maxTempC`/`material`/`pexType`) · (e) `systemOverride` per-SKU · (f) determinism+manifest.
- **שלב-38** (KEYSTONE answer-equivalence) → **מפוצל ל-N sub-commits** (≈3–5): (a) catalog/tree/cats/fixtures equivalence · (b) compat answer-equivalence מול `compat_50_samples`+`full_compliance_audit` · (c) variant-families snapshot (R1-4) · (d) diff-report קריא + hash-baseline · (e) רישום ל-`GATE_REGISTRY.md`.
- **שלב-49** (8 seams + 8 if-ladders ב-install-studio/related_info) → **מפוצל ל-N sub-commits** (≈8–12): seam-per-commit (system-colors · picker · compliance-labels · temp-pills · canConnect · kit · slope/`TradePhysicsConfig`) + `BrandProfile`-per-group (5 הקבוצות של R1-5), כל אחד עם `G-flag-off` golden ירוק לפני המחיקה.
- **§-מוחלף:** §10 (Phasing "100 steps, condensed") — להוסיף הערה: *"'100' = task-taxonomy, לא effort-estimate; שלבים 37/38/49 (ו-29/63/82–84 בעמודים אחרים) הם ענקים → מפוצלים ל-N sub-commits מתועדים; אומדן ריאלי לעמוד זה ~30–45 commits."* · כותרת §10 עצמה מצהירה זאת.
- **שלב מושפע:** **37 · 38 · 49** — כל אחד מקבל כותרת-משנה "מפוצל ל-N sub-commits" + רשימת ה-sub-commits ב-`detail/031-050.md`.

> **סיכום R1 ל-Pillar 2:** (1) byte-identical → **answer-equivalent מול fixtures** (38 מנוסח-מחדש). (2) פיזיקת-אינסטלציה = ענף-קשיח **חי-לנצח**, resolver ל-authored-trades בלבד (41/49). (3) `CompatibilityRule`/`CompletionRule` מקבלים **material/galvanic-group** (33). (4) **snapshot+assert** וריאנטים לפני מחיקת regex (45). (5) **5 קבוצות ה-if-ladders** ממופות ל-`BrandProfile`+parity-test לפני מחיקה (49). (6) **schemaVersion+migrate אמיתי · tombstone/archive · fan-out+migrate-map** כשלבים חדשים בפאזה G. (7) **37/38/49 מפוצלים ל-N sub-commits**; "100"=taxonomy. אינסטלציה (reserved) byte-stable ולא-ניתנת-ל-archive — ה-keystone שמור.
