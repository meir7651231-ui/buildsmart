# HELPER_INDEX — `lib/data/related_info.dart`

## Intro

`related_info.dart` is the data-layer hub for the SmartProduct card: every
"what does this product mean for the customer" question the card asks, this
file answers. It exposes roughly 45 public top-level helpers — bridges from
SmartProduct/SmartBrand into the Lipskey catalog, compat & connection logic,
engineering spec snapshots, install kits, price/share text, compliance copy,
and variant/brand guides. Each helper is a pure function over the catalog +
verified-spec tables; no widgets, no state.

This document is the alphabetical index. For the curated regression list, see
`regression_gate_test._kRequiredHelpers` in `test/regression_gate_test.dart`.

## Alphabetical table

| Name | Returns | Roadmap step | Used in tests |
|---|---|---|---|
| `acceptanceChecklistFor` | `List<String>` | 38 | Y |
| `adapterSuggestionFor` | `LipskeyCatalogProduct?` | 27 | Y |
| `brandDecisionGuide` | `List<({String brand, String advice})>` | 16 | Y |
| `brandSuitableForHot` | `bool` | 65 | Y |
| `cardReadinessScore` | `({int score, String label})` | 30 | Y |
| `catalogProductForBrand` | `LipskeyCatalogProduct?` | 3 | Y |
| `catalogProductForSku` | `LipskeyCatalogProduct?` | 3 | Y |
| `catalogProductForSmart` | `LipskeyCatalogProduct?` | 3 | Y |
| `chainArrowText` | `String` | 23 | Y |
| `chainEdgeLabelHe` | `String` | — | Y |
| `cheaperAlternativeBrand` | `({String name, int price})?` | 45 | Y |
| `compatibleProductsCount` | `int` | — | Y |
| `compatibleProductsFor` | `List<LipskeyCatalogProduct>` | — | Y |
| `complianceTriggersFor` | `List<({String label, String reason})>` | — | Y |
| `complianceWhyHe` | `String?` | 58 | Y |
| `connectionExplainHe` | `String` | — | Y |
| `connectionJoint` | `({EndType type, String size})?` | — | Y |
| `connectionNeedsHe` | `List<String>` | 73 | Y |
| `connectionWarningHe` | `String?` | 29 | Y |
| `deepLinkFor` | `String` | 68 | Y |
| `discoveryTagsFor` | `List<String>` | 67 | Y |
| `durabilityRatingFor` | `({int stars, String reason})?` | 15 | Y |
| `engineeringSpecFor` | `({String material, …})?` | — | Y |
| `finderGroupFor` | `({String emoji, String label})?` | — | Y |
| `frequentlyPairedTypesFor` | `List<String>` | 56 | Y |
| `gapAdviceHe` | `String` | — | Y |
| `hotWaterSuitabilityFor` | `({int suitable, int total, int tempC})` | 26 | Y |
| `installEffortFor` | `({int minutes, String difficulty})?` | 34 | Y |
| `installKitFor` | `({int must, int optional, int tools})?` | — | Y |
| `installTipsFor` | `List<String>` | 35 | Y |
| `installToolsFor` | `List<String>` | 33 | Y |
| `israeliStandardsFor` | `List<({String code, String scope})>` | 12 | Y |
| `jointLabelHe` | `String` | — | Y |
| `lineCostEstimateFor` | `({int product, int accessories, int labour, int total})?` | 42 | Y |
| `lineFitFor` | `({int connects, List<String> names})` | 28 | Y |
| `lineStructureText` | `String` | — | Y |
| `manufacturerInfoFor` | `({String manufacturer, String partNumber})?` | 20 | Y |
| `needsConnectionSpec` | `bool` | — | Y |
| `priceFor` | `int?` | — | Y |
| `quoteTextFor` | `String` | 48 | Y |
| `safetyKitItems` | `List<LipskeyCatalogProduct>` | 25 | Y |
| `smartCardSummaryHe` | `String` | 59 | Y |
| `systemSafetyNoteHe` | `String?` | 24 | Y |
| `variantSiblingsCountFor` | `int` | — | Y |
| `variantSiblingsOf` | `List<LipskeyCatalogProduct>` | — | Y |

## Groups

### Catalog bridge (SmartProduct ↔ Lipskey catalog, Roadmap 3)
- `catalogProductForSku` — SKU lookup, the primary key into the catalog.
- `catalogProductForBrand` — SmartBrand → catalog row (resolves via SKU).
- `catalogProductForSmart` — SmartProduct → catalog row (uses default brand).
- `finderGroupFor` — emoji + label for finder-screen grouping.

### Compat & connection
- `compatibleProductsFor` / `compatibleProductsCount` — which catalog products
  physically mate with `p` (uses `_reallyMates` internally).
- `connectionJoint`, `jointLabelHe`, `chainEdgeLabelHe`, `connectionExplainHe`
  — describe the joint between two catalog products in Hebrew.
- `connectionNeedsHe`, `connectionWarningHe` — material dependencies and
  physical-fit warnings (Roadmap 73, 29).
- `lineFitFor`, `adapterSuggestionFor`, `chainArrowText`, `lineStructureText`,
  `gapAdviceHe` — line builder: count what fits, suggest adapters, render the
  arrow chain and human gap advice.
- `needsConnectionSpec` — gate flag for pipe-like products that need joint UI.

### Spec, scoring, discovery
- `engineeringSpecFor` — one-shot record bundling material, pressure, temp,
  water-system, ends, and bore from `kVerifiedSpecs`.
- `cardReadinessScore` (step 30), `durabilityRatingFor` (step 15) — heuristic
  quality/readiness scores rendered on the card.
- `discoveryTagsFor` (step 67), `frequentlyPairedTypesFor` (step 56) —
  cross-sell hints.
- `israeliStandardsFor` (step 12), `manufacturerInfoFor` (step 20),
  `systemSafetyNoteHe` (step 24) — provenance and safety copy.
- `hotWaterSuitabilityFor` (step 26), `brandSuitableForHot` (step 65) —
  temperature gating per brand.

### Install / kit
- `installKitFor` — `(must, optional, tools)` triplet for the install kit.
- `installToolsFor` (step 33), `installTipsFor` (step 35),
  `installEffortFor` (step 34) — tools list, common mistakes, minutes +
  difficulty rating.
- `acceptanceChecklistFor` (step 38) — Hebrew checklist for site acceptance.
- `safetyKitItems` (step 25) — auto-included safety SKUs for the line.

### Price / share
- `priceFor` — int₪ from `kVerifiedSpecs`, fallback aware.
- `lineCostEstimateFor` (step 42) — product+accessories+labour+total breakdown.
- `cheaperAlternativeBrand` (step 45) — sibling brand that is strictly cheaper.
- `quoteTextFor` (step 48), `smartCardSummaryHe` (step 59),
  `deepLinkFor` (step 68) — shareable Hebrew quote, one-line summary, and
  deep-link URL.

### Compliance
- `complianceTriggersFor` — list of `(label, reason)` flags the card should
  surface (hot water, potable, etc.).
- `complianceWhyHe` (step 58) — long-form Hebrew explanation per label.

### Variants & brand guide
- `variantSiblingsOf` / `variantSiblingsCountFor` — same-family SKUs that
  differ by size/end-type only.
- `brandDecisionGuide` (step 16) — `(brand, advice)` pairs explaining
  "when would you choose this brand."

## Cross-reference: `regression_gate_test._kRequiredHelpers`

The regression gate enforces presence (by name-grep against `test/`) of these
helpers from the index above:

`compatibleProductsFor`, `compatibleProductsCount`, `connectionExplainHe`,
`connectionJoint`, `jointLabelHe`, `chainEdgeLabelHe`, `connectionNeedsHe`,
`connectionWarningHe`, `lineFitFor`, `adapterSuggestionFor`, `safetyKitItems`,
`chainArrowText`, `engineeringSpecFor`, `cardReadinessScore`,
`durabilityRatingFor`, `discoveryTagsFor`, `frequentlyPairedTypesFor`,
`manufacturerInfoFor`, `finderGroupFor`, `israeliStandardsFor`,
`systemSafetyNoteHe`, `hotWaterSuitabilityFor`, `brandSuitableForHot`,
`installToolsFor`, `installTipsFor`, `installEffortFor`, `installKitFor`,
`acceptanceChecklistFor`, `priceFor`, `lineCostEstimateFor`,
`cheaperAlternativeBrand`, `quoteTextFor`, `deepLinkFor`, `smartCardSummaryHe`,
`complianceTriggersFor`, `complianceWhyHe`, `variantSiblingsOf`,
`variantSiblingsCountFor`, `brandDecisionGuide`, `catalogProductForBrand`,
`catalogProductForSku`, `catalogProductForSmart`.

Helpers in this file that the gate does **not** currently enforce:
`needsConnectionSpec`, `lineStructureText`, `gapAdviceHe`. Three more
(`smartProductForSku`, `projectQuoteText`, `projectTemplates`) live in
sibling files and are gated there.
