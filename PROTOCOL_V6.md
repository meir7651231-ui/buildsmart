# BuildSmart Protocol — v6 (narrow hardening pass)

> v6 is a **NARROW** pass on top of v5 (`bbe5758`). The self-authentication
> trust-frontier (trusted-ref everywhere, S1 fail-closed, S3 drift, K1 whole-tree)
> was confirmed CLOSED-in-code by the v6 audit. v6 fixes the **2 CRITICAL
> mechanical bypasses of the whole-tree scan** (H1 non-ASCII filename, H2 invalid
> UTF-8 byte), adds **ONE structural fail-closed** that kills the whole silent-skip
> CLASS (H3 fed-vs-scanned reconciliation), and closes **2 smaller items**
> (H4 slash-laundered named secret, H5 `--emit-ran` made a true runtime proof).
> Nothing else was opened; **no protection was lost** (v5 self-test, v5 regression
> 21/21, and the live whole-tree clean baseline all still pass).

---

## Per-item status

| ID | Severity | Title | Status | Fix |
|----|----------|-------|--------|-----|
| **H1** | CRITICAL | non-ASCII filename (`core.quotePath`) bypasses the whole-tree scan + diff + local hook — git C-quotes a Hebrew path → engine `git show HEAD:"<quoted>"` fails → `_mainTree` `catch` SILENTLY DROPS the file → secret ships green. | **CLOSED (code)** | (a) Every `ls-tree`/`diff --name-only`/`diff --cached` in `protocol-enforce.yml`, `deploy.yml`, and `.githooks/pre-commit` now runs with **`-c core.quotePath=false`** → names are emitted as TRUE UTF-8. (b) The engine's INTERNAL `git show` in `_mainTree` also injects `-c core.quotePath=false`. (c) **Defense-in-depth**: a new `unquoteGitPath()` decodes any C-quoted (`"…\NNN…"`) name back to bytes (allowMalformed UTF-8) — wired into `_mainTree`'s `--names` parse AND `splitDiffByFile`'s `+++ b/"…"` header parse — so the engine is correct even if a caller forgets the flag. **Verified**: a Hebrew-named `.dart` with an AKIA secret is now CAUGHT end-to-end (rc 2) whether fed quoted or unquoted, in both `--tree` and `--diff` modes. |
| **H2** | CRITICAL | invalid-UTF-8 byte → silent file skip — `_mainTree`'s `Process.runSync(...).stdout.toString()` throws `FormatException` on a non-UTF-8 byte; `catch (_) {}` swallows it → file dropped → rc 0. | **CLOSED (code)** | `_mainTree` now reads RAW BYTES (`stdoutEncoding: null`) and decodes with **`utf8.decode(bytes, allowMalformed: true)`** — a stray high-bit byte becomes U+FFFD and the file is STILL scanned (fail-CLOSED on bad bytes, never fail-open by dropping). **Verified**: a secret-bearing `.html` with a lone `0xE9` byte is now CAUGHT (rc 2). |
| **H3** | STRUCTURAL | files-fed-vs-files-scanned RECONCILIATION — kills the whole silent-skip CLASS, not just H1/H2. | **CLOSED (code)** — *the most important fix* | `_mainTree` now counts files **FED** (the scannable subset of `--names`) vs files **ACTUALLY SCANNED** (successfully fetched + decoded). If ANY scannable file was not scanned for ANY reason (quote, decode, missing blob, git error) the run **FAILS CLOSED** with a distinct **rc 3** and a message NAMING the skipped file(s) and the reason. The clean path prints `OK␉reg␉H3 reconciliation: fed==scanned==N`. The CI step (protocol-enforce K1 + deploy K5) recognises rc 3 as the H3 fail-closed band (distinct from 0=clean / 2=findings), AND asserts the `fed==scanned` belt line is present (a stubbed engine that never scanned would not print it → fail closed). **Verified**: a deliberately-unscannable file makes the run rc 3 with the filename reported; a non-scannable asset (`.png`) is legitimately NOT reconciled. |
| **H4** | MEDIUM | `/`-in-value secret exemption overrides credential-name — `_looksLikePathOrId(v)` ran BEFORE the credential-name logic, so `clientSecret="ab/cd/EF/GH"` was exempted as a "path". | **CLOSED (code)** | The path/id exemption is now SKIPPED when the line matches `_credentialNameCtx` (or a provider fingerprint), UNLESS the value is a **concrete** path/URL shape — a real URL scheme, a known file extension on the last segment, or a low-entropy filesystem path (`_isConcretePathOrUrl`). A "just contains a slash" value is no longer laundered. **Verified**: `clientSecret="…/…/…/…"` is CAUGHT; genuine `tokenFile="assets/x.json"`, `authUrl="https://…"`, `secretPath="/etc/…/key"` stay exempt (no false positives), and a slashed id with NO credential name stays exempt. |
| **H5** | HARDENING | K3 Dart `--emit-ran` was a STATIC list (`kDartEngineGateIds`) printed unconditionally — overstated "proves it ran" for the ~20 Dart gates (not a live hole; caught elsewhere by K1+S3). | **CLOSED (code)** | `--emit-ran` is now LOGIC-COUPLED: `emitRanIds()` runs each gate's REAL predicate over a KNOWN-POSITIVE canary (`kDartGateCanaries`) and emits the id ONLY IF the gate FIRES on its canary — mirroring the bash hook's `…; ran <id>` discipline. Gut a Dart gate (e.g. `return const []`) → its canary no longer fires → its id is dropped → registry⇄runtime parity FAILS. **Verified**: the real engine emits all 20 ids; a gutted gate-52 copy emits only 19 and `verify-registry` then FAILS. |

**Every v6 item is CLOSED in code.** No item was left silently open, and `protocol/gates.tsv` (the gate registry) is byte-for-byte unchanged (same hash) — the enforced gate SET is identical to v5, so no protection was removed.

---

## Files changed

| File | Change | Protected? |
|------|--------|------------|
| `app_flutter/tool/protocol_check.dart` | `unquoteGitPath()` (H1); `_isConcretePathOrUrl()` + H4 fix in `_looksHighEntropySecret`; `splitDiffByFile` header unquote (H1); `_mainTree` rewrite — byte-read + allowMalformed (H2) + reconciliation/fail-closed rc 3 (H3); `kDartGateCanaries` + `emitRanIds()` and logic-coupled `--emit-ran` (H5); `_mainDiff` defensive names unquote (H1). | not harness-locked |
| `app_flutter/tool/protocol_check_selftest.dart` | 12 v6 self-test cases (H1/H2/H4/H5 + FP guards); banner v5→v6. | not harness-locked |
| `app_flutter/test/protocol_check_engine_test.dart` | v6 flutter_test group (H1/H2/H4/H5) so `flutter test` (the CI gate) exercises the closes. | not harness-locked |
| `protocol/regression_v6.sh` | NEW honest end-to-end suite (H1/H2/H3/H5 over REAL git trees + workflow-grep). | pinned |
| `.github/workflows/protocol-enforce.yml` | `core.quotePath=false` on `ls-tree`/`diff --name-only`; K1 handles rc 3 (H3) + asserts the reconciliation belt. | **token-authorized edit** |
| `.github/workflows/deploy.yml` | `core.quotePath=false` on `ls-tree`; K5 handles rc 3 (H3) + asserts the belt. | not harness-locked |
| `.githooks/pre-commit` | `core.quotePath=false` on the three `git diff --cached` calls; pin `regression_v6.sh`. | **token-authorized edit** |
| `scripts/update_pins.sh` | pin `protocol/regression_v6.sh`. | not harness-locked |
| `protocol/pins.sha256` | regenerated for the changed pinned files (gates.tsv unchanged). | — |

> The `.allow_protocol_edit` token (architect-relayed, "harden protocol v6 to the
> wall") was created to authorize the `.githooks/pre-commit` + `protocol-enforce.yml`
> edits, USED, and **REMOVED — never committed**. `.claude/*` was NOT touched (WALL).

---

## Honest regression tests added (assert EXACTLY what they name)

**Engine `--self-test` + `flutter_test` mirror** (pure, deterministic):
- **H1** — `unquoteGitPath` decodes a C-quoted Hebrew path to true UTF-8 (and leaves ASCII unchanged); a C-quoted Hebrew `+++ b/"…"` header carrying a secret is CAUGHT (gate-52 ERR).
- **H2** — a blob with a high-bit byte + a secret decodes (allowMalformed, no throw) and is still CAUGHT.
- **H4** — `clientSecret="…/…/…/…"` is CAUGHT; `tokenFile="assets/x.json"`, `authUrl="https://…"`, `secretPath="/etc/…/key"`, and a slashed id with no cred-name all stay exempt (no FP).
- **H5** — `emitRanIds()` fires every canary (== `kDartEngineGateIds`); a gate over a non-triggering input is NOT counted as ran.

**`protocol/regression_v6.sh`** (real git trees + workflow assertions, 26 tests):
- **H1** — a Hebrew-named `.dart` secret CAUGHT via `--tree` over an ACTUAL git tree with **C-quoted names fed** (the original bypass input), rc 2, gate-52 ERR, `fed==scanned==1`.
- **H2** — a `.html` with a real `0xE9` blob byte + a secret CAUGHT, rc 2.
- **H3** — a deliberately-unscannable file → **rc 3 FAIL CLOSED**, the filename NAMED, explicit reconciliation-FAIL message; the three rc bands (0 clean / 2 findings / 3 skip) are DISTINCT; a `.png` asset is NOT reconciled.
- **H5** — baseline `--emit-ran` = 20 ids; a **gutted** gate-52 engine copy → 19 ids (52 dropped) → `verify-registry` parity FAILS.
- **WF** — `core.quotePath=false` present on every `ls-tree`/`diff` (both workflows + hook); rc-3 handling + reconciliation belt present in both workflows.

> Honesty note: H5's test does not merely assert the static list — it GUTS a real
> gate predicate in a compilable engine COPY and proves the id disappears and
> parity fails. H1/H2/H3 build throwaway repos and run the REAL engine binary.

---

## Validation (all reported)

- **`bash -n`** on `.githooks/pre-commit`, `.githooks/pre-push`, `.githooks/commit-msg`: all OK. `bash -n protocol/regression_v6.sh`: OK.
- **`--self-test`**: ALL PASS (v6) — includes the 12 new v6 cases.
- **`flutter analyze`**: **0 errors** (only pre-existing `info` lints across the project).
- **`flutter test test/protocol_check_engine_test.dart`**: **44/44 passed** (incl. the 6 v6 tests). (The full `flutter test` suite exits 0; an unrelated `card_score_test.dart` line flickers `-1` under the parallel compact reporter but passes 100% when run in isolation — it imports only catalog data, nothing v6 touched.)
- **`protocol/regression_v6.sh`**: **26/26 passed**.
- **`protocol/regression_v5.sh`**: **21/21 passed** (incl. its own whole-tree acceptance: 2204 files, rc 0, 0 ERR) — confirming no protection lost.
- **Integrity pins**: `sha256sum -c protocol/pins.sha256` → **12/12 OK** (`gates.tsv` hash unchanged).
- **Live `app_flutter/lib/`**: re-scanned via the whole-tree run — **0 ERR** (7 pre-existing gate-114 tree-mode advisories WARN, as documented in the engine). No new false positives.
- **Registry parity**: emitted ids ⊆ enforced, logic-coupled, all 20 fire.
- **Reconciliation count**: live whole-repo tree `fed==scanned==162` (162 scannable files of 2204 tracked, rc 0).

### THE ACCEPTANCE TEST — engine over the WHOLE tree (root `git ls-tree -r HEAD`) with a Hebrew-named file AND a high-bit-byte file PRESENT

- **Clean tree** (Hebrew-named `.dart` + high-bit-byte `.html` both present, **names fed C-quoted by default**): **rc 0**, **0 ERR**, **`fed==scanned==3`** — every file scanned, RC reflects the real (clean) findings.
- **Secret planted in the HEBREW-named `.dart`**: **rc 2**, CAUGHT (gate-52 ERR).
- **Secret planted in the HIGH-BIT-BYTE `.html`**: **rc 2**, CAUGHT (gate-52 ERR), reconciliation still `fed==scanned==3`.

The acceptance test passes in all three cases: every file is scanned, RC reflects real findings on the clean tree, and a planted secret in either a Hebrew-named OR a high-bit-byte file IS caught.

---

## THE WALL — what CANNOT be fixed from code (admin / platform required)

v6 is code; it does not move THE WALL. The four WALL items below are unchanged from
v4/v5 and remain the **only** non-code-fixable residuals.

### 1. Branch protection makes CI authoritative (the #1 WALL)
In **GitHub → Settings → Branches / Rulesets**, for **both** `main` and
`claude/whats-happening-LyY9G`:
1. Require a pull request before merging (no direct pushes).
2. Require status checks to pass → mark **`protocol-gates`** required.
3. Require branches up to date before merging.
4. **Do not allow bypassing the above (admins included).**
5. Disallow force pushes and deletions.
6. (Recommended) Require linear history (blocks merge-commit laundering).

Without 2+4, CI is advisory. This is what makes the trusted-ref fetch a true anchor.

### 2. CODEOWNERS on the protocol surface (the review half)
`.github/CODEOWNERS` requiring a trusted reviewer for `/app_flutter/tool/protocol_check*`,
`/protocol/`, `/.githooks/`, `/.github/workflows/`, `/.github/CODEOWNERS`, plus
**Require review from Code Owners** in branch protection. S3's drift gate is the CI
half; CODEOWNERS is the binding review half. `vars.PROTOCOL_CHANGE_OK` / `vars.BOOTSTRAP`
are admin-only escape hatches (setting a repo variable is itself an admin action).

### 3. `.claude/*` is HARNESS-LOCKED (WALL — not attempted)
`.claude/hooks/pre-tool.sh` and `.claude/settings.json` are denied at the environment
level. They are intentionally NOT in `protocol/pins.sha256` (the pin script cannot
rewrite a pin on a file it is forbidden to edit). CI/pre-commit assert their PRESENCE
(gates 8/9/98/99); content-hardening them is platform work. v6 did not attempt them.

### 4. Workflow-control-flow-on-PR-event + the seed-to-main bootstrap trust root
A `pull_request`-triggered run executes **the PR's OWN copy of the workflow file**
(`.github/workflows/*.yml` control flow comes from the PR head, not from `main`). The
trusted-ref design narrows the blast radius — the workflow fetches the *engine /
runner / registry / pins* from `origin/main` and judges the PR with THOSE, and S3
diffs the PR's workflow/hook/pins against `origin/main` — but the **control flow that
performs the fetch** is still the PR's. This is structurally irreducible on GitHub
Actions for `pull_request` events and is gated by THE WALL (CODEOWNERS on
`/.github/workflows/` + "no admin bypass" so a malicious workflow edit cannot land).

> **FA2's caveat (quoted), which v6 inherits unchanged:** the trusted-ref anchor and
> S1/S3/S4 fail-closed logic are only a *true* anchor **once v5/v6 are actually MERGED
> TO `origin/main`** — because every trusted fetch reads `origin/main`, and S3 diffs
> against `origin/main`. Until this code is the copy ON `main` (and branch-protection +
> CODEOWNERS guard `main` so an attacker cannot seed a stubbed engine/workflow onto it
> in the same move), CI judges a PR against whatever currently sits on `main`. The
> bootstrap window (`vars.BOOTSTRAP=1`) exists precisely to land the first such commit,
> and must be removed by an admin immediately after. **The protocol cannot bootstrap
> its own trust root from within a PR; the seed-to-main step is a human/platform act.**

### 5. The irreducible self-authentication limit
Code that lives in the repo it polices can never be 100% self-securing: whoever can
change the enforcement (engine, hooks, workflows, registry, pins) on the
**authoritative ref** can weaken it. v6 raises the cost as far as code allows; the
final trust root is **human/platform** (branch protection + CODEOWNERS + no admin
bypass + the seed-to-main act above). This is a property of the threat model.

---

## Is everything now CLOSED-or-WALL? (have we hit the wall?)

**YES — everything is CLOSED-or-WALL; v6 hits the wall.**

- All five audited residuals (**H1, H2, H3, H4, H5**) are **CLOSED IN CODE**, each
  with an honest test that asserts exactly the bypass it closes, and each verified
  end-to-end (the acceptance test catches a secret in both a Hebrew-named and a
  high-bit-byte file while reconciling `fed==scanned`).
- **No protection was lost**: gate registry unchanged, v5 self-test + v5 regression
  21/21 still pass, live tree still 0 ERR (no new false positives).
- The only remaining holes are the **five WALL items** above — branch-protection,
  CODEOWNERS, `.claude/*` harness-lock, workflow-control-flow-on-PR-event + the
  seed-to-main bootstrap, and the irreducible self-auth limit. **All are
  platform/human by nature**, all pre-date v6, and none is code-fixable from inside
  the repo.

**There is no v7 code residual.** The whole-tree-scan silent-skip CLASS is now
fail-closed (H3), the two mechanical bypasses into it are shut (H1/H2), the
slash-laundering hole is shut (H4), and the runtime-proof claim is now honest (H5).
The next step is the admin applying THE WALL (items 1, 2, and the seed-to-main merge
are the high-value ones); items 3–5 are irreducible platform/threat-model facts.
