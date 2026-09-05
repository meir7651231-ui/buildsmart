# Protocol v10 — close the two code-fixable holes 8 passes missed

The robustness re-audit found TWO real, code-fixable security holes that survived
v2→v9. v10 closes BOTH airtight, with HONEST tests asserting the exact proven
vectors and security counter-cases. Everything that remains is the WALL (branch
protection / CODEOWNERS / deployment), which the user owns.

---

## V10-A — ReDoS / self-DoS in the stuck_log antipattern matcher (P0)

**The hole.** `gateAntipatternRecurrence` (gate 103) and the generated
`test/stuck_regression_test.dart` both compiled a regex straight from
`knowledge/stuck_log.md` (`RegExp(ap.pattern)`) and ran `hasMatch` over content
using Dart's **backtracking** RegExp with NO timeout. PROVEN: a single committed
line `ANTIPATTERN: (a+)+$` plus a ~35–40-char repeated run in a staged `lib/`
line makes `hasMatch` **hang forever** (28 chars ≈ 7s, doubling per char). One
poisoned stuck_log line would brick every future commit (the hook) AND burn CI
`flutter test` forever.

**The fix — three independent guards (defense in depth):**

1. **Reject catastrophic patterns at parse** (`antipatternCatastrophicReason` in
   `parseAntipatterns`). A pattern with a nested quantifier (`(…+)+`, `(…*)*`,
   `(…+)*`, a quantified group with an inner quantifier) or a large repetition
   bound (`{N}`/`{N,}`/`{N,M}` with N or M ≥ 100) is **skipped** — never stored,
   never compiled, never run. The proven `(a+)+$` vector dies here instantly.
2. **Cap input length** at `kAntipatternMaxLineLen` (2 KB). No line longer than
   that is ever fed to the backtracking matcher — caps the state-space blowup.
3. **Hard wall-clock budget** (`boundedAnyMatch`, `kAntipatternMatchBudget` =
   500 ms). Every surviving pattern's whole scan runs in a **throwaway isolate**;
   if it exceeds the budget the isolate is **killed**, the match is treated as
   "did not match", and a WARN names the offending pattern. The engine NEVER
   hangs. Cost is ONE isolate spawn **per pattern** (≈ #antipatterns), not per
   line — a per-line spawn made the generated test O(patterns×lines) and time
   out, so the matcher scans all lines for a pattern inside one budgeted isolate.

The sync `gateAntipatternRecurrence` (used by the self-test + the runtime canary,
which must stay synchronous for K3 parity) is protected by guards 1+2 — already
enough to make the proven vector return instantly. The PRODUCTION callers
(`_mainDiff`/`_mainTree`, now async) use `gateAntipatternRecurrenceBounded`,
which adds guard 3. The generated test mirrors all three (`_isCatastrophic` +
`_boundedAnyMatch` + 2 KB cap) so `flutter test` can never hang.

**Proof (engine, the real `--diff` codepath):**
- `ANTIPATTERN: (a+)+$` + a 40-char run → **RC 0 in 0.80 s** (was an infinite
  hang); emits `WARN 103 antipattern pattern REJECTED (unsafe regex: nested
  quantifier …)`.
- A pattern that SLIPS the static detector (`a?·30 a·30`, no nested group, no
  large `{N}`, but still ReDoS-hangs raw Dart) → **RC 0 in 1.36 s**; emits
  `WARN 103 antipattern scan TIMED OUT (>500ms, killed)` — guard 3 caught it.
- A legit antipattern still **ERR (RC 2)**; a no-match legit pattern stays RC 0.

**Proof (`flutter test` of the generated test):**
- A stuck_log with `(a+)+$` → the generated suite runs to completion in ~3 s,
  ALL PASS (guard 2 skips the poison pattern).
- A stuck_log with the slip pattern → the suite finishes in ~10 s and the slip
  test FAILS LOUDLY with `regex TIMED OUT — possible ReDoS; rewrite it` (guard 3)
  instead of hanging CI forever.
- The clean, regenerated real `stuck_regression_test.dart` → **64/64 GREEN**.

---

## V10-B — whole-tree scan skips submodule / symlink / LFS content (P0)

**The hole.** The K1/K5 whole-tree scan ran `git ls-tree -r --name-only HEAD`
→ engine `--tree`. That feed is mode-blind, so the scan SKIPPED forbidden
content in three places while H3 `fed==scanned` reconciliation FALSELY passed
(RC 0):
- **(A) Submodules** — `ls-tree -r` emits a `160000` gitlink and never recurses,
  so a secret inside the submodule is never fetched (`git show HEAD:sub/...`
  fails from the parent).
- **(B) `.dart` symlinks** — `git show HEAD:link` returns the link-**target
  text**, not the real content; a `lib/aliased.dart` symlink was "scanned" as
  harmless link text while its true target was never fetched.
- **(C) git-LFS-tracked files** — `git show` (and the smudge-filtered per-commit
  diff) return the LFS **pointer**, not the content; a secret in an LFS file
  shipped invisibly.

All three were reproduced at `TREE_RC=0` against the OLD `--name-only` feed.

**The fix.** The workflows now feed `git ls-tree -r HEAD` **WITH the mode column**
(drop `--name-only`) via a new engine flag `--tree-entries`. `parseTreeEntries`
reads `<mode> <type> <sha>\t<path>`, so the engine can SEE `120000`/`160000`:
- **Gitlinks (160000 / type commit):** folded into the H3 `fed` set and FAIL
  CLOSED (RC 3) unless explicitly allowlisted with `--allow-gitlink <path>` (the
  admin escape hatch; an allowlisted submodule is counted as accounted-for with a
  WARN, to be scanned out-of-band via `git submodule foreach`). An unparseable
  ls-tree row also fails closed (it could hide a gitlink/symlink).
- **Symlinks (120000):** the link target is read; if the symlink has a scannable
  name (`.dart`/…) or aliases scannable content (`symlinkIsDangerous`) it is
  REJECTED (folded into `fed`, RC 3). A benign non-scannable symlink (e.g.
  `README.md → …`) is legitimately skipped — no false positive.
- **LFS pointers:** any scannable blob whose content carries the pointer
  signature (`git-lfs.github.com/spec` + `oid sha256:<64 hex>`,
  `looksLikeLfsPointer`) is REJECTED (RC 3). This works even in legacy
  `--names` mode (content-signature, no mode needed) — defense in depth for the
  smudge-blind per-commit path.

Applied in BOTH `protocol-enforce.yml` (K1) and `deploy.yml` (K5). A focused
per-commit gate (`gate_tree_modes` in `.githooks/pre-commit`, under the existing
`reg` umbrella id — no new gate row, so registry⇄runtime parity is untouched)
blocks the same three vectors locally via `git diff --cached --raw` (which exposes
the staged mode column) so a dev never even creates such a commit.

**Proof (engine `--tree` over fixtures):**
- Secret in a submodule → **RC 3 FAIL CLOSED**, `fed=2 scanned=1` (was RC 0,
  `fed==scanned==1` false pass). `--allow-gitlink` → RC 0 (accounted-for).
- `.dart` symlink → **RC 3 FAIL CLOSED** (`120000 SYMLINK -> "…" masquerading as
  scannable content`). Benign `md→md` symlink → RC 0 (no false positive).
- LFS pointer `.dart` → **RC 3 FAIL CLOSED**, also caught in legacy `--names`
  mode.
- Per-commit `gate_tree_modes`: gitlink / symlink / LFS each block; a clean
  normal commit does not fire.

---

## V10-C — buildability polish (P2, done safely)

The audit noted over-reach: a pure-DATA add to `lib/data/*catalog.dart` wrongly
tripped gate 42 ("new public symbol without test"). v10 makes gate 42 exempt a
top-level `const`/`final` whose RHS is a DATA literal (`[ { < " ' ` or a number)
**only** under `lib/data/` and **only** when it is not a function (no `=>`, no
`(…) {` body, no `Function` type). A function/class/method/getter — or a
logic-valued const, or any symbol under `lib/logic`/`lib/state` — STILL demands a
test. The mutation_log over-reach (gate 44) was already fixed by v8's
`_staged_helper_adds_logic` (pure-data changes inject no fault → no demand).
The multi-file-rename retry-cascade (gates 24/44/59/102) was left as **deferred**:
unwinding it touches the retry-trap machinery and risked the security floor with
no security benefit — out of scope for a P0 security pass.

**Proof:** a pure-data catalog const in `lib/data/` → gate 42 silent; a function
in `lib/data/`, an arrow-const in `lib/data/`, and a const in `lib/logic/` all
still fire gate 42.

---

## Validation summary

- `dart analyze` (engine + selftest + test mirror): **0 errors / 0 warnings**.
- engine `--self-test`: **ALL PASS (v10)** — adds 24 V10 cases (guards 1+2,
  parseTreeEntries, LFS/symlink detectors, sync gate-103 no-regression).
- `flutter test test/protocol_check_engine_test.dart`: **63/63 GREEN** — includes
  async tests that prove guard 3's wall-clock kill IN the `flutter test` harness.
  (Also corrected 2 stale v7-era WARN expectations that v9 made ERR.)
- `flutter test test/stuck_regression_test.dart` (regenerated, clean):
  **64/64 GREEN** in ~9 s.
- `protocol/regression_v10.sh --self-test`: **26/26 PASS** — both holes proven
  closed end-to-end, with the "old path falsely passes" proof, timing assertions,
  and no-false-positive counter-cases.
- whole-tree over the LIVE tree with the new `--tree-entries` path: **byte-
  identical** to the old `--names` path (zero new false-positive; the app_flutter-
  scoped K1 baseline stays RC 0 / `fed==scanned`). NOTE: a repo-ROOT scan trips a
  PRE-EXISTING gate-52 finding on the bundled `index.html` catalog — present in
  v9 too, identical OLD vs NEW, out of v10 scope.
- `gates.tsv` UNCHANGED → registry⇄runtime parity untouched (the new hook gate
  reuses the `reg` id). `protocol/pins.sha256` regenerated via
  `scripts/update_pins.sh` (15 files, all match), now pinning `regression_v10.sh`.

## Still open
**Code side: none found.** A re-audit that re-attacks ReDoS + submodule/symlink/
LFS now hits a fail-closed wall. What remains is the WALL: branch protection,
CODEOWNERS on the protocol-critical paths, and the deploy environment — the
user's half.
