# atom decompose

An **automatic atom-decomposer** for BuildSmart screens. Point it at one screen
`.dart` file; it emits a **3-layer decomposition per atom** (object · connections
· behaviour) plus a **registry reconciliation**, in the
`app_flutter/knowledge/screens/<screen>/` format.

Pure static analysis over the Dart **AST** (`package:analyzer`, no element
resolution, no running app). Lives under `tools/atom/` — it is **not** part of
the app library and never ships in a build.

## Run

```bash
cd tools/atom/decompose
dart pub get

# from the repo root:
dart run tools/atom/decompose/bin/decompose.dart \
  app_flutter/lib/screens/smart_home_screen.dart \
  --name contractor-home            # logical screen key (default: file basename)
# → writes app_flutter/knowledge/screens/contractor-home/

# inspect without writing:
dart run tools/atom/decompose/bin/decompose.dart <screen.dart> --print
```

Flags: `--registry <path>` (default `app_flutter/lib/state/studio/element_registry.dart`),
`--out <dir>` (default `app_flutter/knowledge/screens`), `--name <key>`, `--print`.

**Batch** — decompose every screen in a directory in one pass (registry parsed
once), writing each to `<out>/<basename>/`, printing a coverage summary:

```bash
dart run tools/atom/decompose/bin/decompose.dart --batch app_flutter/lib/screens \
  --out app_flutter/knowledge/screens
# → 76 full · 41 thin · 0 errored · 117 total
```

These decompositions are **code-derived knowledge**: they live next to the code
at `app_flutter/knowledge/screens/<screen>/` and are regenerated from the batch,
never hand-edited. (Hand-authored specs live on the `nice-volta` knowledge
branch.) A file with no widget class is skipped, not fatal.

## What an atom is

- **composer** — the public widget class that arranges the screen's sections
  (e.g. `SmartHomeBody`). One per screen.
- **section** — each widget the composer places directly, or reaches through an
  in-file dispatch switch (`…SectionFor(s) => switch (s) { … }`). The switch also
  recovers each section's `HomeSection` enum member.
- Support helpers a section composes (cards, tiles, pads) are **not** atoms —
  their content **rolls up** into the section that uses them, so e.g.
  `_SmartTreeCard`'s `add_to_cart` id is attributed to the `_SmartTreeRow`
  products section.

## The three layers (+ floor)

Extracted from the AST, per atom:

| layer | Hebrew | what | how it is read from the AST |
|-------|--------|------|------------------------------|
| 1 · object | עצם | `nodes` | `Text('…')` / `CfgText('id','…')` / `CfgVisible('id')` literals + string literals passed to in-file widgets (section titles, empty cards). Each `CfgText`/`CfgVisible` id is **cross-checked** against `element_registry`. |
| 2 · connections | חיבורים | `edges` | **reads** = `ref.watch` / `ref.read`; **writes** = `.state =` / notifier mutators (`add`, `remove`, …); **action** = `Navigator.push` / `show*` / `open*`; **gated-by** = `modOn` / `featOn` / const-flag guards / `if (…) SizedBox.shrink()`. |
| 3 · behaviour | התנהגות | `flows` | `trigger → mechanism → effect`, where mechanism is **verb** (a call), **rule** (`if` / `?:`) or **formula** (a pure expression). |
| — | floor | `floor` | external (out-of-file) functions the atom leans on (`groupThousands`, `productImage`, `cfgRadius`, …). |

Plus, per atom:

- **gaps** (`object.unregistered`) — visible text the atom paints that is **not**
  in `element_registry` (a plain `Text` where a `CfgText` id would let the owner
  edit it live). The object summary reads `registry N · mapped M/N · unregistered K`.
- **contract** (`contract`) — the *untangle* analysis: `extractable`
  (`clean` · `needs-untangle` — writes global state, lift to callbacks ·
  `embeds-shared` — embeds a big shared widget that is its own atom), the atom's
  declared `props`, and `untangle` notes (which writes → callbacks, which embeds
  → split out).
- **variant / gate** — when the composer renders one widget behind a const-flag
  for a section (`kAxisDive ? [_SuperFinderOpen()] : …`), that widget is the
  **live** variant (`variant: live`, `gate: kAxisDive`) and the section's
  dispatch widget is the **preview** (`variant: preview`).

Plus a screen-level **registry reconciliation** — every id the screen uses and
whether `element_registry` carries it (`matched/total`).

## Screen shapes it handles

- **Stateless composer + dispatch switch** (`smart_home_screen` — `SmartHomeBody`,
  `…SectionFor(s) => switch (s) {…}`): sections + `HomeSection` mapping + live/preview.
- **Stateful composer** (`store_screen`, `manager_dashboard_screen`): the build
  lives in the `State` class (`_XState extends ConsumerState<X>`); the tool
  attributes the State's build to the widget, so its tabs/rows are found as
  sections. Support helpers (with their own State classes) roll up.

## Output files (per screen dir)

- `index.md` — atom table + registry reconciliation.
- `<atom>.json` / `<atom>.md` — the 3 layers + floor, one per atom.
- `registry.json` — the reconciliation.
- `screen.json` — the whole decomposition (machine-readable).

## Sources & branches (per `knowledge/AGENT-SOURCES.md`)

- **Code + this tool** live on `claude/whats-happening-LyY9G` (the live tree).
  All golden **inputs** (the screen `.dart`, `element_registry.dart`) are read
  from there.
- **Published knowledge** — the human-readable decompositions — live on
  `claude/nice-volta-BSbVm` at `knowledge/screens/<screen>/`. That is the SSOT
  for the golden MD; the output is **not** committed to the code branch.

Publish (from a `nice-volta` checkout, pointing `--registry` at the live tree):

```bash
dart run <path-to-tool>/bin/decompose.dart <live>/app_flutter/lib/screens/smart_home_screen.dart \
  --name contractor-home --out knowledge/screens \
  --registry <live>/app_flutter/lib/state/studio/element_registry.dart
```

## Golden

`test/golden_test.dart` runs the decomposer on the live `smart_home_screen.dart`
and asserts the output equals the **self-contained fixture** at
`test/golden/contractor-home/` byte-for-byte, plus the anchors: **one composer ·
registry 6/6 · section mapping recovered · super-finder live/preview · untangle
contract · gaps surfaced**. (Atom count tracks the live screen — 10 today.)

```bash
cd tools/atom/decompose && dart test
```

If the live screen legitimately changes, regenerate the fixture:

```bash
dart run bin/decompose.dart ../../../app_flutter/lib/screens/smart_home_screen.dart \
  --name contractor-home --out test/golden \
  --registry ../../../app_flutter/lib/state/studio/element_registry.dart
```
