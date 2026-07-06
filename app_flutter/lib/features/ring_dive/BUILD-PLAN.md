# RingDive (צלילת-טבעות) — build plan

A rotary product-finder that **replaces the smart keyboard's product-finding
presentation** with a spinning knurled dial, while reusing the SAME drill-down
engine (`card_engine.dart`). Owner design handoff, 2026-07-06.

## Non-negotiables (every phase)
- **Flag-gated `kRingDiveFlag` ('kRingDive'), OFF = byte-identical.** Demo build
  via `--dart-define=ENABLE_RING_DIVE=true` (`kEnableRingDiveDemo`). Live deploy
  workflows do NOT pass it — cut-over stays owner-gated.
- **Zero engine changes.** The dial is a new VIEW over `mergedKeys(...)`; the
  brain (`card_engine` / `word_finder_engine`) is untouched (a byte-identity test
  guards it, like #38 did).
- `flutter analyze` = 0 new issues · golden/byte-identity green · **commit local
  only — push ONLY on the literal owner word "תדחוף".**
- Plain-word commit messages, **no backticks in `-m`**.

## Shared-engine wiring (the whole point)
`card_engine.mergedKeys(pool, stack, lexicon, subtype)` → sealed `CardVerdict`:
- `CardAskWords(questionHe, words)` — opening turn (stack empty) → the dial's
  first ring shows the opening plain-words.
- `MergedKeys(chips)` — the merged axis options → the dial's rotating labels.
  Each `SignalChip` (axisId · value · displayLabel · axisName) is one dial option.
- `CardResolve(product, siblings)` — pool collapsed to one card → qty phase.
- `CardShowProducts(products)` — scan-by-eye → the results footer.

A **dive** = tap the hub/option → build a `NewbieStep` from the chosen chip →
push to the stack (`cardKeyboardStackProvider`-style, but a RingDive-scoped
provider) → recompute the pool → re-run `mergedKeys`. `≤6` is already enforced
inside the engine (`kMaxDiveTurns` gate); `≤4`-between-products is `hop_graph`.
Auto-skip single-option axes: the engine's own ladder + a thin dial-side skip.

## Owner decisions (defaults chosen; owner may override)
1. **Scope** — RingDive replaces the smart product-finder only; the floating
   keyboard (nav/text shell) is untouched. *(default)*
2. **Axis order** — engine-driven (most-splitting axis per turn), NOT the
   prototype's fixed dept→…→color order. *(default — keeps the smarts + ≤6)*
3. **Typing** — pure-dial first; the floating keyboard's text field can SEED the
   pool later (`pool_seed.dart`) as a compose option. *(default)*
4. **Rollout** — web-demo define first → verify live → then mobile. *(default)*

## Phase ladder
- **P0 — flag + skeleton.** `ring_dive_flag.dart` · `feature_flags.dart` seed ·
  `ring_dive_screen.dart` (SizedBox.shrink OFF, 320×320 box ON). ← this commit.
- **P1 — dial geometry (CustomPainter).** Base disc (radial gradient + warm
  shadow), 20 knurled grip pads @ r=108 (active pad @ 12:00), center groove,
  locked depth rings, fixed 12:00 pointer. Static (no rotation yet).
- **P2 — curved labels.** Text-on-arc per option at its LIVE screen angle
  (`-90 + i*360/n + rot`); flip the baseline on the lower half so text stays
  upright. Focus label bigger/orange. White halo stroke.
- **P3 — rotation / drag / snap + haptics.** GestureDetector pan + `atan2`
  angle; accumulate rot; snap to detent on release (`round(rot/step)*step`);
  focusIndex; tap-vs-drag (>~8° = drag, suppress tap). `HapticFeedback`
  selectionClick per detent, mediumImpact on select. reduce-motion gated.
- **P4 — wire to `card_engine`.** Replace any demo data with the real pool;
  options = `MergedKeys.chips`; dive = NewbieStep→narrow→re-run. RingDive-scoped
  stack provider (identity-isolated). This is where it becomes REAL data.
- **P5 — the 4 phases + breadcrumb.** dive → qty → cart → added. Center hub
  morphs per phase (axis name+focus / product image+"בחר ×N" / "הוסף לסל"+total /
  ✓). Breadcrumb pills = answered axes; tap a pill = back-to-level.
- **P6 — results footer + product sheet.** Horizontal product cards from
  `filtered()` / `hop_graph`; tap → bottom sheet (specs + הוסף להזמנה) → cart.
- **P7 — swap seam.** At the smart-keyboard entry point, gate: flag ON →
  RingDive, OFF → existing surface. One seam. Byte-identical OFF.
- **P8 — polish + tests.** a11y/bidi (RTL semantics), reduce-motion, purity tests
  for pure helpers, widget test for a dive→resolve→add path, byte-identity test.

## Status
- P0 done (94634644) — flag + skeleton + feature_flags seed + BUILD-PLAN.
- P1 done (7d9d2ecf) — ring_dive_dial.dart CustomPainter: warm-shadow base
  disc, 20 knurled pads (active @ 12:00), top gloss, center groove, locked-ring
  param, 12:00 pointer. Static; rotation + lockedCount params ready for P3/P4.
- P2 done (this commit) — rim labels: one per option around radius 90,
  tangent-rotated (upright-flip on the lower half), focus bigger+orange @ 12:00,
  white halo. Whole-label tangent (not per-glyph arc) — faithful for the short
  axis values; per-glyph curving is a P8 option. If the owner finds the side
  (tangential) labels hard to read, an upright-in-ring variant is a one-liner.
  Screen shows 6 preview labels (replaced by engine chips in P4). analyze 0.
- P3 done (this commit) — ring_dive_wheel.dart: drag-to-rotate (atan2), detent
  snapping on release, focus tracking, haptics (selectionClick per detent,
  mediumImpact on select), tap-vs-drag (8 deg threshold), reduce-motion gated.
  Screen renders the interactive wheel. analyze 0.
- P1-3 milestone — local render of the dial verified (see the loop report).
- P4 next — wire to card_engine: options = MergedKeys chips, tap = dive
  (NewbieStep -> narrow -> re-run); RingDive-scoped stack provider.
