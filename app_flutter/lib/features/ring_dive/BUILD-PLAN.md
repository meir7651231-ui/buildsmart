# RingDive (צלילת-טבעות / Pro-X-Light) — build plan

A rotary product-finder: ONE wheel, phase-driven (root → find → qty → done),
9 search styles, clean one-axis-per-turn drill over the REAL catalog. Owner
design handoff "RingDive-Pro-X-Light" (6/7). Replaces the smart keyboard's
product-finding presentation; **zero engine change** (RingDive reads its own
derivation layer + the existing finder helpers).

## Non-negotiables
- Flag-gated `kRingDiveFlag`, OFF = byte-identical. **Push ONLY on "תדחוף".**
- analyze-0-new · tests green · local commits · plain-word messages (no backticks).

## Owner-locked (6/7)
- **No price** (the catalog has none) — omit everywhere.
- **Skip an axis with no data** — findAxes only offers axes with ≥2 options.
- **compat "what connects"** = the REAL verified-connections engine (kVerifiedSpecs).
- **jobs/kits** = the REAL smart_tree recipes (kSmartProducts).

## The design (RingDive-Pro-X-Light.dc.html) — ONE wheel, phase() drives the view
- **root** — the 9 search styles (dept·cat·type·size·angle·color·material·brand + job).
- **find** — the active axis's options; an axis-switcher chip strip jumps between
  the remaining axes (findAxes ≥2); once ≤1 product remains → product leaves.
- **qty** — two concentric number rings (tens 00–90 outer, units 0–9 inner) → 0–99.
- **done** — scan spinner → success → complete-kit / what-connects / new-search.
compat mode = "what connects to this product"; job mode = fill kit slots.

## The 8-axis derivation (ring_dive_catalog.dart) — RD-A DONE
Each real product → {dept, cat, type, size, angle, color, material, brand}:
- dept ← kDeptCatHeadings reverse (category→department)
- cat  ← catalog-tree top-category title · type ← catalog-tree leaf (== categoryHe)
- size ← productSizeTokens(p).label (multi-valued) · angle ← parseAngleTokens(name)
- material ← materialOf(p) (partial) · color/brand ← direct
Missing → omitted. `rdMatching` = predicate membership (product CARRIES the value),
so multi-valued size works + reuses the engine's canonical tokens.

## Phase ladder
- **RD-A done (this commit)** — ring_dive_catalog.dart: the derivation layer +
  rdMatching / rdOptsFor / rdFindAxes. VERIFIED over 1948 products: clean axes
  (מחלקה=2 · קטגוריה=10 · סוג=98 · גודל=150 · זווית=8 · צבע=21 · חומר=6 · מותג=4;
  sample trap → אינסטלציה / ניקוז וצנרת / מחסומים גלויים / 1¼" / לבן / ליפסקי).
- **RD-B next** — phase/state model: rework ring_dive_screen to mode/path/
  axisField + phase(); wheel shows root-styles / axis-options / product-leaves.
- **RD-C** — the 9 root styles + the axis-switcher chip strip.
- **RD-D** — qty dual number-ring (tens/units 0–99).
- **RD-E** — compat (real kVerifiedSpecs) + job (real kSmartProducts) modes.
- **RD-F** — done phase + follow-ups; results rail; product + cart sheets.
- **RD-G** — visual polish to the design tokens (RINGDIVE·OS wordmark, corner
  brackets, scan-line, JetBrains Mono numerals, glassmorphic hub, exact geometry).
- **RD-H** — tests + memory update → report 'ready for cut-over'.

## Reused from the earlier build (P0-P6, 94634644..a053ec81)
The dial CustomPainter (ring_dive_dial), the wheel gesture (ring_dive_wheel), the
hub/breadcrumb/results/sheet/qty scaffolding — KEPT. The card_engine data wiring
in ring_dive_screen is REPLACED by ring_dive_catalog + the phase model (the old
wiring produced a word-cloud; owner corrected it to the clean taxonomy drill).

## Status
- RD-A done (5c8f2086) — the derivation layer.
- RD-B done (this commit) — ring_dive_screen rewired from card_engine to
  ring_dive_catalog: root (9 styles) → find (one clean axis per turn) → product
  leaves → qty → cart. Reuses the wheel/hub/breadcrumb/footer/sheet/cart. Test
  verifies the clean root→dept→categories drill. analyze 0, tests green.
- RD-C next — the axis-switcher chip strip (jump between the remaining axes).
