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
