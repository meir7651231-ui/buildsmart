# data/ — hard-cases (owner-decisions · NOT refactors)

> Surfaced by the read-only data decomposer (`tools/atom/decompose --data`). Each
> entity's fields · relations · decoders · contract are in its `*.data.md`; the
> machine model is in each module's `module.data.json`. **The decomposer documents
> debt — it never changes app code.** These are the structural facts a programmer
> must know and the calls only the owner may make.

The data layer is three tiers that do not fully agree:
1. **spine (live):** `LipskeyCatalogProduct` (const, `data/lipskey_catalog.dart`)
   + company overlay.
2. **physics (live):** `VerifiedSpec` + `ConnectorEnd`/`EndType`
   (`data/lipskey_verified_connections.dart`).
3. **new connector model:** `ConnectorType` + `CompatibilityRule`
   (`domain/connection_schema.dart`), seeded from tier 2 but **not wired to a live
   screen** (zero-regression, dormant).

## HARD-CASE #54 — the homeless price (⚠️ owner decision)
**`price` is NOT a field on the product.** The decomposer finds three disconnected
representations, none canonical:
- **(a)** `price_estimate.estimatePrice` — a category→ILS guess (`_categoryPriceILS`,
  fallback ₪25, `lowConfidence`). *Derived, not stored.*
- **(b)** `SmartBrand.price : int?` — `null` renders "מחיר לפי ספק". *A brand hint.*
- **(c)** `InventoryItem.price : num` — Firestore, **per store**
  (`data/store_inventory.dart`). *The only real, transacted price.*

**Owner decision:** which representation is the source of truth (and whether a/b
should read through c) is a product/architecture call — documented, not resolved.

## HARD-CASE #2 — name → data (the derived getters)
`LipskeyCatalogProduct` stores 16 fields but the decomposer surfaces **~15 DERIVED
fields** — `connectionSizes` · `connectionGender` · `connectionMethod` ·
`imageAsset` … — computed at READ time by regex over `nameHe`. A record's real
shape is bigger than its stored columns; the connection geometry is *inferred from
a Hebrew name string*, not stored. **Owner decision (phase D):** lift these to
declared schema fields so a record carries its geometry, not a parser.

## HARD-CASE #1 — data welded to flow (string-category classifiers)
The flow engines (`productSystems` / `flowRole`, phase L) classify by matching
`categoryHe` **strings** against const sets (`_supplyCats` / `_drainCats` / …).
Those tables are data living inside `logic/`. **Owner decision:** move them to
`connection_schema` / `trade_schema` so classification reads data, not code.

## HARD-CASE #7 — tolerant decoders (no validation layer)
Every `fromJson` in the schema/seed tier is **tolerant**: a missing / wrong field
falls back to a default rather than throwing (the decomposer flags these with
`tolerantDecoder`). So a **corrupt record decodes silently** — there is no
validation seam that rejects a malformed row. **Owner decision:** whether to add a
validation layer (and fail loud on bad data) vs. keep degrading. Documented as
debt, not added.

## HARD-CASE #8 — two parallel connection models
Tier 2 (`VerifiedSpec` — per-SKU physical ends) and tier 3 (`ConnectorType` +
`CompatibilityRule` — a generic type/rule matrix) are **two models of the same
domain**. `buildPlumbingSeed()` unifies them one-way (891 `VerifiedSpec` →
`ConnectorType`+`CompatibilityRule`), and tier 3 is dormant. **Owner decision:**
which model is canonical long-term, and when (if) tier 3 goes live. The decomposer
maps both; it does not merge them.

## Resistant fields (documented, not "fixed")
- `dims : Map<String,dynamic>?` — a free-form bag (#55).
- size strings mix mm / inch / ½¼¾ / × (+ `kBspInchToMm`).
- `EndType.hdpeCompression` is overloaded (HDPE-pressure AND PVC/PP-drainage →
  needs `material` + `systemOverride` to disambiguate).
- `ProductConnectorSpec.envelope : Map<String,num>` — open-keyed.

---
*Guards held: read-only · zero app-code change · debt = documented owner-decisions.
Regenerate: `dart run atom_decompose:decompose --data <file> --out app_flutter/knowledge/data`.*
