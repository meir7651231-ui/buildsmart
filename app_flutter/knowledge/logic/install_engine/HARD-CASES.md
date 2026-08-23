# install_engine — hard-cases (owner-decisions · NOT refactors)

> Surfaced by the read-only logic decomposer (`tools/atom/decompose --logic`).
> The engine's own map is in `module.logic.json`; each function's inside is in its
> `*.logic.md`. **The decomposer documents debt — it never changes app code.**
> These are the structural facts a programmer must know, and the calls only the
> owner may make.

`install_engine.dart` — ~1629 lines · **39 functions** · **3 mutable caches** ·
one imported registry mutated at runtime. It is the god-module of the plumbing
domain (compatibility, least-cost routing, BOM assembly, safety compliance).

## Hidden runtime state — the 3 caches
Top-level mutable collections (state that survives between calls, invisible to a
caller reading a signature):

| cache | decl | written by | note |
|---|---|---|---|
| `_skuCache` | `Map? _skuCache` (lazy) | `_skuOf` | sku→product index, built once |
| `_compatCache` | `final … = {}` | `compatibleWith` | memoised compatibility lists (keyed `sku|tempC`) |
| `_syntheticPipeCache` | `final … = {}` | `_syntheticPipe` | synthetic pipe products by `PIPE-<mat>-<dn>` |

**Owner-decision:** these make the engine's pure-looking predicates
`deterministic-side-effecting`. Extracting them to an injected store is a
refactor of a live engine — not done. Documented as debt.

## HARD-CASE — runtime mutation of the "const" registry
`_syntheticPipe` calls **`kVerifiedSpecs.putIfAbsent(...)`** — it writes a
synthetic `VerifiedSpec` into the IMPORTED, const-looking spec registry at run
time (decomposer: `writes: [state:kVerifiedSpecs, cache:_syntheticPipeCache]`,
purity `side-effecting`). So `kVerifiedSpecs` is not immutable; a pipe lookup can
grow it. **Owner-decision:** whether the registry should be append-only-at-boot
vs. mutated on demand is an architecture call, not a decomposer fix.

## HARD-CASE #1 — data welded to flow (string-category classifiers)
`productSystems` and `flowRole` are **pure** (decomposer confirms: no writes) but
classify products by matching `categoryHe` **strings** against const sets
(`_supplyCats`, `_drainCats`, `_fixtureCats`, `_structuralCats`, `_terminalCats`,
`_fittingCats`, `_accessorySkus`, …). Those tables are **data wearing a logic
coat**. **Owner-decision (phase D):** migrate the category tables to schema
(`connection_schema` / `trade_schema`) so the classifier reads data, not
hard-coded Hebrew strings. Marked, not moved.

## HARD-CASE #2 — order-sensitive in-place safety injection
`_autoAddCompliance` is `side-effecting` and mutates its arguments in place
(decomposer: `writes: [mutation:items.insert, mutation:accessories.add,
cache:_skuCache]`). It injects PRV / expansion-vessel / TMTV / dielectric unions
into the passed `items` list at computed indices — **the injection ORDER is the
behaviour**, not an implementation detail. **Owner-decision:** the safety output
is a **reference-value + caveat (M5)** — never a binding requirement; any change
to the ordering or the thresholds is a domain-safety decision.

## HARD-CASE #3 — the gated delegation seam (s41)
`connectionMethodLabel` / `lineComplianceChecklist` carry a branch gated by
`tradeId != 'plumbing'` that delegates to `ConnectionResolver`, wrapped in a
`try/on Object` **kill-switch** ("plumbing never delegates"). It is a *conditional*
connection between two engines, not one node. **Owner-decision:** the trade-
agnostic resolver (`domain/connection_resolver.dart`, dormant) is the intended
home for the string-category physics (HC #1); wiring it live is an owner call.

---
*Guards held: read-only · zero app-code change · safety = reference-value + caveat
(M5) · byte-identical/dormant untouched. Regenerate: `dart run atom_decompose:decompose
--logic app_flutter/lib/logic/install_engine.dart --out app_flutter/knowledge/logic`.*
