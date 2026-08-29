# atom testgen

Generate `flutter_test` files from the atom-decomposition graphs
(`app_flutter/knowledge/screens/<screen>/*.json`, produced by
`tools/atom/decompose`). **The rule: every testable edge + flow-step → a test.**

Dart-only (reads JSON, emits Dart). Lives under `tools/atom/` — dev-tooling with
its own CI job, never part of the app build.

## Run

```bash
cd tools/atom/testgen && dart pub get

# one screen (from the repo root):
dart run tools/atom/testgen/bin/testgen.dart \
  --screen tools/atom/decompose/test/golden/contractor-home \
  --out app_flutter/test/generated

# batch — every screen graph → one test file each:
dart run tools/atom/testgen/bin/testgen.dart \
  --graphs app_flutter/knowledge/screens --out app_flutter/test/generated
```

## What it generates

Pumps the screen's PUBLIC composer (the proven
`favorite_tile_opens_sheet` pattern: fonts + RTL + tall surface + mock prefs),
then, per atom:

| graph element | test |
|---|---|
| `registry-ID` node (`cfgText`) | **wired** — the element's text renders |
| `cfgText`/`cfgVisible` node | **hide** — gone when `resolvedNodeProvider(id)` is overridden hidden |
| `verb` flow with a toast effect | **verb** — tap the labelled trigger → the toast fires |

Skipped by design (would not compile or render, so can't pass): a **private**
composer, a composer with **required ctor args** (`constructible: false` in the
graph), **preview** variants + **const-gated** atoms (not in the live tree by
default), trivial `reads`, and — for now — `formula` (needs the decomposer to
capture formula steps · a later slice).

## Opt-in + non-blocking

Every generated file self-skips unless `--dart-define=atomgen=true`, so the main
swarm suite compiles them (0 tests run) and a failure never blocks CI. The
`atom-tools` workflow's `generated-triage` job runs them with the define,
`continue-on-error`. See `app_flutter/test/generated/TRIAGE.md`.

## Golden

`test/golden_test.dart` runs the generator on the `contractor-home` graph and
pins its output (`test/golden/contractor-home_generated_test.dart.txt`) — the
smartTree ST-3 anchors: `registry-ID → wired`, `CfgVisible → hide`,
`verb → toast`. Those 13 tests are verified to PASS against
`smart_home_screen.dart` (13/13). `dart test` — 4/4.
