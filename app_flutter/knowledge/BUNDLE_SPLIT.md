# BUNDLE_SPLIT — code-split & lazy-load strategy (ROADMAP step 88)

Planning artifact only. No code is changed by this document. It surveys the
current `lib/` bundle composition and proposes a concrete, ordered split plan
to shrink the initial JS payload that `flutter build web --release` produces.

## Current bundle composition

Top-10 biggest files under `lib/` by line-count (raw size, not gz/transferred):

| Rank | File                                       | Lines |
|-----:|--------------------------------------------|------:|
| 1    | `lib/screens/catalog_screen.dart`          |  7668 |
| 2    | `lib/data/lipskey_catalog.dart`            |  6822 |
| 3    | `lib/screens/install_studio_screen.dart`   |  3184 |
| 4    | `lib/screens/store_screen.dart`            |  2993 |
| 5    | `lib/screens/lipskey_product_sheet.dart`   |  2890 |
| 6    | `lib/data/smart_tree.dart`                 |  2343 |
| 7    | `lib/screens/lipskey_products_screen.dart` |  1822 |
| 8    | `lib/data/lipskey_verified_connections.dart` |  1727 |
| 9    | `lib/logic/install_engine.dart`            |  1390 |
| 10   | `lib/screens/chats_screen.dart`            |  1436 |

Data points worth highlighting:
- `lipskey_catalog.dart` declares **936 products** (`LipskeyCatalogProduct(` ctor count); `polyroll_catalog.dart` adds **3** more — every one ships in the initial bundle.
- `lipskey_verified_connections.dart` declares **887 `VerifiedSpec(` entries** — all eagerly registered into `kVerifiedSpecs` at app start.
- Inside `catalog_screen.dart`, `_SmartProductSheet` (+ its state class) spans **lines 4325 → 6102** — roughly **1777 lines** of widget code, all loaded for first paint even though the sheet is only shown after a tap.
- `main.dart` imports `home_shell` directly, which transitively pulls every screen in `lib/screens/`. There is no current `deferred as` import in the project.

## Why splitting matters

`flutter build web --release` produces a **single `main.dart.js`** (plus a tiny
bootstrap + canvaskit). Every Dart library reachable from `main.dart` — every
screen, every data table, the install engine, every catalog product literal —
is tree-shaken **into that one file**. The browser must download, parse and
JIT the whole bundle before the first frame can render.

Concretely, three things bloat the initial payload more than they need to:

1. **`_SmartProductSheet`** lives inside `catalog_screen.dart`. The catalog
   screen *is* the landing tab, so the sheet's ~1.8K lines (with all its
   sub-widgets `_ExplodeChips`, `_DiagramFlow`, `_StageCard`, `_AccRow`,
   `_MiniQtyBtn`) ship in the first chunk even though most users will never
   open them on a given visit.
2. **`install_engine.dart` + `install_kit.dart` + `pressure_drop.dart` +
   `price_estimate.dart`** (~2K lines combined) are pulled in by
   `catalog_screen.dart`'s `show buildInstallation` import. They only run when
   the user taps the "בנה לי קו (BOM)" button.
3. **The 936-product catalog literal** is a giant constant array, parsed and
   constructed on app boot. Same for the **887 verified specs map**.

Targeting these three is the highest-leverage move available without
re-architecting the app.

## Recommended split strategy

Ordered cheapest-first. Each step is independently shippable.

### 1. Extract `_SmartProductSheet` to its own file (no behavior change)
Move `_SmartProductSheet`, `_SmartProductSheetState`, `_ExplodeChips(State)`,
`_DiagramFlow(State)`, `_StageCard`, `_AccRow`, `_MiniQtyBtn` and the public
`openSmartProductSheet(...)` entrypoint into a new
`lib/screens/smart_product_sheet.dart`. The sheet is the only consumer of
`buildInstallation` inside `catalog_screen.dart`, so this clears the way for
step 2. Pure refactor — same tree-shake graph, easier to reason about.

### 2. Defer-import the install engine
Once the sheet is its own file, change its engine import to:

```dart
import 'package:buildsmart/logic/install_engine.dart' deferred as eng;
```

and gate every call site behind `await eng.loadLibrary(); eng.buildInstallation(...)`.
The first time the user taps "בנה לי קו (BOM)" they pay a one-time chunk
fetch (~tens of KB); landing on the catalog tab no longer pays for the engine.

### 3. Defer-import the verified-spec map
`lipskey_verified_connections.dart` ships an 887-entry `kVerifiedSpecs` map
that is only consulted by compatibility queries (`compatibleProductsFor`,
`engineeringSpecFor`, `materializeChain`). Wrap it behind an async loader
(`ensureSpecsLoaded()`) and trigger it from the same code path as step 2.

### 4. Code-split the 935-product catalog by category
The catalog is one big `const` list. Split into per-category files
(`lipskey_catalog_drainage.dart`, `lipskey_catalog_supply.dart`,
`lipskey_catalog_fixtures.dart`, etc.) re-exported via a thin facade. With
`deferred as` on the per-category libraries, the home tab only loads what its
chips need; the rest fault in on chip tap.

### 5. Defer secondary screens
`install_studio_screen.dart` (3184 lines), `store_screen.dart` (2993),
`chats_screen.dart` (1436), `notifications_screen.dart` (1080) — all reached
via tab/bottom-nav. Push each behind `deferred as` at the `home_shell` route
table so they fault in on first navigation.

## Quick wins vs. larger refactors

| Step                                     | Effort | Risk | Impact | Type        |
|------------------------------------------|:------:|:----:|:------:|-------------|
| 1. Extract `_SmartProductSheet`          | S      | low  | none*  | quick win   |
| 2. Defer install engine                  | S      | low  | medium | quick win   |
| 3. Defer verified-spec map               | M      | med  | medium | quick win   |
| 5. Defer secondary tab screens           | M      | low  | high   | quick win   |
| 4. Per-category catalog code-split       | L      | med  | high   | refactor    |

\* Step 1 unblocks step 2; on its own it is bundle-neutral but is the
prerequisite for the meaningful payload reduction.

## How to measure

Run `flutter build web --release --analyze-size --target-platform=web` (or the
plain `--analyze-size` flag — Flutter writes a size report to
`build/web/analyze-size.json` plus a human summary on stdout). Open the JSON in
Flutter DevTools' **App Size** tool, or eyeball `build/web/main.dart.js`'s
on-disk size. Key things to look for:

- Total `main.dart.js` size before vs. after each step (gz and raw).
- Per-package contribution of `package:buildsmart/screens/catalog_screen.dart`
  and `package:buildsmart/data/*.dart` — these should drop after steps 1-4.
- New chunk files appearing in `build/web/` (deferred libraries land as
  `main.dart.js_*.part.js`); confirm their existence and approximate sizes.
- Time-to-first-paint in a throttled Lighthouse run (Fast 3G).

A reasonable target: cut initial `main.dart.js` by **25-40%** after steps
1-3+5, with step 4 stretching that further but at higher refactor cost.

## Out-of-scope for this doc

- No code is moved, deleted, or rewritten here.
- No `pubspec.yaml` change.
- No CI/build-pipeline change.
- No measurement run was performed — the numbers above are line-count proxies,
  not byte sizes. Actual byte sizes must come from `--analyze-size` once
  the work begins.
