# Atom Engine — LEARNINGS

Every learning gets recorded here and applied to **all** atoms, not just the
one that surfaced it. Newest first.

---

## L1 — "byte-identical" really means "engine tree-shaken"; the version bump moves the hash

A literal `sha256` match of `main.dart.js` is **not** achievable, and expecting
it was wrong. Reason: gate 59 mandates a version-label bump when you touch
`lib/screens/`, and that label is a UI **string compiled into the bundle** — so
the hash necessarily changes. The safety property that actually matters is that
**no engine/atom code is retained when the flag is off**.

Measured (this slice):
- Baseline (pre-engine, flag off): `84f6c97f…b0c6`, **5,592,763 bytes**.
- After (flag off): `2c26189d…fd73`, **5,592,783 bytes** — delta **+20 bytes**,
  fully accounted for by the longer v5.56 label string (which itself contains
  the text "kAtomEngine"). Grepping the off-bundle finds no atom code — the one
  "AtomEngine" hit is that label string, not a retained class.
- The whole `lib/atoms/` graph is dead-code-eliminated by the const-`false`
  condition + tree-shaker. `finder_screen.dart` is untouched, so the live path
  is unchanged.

So byte-verify = "delta is only the version string, zero retained atom
symbols", not "identical hash". Keep the fallback screen untouched so the live
path can never shift.

## L2 — Reuse the finder's OWN public helpers; re-extract against the LIVE screen

An atom is only correct if it renders pixel-identical to the screen it was lifted
from *as that screen is today*. The finder is actively maintained: between
slice-1's first draft (an older base) and integration onto the live branch it had
grown a `wall` chip axis + a water-system pool filter, adopted `CfgText` and a
Semantics/48dp close target, and — crucially — moved its narrow-axis logic into
the public `lib/features/word_finder/narrow_axis.dart`.

Two rules fell out, applied to every atom:
1. **Bind to the screen's existing public helpers; never copy one you can import.**
   `finder_model.dart` now *imports* `narrow_axis.dart` (`narrowAxis`,
   `productHasChip`, size/angle tokens — the same functions the finder runs) and
   adds only what it lacks (group pool, system counts, sub/letter/wall options).
   Parity holds by construction — one code path, not two that can drift.
2. **Re-extract against the live `finder_screen.dart` and re-run the parity test
   on integration.** The pixel/structural test is the contract that keeps the
   engine path honest as the fallback evolves; a stale extraction fails it loudly
   (it did — that is how the `wall` axis was caught).

## L3 — Manifest is SSOT; the embedded const must stay in sync

The JSON manifest (`atom-engine/manifests/contractor-home.json`) is the human
SSOT. The engine parses an **embedded copy** of that JSON
(`kContractorHomeManifestJson` in `lib/atoms/atom_schema.dart`) so rendering is
synchronous (no async asset load, no blank first frame — which would break
pixel parity). `atom_home_parity_test.dart` asserts the embedded const equals
the file byte-for-byte, so the two can never drift.

## L4 — Chip bars unify; other atoms don't

Atoms 3–7 (subtype/narrow/angle/letter/wall) are structurally identical — all
build a labeled `_chipRow` of `_chip`s — so they collapse to a single
`AtomChipBar` bound five ways from the schema (the wall bar passes a `labelFor`
to show `$c מ"מ` while keying on `c`). `type_grid`, `breadcrumb`, `result_count`,
`chip_tip` and `results` are each unique. Don't force-unify the unique ones; the
win is only where the source builders were already the same.
