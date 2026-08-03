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

Plus a screen-level **registry reconciliation** — every id the screen uses and
whether `element_registry` carries it (`matched/total`).

## Output files (per screen dir)

- `index.md` — atom table + registry reconciliation.
- `<atom>.json` / `<atom>.md` — the 3 layers + floor, one per atom.
- `registry.json` — the reconciliation.
- `screen.json` — the whole decomposition (machine-readable).

## Golden

`test/golden_test.dart` runs the decomposer on `smart_home_screen.dart` and
asserts the output **equals** the committed golden at
`app_flutter/knowledge/screens/contractor-home/` byte-for-byte, plus the spec
anchors: **8 atoms · one composer · registry 6/6 · section mapping recovered**.

```bash
cd tools/atom/decompose && dart test
```

If a screen legitimately changes, regenerate the golden with the `dart run …`
command above and re-commit the `contractor-home/` dir.
