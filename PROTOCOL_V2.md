# BuildSmart Protocol v2 — Design Proposal

> **Status: PROPOSAL.** Lives only on `claude/agent-network-proto-build`
> (worktree `/home/user/wt-proto-build`). It does **not** touch the live
> protocol on `claude/whats-happening-LyY9G`. Gates are off on this branch, so
> commits here are free. Nothing here is adopted until the architect approves
> and the files are ported to the live branch.

This is a "better copy" of the BuildSmart enforcement protocol. It keeps **every
real protection** of v1 and fixes the structural problems the researcher mapped
and the architect verified.

---

## 1. What was wrong with v1 (verified findings)

| # | Problem | Evidence |
|---|---------|----------|
| A | **No single source of truth.** `GATE_REGISTRY.md` was hand-maintained markdown that drifted from the code; its "free gates" list was wrong for ~20 numbers. Nothing enforced registry⇄code parity, so it rotted. | `app_flutter/knowledge/GATE_REGISTRY.md` vs the 100 distinct ids emitted by `.githooks/pre-commit`. |
| B | **#1 recurring bug class: brittle bash content greps.** emoji/RTL/secret/antipattern greps broke under MSYS/git-for-windows (git swaps the grep binary/PATH at hook time). Gates 23/64/93/103/109/114 each had to be rewritten from `grep` to bash `case`/glob. Every new bash content gate is a latent MSYS bug. | Comments throughout `pre-commit` ("לקח #52"), e.g. lines 236-245, 485-491, 695-736. |
| C | **Defect: `err "105"` mislabeled.** Line 161 is the *commit-msg-missing* check but emits id `105`, sitting among gates 6-9. | `pre-commit:161`. |
| D | **Defect: 15≡83 duplicate.** Line 186 (`err "15"`) and line 217 (`err "83"`) both assert `core.hooksPath == .githooks`. | `pre-commit:186,217`. |
| E | **Inflated count from comment-only / moved / cancelled entries.** Gate 34 moved to pre-push; gate 59 cancelled; 61/76 removed; 100 is just a summary banner. | `pre-commit:348,252,470-474,551-552,911-925`. |
| F | **925-line bash monolith.** One linear script, hard to read/modify, no functions. | `wc -l .githooks/pre-commit`. |
| G | **CI enforces ~8 gates vs the hook's 116** → the only un-bypassable layer misses ~108 protections. | `.github/workflows/protocol-enforce.yml` has 8 `Gate N` steps. |

v1 emits **100 distinct gate ids** (max id 116). The gap (100 vs 116) is exactly
the moved/cancelled/removed/summary entries in (E) plus the `7c`-vs-`105`
mislabel in (C).

---

## 2. What v2 changes (and why)

### 2.1 [P0] Gate registry = single source of truth — `protocol/gates.tsv`
One row per **real** gate: `id · group · name · severity · trigger · tier ·
engine · status · check-desc`. Reconciled 1:1 with the actual emitted ids.

A new gate **`reg`** runs on every commit and **fails** if the set of ids the
hook can emit (`HOOK_GATE_IDS` in `pre-commit`) ≠ the set of `enforced` ids in
the registry. The comparison is done by the Dart engine
(`--verify-registry`) — deterministic, no grep. **The registry can no longer
drift from the code**: adding/removing a gate without updating both sides fails
the commit. This is the structural fix for problem (A) and makes the old
`GATE_REGISTRY.md` rot impossible.

> **Parity-set definition.** The set compared is the **enforced inventory**:
> every gate the hook implements, identified by `HOOK_GATE_IDS` in `pre-commit`,
> vs every row with `status=enforced` in `gates.tsv`. This includes gates that
> act silently rather than emitting `err`/`warn` — e.g. gate `104`
> (`severity=n/a`) which auto-regenerates `stuck_regression_test`. Including
> silent-but-real protections makes the registry a *complete* inventory, not
> just a list of blockers. Two id "namespaces" are deliberate: numeric legacy
> ids are preserved 1:1; the relabeled commit-msg check uses `7c` and the new
> parity gate uses `reg` (string ids so they never collide with the legacy
> numbering plan in the old registry).

`GATE_REGISTRY.md` is superseded by `protocol/gates.tsv`. (Recommendation:
replace it with a one-line stub pointing at the TSV — see Adoption.)

### 2.2 [P3] One deterministic content engine — `app_flutter/tool/protocol_check.dart`
All brittle string/content gates move out of bash into a single pure-Dart
engine. Dart `RegExp` behaves identically on Linux/macOS/Windows; there is no
external binary, no PATH swap, no locale surprise. This kills problem (B), the
#1 recurring bug class.

Gates moved into the engine: **28, 46, 48, 50, 51, 52, 54, 62, 63, 64, 65, 67,
69, 70, 73, 74, 95, 97, 103, 114** (the content-analysis set, including the
named targets: emoji, RTL left/right, secrets, dark-surface, persistence-key,
kLipskeyCatalog, antipattern-recurrence).

The hook dumps `git diff --cached` once and calls the engine; the engine prints
`ERR|WARN<TAB>id<TAB>msg`, which the runner re-emits through its own
`err()`/`warn()` so the retry/fingerprint bookkeeping is unchanged.

**Proven** by 36 built-in unit tests (`--self-test`) **and** a mirror
`flutter_test` (`test/protocol_check_engine_test.dart`). The headline tests
reproduce the **MSYS-class miss**: an invented emoji and a recurring antipattern
that the old bash greps let through silently are now caught deterministically.

> **Why a built-in `--self-test` and not only `flutter test`:** this repo has
> `flutter_test` but not the standalone `test` package, and `dart test` is
> unavailable. The engine is pure Dart, so `--self-test` proves it everywhere a
> Dart SDK exists — with **zero fragile external dependency**, which is the same
> principle that motivated leaving bash greps behind. The `flutter_test` mirror
> additionally wires it into `flutter test`/CI.

### 2.3 [P8] Defects fixed
- **105 mislabel → `7c`.** The commit-msg-exists check now emits id `7c` and
  sits with the other hook-exists gates (6/7/8/9). (`105` retired.)
- **15≡83 merged.** One gate (`15`) asserts `core.hooksPath==.githooks`. `83`
  retired with justification in the registry + mapping table.
- **Comment-only/moved entries removed from the live count.** `34` (→pre-push),
  `59` (cancelled), `61`/`76` (removed), `83` (dup), `100` (summary banner) are
  documented in the registry with `status != enforced` and are **excluded** from
  the parity set, so the count reflects **distinct protections** (100 real +
  `reg`).

### 2.4 [P1] Modular, readable `pre-commit`
A thin `run()` orchestrates one `gate_<group>()` function per group, plus
`run_content_engine` and `gate_registry_parity`. **Behavior is preserved
bit-for-bit**: branch-scoping, emergency-disable, `version.g.dart` generate,
retry/fingerprint, the fail-fast barrier (cheap gates before Flutter), tiering
(skip Flutter with no `.dart/.yaml`; skip tests on rebase/amend replay), and
baseline/known-failing tracking all behave as before — just organized into
named functions. Problem (F).

### 2.5 [P4 — design only] Close the CI gap
See §5. We describe (do not yet wire) how CI calls the **same** Dart engine so
the un-bypassable layer stops missing ~108 protections. Problem (G).

---

## 3. Architecture preserved (unchanged)

- **4 enforcement layers:** pre-commit (this file), `.claude` PreToolUse +
  SessionStart, CI. All four still present; gate `99` still asserts it.
- **Fail-fast barrier:** all cheap gates run first; on any failure we stop
  before the ~13-min Flutter tier (`run()` barrier after `gate_registry_parity`).
- **Tiered execution:** Flutter skipped when no `.dart/.yaml` staged; `flutter
  test` skipped on rebase/amend/cherry-pick replay (analyze still runs).
- **Baseline/known-failing tracking:** gate 32, including the baseline-phantom
  guard (`known_failing.txt` count must equal `known-failing:` in STATUS).
- **Retry/fingerprint:** gate 102 classification via `stuck_fingerprints.txt`,
  `gates=v2:` format, HEAD-aware retry detection — copied verbatim.
- **Self-regression generator:** gates 103/104/111 (engine handles 103;
  104 regen + 111 consistency stay in bash, cheap).
- **Branch-scoping:** lines that `exit 0` on any branch ≠
  `claude/whats-happening-LyY9G` are unchanged.

---

## 4. OLD → NEW mapping (EVERY v1 gate)

Legend: **KEPT** = same id, same behavior (content gates additionally moved to
the Dart engine, noted as `→engine`). **MERGED** = folded into another id.
**MOVED** = enforced in a different layer. **RETIRED** = removed with reason.

### Foundations & state
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| 1 | KEPT | 1 | work-branch |
| 2 | KEPT | 2 | knowledge files exist |
| 3 | KEPT | 3 | WIRING exists |
| 4 | KEPT | 4 | pubspec exists |
| 5 | KEPT | 5 | branch tracked (warn) |
| 6 | KEPT | 6 | pre-commit in repo |
| 7 | KEPT | 7 | pre-push in repo |
| **105** | **FIX (relabel)** | **7c** | was MISLABELED `err "105"` at line 161; it is the commit-msg-exists check → correct id `7c`, grouped with 6/7/8/9. `105` retired. |
| 8 | KEPT | 8 | settings.json in repo |
| 9 | KEPT | 9 | pre-tool.sh in repo |
| 10 | KEPT | 10 | workflow exists |
| 11 | KEPT | 11 | version.g.dart generated/tracked/staged guard |
| 12 | KEPT | 12 | version synced |
| 13 | KEPT | 13 | ROADMAP Group A |
| 14 | KEPT | 14 | STATUS has version |
| 15 | KEPT (absorbs 83) | 15 | hooksPath==.githooks |
| 16 | KEPT | 16 | pre-commit executable |
| 17 | KEPT | 17 | pre-push executable |
| 18 | KEPT | 18 | knowledge/ dir |
| 19 | KEPT | 19 | lib/state/ dir |
| 20 | KEPT | 20 | test/ dir |
| **83** | **MERGED → 15** | — | identical check to 15 (`core.hooksPath==.githooks`). Removed; 15 covers it. |

### Planning
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| 21 | KEPT | 21 | session_plan exists |
| 22 | KEPT | 22 | session_plan filled |
| 23 | KEPT | 23 | ROADMAP in-progress marker — whole-file read kept as bash builtin (MSYS-safe `case`); content nature noted. |
| 24 | KEPT | 24 | WIRING updated |
| 25 | KEPT | 25 | Preact-shared untouched (bash builtin glob; MSYS-safe) |
| 26 | KEPT | 26 | test filename singular |
| 27 | KEPT | 27 | snake_case filenames |
| 28 | KEPT →engine | 28 | local URI — now Dart |
| **59** | **RETIRED** | — | forced version-bump CANCELLED in v1 (conflict-magnet, lesson #72); superseded by 11/12. Documented `status=cancelled`. |

### Test tier
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| 31 | KEPT | 31 | flutter analyze (errors) |
| 32 | KEPT | 32 | tests vs baseline + baseline-phantom |
| 33 | KEPT | 33 | test count not down |
| **34** | **MOVED → pre-push** | — | build web release already moved to `pre-push` in v1 (fast-gate). Documented `status=moved`; pre-push unchanged. |
| 35-40 | KEPT | 35-40 | critical test files exist (warn) — emitted by the loop `warn "$N"`. v2 lists all six (35-40) explicitly in BOTH the registry and `HOOK_GATE_IDS`, so the parity check covers them. |
| 41 | KEPT | 41 | no greaterThan(0) |
| 42 | KEPT | 42 | helper needs test |
| 43 | KEPT | 43 | mutation_log exists |
| 44 | KEPT | 44 | mutation_log updated |

### Quality
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| 46 | KEPT →engine | 46 | dark surface |
| 47 | KEPT | 47 | dialog/sheet needs WIRING (warn) |
| 48 | KEPT →engine | 48 | no print() |
| 49 | KEPT | 49 | TODO/FIXME context (warn) |
| 50 | KEPT →engine | 50 | no dart:html |
| 51 | KEPT →engine | 51 | no hard URL (warn) |
| 52 | KEPT →engine | 52 | no secrets |
| 53 | KEPT (3 checks merged) | 53 | `.env` + `credentials` + bypass-token files. v1 emitted `err "53"` from 3 sites; v2 keeps all 3 assertions under one gate body. |
| 54 | KEPT →engine | 54 | no dark ColoredBox |
| 55 | KEPT | 55 | nested UI logic (warn) |
| 56 | KEPT | 56 | logic helper needs test |
| 58 | KEPT | 58 | fromEnvironment needs docs (warn) |
| 60 | KEPT | 60 | new prod dep (warn) |

### Language / culture
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| **61** | **RETIRED** | — | auto Hebrew-in-index check removed in v1 (Flutter-only leaves need not be in index.html). Documented `status=removed`. |
| 62 | KEPT →engine | 62 | no hard left/right (warn) |
| 63 | KEPT →engine | 63 | no TextAlign.left/right (warn) |
| 64 | KEPT →engine | 64 | no invented emoji (warn) |
| 65 | KEPT →engine | 65 | no TextDirection.ltr (warn) |
| 66 | KEPT | 66 | touched app/ (warn) |
| 67 | KEPT →engine | 67 | new Hebrew string in app/ (warn) |
| 68 | KEPT | 68 | Preact inspections frozen |
| 69 | KEPT →engine | 69 | color revert (warn) |
| 70 | KEPT →engine | 70 | gitignore secrets guard |

### Save-safety
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| 71 | KEPT | 71 | cart needs test (warn) |
| 72 | KEPT | 72 | helper in WIRING (warn) |
| 73 | KEPT →engine | 73 | persistence key format |
| 74 | KEPT →engine | 74 | no manual ProviderContainer |
| 75 | KEPT | 75 | providers not removed (warn) |
| **76** | **MOVED → commit-msg** | — | "commit message not empty" is comment-only in v1 pre-commit (lines 551-552); it is actually enforced by `.githooks/commit-msg`. Documented `status=moved`; commit-msg unchanged. |
| 77 | KEPT | 77 | large file (warn) |
| 78 | KEPT | 78 | no binaries |
| 79 | KEPT | 79 | no lock/modules (warn) |
| 80 | KEPT | 80 | pubspec.lock override (warn) |

### Final-safety
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| 81 | KEPT | 81 | hook in sync (fail-fast) |
| 82 | KEPT | 82 | pre-push in sync (warn) |
| 84 | KEPT | 84 | workflow not deleted |
| 85 | KEPT | 85 | workflow intact |
| 86 | KEPT | 86 | catalog no dup SKU |
| 87 | KEPT | 87 | polyroll needs test (warn) |
| 88 | KEPT | 88 | MASTER_PROTOCOL guard (warn) |
| 89 | KEPT | 89 | no delete tests |
| 90 | KEPT | 90 | no delete state |
| 91 | KEPT | 91 | unstaged lib (warn) |
| 92 | KEPT | 92 | state needs STATUS (warn) |
| 93 | KEPT →engine | 93 | ROADMAP checkmark (warn) |
| 94 | KEPT | 94 | knowledge_protocol_test (reads TEST_OUT) |
| 95 | KEPT →engine | 95 | number needs isolate (warn) |
| 96 | KEPT | 96 | pubspec version warn |
| 97 | KEPT →engine | 97 | gitignore no-hide .claude |
| 98 | KEPT | 98 | settings in repo (final) |
| 99 | KEPT | 99 | 4 enforcement layers |
| **100** | **RETIRED (summary)** | — | summary banner, not a protection. Still printed by `run()`; documented `status=summary`, excluded from parity set. |

### Learning / knowledge
| v1 id | disposition | v2 id | notes |
|------:|-------------|:-----:|-------|
| 101 | KEPT | 101 | stuck_log exists |
| 102 | KEPT | 102 | retry needs stuck entry |
| 103 | KEPT →engine | 103 | antipattern recurrence — now Dart (the highest-value MSYS fix) |
| 104 | KEPT | 104 | regen stuck_regression (bash; n/a severity) |
| 106 | KEPT | 106 | session_plan Owner+Scope |
| 107 | KEPT | 107 | UI visual log (warn) |
| 108 | KEPT | 108 | CARRY_FORWARD exists |
| 109 | KEPT | 109 | sub-protocol → CARRY_FORWARD (bash builtin count; MSYS-safe) |
| 110 | KEPT | 110 | audit log not empty (warn) |
| 111 | KEPT | 111 | stuck_regression consistency |
| 112 | KEPT | 112 | unified stubs |
| 113 | KEPT | 113 | asset-gen contact-sheet (warn) |
| 114 | KEPT →engine | 114 | kLipskeyCatalog in UI |
| 115 | KEPT | 115 | hot-file claim (warn) |
| 116 | KEPT | 116 | UI needs visual-verify (replay-skip) |
| — | **NEW** | **reg** | registry⇄code parity — the structural guarantee v1 lacked. |

**Note on 35-40 (dynamic ids):** v1 emits these via a loop (`warn "$N"`,
N=35..40) for the 6 critical test files. v2 keeps the identical loop AND lists
all six explicitly in both the registry and `HOOK_GATE_IDS`, so the parity check
verifies them like any other gate. (In v1 these ids were emitted at runtime but
absent from `GATE_REGISTRY.md` — a silent parity hole that v2's `reg` gate now
closes.)

**Totals:** v1 distinct emitted ids = 100. v2 enforced gates = **106 real +
`reg`** = **107** (the +6 vs v1's 100 is gates 35-40, which v1 emitted but never
registered). v1 ids retired/moved/relabeled — all justified above — are: **83**
(merged→15), **105** (relabel→7c), **34** (moved→pre-push), **76**
(moved→commit-msg), **59** (cancelled), **61** (removed), **100** (summary).
**0 protections lost.**

---

## 5. [P4 — design only] Closing the CI 8-vs-116 gap

Today CI (`protocol-enforce.yml`) re-implements ~8 gates by hand. The
un-bypassable layer therefore misses ~108 protections. v2 makes closing this
*mechanical*, because the content gates and the parity check are now a callable
engine:

**Proposed CI step (not yet wired — design only):**
```yaml
- name: Protocol content gates (same engine as pre-commit)
  working-directory: app_flutter
  run: |
    # Diff the PR/push range, feed it to the SAME Dart engine the hook uses.
    BASE="${{ github.event.pull_request.base.sha || github.event.before }}"
    git diff "$BASE"...HEAD > /tmp/range.diff
    dart run tool/protocol_check.dart --diff /tmp/range.diff \
        --stuck-log knowledge/stuck_log.md
    # Non-zero exit on any ERR finding fails the job.

- name: Registry ⇄ code parity
  run: |
    # Extract HOOK_GATE_IDS from the hook and verify against the registry.
    awk '/^HOOK_GATE_IDS=/{f=1} f{print} /reg"$/{if(f)exit}' .githooks/pre-commit \
      | sed 's/HOOK_GATE_IDS=//; s/\\$//; s/"//g' | tr ' ' '\n' | grep . > /tmp/ids
    dart run app_flutter/tool/protocol_check.dart --verify-registry \
        --emitted /tmp/ids --registry protocol/gates.tsv
```
Because the engine is the single implementation, CI and the hook can never
diverge on content gates. The structure-only gates (file existence, hooksPath,
deletions) remain cheap to mirror, but the *brittle* logic — the part that
actually rotted — is shared. **Recommended as a fast follow-up, not part of this
proposal's code.**

---

## 6. Status: COMPLETE vs PROTOTYPE vs DEFERRED

**COMPLETE (built, validated):**
- `protocol/gates.tsv` — full registry, 106 real gates + `reg` (107 total),
  reconciled against the actual emitted ids; defects fixed (105→7c, 15≡83
  merged, 34/59/61/76/83/100 documented as non-enforced; 35-40 now registered).
- `app_flutter/tool/protocol_check.dart` (+ `protocol_check_selftest.dart`) —
  deterministic content engine for 20 content gates + registry parity. `bash`-
  free. 36 self-tests pass; `dart analyze` shows 0 errors/warnings.
- `app_flutter/test/protocol_check_engine_test.dart` — `flutter_test` mirror.
- `.githooks/pre-commit` (v2) — modular runner; all 106 protections + `reg`;
  `bash -n` clean; registry parity verified (107==107).
- This design doc with the full OLD→NEW mapping.

**PROTOTYPE (works, but not battle-tested end-to-end):**
- The hook's `run_content_engine` invokes `dart run` on every commit. It works
  in this environment, but a real adoption should confirm `dart run` cold-start
  latency is acceptable (a few hundred ms) or pre-compile the engine
  (`dart compile exe`) and call the binary. Logic is identical either way.
- A full live `git commit` exercising the Flutter tier was **not** run here
  (gates are off on this branch by design, and the Flutter tier is ~13 min).
  The cheap tier, the engine, and parity are all validated; the Flutter-tier
  bash was preserved verbatim from v1.

**DEFERRED (described, not built):**
- **CI wiring (§5).** Design only, per the brief ([P4]).
- **`prefer_const_constructors` / `use_raw_strings` info-lints** in the engine
  (27 `info`, 0 error/warning). Non-blocking; left for a formatting pass.
- **Porting to the live branch.** This is a proposal; adoption steps below.

---

## 7. Adoption steps (when approved)

1. Cherry-pick `protocol/gates.tsv`, `app_flutter/tool/protocol_check.dart`,
   `app_flutter/tool/protocol_check_selftest.dart`,
   `app_flutter/test/protocol_check_engine_test.dart`, and the new
   `.githooks/pre-commit` onto `claude/whats-happening-LyY9G`.
2. `cp .githooks/pre-commit .git/hooks/pre-commit` (gate 81 enforces this).
3. Replace `app_flutter/knowledge/GATE_REGISTRY.md` with a stub pointing at
   `protocol/gates.tsv` (or delete it — gate 2 does not require it).
4. (Optional, recommended) pre-compile the engine:
   `dart compile exe tool/protocol_check.dart -o tool/protocol_check` and call
   the binary from the hook to remove `dart run` cold-start.
5. (Fast follow-up) wire the two CI steps from §5.
6. Run one real `git commit` on the live branch to confirm the Flutter tier
   path; confirm `flutter test` includes `protocol_check_engine_test`.

---

## 8. Files in this proposal
- `protocol/gates.tsv` — the single source of truth.
- `.githooks/pre-commit` — modular v2 runner (replaces the 925-line monolith).
- `app_flutter/tool/protocol_check.dart` — content engine + parity + self-test.
- `app_flutter/tool/protocol_check_selftest.dart` — built-in unit tests (part).
- `app_flutter/test/protocol_check_engine_test.dart` — flutter_test mirror.
- `PROTOCOL_V2.md` — this document.
