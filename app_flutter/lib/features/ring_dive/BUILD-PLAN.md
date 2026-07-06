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
- RD-B done (6385553d) — ring_dive_screen rewired from card_engine to
  ring_dive_catalog: root (9 styles) → find (one clean axis per turn) → product
  leaves → qty → cart. Test verifies the clean root→dept→categories drill.
- RD-V1 done (21ca0c0b) — **the dial visual is rebuilt to Pro-X-Light** (one
  CustomPainter: warm plate, 72 ticks, wedge, r122 straight labels + focus halo,
  dashed locked rings; glassmorphic hub). Verified by a render vs the prototype.
  The OLD knurled-orange dial is gone. **The owner's "this is not the new design"
  was the dial look — now fixed.**
- RD-V1.5 done (swarm hardening) — the canonical 10-lens swarm (audit →
  validate → fix, 31 agents) confirmed 14 findings; the file-disjoint fixers
  applied the verified subset. Orchestrator byte-verify: analyze
  lib/features/ring_dive = 0 · ring_dive test 2/2 green · flag OFF still
  SizedBox.shrink. Fixes: honest job placeholder (no fake dept drill) · pool
  filtered once per frame · live _leaves field (no stale closure) · RTL
  breadcrumb + footer reverse and newest-first order · wheel _moved reset in
  didUpdateWidget · catalog stores the trimmed value + reuses a match set ·
  dial caches the unfocused label layouts + compares label content in
  shouldRepaint. Still to visually confirm in RD-V2: the RTL breadcrumb/footer
  order (a render check, not a logic one).
- RD-V2 done — the SCREEN CHROME is rebuilt to Pro-X-Light: the 392px phone card
  (radial warm bg, gradient border, 4 corner brackets, static scan-line), the
  RINGDIVE·OS status bar + reset, the 56px count block (count · readout · status
  line), the "סנן לפי" axis-switcher chip strip, numbered breadcrumb chips, and
  the results rail (NO price — the catalog has none). Verified: analyze 0 · test
  2/2 · flag OFF byte-identical · a headless runAsync render (root + find PNGs)
  confirms the STRUCTURE matches the prototype 1:1 (card, brackets, bar, count,
  axis strip, breadcrumb, wheel, rail all present + placed). Text shows as tofu
  in flutter_test (no fonts) — real-font fidelity is verified next in a browser
  render. LESSON: toImage in flutter_test MUST run inside tester.runAsync (a
  real-async future deadlocks under the fake clock — it timed out 2× before).
- RD-V3 done — the qty dual number-ring (ring_dive_qty.dart): tens 00–90 (outer
  r124) + units 0–9 (inner r84) summed to 0–99. The first drag direction picks
  the ring (CCW → tens), a tap on a number snaps its ring, release snaps both.
  Wired into the screen's qty phase, replacing the discrete pick list; a live
  ValueNotifier feeds the "הוסף לסל × N" confirm bar (ביטול + add), off setState
  so a drag rebuilds only the ring + label, not the card. Verified: analyze 0 ·
  test 2/2 · flag OFF byte-identical · a headless runAsync render (root → dive →
  product → qty) confirms the two concentric number rings + focus halos + the
  central "+" + the live-value hub + the confirm bar all match the prototype.
- RD-E1 done — compat ("what connects to this product") wired to the REAL
  verified-connections engine: `compatibleWith(product)` from logic/install_
  engine.dart (memoised, canConnect + temp-suitability over kVerifiedSpecs). The
  done phase now offers "🔗 מה מתחבר לזה" when the added product has real
  partners; it opens a `compat` mode whose wheel is the partner list (short
  type+size labels), tap adds a partner. Verified: analyze 0 · test 3/3 (a new
  test drives root→product→confirm→"what connects"→asserts compat) · flag OFF
  byte-identical · a headless render confirms the compat count block + partner
  wheel + rail. Known-deferred: the wheel caps at 12 partners (count block shows
  the true total; pagination is RD-F) and the rail header still reads "מועמדים".
- RD-E2 next — the job/kit mode via the REAL smart_tree recipes (kSmartProducts:
  SmartProduct.acc slots, smartProductForSku); entered from the root "לפי עבודה"
  style and the done "השלם ערכה" follow-up. Then RD-F (done follow-ups + cart
  sheet + wheel pagination), RD-G (motion polish + bundle JetBrains Mono + a
  browser-render fidelity pass). Show the owner LIVE only once the FULL screen
  matches (not piecemeal).
