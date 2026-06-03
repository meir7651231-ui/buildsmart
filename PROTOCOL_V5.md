# Protocol Hardening — v5 (the convergence pass)

> v5 closes the EXACT residuals two verifiers (RA1 engine, RA2 CI) found in v4.
> The headline: v4's new bare-hex secret rule **red the engine's own clean tree**
> (N1) — CI failed on every clean PR. That is fixed, plus four other false-
> positives/evasions and four runner/workflow gaps. After v5 the remaining holes
> are **ONLY THE WALL** (branch-protection / CODEOWNERS / `.claude/*` harness-lock
> / self-auth root).
>
> INTEGRITY: v4 shipped a LAUNDERED self-test ("does NOT flag `0xFF111111` in ink"
> that actually asserted `0xFF1A1200`). v5 removes it and every v5 test asserts the
> EXACT input it names. See F3 below.

Work was done ONLY in `wt-proto-build` (branch `claude/agent-network-proto-build`),
built ON TOP of v4 `ba63595`. `.allow_protocol_edit` was created, used, and
removed — never committed (it is `.gitignore`d and a tracked-bypass gate would
block it anyway).

---

## Per-residual status

| ID | Residual (verifier-exact) | Status | How it is closed |
|----|---------------------------|--------|------------------|
| **N1** | v4's whole-tree CI scan REDS its own clean tree — the bare-hex secret rule flags the 40-char all-zero SHA in `protocol-enforce.yml` (K1 fail-closed code) → root `git ls-tree -r HEAD` over ~2202 files → **TREE_RC=2 → CI fails every clean PR**. | **CLOSED** | Secret engine path-(a) now exempts (a) **single-repeated-character runs** (`0000…`, all-`f`) and (b) **git-object-SHA shapes** (pure-hex, single-case, canonical digest length 32/40/64). Acceptance gate met: engine over the WHOLE 2202-file tree (root `ls-tree`, the way K1 feeds it) is **RC=0, ZERO ERR**. |
| **F3** | `0xFF111111`/`BsTokens.bgDark` as INK still false-fires gate 46 — `_legacyDarkSurface` fired UNCONDITIONALLY (no surface guard). | **CLOSED** | Guarded behind `_surfaceCtx` exactly like the semantic path: `(_legacyDarkSurface ∧ _surfaceCtx) ∨ hasDarkSurface`. The decision also **strips nested ink spans** (`TextStyle(…)`/`Icon(…)`) so a surface ctor that merely CONTAINS dark ink is not flagged. The laundered self-test is **deleted** and replaced with honest tests: the REAL `0xFF111111` ink is NOT flagged; a `0xFF111111` SURFACE **IS** flagged. |
| **F2** | Bare hex digests (`buildSha`=40-hex git sha, `cacheKey`=md5, `assetHash`=32-hex) false-fire gate 52. | **CLOSED** | Same engine change as N1: a pure-hex digest-length value is a PUBLIC digest, exempt UNLESS the line NAMES it a credential (`_credentialNameCtx`) and not a digest (`_digestNameCtx`). Paired with A1 so the hex-digest FP is not reopened (base32 has G–Z letters a hex digest cannot). |
| **A1** | base32 secrets (TOTP/2FA seeds, `[A-Z2-7]{16,}`, entropy 3.8–4.2) evade the 4.2 floor. | **CLOSED** | Explicit `_looksBase32Secret`: `[A-Z2-7]{16,}`, must contain a G–Z letter (distinguishes from hex), entropy ≥ 3.2. The assignment extractor floor was lowered 20→16 (only base32 is admitted in the 16–19 band; hex/base64 keep ≥32). Does NOT reopen F2. |
| **E4** | Multi-line dark surface — `backgroundColor:` on one line, `Color(0xFF0A0A0A)` wrapped to the next (what `dart format` emits >80 cols) evades 46/54. | **CLOSED** | `_surfaceGateLines` emits, in addition to every raw line, MINIMAL joined lines: a named surface-colour property (`backgroundColor:`/`cardColor:`/`ColoredBox(`…) joined forward to the first colour token / `;`. Nested ink spans stripped (F3 kept). The full-constructor-span join was **rejected** — it over-fired on the live tree (pulled sibling `BoxShadow` colours into the surface check); the minimal join is what keeps the acceptance test at RC=0. Translucent (alpha < 0x80) shadow colours are additionally not treated as surfaces. |
| **S1** | K2 bootstrap fallback silent & unbounded — CI writes `fetched_all`/`trusted_complete` to `$GITHUB_OUTPUT` but NEVER reads it; a missing engine on `origin/main` silently falls back to the PR copy → a stubbed PR engine ships. | **CLOSED (code) / WALL (true anchor)** | New `S1` step READS `steps.trusted.outputs.trusted_complete` and **FAILS CLOSED** (exit 1) when the trusted fetch is incomplete, UNLESS an explicit one-time `vars.BOOTSTRAP=1` is set (admin removes it once the protocol is on main). No more silent stub-judges-itself. (The full anchor still needs branch-protection so an attacker can't seed the stub onto `main` — THE WALL.) |
| **S2** | K3 group-`ran` is entry-proof, not exec-proof — ~8 bash groups emitted a batch `ran 11 12…20` at function ENTRY; gut a check, keep the `ran` line → parity passes. | **CLOSED** | ALL 8 batch groups (`state`/`planning`/`quality`/`lang`/`save_safety`/`final_safety`/`learning`/`knowledge`) converted to trailing per-check `; ran <id>` like `gate_foundations`. Gates behind an applicability guard record `ran` when reached and `napp` when not (honest, like gate 94). Audit ledger still == enforced set (107/107). Regression proves: gut a check → its `ran` is gone → registry parity FAILS (rc 2). |
| **S3** | K4 pin self-consistent (re-pin bypass) — `.trusted/githooks/pre-commit` is FETCHED but never run; the pin + pinned file are both the PR copy, so gut-hook + `update_pins.sh` + commit `pins.sha256` passes K4. | **CLOSED (code) / WALL (review half)** | New `S3` step DIFFS the PR's hooks/workflows/`pins.sha256` against the **TRUSTED `origin/main`** copies (fetched in K2). A re-pin does NOT bypass it — the baseline is `origin/main`, not the PR. Drift fails unless `vars.PROTOCOL_CHANGE_OK=1` (a reviewed protocol PR). New `S3b` RUNS the trusted pre-commit in audit mode to produce the K3 ledger — the `.trusted/` hook set is no longer a dead fetch; it is the K3 ledger source. (CODEOWNERS on `main` is the binding review half — THE WALL.) |
| **S4** | `deploy.yml` K5 runs the UNTRUSTED PR engine + a narrower (app_flutter-cwd) tree. | **CLOSED (code) / WALL (true anchor)** | `deploy.yml` now fetches the engine/registry from `origin/main` (same trusted mechanism as protocol-enforce K2) and runs K5 from the **REPO ROOT** with `ls-tree -r HEAD` (like K1) so `.github/`, `app/`, root `index.html` are all scanned — not just `app_flutter/*`. S4 also fails closed on an incomplete trusted fetch (no PR-stub ship). |

**Every residual is CLOSED, or CLOSED-in-code with the residual WALL half explicitly named.** No residual is left silently open.

---

## THE ACCEPTANCE TEST (#1) — engine over the whole 2202-file tree

```
git --no-replace-objects ls-tree -r --name-only HEAD  →  2202 files   (the way CI K1 feeds it)
dart run app_flutter/tool/protocol_check.dart --tree \
    --names <tree> --show "git --no-replace-objects show HEAD:" \
    --stuck-log app_flutter/knowledge/stuck_log.md
RESULT: TREE_RC = 0   ·   ERR = 0   ·   (7 WARNs = pre-existing gate-114 tree-mode advisories, by design)
```

v4 baseline on the SAME command was **TREE_RC=2** (one ERR: gate 52 on the all-zero
SHA in `protocol-enforce.yml`). N1 is the fix; the acceptance test is now green.

Engine over the live `app_flutter/lib/` only: **0 ERR**.
`deploy.yml` K5/S4 (trusted engine, repo-root tree) simulated locally: **RC=0, 0 ERR**.

---

## Validation (all run, all green)

| Check | Result |
|-------|--------|
| `bash -n` on all 3 hooks (`pre-commit`, `pre-push`, `commit-msg`) | **OK** |
| `bash -n` on every embedded `run:` block in both workflows | **OK** |
| `dart run … --self-test` | **ALL PASS (v5)** — 141 checks |
| `flutter test` protocol mirror (`protocol_check_engine_test` + `protocol_security_test` + `knowledge_protocol_test`) | **48/48 pass** (incl. live-tree "no dark surface" guard) |
| `flutter analyze` | **0 errors, 0 warnings** on the protocol files |
| **THE ACCEPTANCE TEST** — whole 2202-file tree, root `ls-tree`, the CI K1 way | **RC 0 · 0 ERR** |
| Engine over live `app_flutter/lib/` | **0 ERR** |
| Registry⇄runtime parity (audit ledger vs `gates.tsv`) | **OK — 107 enforced == 107 ran** |
| `protocol/regression_v5.sh` (S1–S4 + acceptance) | **21/21 pass** |
| `protocol/pins.sha256` vs current files | **all match** |
| YAML validity (`yaml.safe_load`) both workflows | **OK** |

---

## Honest tests added (assert EXACTLY what they name)

Engine (`--self-test` + flutter_test mirror):
- **N1**: the all-zero 40-hex SHA (the literal K1 fail-closed line) is NOT a secret; an all-same-char 64-hex run is NOT; whole-tree mode does NOT fire on the zero-SHA in a `.yml`.
- **F3**: the REAL `0xFF111111` as `TextStyle` ink is NOT flagged; `0xFF111111` as a `backgroundColor` surface **IS** flagged; `BsTokens.bgDark` as an ink arg is NOT, as a `Container` surface **IS**; a `Container` whose child has wrapped dark ink is NOT; a `Container` whose OWN `color:` is dark **IS** (with a white-ink child present).
- **F2**: 40-hex git sha1 `buildSha`, 32-hex md5 `cacheKey`, 64-hex sha256 `assetHash`, and a bare 40-hex digest with no credential name are all NOT secrets.
- **A1**: a 16-char base32 TOTP seed and a 32-char base32 2FA secret ARE caught; the rule does NOT reopen F2 (a 32-hex md5 stays exempt).
- **E4**: a wrapped `backgroundColor:`/`scaffoldBackgroundColor:`/`cardColor:` value IS caught; a wrapped `ColoredBox` colour IS caught; a wrapped `TextStyle` INK is NOT; a translucent `BoxShadow(0x14000000)` is NOT a surface; `_parenDelta` ignores parens inside string literals.
- **C1** (reconciled honestly): a hex secret fires WHEN NAMED a credential (`apiSecret`/`clientSecret`) or at a NON-digest length; a base64 blob fires. (The v4 contextless-40-hex assertion WAS the N1/F2 FP and is removed.)

Bash / CI (`protocol/regression_v5.sh`):
- **S2**: clean hook audit ledger PASSES parity; then gut gate-20's check line → its `ran 20` is gone → tampered ledger MISSING gate 20 → registry parity FAILS (rc 2). (Exec-proof, not entry-proof.)
- **S1**: the workflow READS `trusted_complete` and has a FAIL-CLOSED branch; the decision simulated: complete→pass, incomplete+no-bootstrap→FAIL, incomplete+BOOTSTRAP→pass.
- **S3**: a re-pinned GUTTED hook still DIFFERS from the trusted `origin/main` copy (re-pin does not bypass); the workflow diffs PR-vs-trusted and RUNS the trusted hook for the K3 ledger (no dead fetch).
- **S4**: `deploy.yml` fetches + runs the TRUSTED engine, scans the WHOLE repo-root tree, the K5 engine step is NOT pinned to the `app_flutter` CWD, and it fails closed on an incomplete trusted fetch.
- **ACCEPTANCE** embedded: whole-tree (2202 files) RC=0, ZERO ERR.

---

## Files changed (v5)

- `app_flutter/tool/protocol_check.dart` — secret engine (N1/F2/A1 helpers + path-a rewrite), `_isDarkSurfaceLine`/`_surfaceGateLines`/`_stripInkSpans` (F3/E4), translucent-alpha guard in `parseColors`. Gates 46 & 54 use the joined surface lines.
- `app_flutter/tool/protocol_check_selftest.dart` — laundered F3 test removed; honest N1/F2/A1/F3/E4 tests added; C1 reconciled; v5 banner.
- `app_flutter/test/protocol_check_engine_test.dart` — flutter_test mirror updated to match (honest F3/N1/F2/A1/E4).
- `.githooks/pre-commit` — S2: all 8 batch `ran` groups → trailing per-check `; ran`/`napp`; `regression_v5.sh` added to `PROTECTED_PINNED`.
- `.github/workflows/protocol-enforce.yml` — S1 fail-closed step; trusted fetch widened (pre-push/commit-msg/workflows/pins); S3 trusted-diff step; S3b trusted-runner K3 ledger; K3 now consumes the trusted ledger.
- `.github/workflows/deploy.yml` — S4: trusted engine fetch + repo-root `ls-tree` K5 + fail-closed.
- `scripts/update_pins.sh` — pins `protocol/regression_v5.sh`.
- `protocol/pins.sha256` — regenerated (pre-commit + both workflows + regression file).
- `protocol/regression_v5.sh` — **new** honest S1–S4 + acceptance shell suite.
- `PROTOCOL_V5.md` — this doc.

---

## THE WALL — what CANNOT be fixed from code (admin / platform required)

After v5, these are the ONLY remaining holes. They are platform/human, not code.

### 1. Branch protection makes CI authoritative (the #1 WALL)
CI (`protocol-gates`) runs the full protocol but only **blocks a merge** if the
admin requires it. In **GitHub → Settings → Branches** (or a Ruleset), for **both**
`main` and `claude/whats-happening-LyY9G`:
1. **Require a pull request before merging** (no direct pushes to the protected branch).
2. **Require status checks to pass** → mark **`protocol-gates`** as **required**.
3. **Require branches to be up to date before merging** (re-run against the latest base).
4. **Do not allow bypassing the above settings** (applies to admins too).
5. **Disallow force pushes** and **disallow deletions** on the protected branch.
6. (Recommended) **Require linear history** (blocks merge-commit laundering).

Without 2+4, CI is advisory only. **This is what makes S1/S3/S4's trusted-ref
fetch a true anchor** — it stops an attacker from seeding a stubbed engine onto
`main` (which the trusted fetch then reads).

### 2. CODEOWNERS on the protocol surface (anchors S1/S3/S4/K2 — the review half)
The trusted-ref CI judges a PR with `origin/main`'s engine/runner/registry, and
S3 diffs the PR's hooks/workflows/pins against `origin/main`. That is a true anchor
ONLY if an attacker **cannot also change `main`'s copy** in the same move. Add
`.github/CODEOWNERS` requiring a trusted reviewer for:
```
/app_flutter/tool/protocol_check*       @trusted-owner
/protocol/                              @trusted-owner
/.githooks/                             @trusted-owner
/.github/workflows/                     @trusted-owner
/.github/CODEOWNERS                     @trusted-owner
```
and enable **Require review from Code Owners** in branch protection. S3's drift gate
is the CI half; CODEOWNERS is the binding review half. The `vars.PROTOCOL_CHANGE_OK`
and `vars.BOOTSTRAP` repo-variables are admin-only escape hatches (set deliberately
for a reviewed protocol PR / one-time seed, removed after) — they are NOT a
self-service bypass because setting a repo variable is itself an admin action.

### 3. `.claude/*` is HARNESS-LOCKED (pre-tool / settings hardening)
`.claude/hooks/pre-tool.sh` and `.claude/settings.json` are denied at the
**environment level** (writes refused before any guard runs). v5 did **not** attempt
them (per instruction). Their hardening is WALL:
- They are intentionally **NOT** in `protocol/pins.sha256` (this repo's
  `update_pins.sh` cannot rewrite a pin on a file it is forbidden to edit, which
  would brick the pin check). Their integrity is the platform's responsibility.
- CI still asserts their **presence** (structural step) and the pre-commit asserts
  presence (gates 8/9/98/99). Content-hardening them is platform work.

### 4. The irreducible self-authentication limit
A protocol enforced **by code that lives in the same repo it polices** can never be
100% self-securing: whoever can change the enforcement (engine, hooks, workflows,
registry, pins) on the **authoritative ref** can weaken it. v5 raises the cost as
far as code allows (trusted-ref CI for enforce AND deploy, fail-closed bootstrap,
trusted-vs-PR drift detection, exec-proof runtime parity, whole-repo-root scans,
honest tests), but the final trust root is **human/platform**: branch protection +
CODEOWNERS + "no bypass for admins". This is a property of the threat model, not a
bug to be coded away.

---

## Is everything now CLOSED-or-WALL?

**YES.** Every v5 residual (N1, F3, F2, A1, E4, S1, S2, S3, S4) is **CLOSED in code**;
S1/S3/S4 additionally name a residual **WALL** half (branch-protection + CODEOWNERS)
that is platform/human by nature. The four WALL items above (branch protection,
CODEOWNERS, `.claude/*` harness-lock, self-auth root) are the **only** remaining
holes, and all four were already WALL in v4 — v5 introduced no new code-fixable
residual.

**There is no v6 code residual.** The next step is the admin applying THE WALL
(items 1–2 are the high-value ones); items 3–4 are irreducible platform/threat-model
limits. We have hit the wall.
