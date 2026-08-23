# DECOMP-DEPTH — the capstone coverage board (step 99-100)

> The problem (owner): the app graph named engines / data / primitives / journeys
> **by name** — "calls the connection engine" — without opening what they *do
> inside*. A programmer saw a call site, not the mechanism. **Real decomposition =
> seeing the inside.**
>
> The result: five read-only decomposer modes, each reproducing a manual golden
> 1:1 before any wide run, each surfacing its debts as **owner-decisions** (never
> refactored). A new programmer can now open **any** atom and see the inside —
> algorithm · contract · data · journey.

## Coverage

| phase | layer | what was opened | scale |
|---|---|---|---|
| **L + S** | logic | engines + decision helpers, each `object · connections · algorithm · contract · floor` | **50 modules · 420 atoms** |
| **D** | data | catalogs / schemas / seeds, field-by-field (type · required · default · **derived**) | **62 modules · 159 entities** |
| **P** | primitives | the floor turned into contracts (signature · returns · **edge** · purity) | **22 primitives · 6 modules** |
| **N** | journeys | the Navigator-1.0 graph, recovered from the pushes (node · edge · bypass) | **905 nodes · 200 edges** |
| **async** | loading | the state machine + the local/remote split | **310 providers (10 async) · 4 typed exceptions** |
| **B** | backend | Cloud Functions, function-tier (trigger · reads/writes · calls · HttpsError) | **20 functions** |

*(Phase **W** — the Preact `app/` TS decomposer — was **skipped by owner
decision**: the legacy is unfolded and the parity audit already covered "what's
in the old one". Not a gap.)*

## The client/server loop closes

The server's typed throws mirror the client's typed exceptions:
`advanceOrderStage → HttpsError("failed-precondition")` **≙**
`OrderFunctionsException("failed-precondition")`. See `knowledge/backend` +
`knowledge/async`.

## The debts — documented as OWNER-DECISIONS, never refactored

| # | debt | where |
|---|---|---|
| #1 | string classifiers that belong in schema | `data/HARD-CASES.md` |
| #2 | name→data (geometry regexed out of `nameHe` at read) | `data/HARD-CASES.md` |
| #6 | the invariant lives in a setter (`SmartCartNotifier.add`) | `logic/install_engine/HARD-CASES.md` |
| #7 | tolerant decoders (malformed input degrades silently) | `data/HARD-CASES.md` |
| #8 | dual model (VerifiedSpec tier-2 vs ConnectorType tier-3) | `data/HARD-CASES.md` |
| #54 | the homeless price (3 disconnected representations) | `data/HARD-CASES.md` |
| — | toast is impure + lives in `widgets/` not `state/` | `primitives/README.md` |
| — | Navigator bypass seams + dead IntelRouteObserver + route-less screens | `journeys/README.md` |
| — | the local sync layer has no error path (cannot fail) | `async/README.md` |

## The guards (held on every slice)

- 🛡️ **read-only** — the decomposer is a reader; **zero app/server-code change**,
  verified by `git diff` each slice.
- **document, don't fix** — god-modules, hidden caches, tolerant decoders, the
  homeless price, data welded to flow → **owner-decisions**, never refactored.
- **golden-first** — each mode reproduces its manual golden 1:1 before any wide
  run. **95 tool goldens**, Atom Tools blocking gate green.

## The tool

`tools/atom/decompose` — one CLI, six modes: `--logic` · `--data` ·
`--primitives` · `--journeys[-batch]` · `--async[-batch]` · `--backend[-batch]`.
Re-run any of them to regenerate the knowledge under `app_flutter/knowledge/`.

## Round 2 — the parallel session's build, decomposed

The catalog-config + internal-card + fittings-grid work (55 commits) was opened
by the SAME six modes, no tool change needed — proof the decomposer generalizes:

| layer | opened | scale |
|---|---|---|
| logic | fittings connection-geometry (`directedPortsOf`, `portsFace`, grid topology) + catalog-config browse engine (`browse_model` 20 atoms) | **8 engines · 59 atoms** |
| data | `VariantFamily` · `GridCell` · `ProductConfigSchema` · `related_info` | **4 modules · 5 entities** |
| primitives | `snapOdToDn` (od → DN scale) · `imageBrightness` · `canonicalDn` | **2 modules · 7 primitives** |
| journeys | the new feature screens — 148 nodes, only 5 edges: they are **home-embedded** (flag + provider-swap), not Navigator routes | `knowledge/journeys-features/` |

Two findings surfaced and were **documented, not fixed**: (1) the new features
live inside the home shell via flags/provider-swaps, invisible to a route tool;
(2) `smart_home_screen` grew 10→14 atoms (catalog-config + internal-card each an
Open/Hero live+preview pair) — the golden was regenerated to track it. A real
tool bug was fixed in passing: a `lastIndexOf(...) < 0` guard no longer
mis-reads as a currency sign (primitive edge detector).

## Round 3 — the whole `state/` + engine tail, completed

Phase S opened only the 10 decision-helpers and left the rest of `state/` as a
documented residual. Round 3 closes that residual: **every** logic-bearing module
in `lib/` was swept — the full `state/` tier (auth/login, registration, customers,
orders, push, personas, projects, rewards, notifications, …), the
`features/card_keyboard` finder engine, the `features/fittings` geometry/render
engines, and the `features/ring_dive` catalog engines.

**~150 new modules · ~1,370 new atoms** → the logic layer is now
**206 modules · 1,852 atoms**. Named anchors the owner asked for: `auth_state`
(41 atoms, the login engine), `user_profile` (11, the registration heart),
`customers_store` (12).

**The remaining "gaps" are not gaps:** the `data/repositories/*` abstract
interfaces have no body to open (0 atoms — their concrete `*_firebase` impls are
decomposed), and files like `ring_dive_qty` / `route_preview` are Widgets /
CustomPainters (UI, they belong to the screens/journeys layer, not logic). After
Round 3 **no logic-bearing module in `lib/` is left name-only.**
