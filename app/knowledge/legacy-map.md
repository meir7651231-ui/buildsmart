# Legacy → Modern Mapping

Maps significant code blocks in `../index.html` (the legacy prototype)
to their counterparts in `app/`. Every entry cites the legacy line
range and the new file. Add a row when you port something.

> The legacy file is **the spec** (R6). This document is the index.

## Data structures

| Area | Legacy | Modern | Notes |
|---|---|---|---|
| TREES catalog | `index.html:5441-6044` | `src/data/catalog.ts` | 202 products + accessories |
| VARIANTS | `index.html:6060-6182` | `src/data/variants.ts` | 44 size/SKU pickers |
| STORE_PRICING | `index.html:11908-11941` | `src/data/suppliers.ts` | 696 SKU prices × 3 stores |
| SUPPLIER_STORES | `index.html:11942-11946` | `src/data/suppliers.ts` | 3 suppliers (s1/s2/s3) |
| TOOLS | `index.html:6216-6320` | `src/data/tools.ts` | 21 job-type tool bundles |

## State & navigation

| Area | Legacy | Modern | Notes |
|---|---|---|---|
| `appStore` (role/screen) | `index.html:20280` | `src/store/bs-store.ts` | Replaced by `activePersona` signal |
| `toggleRoleDrawer()` | `index.html:18364-18370` | `src/store/bs-store.ts` `toggleBs()` | Dial pattern instead of drawer |
| `enterRole(role)` | `index.html:11806-11820` | `src/store/bs-store.ts` `setPersona()` | Identical role list |
| `showScreen(id)` | `index.html:11635-11640` | `src/app.tsx` ActiveView switch | Routed via persona |
| `loginExisting()` | `index.html:11823-11829` | (not yet ported) | Onboarding TBD |

## Catalog / categories

| Area | Legacy | Modern | Notes |
|---|---|---|---|
| `renderCatalog()` | `index.html:9310-9346` | `src/components/product-grid.tsx` | Grid + per-card render |
| Category drill rendering | `index.html:8901-8974` | `src/components/category-circles.tsx` | Circles + back + current |
| `productPrice(key)` | `index.html:6397-6408` | (TBD) | Needs full pricing wire-up |
| `openTree(key)` | `index.html:9546-9605` | `src/components/product-sheet.tsx` | Light port; smart-tree not yet |

## Search

| Area | Legacy | Modern | Notes |
|---|---|---|---|
| `buildSearchIndex()` | `index.html:8591-8621` | `src/data/search-index.ts` | screens + cats + products |
| `searchSuggestions(q)` | `index.html:8629-8651` | `src/lib/search.ts` `searchExact()` | prefix-first scoring |
| `fuzzySearchSuggest(q)` | `index.html:21095-21114` | `src/lib/search.ts` `searchFuzzy()` | Levenshtein, ≤ floor(len/3)+1 |
| `onHomeSearchInput()` | `index.html:8777-8780` | `src/components/search/search-panel.tsx` input handler | |
| Voice/barcode demo modals | `index.html:21181-21229` | `src/lib/voice.ts`, `src/lib/barcode.ts` | Real Web Speech + BarcodeDetector |

## Regression

| Area | Legacy | Modern | Notes |
|---|---|---|---|
| `runRegressionTests(filter)` | `index.html:15253-15329` | `src/test/runner.ts` `runRegression()` | Inline in Manager, not modal |
| `buildRegressionReport()` | `index.html:15829-16112` | `src/test/runner.ts` + `tests/*.ts` | Per-category test files |
| `regCheckProduct(key)` | `index.html:12320-12508` | `src/test/tests/products.ts` | 5-7 checks adapted to our schema |
| `BUTTON_REGISTRY` | `index.html:12517-12942` | `src/test/registry.ts` | 21 entries (vs 176) — grows |
| `findDuplicates()` | `index.html:12984-13061` | `src/test/tests/dupes.ts` | Same scope |
| Display-sync probes | `index.html:14759-14901` | `src/test/tests/dsync.ts` | Signal invariants |

## Personas (status)

| Persona | Legacy screen | Modern view | Status |
|---|---|---|---|
| contractor | `screen-login` + `view-catalog` | `views/home.tsx` | implemented (catalog + sheet) |
| manager | `screen-manager` `index.html:4207-4238` | `views/manager.tsx` | partial (regression panel only) |
| store | `screen-store-login` + `screen-store` | `views/store.tsx` | stub |
| courier | `screen-courier` `index.html:4291-4308` | `views/courier.tsx` | stub |
| worker | `screen-worker` `index.html:4321-4330` | `views/worker.tsx` | stub |

## Not yet ported

| Area | Legacy | Why later |
|---|---|---|
| Onboarding (login/registration) | `index.html:4042-4145` | Will port after personas are real |
| Smart product tree | `index.html:9546-9605, 10251-10310` | Large feature; needs accessories UI |
| Cart line items | `index.html:7700-8100` | Cart icon exists; cart page missing |
| Courier delivery flow | `index.html:17963-18150` | Stub view only |
| Worker task picker | `index.html:11832-11881` | Stub view only |
| Manager dashboards (orders/customers/manage tabs) | `index.html:4212-4231` | Only regression tab built |
| Store dashboard | `index.html:4254-4288` | Stub view only |
