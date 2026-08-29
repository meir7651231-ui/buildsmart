# Dimension 6 — Reliability & Verification, built RIGHT

> The crux. Every other layer is worthless if the gate says GREEN when the bug is still live.
> This document specifies the **verification layer as mechanism, not prose.** Wherever the old
> system said "trust the bytes + tests" as a *rule*, this says *which program runs, what it reads,
> what exit code it emits, and why it cannot be skipped.*

The single question this layer must answer mechanically:

> **Did the edit FIX the bug, or did it merely CONTAIN the token?**

`grep "fixed"` proving a string exists is the failure mode the whole lesson turns on: a fixer can
rename the buggy logic, satisfy the byte-check, and ship a live bug under a green gate. The answer is
not a better rule. It is a **gate pipeline** in which a byte-check and a *behavior-check that is
provably aimed at the changed lines* are composed into one exit code, fired by a hook that an agent
with a shell cannot route around.

---

## 0. Threat model — what a "passing" verify must survive

These are the concrete ways a green result lies. Every mechanism below maps to one or more.

| # | Attack on the verify | Old system's defense | Why prose failed |
|---|---|---|---|
| T1 | **Token-not-fix**: fixer renames buggy logic; grep for new marker passes; bug still live. | PLAYBOOK §4b prose: "pair each fix with the test." | A rule the orchestrator must *remember* to honor. No program enforces the pairing. |
| T2 | **Uncovered fix**: the changed line is executed by *no test*; suite is green because it never runs the new code. | Step 5 prose: "if a fix touches code with no coverage, add a test or record the gap." | Self-issued, unmeasured. Nothing computes which changed lines are covered. |
| T3 | **Scope miss**: tests pass but run a target/dir that excludes the changed file (6.3 scope-targeting trap). | central-verify prints `gate target` + HEAD. | Printing is not asserting. The orchestrator can read past a wrong target. |
| T4 | **Test-validity / tautology**: a test that cannot fail under the bug (asserts the wrong thing) goes green (6.2 test-validity trap). | none. | No rule can detect a test that doesn't exercise the claim. |
| T5 | **Test-edited-to-green**: fixer (or orchestrator) weakens/deletes the assertion that was failing. | PLAYBOOK: "only when the OLD assertion was proven wrong." | A judgment call with no artifact. The diff to `test/` is invisible to the gate. |
| T6 | **Stale green**: a GREEN captured at SHA *A* is cited to ship SHA *B* (6.5 staleness). | "run immediately before the action." | "Immediately" is unmeasured wall-clock trust. |
| T7 | **Skip-the-gate**: agent runs the push directly (`git push`), never invoking central-verify. | central-verify is "THE GATE" by convention. | A convention is one `git push` away from bypass. The gate isn't *in the path* of the push. |
| T8 | **Flake**: nondeterministic test flips GREEN/RED; a lucky GREEN ships (6.6 flaky protocol). | prose protocol. | Nothing detects or quarantines the flip. |
| T9 | **Silent-zero**: a misconfigured runner exits 0 having run nothing (6.3 tool-misconfiguration). | central-verify trusts analyze exit code. | Exit 0 with 0 tests collected is still 0. Nobody asserts a *floor* on tests run. |

The design's job: make T1–T9 each fail **loud and automatically**, or be **explicitly quarantined with a human signature** — never silently green.

---

## 1. Architecture — the gate pipeline and what each stage proves

The verify layer is a single composed program, **`verify-gate.sh`**, that runs **N stages in fixed order, short-circuiting on the first non-zero**, and emits ONE artifact: a signed **verdict file**. Nothing downstream (push, deploy, "done" report) reads anything *except* that verdict file, and the verdict file is bound to a commit SHA so it cannot be reused for a different state (T6).

```
            ┌───────────────────────── verify-gate.sh <APP> <BASE_SHA> ─────────────────────────┐
            │                                                                                    │
 changed    │  S0 SCOPE      S1 BYTES      S2 BUILD      S3 TEST          S4 DIFF-COV   S5 TEST-  │
 files  ──► │  fingerprint   grep-verify   analyze +     run suite,       map changed   VALIDITY  │ ──► verdict.json
 (git diff) │  assert        present/      compile       assert FLOOR     lines → tests  mutate    │     (sha-bound,
            │  target==diff  absent        artifact      on tests-run     fail if a      changed   │      signed)
            │     │             │             │             │             changed line     line,    │
            │   T3,T9         T1 (content)  build break   T9 silent-zero  is uncovered    expect    │
            │                                                              T1,T2          RED  T4   │
            └────────────────────────────────────────────────────────────────────────────────────┘
                    every stage writes its own line to verdict.json.stages[]; ANY fail ⇒ verdict=FAIL
```

**What each stage PROVES (and the trap it kills):**

- **S0 — Scope fingerprint (kills T3, half of T9).** Assert, not print. The gate is handed `BASE_SHA`; it computes `git diff --name-only BASE_SHA..HEAD` = the **changed set**. It confirms (a) `$APP/pubspec.yaml` exists (stack match), (b) every changed `*.dart` under `lib/` lives inside `$APP` (the test target's source root), (c) HEAD is clean (no un-committed drift). If a changed source file is *outside* the area the test command will execute, the gate FAILS here — a green test result for the wrong scope can never be reached. The changed set is written into the verdict so every later stage is measured against *this exact list*.

- **S1 — Byte-check (kills T1 at the content level).** `grep-verify.sh` over the orchestrator's `present/absent` claims: new marker present (count ≥ 1), old buggy string gone (count 0), file exists. This is **necessary but explicitly insufficient** — it proves the token is *there*, never that it *works*. S1 exists so that a fix which isn't even physically present fails *cheaply* before we spend minutes building. (Reuses the existing, already-hardened `grep-verify.sh` verbatim.)

- **S2 — Build/analyze (kills build-break, half of T9).** `flutter pub get` (no swallow) → `flutter analyze` (assert **exit 0 AND zero `error •` lines** — both, per the existing hardening) → `flutter build web --release` (artifact compiles). Proves the changed bytes form a buildable program. Reuses central-verify's hardened blocks.

- **S3 — Test suite + run-floor (kills T9 silent-zero).** Run `flutter test --coverage --reporter=json`, parse the JSON event stream, assert: exit 0, **AND `testCount ≥ FLOOR`** where FLOOR is the test count recorded at the *base* SHA (a runner that collects 0 tests and exits 0 fails here — a green with fewer tests than the baseline is a regression in the *verifier itself*). Emits `coverage/lcov.info` as the input to S4. This is the **behavior-truth** stage: tests beat grep when they disagree.

- **S4 — Diff-coverage pairing (kills T2, and T1 at the behavior level — THE crux mechanism).** This is the stage the old system never had. It answers "does a test actually *execute* the changed line?" Detailed in §2.1. In one line: **map every changed executable line to the set of tests that cover it; FAIL if any changed executable line is covered by zero tests.** A fix on a line no test runs is, by construction, unproven — and the gate refuses to call unproven "GREEN."

- **S5 — Test-validity / mutation spot-check (kills T4, the deepest trap).** Coverage proves a test *executed* the line; it does **not** prove the test would *fail* if the line were wrong (a tautological assertion executes the line and still can't catch the bug). S5 closes the residual gap with a **targeted mutation probe**: for each changed line that S4 marked covered, mutate it (negate the boolean / bump the constant / swap the operator) and re-run *only the covering tests*; if they still pass, the "covering" test is a tautology and the gate FAILS with `TEST-INEFFECTIVE: <file:line> survived mutation`. Detailed in §2.2. This is the only stage that is *probabilistic* (see §3) — it is run as a **bounded** spot-check, and its limits are stated honestly rather than hidden.

The verdict file is the **sole currency** (§2.3): push and deploy stages read `verdict.json`, check `verdict==PASS` **and** `verdict.head==<sha being pushed>`, or they refuse. This is how T6 (stale green) dies — a verdict is meaningless except for the exact SHA it was computed on.

---

## 2. MECHANISMS — concrete, with the real tools named

For each, I state explicitly: **shell/config change** vs **real tooling build**.

### 2.1 Diff-coverage pairing — the "fix, not token" engine (S4)

**This is the #1 mechanism. It is real engineering, not a rule.** It composes three real tools:

1. **`flutter test --coverage`** (already in the toolchain — Flutter 3.29.3 verified present) writes `coverage/lcov.info` in **LCOV format**: per-source-file `DA:<line>,<hitcount>` records — exactly which executable lines ran, and how many times. (Verified: this is the standard Flutter coverage output.)
2. **`git diff --unified=0 BASE_SHA..HEAD`** — the authoritative changed-line set (per file, per line number), generated by the gate itself from the SHA it was handed in S0. `--unified=0` so only truly-changed lines count, not context.
3. **`diff-cover`** (`Bachmann1234/diff_cover`, on PyPI — a real, maintained tool; verified it ingests **LCOV** and `git diff`, and supports `--fail-under=N` returning non-zero below threshold). It intersects (1)×(2) and reports the **coverage of changed lines only**.

The gate stage:

```bash
# S4 — diff-coverage. FAIL if any changed executable line is uncovered.
diff-cover coverage/lcov.info \
    --compare-branch "$BASE_SHA" \
    --fail-under=100 \
    --format json:diff-cov.json --format markdown:diff-cov.md
dc=$?
# 100 = every CHANGED executable line was hit by >=1 test. Below ⇒ a fix landed on dead-to-tests code.
if [ "$dc" -ne 0 ]; then
  echo "GATE FAIL S4: changed lines not covered by any test:"
  jq -r '.src_stats[].violation_lines[]?' diff-cov.json   # the exact file:line a fixer must cover
  exit 1
fi
```

- **Why `--fail-under=100`, not 80:** this is a *polish-ship* of a small, validated diff (the PLAYBOOK's whole domain), not a sprawling feature branch. The threshold is over **changed lines only**, not the whole repo — demanding 100% of *a handful of edited lines* is reasonable and is exactly the T2 guarantee: *no changed line escapes a test.* A repo-wide 100% would be absurd; a diff-scoped 100% is the bar.
- **The honest gap diff-cover itself has (designed-around):** coverage tools list *executable statements*, not every textual line — blank lines, `}`, comments, and pure type declarations have no `DA:` record and are correctly ignored. diff-cover's own docs note it "does not report lines that appear in one and not the other." That's *correct* behavior, but it creates a **silent-pass hole**: a change consisting *only* of non-executable lines would yield "0 changed lines measured → 100% → pass" while exercising nothing. The gate plugs this: S4 first computes `MEASURABLE = (changed lines) ∩ (lines with a DA: record in lcov)`. If a changed `lib/**.dart` file has **edited executable lines but `MEASURABLE==0` for it**, that is `COVERAGE-UNMEASURABLE: <file>` → FAIL (not pass). A change that is genuinely only-comments/whitespace is allowed only if S1 also shows no behavioral marker — i.e. it is honestly a non-behavioral edit.
- **Build type:** **real tooling** — `diff-cover` is `pip install`'d into the gate's environment (build-order item B2); `jq` for JSON parsing is a package install. The *wiring* (the S4 block, the MEASURABLE intersection, the verdict emission) is shell. The coverage data generation is a one-flag change to the existing test command (`--coverage`).

**What S4 proves that grep cannot:** grep proves the string `if (qty > 0)` is in the file. S4 proves a test *ran that line*. Together with S5, the chain becomes: the line exists (S1) → it compiles (S2) → the suite is green and ran ≥FLOOR tests (S3) → **a test executed this exact changed line** (S4) → **that test would go red if this line were wrong** (S5). Only the conjunction earns "FIXED."

### 2.2 Mutation spot-check — proving the covering test isn't a tautology (S5)

Coverage (S4) has a known blind spot, stated plainly: a test can *execute* a line and still assert nothing meaningful about it (T4). S5 is the mechanism that distinguishes "executed" from "actually checked," bounded so it stays affordable.

For each `file:line` in S4's MEASURABLE-covered set (typically a handful — only the changed lines):

```
for L in changed_covered_lines:
    save original
    apply ONE deterministic mutation by node kind:
        boolean cond  → wrap in `!( … )`
        numeric const → `+1`
        `==`↔`!=`, `>`↔`<=`, `&&`↔`||`, `+`↔`-`
        return X       → return a sentinel of X's type
    run ONLY the tests diff-cover attributed to L  (targeted, fast)
    if those tests still PASS:  record SURVIVED  (the test is a tautology for this line)
    restore original
verdict: any SURVIVED ⇒ GATE FAIL  "TEST-INEFFECTIVE: file:line"
```

- **Why only the covering tests, only the changed lines:** full-program mutation testing is too slow for a per-push gate (minutes→hours). Scoping mutations to *changed lines* and running *only their covering tests* makes it a seconds-to-low-minutes spot-check — affordable on every push. This is the deliberate engineering trade: not "is the whole suite strong," but "is the test that supposedly proves *this fix* actually able to catch a regression in *this fix*."
- **Tooling reality:** Dart/Flutter mutation tooling exists (e.g. the `mutation_test` package) but is less battle-hardened than the rest of the chain. Therefore S5 ships in two stages: **S5a** = a small in-house mutator that handles the four high-value mutation kinds above against the specific changed lines (real tooling we build — a few hundred lines of Dart/AST or even line-regex for the constant/operator cases), gated behind a `STRICT=1` flag; **S5b** = swap in a maintained mutation engine when one proves stable on this repo. S5 is **advisory→blocking by config**: default it runs and reports `SURVIVED` as a warning in the verdict; with `STRICT=1` (the factory's Tier-0 default for production ships) a survivor is a hard FAIL.
- **Honest scope (see §3):** S5 raises the cost of a tautological test from zero to "must survive these N mutations"; it does **not** prove the test is *complete*. It is a floor on test *effectiveness for the changed line*, not a ceiling on correctness. Stated, not hidden.

### 2.3 The verdict file — sole currency, SHA-bound (kills T6)

The gate's only output anyone trusts. JSON, written atomically last:

```json
{ "verdict": "PASS",
  "app": "/abs/app_flutter",
  "head": "9f3c1a2…",            // full SHA the gate ran on
  "base": "1b2d…",
  "changed_files": ["lib/cart/qty.dart"],
  "stages": [
    {"id":"S0","name":"scope","status":"PASS","detail":"target==diff, tree clean"},
    {"id":"S1","name":"bytes","status":"PASS","detail":"3 present, 1 absent"},
    {"id":"S2","name":"build","status":"PASS","detail":"analyze 0 err · web build ok"},
    {"id":"S3","name":"test","status":"PASS","detail":"142/142, floor=140 ok"},
    {"id":"S4","name":"diff-cov","status":"PASS","detail":"changed-line cov 100% (7/7 measurable)"},
    {"id":"S5","name":"mutation","status":"PASS","detail":"7 lines, 0 survived (STRICT)"}
  ],
  "ts": "2026-06-05T…Z",
  "sig": "hmac-sha256(head ‖ verdict ‖ stages, KEY)" }
```

- `sig` is an **HMAC over the content keyed by a secret the verify environment holds** (CI secret / runner-only env). The push hook (§2.4) recomputes the HMAC and rejects any verdict whose signature doesn't verify — so an agent **cannot hand-write a `PASS` verdict** with a shell `echo`. It can run the gate (which signs), but cannot forge the gate's signature. (This is the structural fix for the v2 lesson that `ALLOW_PROTECTED=1`'s "human-only" was *just a comment* — here the boundary is a key the agent doesn't have, not a sentence asking it to behave.)
- `head` binds the verdict to one SHA. A verdict for SHA A presented to push SHA B fails the equality check in §2.4. T6 dead.

### 2.4 The un-skippable gate — a hook in the push path, not a "hard rule" (kills T7)

The lesson: a gate that is *convention* is one `git push` away from bypass. So the gate is moved **into the only path that can ship**, two layers, defense in depth:

**Layer A — server-side `pre-receive` hook (the boundary the agent cannot reach).**
On the git server / GitHub branch protection, a `pre-receive` (or required-status-check) rejects any push whose tip commit does not have a **valid, matching, PASS verdict**. Mechanism on GitHub: branch protection **Require status checks to pass** + the verify-gate runs as the **required CI check**; the merge API physically refuses a PR whose required check isn't green. The agent has a shell *in its own worktree*, but it does **not** administer the server's branch protection — that's a permission boundary owned by a human/org admin, exactly where a real boundary belongs. This is the structural answer to T7: even a fully bypassed local environment cannot land code the server's required check hasn't passed.

**Layer B — local `pre-push` hook (fast fail, and covers non-PR pushes).**
A repo `pre-push` hook (installed via `core.hooksPath` pointing at a version-controlled `.githooks/`) runs:

```bash
# .githooks/pre-push  — refuses to push a SHA without a fresh, valid, matching PASS verdict.
read local_ref local_sha remote_ref remote_sha
v=.verify/verdict.json
[ -f "$v" ] || { echo "PUSH REFUSED: no verdict — run verify-gate.sh"; exit 1; }
# 1) signature must verify with the runner key (an agent cannot forge PASS)
verify-sig "$v" || { echo "PUSH REFUSED: verdict signature invalid (hand-edited?)"; exit 1; }
# 2) verdict must be for THIS exact sha (kills stale-green T6)
[ "$(jq -r .head "$v")" = "$local_sha" ] || { echo "PUSH REFUSED: verdict is for $(jq -r .head "$v"), pushing $local_sha"; exit 1; }
[ "$(jq -r .verdict "$v")" = "PASS" ]   || { echo "PUSH REFUSED: verdict=$(jq -r .verdict "$v")"; exit 1; }
exec ff-push-core "$@"   # only now the existing ff-push divergence/default-branch guards run
```

- **`ff-push.sh`'s `ALLOW_PROTECTED=1` hole is fixed structurally**, not by a stern comment: pushing a *protected* branch is gated by **Layer A's branch protection** (server-owned), so even with `ALLOW_PROTECTED=1` set locally, the server's required-check + protection still refuse a non-verified or non-approved push. The env override stops being a "please don't" and becomes "you may try; the server still says no." The local guard remains as a fast, honest first refusal.
- **Build type:** Layer A is **config** (branch protection + a required-check definition in CI YAML — items B4/B5). Layer B is a **shell hook** committed to `.githooks/` + a one-time `git config core.hooksPath .githooks` (B3). `verify-sig` is a 10-line HMAC checker (B2).
- **Can the agent disable the hook?** Locally, `core.hooksPath` is editable by anyone with the shell — so **Layer B is not the security boundary; Layer A is.** Layer B's value is fast local feedback + catching honest mistakes; Layer A (server-side, human-administered) is the boundary that holds when the local env is hostile. This is the honest split: *the un-bypassable gate lives where the agent has no permissions.*

### 2.5 Test-edit guard — you may not silently weaken a test (kills T5)

A fixer is already forbidden to touch `test/`; the orchestrator owns test updates. Mechanism, not honor system:

- S0 computes the changed set. If it includes any path under `test/`, the gate requires a **paired justification record** `.verify/test-changes.json` listing each touched test with one of: `{NEW_TEST}` (added coverage — always allowed), `{ASSERTION_CORRECTED, old_assert, new_assert, reason}` (allowed), `{WEAKENED|DELETED}` (allowed **only** with `human_approver` field present + a matching entry in a human-signed approvals file).
- The gate cross-checks: for every `WEAKENED|DELETED` test change, the `human_approver` must appear in `.verify/approvals.sig` (a file only a human-held key signs — same HMAC trick, **different key** from the runner key, so the *gate itself* can't self-approve a weakening). No record, or self-issued approval ⇒ `GATE FAIL S0: test weakened without human approval`. This is the mechanical form of "the agent does not get to declare its own failures out-of-scope" (6.9).
- **Build type:** shell + the same HMAC verifier, second key. The approvals key lives only with the human/Tier-0, mirroring the §2.4 permission split.

### 2.6 Flake detection — quarantine, don't coin-flip (kills T8)

- S3 runs the suite **twice** when `STRICT=1` (or always, if cheap). Any test whose result differs between identical runs is written to `verdict.stages[S3].flaky[]` and the verdict becomes `FAIL` with reason `FLAKY` (not PASS, not "70% pass"). A flaky test is an *unstable environment*, which by 6.6 is UNVERIFIED, which is FAIL for shipping.
- A flaky test may be **quarantined** only via the same human-approval record as §2.5 (it does not get to silently pass). Quarantine moves it out of the FLOOR count *and* records it, so the FLOOR can't be gamed by quarantining real tests.
- **Build type:** shell (re-run + set-diff of JSON test results) — no new tooling.

---

## 3. Honest limits — what verification fundamentally CANNOT prove, and how this design contains it

Stated plainly, because pretending otherwise is itself the reliability defect this dimension exists to kill. Each limit gets a **containment** so it fails safe, not silently.

1. **Specification correctness is undecidable by the gate.** The gate proves the code does *what the tests say*. It cannot prove the *tests say the right thing* — if the spec itself is wrong (the intended behavior is misunderstood), a green gate ships a faithfully-implemented wrong feature. **Contained by:** this is precisely why the architecture keeps the **adversarial validator** (CONFIRMED is a *static human-judgment-adjacent* claim) and **human authorization at the push point** in the loop. The gate's verdict is necessary, never sufficient, for "correct" — only for "consistent + covered + non-tautological." The verdict file says exactly that and no more (it claims `PASS`, never `CORRECT`).

2. **Mutation (S5) is a sampler, not a prover.** S5 raises the cost of a tautological test but cannot enumerate all ways a test is weak; a test can survive the four mutation kinds and still miss a subtler bug. **Contained by:** S5 is scoped and *labeled probabilistic* in the verdict (`mutation: 7 lines, 0 survived` — a sample size, not a proof). It strictly *adds* assurance over the old system (which had none) and never *subtracts* — a PASS at S5 never overrides a FAIL elsewhere. We state its sample, not a guarantee.

3. **The runtime ceiling — flattened, not nested.** Verified: in Claude Code a sub-agent cannot spawn sub-agents (`NESTING_SUPPORTED=no`); the per-fleet `supervisor`'s "objective verify" is, in flattened mode, executed by the one orchestrator. So the *independence* of the verifier from the doer is **organizational, not enforced by process isolation** in this runtime. **Contained by:** the gate is a **separate program with its own exit code and an HMAC the orchestrator can't forge** — so even when the same agent runs both the fix and the gate, it cannot make the gate *say* PASS without the gate actually passing. The independence that matters (the verdict can't be faked) is mechanical; only the *spawning topology* is flattened. On the Agent SDK runtime the supervisor becomes a distinct process and even the *execution* of the verify is isolated — the design ports up cleanly (same gate, run by a different node).

4. **The model capability ceiling (the v1→v6 lesson).** No amount of gate can make the underlying model *write* a correct fix; the gate can only refuse to *ship* an unproven one. Adding more verify stages has diminishing returns and eventually just churns. **Contained by:** the gate's role is explicitly **bounded to refusal, not generation** — it converts "the model might be wrong" into "a wrong fix cannot pass silently; it stalls loudly at a named stage." That is the honest maximum: prompts/gates *approach* reliability by making failure visible and un-shippable; they never transcend the model that writes the code. When the model genuinely cannot produce a covered, mutation-surviving fix, the correct gate outcome is a **loud STALL with the exact failing `file:line`** handed up the pipe — not a lowered bar.

5. **Coverage ≠ exhaustive paths.** 100% changed-line coverage means each changed line ran ≥ once, not that every input/branch combination ran. A line can be covered on its happy path and buggy on an edge. **Contained by:** S4 reports line coverage honestly (it never claims branch/path coverage); S5's mutation probe partially compensates by checking the covering test actually constrains the line's behavior; remaining edge-case risk is surfaced to the validator/human, not swallowed. The verdict never inflates "line covered" into "behavior exhausted."

6. **`pre-push` (Layer B) is locally disable-able.** An agent with the shell can edit `core.hooksPath`. **Contained by:** the *real* boundary is **Layer A (server-side required check + branch protection), administered by a human/org — a permission the agent does not hold.** Layer B is convenience + honest-mistake catching; the design never claims Layer B as the security boundary. This is the explicit, honest split that the old `ALLOW_PROTECTED` comment pretended away.

**The meta-limit, stated:** verification can guarantee *"no unproven change ships silently."* It cannot guarantee *"every shipped change is correct."* The gap between those two is exactly where human judgment and the validator live. The design's honesty is that it draws that line **in mechanism** (what the gate signs for) rather than blurring it in prose.

---

## 4. Build order — highest safety/leverage first, with dependencies

Ordered so that at every step the system is *strictly safer than before*, and nothing depends on a later item.

| # | Build | Type | Kills | Depends on | Why this order |
|---|---|---|---|---|---|
| **B0** | **`verify-gate.sh` skeleton**: S0 scope-assert + S1 (wrap existing `grep-verify.sh`) + S2/S3 (lift central-verify's hardened analyze/build/test blocks) + emit **unsigned** `verdict.json`. | shell | T3, T9, build-break | existing scripts | Immediately replaces ad-hoc "trust the bytes" with one composed exit code + a target assertion. Highest leverage, lowest cost — reuses what's already hardened. |
| **B1** | **S3 run-floor**: parse `flutter test --reporter=json`, assert `testCount ≥ baseline`. Record baseline per branch. | shell + jq | T9 silent-zero | B0 | Tiny add; closes the "0 tests, exit 0" hole that would undermine every later stage. |
| **B2** | **Signing + `verify-sig`**: HMAC the verdict with a runner-only key; 10-line verifier. | real (small) tool | enables T6/T7 fixes | B0 | The verdict must be unforgeable *before* anything trusts it. Prereq for B3/B5. |
| **B3** | **Layer B `pre-push` hook** in `.githooks/` + `core.hooksPath`; checks sig + `head==sha` + `verdict==PASS`, then `exec`s the existing `ff-push` core. | shell hook + config | T6 (local), fast T7 | B2 | First *un-skippable-by-honest-paths* gate; instant local feedback. Not yet the hard boundary (that's B5). |
| **B4** | **CI job** running `verify-gate.sh` on every push/PR, uploading `verdict.json` + `diff-cov.md` as the check output. | config (CI YAML) | enables B5 | B0–B2 | Moves the gate to a machine the agent doesn't fully control; surfaces the verdict on the PR. |
| **B5** | **Layer A: branch protection** = require the B4 check; protected/default branches require it + human approval. | config (server) | T7 (the real boundary), protected-push | B4 | The boundary that holds when the local env is hostile. Now `ALLOW_PROTECTED`'s comment is irrelevant — the server refuses. |
| **B6** | **S4 diff-coverage**: add `--coverage` to S3's test run; `pip install diff-cover`; S4 block with `--fail-under=100` over changed lines + the MEASURABLE-intersection plug. | real tooling | **T1 (behavior), T2** | B0, B1 | **The crux mechanism** — but sequenced after the gate is unforgeable and un-skippable, so the moment it can FAIL, that FAIL actually blocks a ship. |
| **B7** | **S5a mutation spot-check**: in-house mutator for the 4 mutation kinds over changed-covered lines; run covering tests; `STRICT=1` ⇒ survivor = FAIL. | real (small) tool | T4 | B6 (needs S4's covered-line map) | Deepest trap, highest build cost, depends on S4's line→test map. Ships advisory first, then `STRICT`. |
| **B8** | **Test-edit guard (S0+)** + **flake detection (S3+)**: justification/approval records with a *second*, human-held HMAC key; double-run flake set-diff. | shell + 2nd key | T5, T8 | B2 (HMAC), B0 | Rounds out the residual lies once the spine (B0–B7) is solid. The human-key split mirrors B5's permission boundary. |
| **B9** | **S5b**: swap in a maintained mutation engine when proven stable on this repo; keep S5a as fallback. | real tooling | hardens T4 | B7 | Last — an optimization of an already-working stage. |

**Critical path to "a fix that only contains the token cannot ship":** B0 → B1 → B2 → B6 (diff-coverage with a signed, floored, scope-asserted gate). After **B6** the central promise holds mechanically: *a change on a line no test executes FAILS the gate, and that FAIL cannot be forged (B2) or skipped on a PR (B4/B5).* **B7** then upgrades "a test ran the line" to "a test that would catch the line being wrong." Everything after B6 is depth, not the spine.

---

## 5. How this maps back to the lesson

- **Prose → mechanism, line by line:** "pair each fix with the test" (T1) became **S4 diff-coverage + S5 mutation**, an exit code. "run the gate before pushing" (T7) became **a required server-side check (Layer A) + a signed verdict the push path reads**. "human-only override" (the `ALLOW_PROTECTED` comment) became **a permission boundary the agent doesn't hold** (branch protection) + **an HMAC key the agent can't forge**. "record the gap as accepted risk" (T2/T5/T8) became **human-key-signed approval records** the gate cross-checks. A named hole is no longer a hole — it is a stage that exits non-zero.
- **No new contradictions:** the gate is **one** program with **one** ordered pipeline and **one** signed output; push/deploy read only that. There is no second "rule" that can disagree with the script, because the script *is* the rule — and the only prose left ("PASS ≠ CORRECT") is a *limit statement*, deliberately not an enforcement claim.
- **The ceiling, owned:** where mechanism stops (spec correctness, model capability, mutation sampling, local-hook editability), the design says so in §3 and **contains each by failing loud/needing a human key**, never by quietly trusting. That honesty is the dimension.
