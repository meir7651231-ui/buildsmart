# SCHEMA — BuildSmart data model (Roadmap step 4)

One canonical map of the app's data layer, replacing the duplication between the
catalog card and the SmartProduct card. Three pillars (Catalog, VerifiedSpec,
SmartTree) joined by a thin SKU-keyed bridge, plus the card-side state models
that *reference* catalog products without ever copying their fields.

Keep this file in lockstep with the code; it is read by every new sub-agent.

## 1. Catalog products — `kCatalogProducts`

Location: `lib/data/lipskey_catalog.dart` (class + `kLipskeyCatalog`) and
`lib/data/polyroll_catalog.dart` (`kPolyrollCatalog` + the unified list).

```
final List<LipskeyCatalogProduct> kCatalogProducts =
    [...kLipskeyCatalog, ...kPolyrollCatalog];
```

`kCatalogProducts` is the single source of truth for "what products exist".
The Polyroll branch (PPR) reuses the same `LipskeyCatalogProduct` class — the
`brand` field discriminates ("ליפסקי" vs "פולירול"), driving the asset path.

### `LipskeyCatalogProduct` fields
| field | type | meaning |
|---|---|---|
| `sku` | `String` | מק"ט ספק — the global key. Unique across the unified list. |
| `nameHe` / `nameEn` | `String` | display name (Hebrew is canonical). |
| `brand` | `String` | `'ליפסקי'` (default) or `'פולירול'`; selects `assets/<dir>/`. |
| `categoryHe` / `categoryEn` / `categoryEmoji` | `String` | catalog category — the connector-coverage gate keys off `categoryHe`. |
| `page` | `int` | source PDF page; default asset is `assets/<dir>/pages/page_NN.jpg`. |
| `dims` | `Map<String, dynamic>?` | raw dimensions (e.g. `{'DN':'75','L (cm)':'300'}`). Fallback DN source. |
| `imageFile` / `specImageFile` / `specImageFiles` | `String?` / `List<String>?` | product photo + cropped spec diagrams (pager). |
| `qtyPack` / `qtyPallet` / `color` | optional | packaging metadata. |
| `productType` (getter) | `String?` | derived from `nameHe` via `kLipskeyTypes` (e.g. "צינור", "מצמד", "ברז"). Used by `_isPipeProduct` + the type tree. |
| `connectionSizes` (getter) | `List<String>` | DN ends, in order: override → name parse → `dims['DN']` → category default. |
| `connectionGender` / `connectionMethod` (getters) | `String?` | name-parsed זכר/נקבה and תבריג/הדבקה/אלקטרו. |

### Lookup
A unified SKU→product index is memoised once in `related_info.dart`
(`_skuIndex`) and reused everywhere — `catalogProductForSku('217861')` is O(1)
and works for both Lipskey and Polyroll SKUs.

## 2. Verified specs — `kVerifiedSpecs`

Location: `lib/data/lipskey_verified_connections.dart`.

```
final Map<String, VerifiedSpec> kVerifiedSpecs = { '<sku>': VerifiedSpec(...), ... };
```

Verified specs describe the *physical* end-connectors and material of a
product — the only data the compat engine trusts. Coverage is gated by
`compat_coverage_test`: every catalog product where `needsConnectionSpec(p)` is
true must have a spec. Synthetic specs (HW-*, PIPE-*) are inserted at runtime
via `putIfAbsent` and never appear in the carousel (which filters on
`kCatalogProducts`).

### `VerifiedSpec` fields
- `sku: String` — must match a `LipskeyCatalogProduct.sku` (or a synthetic key).
- `ends: List<ConnectorEnd>` — the physical ports (1..N).
- `material: String` — `'HDPE'`, `'PEX'`, `'נחושת'`, `'פליז'`, `'PVC'`, `'PP'`, `'רב-שכבתי'`, `'ceramic'`, `'rubber'`, `'פלדה'`, `'נירוסטה'`.
- `pressureRating: String?` — e.g. `'PN16'`, `'PN10'`.
- `pexType: String?` — `'PEX-B · Crimp'` etc. (PEX products only).
- `maxTempC: double` — continuous service ceiling; default `40` (the HDPE cap).
- `systemOverride: WaterSystem?` — override when the end-geometry disagrees with the plumbing role (e.g. a bottle-trap whose 1¼" threads read "supply" but belong to drainage).
- `compatibleWith(other)`, `suitableForTemp(t)`, `endSystems` getter — derived helpers.

### Enums
- `EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }` — `hdpeCompression` is **overloaded**: it represents any push-fit/socket compression across HDPE / PEX / PVC / PP / רב-שכבתי / ceramic / rubber. Material resolution happens at the spec level (`_materialsCompatible`).
- `WaterSystem { supply, drainage }` — pressure water supply vs gravity drainage. The two systems only meet *inside* a fixture; a built line must stay within one system (see PLAYBOOK §D).
- `ConnectorEnd(type, size)` — `size` is a string ("75", "32", `'1/2"'`). Methods: `directMatesWith`, `pipeSharedWith`, `system` getter.

## 3. SmartTree — `kSmartProducts`

Location: `lib/data/smart_tree.dart`.

```
const List<SmartProduct> kSmartProducts = [ ... ];
```

This is the curated "smart card" tree — ~81 products presented as one card each
in the SmartProduct sheet. Unlike the flat catalog, a SmartProduct is a
*concept* ("ברז לכיור", "סיפון לכיור רחצה") with a chosen brand and curated
accessories + install stages.

### `SmartProduct`
- `key: String` — stable id for state (`cardSelectionProvider`, `stageProgressProvider`, ...).
- `name`, `emoji`, `cat: String` — display + the category bucket.
- `brands: List<SmartBrand>` — alternative SKUs presented as cards.
- `acc: List<SmartAcc>` — recommended accessories (each may have its own SKU + must-flag).
- `stages: List<SmartStage>` — install diagram steps with `match[]` for cross-highlighting accessories.
- `diagramTitle: String`.
- Derived: `mustCount` (count of `acc.where((a) => a.must)`), `recBrand` (`brands.firstWhere((b) => b.rec, orElse: () => brands.first)`).

### `SmartBrand` — **this is where the SKU lives, NOT on SmartProduct**
- `name: String` — display label of the brand option.
- `tag: String` — short tag ("מומלץ", "גרסה חלופית", "מחיר לפי ספק").
- `price: int?` — `null` = "מחיר לפי ספק".
- `rec: bool` — true exactly for the recommended option (typically one per product).
- `sku: String?` — supplier SKU; the *only* link into `kCatalogProducts`. May be null for placeholder/legacy brands.
- `imageAsset: String?`.

### `SmartAcc`
- `name`, `emoji`, `why: String`, `must: bool`, optional `price`, optional `sku`.

### `SmartStage`
- `emoji`, `label`, `sub`, `isFinal`, `match: List<String>` — substrings matched against `SmartAcc.name` to highlight relevant accessories at that stage.

## 4. The bridge — SKU is the only foreign key

Location: `lib/data/related_info.dart` (forward) + `lib/data/smart_tree.dart` (reverse).

```
LipskeyCatalogProduct? catalogProductForSku(String? sku);
LipskeyCatalogProduct? catalogProductForBrand(SmartBrand brand);
LipskeyCatalogProduct? catalogProductForSmart(SmartProduct sp); // uses sp.recBrand
SmartProduct?           smartProductForSku(String sku);          // reverse
```

- **Forward direction (catalog ← smart):** the SmartProduct card calls
  `catalogProductForBrand(brand)` once per render to fetch the catalog row for
  the *currently selected* brand. From that row it pulls `VerifiedSpec` (via
  `kVerifiedSpecs[prod.sku]`), the compat count, the price, the standards tags,
  etc. — see `engineeringSpecFor`, `compatibleProductsFor`, `priceFor`,
  `israeliStandardsFor`.
- **Reverse direction (smart ← catalog):** `smartProductForSku` lets the
  catalog card open the SmartProduct sheet for a product that has a smart
  counterpart. Built lazily once in `smart_tree.dart` (`_smartBySku`).
- **Round-trip guard:** `smartproduct_contract_test` asserts every
  `SmartBrand.sku` exists in `kCatalogProducts`, every SmartProduct has a
  resolvable recommended brand, and `smartProductForSku(catalogProductForSmart(sp).sku) == sp` where applicable.

## 5. Card-side state models — referenced by SKU, never copied

### `ProjectItem` — `lib/state/card_projects.dart`
Persisted under `bs.card-projects.v1`. Fields: `project`, `location`,
`productKey` (= `SmartProduct.key`), `brandName`, `sku`, `qty`. Its `id` is
`'$project|$location|$productKey|$brandName'`; `projectItemsAfterAdd` merges
qty for matching ids. The pure quote builder `projectQuoteText(project, items)`
re-resolves each `sku` via `catalogProductForSku` to pull a fresh `priceFor`,
so it always reflects the current catalog.

### `SmartCartLine` + `SmartCartAcc` — `lib/state/smart_cart.dart`
Persisted under `bs.smart-cart.v1`. A line stores `productKey`, `productName`,
`productEmoji`, `brandName`, `brandPrice`, `productQty`, `accessories: List<SmartCartAcc>`.
Each `SmartCartAcc` is `{name, emoji, price, qty}`. Total = `brandPrice *
productQty + Σ(acc.price * acc.qty)`. Notice the cart line does **not** store
the SKU directly; the SKU is reachable via `brandName` → the SmartProduct's
`brands` list — but practical lookups go from the picker (which already has the
SmartBrand) and from there to `catalogProductForBrand`.

## 6. Data-flow — how a SmartProduct card pulls spec/price/compat

```
                 ┌──────────────────────────────────────────┐
                 │   SmartProduct sheet (catalog_screen)    │
                 │   user selects: SmartBrand b             │
                 └───────────────┬──────────────────────────┘
                                 │ catalogProductForBrand(b)
                                 ▼
                 ┌──────────────────────────────────────────┐
                 │  _skuIndex[b.sku] in related_info.dart    │
                 │      built once from kCatalogProducts     │
                 └───────────────┬──────────────────────────┘
                                 │ LipskeyCatalogProduct prod
            ┌────────────────────┼─────────────────────────────┐
            ▼                    ▼                             ▼
  kVerifiedSpecs[prod.sku]   priceFor(prod)         compatibleProductsFor(prod)
  → VerifiedSpec             → int? (₪)             → List<LipskeyCatalogProduct>
  • material/PN/maxTempC      shown in 📦 header     • iterates kCatalogProducts
  • ends → endSystems         + cheaper-alt chip      • filters by _reallyMates
  • engineeringSpecFor                                  using both specs' ends
            │                                              │
            ▼                                              ▼
    standards / compliance / safety-kit             "🔗 מתחבר ל-N מוצרים"
    (israeliStandardsFor, complianceTriggersFor,    + connectionExplainHe
    safetyKitItems)                                  labels
```

Reverse path (catalog leaf → smart sheet): `smartProductForSku(p.sku)` returns
the curated card, and the catalog leaf adds a "פתח כרטיס חכם" entry point when
non-null.

## 7. Invariants enforced by tests

- `compat_coverage_test`: every catalog product with `needsConnectionSpec(p)` has a `VerifiedSpec`.
- `smartproduct_contract_test`: every `SmartBrand.sku` is a real catalog SKU; every SmartProduct has a resolvable rec brand.
- `regression_gate_test`: every curated helper in `related_info.dart` is referenced by at least one test.

Add a SmartProduct → add the SKU to a brand → contract test stays green. Add a
catalog product → if it's a connector, register a `VerifiedSpec` in
`kVerifiedSpecs` → coverage stays green. No other coupling between the three
collections.
