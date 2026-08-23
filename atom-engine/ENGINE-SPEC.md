# Atom Engine — ENGINE-SPEC (SSOT)

> Single source of truth for the BuildSmart **atom assembly engine**.
> Slice-1 scope: **atomize the contractor home screen for real** — the home
> renders from a schema through the engine, byte-identical to the original,
> behind a compile-time flag.

## 0. Why

The app's screens are hand-wired widget trees. We want screens that are
**assembled from data**: an ordered list of reusable, portable *atoms* plus a
per-screen *manifest* that says which atoms appear, in what order, and when
each is visible. This generalizes the ad-hoc "section" composition already in
the codebase (the finder home's `build()` Column of conditional children) into
one engine.

Benefits: atoms become reusable across screens/personas; screens become
declarative (a manifest); layout changes become data edits; each atom is
independently testable.

## 1. Definitions

- **Atom** — a pure, portable widget. It receives everything it needs through
  explicit props/callbacks and reads no ambient screen state. An atom is a
  faithful extraction of one visual/logical block of a screen.
- **Manifest** — a JSON document describing one screen: the ordered atom slots,
  each slot's `type`, its `when` (visibility predicate key), and layout flags
  (e.g. `expanded`). See `manifests/contractor-home.json`.
- **Schema** — the parsed, typed form of a manifest (`AtomSchema`,
  `lib/atoms/atom_schema.dart`).
- **Resolver** — supplied by a screen *controller*. Given an `AtomSpec` it
  returns an `AtomSlot { visible, child }`: it evaluates the `when` predicate
  against live screen state and builds the atom widget with real props.
- **Engine** — `AtomEngine.render(schema, resolve)`: walks the schema in order,
  drops invisible slots, wraps `expanded` slots in `Expanded`, returns a
  `Column`. The engine is domain-agnostic; all data lives in the resolver.

Separation of concerns: **manifest** = order + visibility keys + layout;
**resolver/controller** = data + predicate evaluation; **atom** = pixels.

## 2. Safety model (non-negotiable)

The engine ships **default-off** and must be provably inert when off.

1. **Compile-time flag** — `kAtomEngine`
   (`lib/atoms/atom_flag.dart`), `bool.fromEnvironment('ATOM_ENGINE')`,
   default `false`. When false the engine path is unreachable and tree-shaken.
2. **default = code-identical (engine tree-shaken)** — with the flag off, the
   release `main.dart.js` contains **none** of the engine/atom code: the const
   `false` condition dead-code-eliminates the `AtomHomeScreen` branch and the
   tree-shaker drops the whole `lib/atoms/` graph. The fallback screen
   (`FinderScreen`) is **not touched**; the engine, atoms and controller are
   additive files reached only when the flag is on. (A literal byte-for-byte
   hash match is not achievable because gate 59 mandates a version-label bump,
   and that label string is compiled into the bundle — see byte-verify.)
3. **byte-verify** — capture `sha256` and byte-size of `main.dart.js` before the
   change; after the change, `flutter build web --release` (flag off) must show
   a delta of **only the version-label string** (a couple dozen bytes) and
   **zero retained atom code** (no `AtomHomeScreen`/`AtomEngine`/atom symbols in
   the bundle beyond the label text). Recorded in `LEARNINGS.md`.
4. **toggle-matrix** — the app builds and passes analyze+test in both states:
   flag off (default) and flag on (`--dart-define=ATOM_ENGINE=true`).
5. **central-verify green** — `flutter analyze` 0 errors, `flutter test` 0 new
   failures, `flutter build web --release` succeeds.
6. **fallback to old** — the original screen stays as the live path and the
   on-state's proof of correctness. If the engine path ever regresses, flip the
   flag off and the old screen is byte-for-byte back.

## 3. Proof obligation (slice-1)

The home **runs from the engine** and is **pixel-identical** to the original:
`AtomHomeScreen` (engine-driven) and `FinderScreen` (original) render the same
tree for the same drill state. Enforced by `test/atom_home_parity_test.dart`.

## 4. The 9 atoms of the contractor home

The home is the finder (`lib/screens/finder_screen.dart`, the `'מאתר'` section —
the `'בית'` home is now `SmartHomeBody` and is untouched), whose `build()` is a
Column of exactly 8 conditional children plus the results surface, over a landing
type list. Each becomes an atom:

| # | Atom id           | Widget            | Source builder      | `when`                         |
|---|-------------------|-------------------|---------------------|--------------------------------|
| 1 | `type_grid`       | `AtomTypeGrid`    | `_typeList()`       | `group == null` (landing)      |
| 2 | `breadcrumb`      | `AtomBreadcrumb`  | `_header()`         | `group != null`                |
| 3 | `subtype_chips`   | `AtomChipBar`     | `_subBar()`         | `subs > 1`                     |
| 4 | `narrow_chips`    | `AtomChipBar`     | `_sizeBar()`        | `narrow.chips not empty`       |
| 5 | `angle_chips`     | `AtomChipBar`     | `_angleBar()`       | `angleChips > 1`               |
| 6 | `letter_chips`    | `AtomChipBar`     | `_letterBar()`      | `letterChips > 1`              |
| 7 | `wall_chips`      | `AtomChipBar`     | `_wallBar()`        | `wallChips > 1`                |
| 8 | `result_count`    | `AtomResultCount` | `_countStrip()`     | `results not empty`            |
| 9 | `chip_tip`        | `AtomChipTip`     | `_chipTip()`        | `results not empty && !dismissed` |
| — | `results`         | `AtomProductList` | results `Expanded`  | `group != null` (terminal, `expanded`) |

Atoms 3–7 are one parameterized `AtomChipBar` bound five ways — the strongest
unification the code allows (all call the same `_chipRow`/`_chip`); the wall bar
passes a `labelFor` so it shows `$c מ"מ` while keying selection on `c`.

The narrow-axis logic (size/angle/colour/word tokens, curated facets, chip
matching) is **reused** from `lib/features/word_finder/narrow_axis.dart` — the
same public library the finder itself uses — so the two can never diverge.
`lib/atoms/finder_model.dart` adds only what that library lacks: group pool
selection, system-aware category counts, sub-type derivation, letter/wall
options. It mirrors the private helpers still inside `finder_screen.dart` (the
untouched fallback); the parity test guards against drift.

## 5. Files

```
atom-engine/
  ENGINE-SPEC.md                 ← this file (SSOT)
  manifests/contractor-home.json ← the home manifest (SSOT)
  LEARNINGS.md                   ← every learning, applied to all atoms

app_flutter/lib/atoms/
  atom_flag.dart        ← kAtomEngine
  atom_schema.dart      ← AtomSpec / AtomSchema (+ embedded manifest const)
  atom_engine.dart      ← AtomEngine.render + AtomSlot
  finder_model.dart     ← shared pure domain logic (public)
  home_atoms.dart       ← the atom widgets
  atom_home_screen.dart ← engine-driven home (controller + resolver)

app_flutter/test/atom_home_parity_test.dart  ← parity + manifest-sync proof
```

## 6. Adding an atom / a screen

1. Add the widget to `home_atoms.dart` (or a new `<screen>_atoms.dart`), pure.
2. Add its slot to the screen manifest (order, `type`, `when`, layout flags).
3. Keep the embedded manifest const in sync (the parity test enforces it).
4. Teach the controller's resolver the new `type`/`when`.
5. Prove parity against the fallback, run central-verify, record learnings.
