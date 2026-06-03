# BuildSmart Protocol — v4 Hardening Pass

> Closes the CODE-FIXABLE residuals a 3-agent verification re-attack found in v3.
> Builds ON TOP of v3 (`24e6ab8`). No protection lost; v3's introduced
> false-positives are FIXED. Honest about CLOSED vs PARTIAL vs WALL.
>
> Authoritative layering: **CI (`protocol-enforce.yml`) + GitHub branch
> protection + CODEOWNERS** ≫ local hooks. The hooks are convenience + fast
> feedback; CI run from a TRUSTED ref is the un-skippable lock — but only once the
> admin steps in **THE WALL** are applied.

---

## Per-residual status

### Structural / CI keystone

| ID | Residual (v3 defect) | Status | What changed |
|----|----------------------|--------|--------------|
| **K1** | CI scanned only `BASE…HEAD` touched files → push-to-main empty-diff, incremental-not-whole-tree, `\|\|true`+empty-diff silent pass | **CLOSED** | `protocol-enforce.yml` now runs the engine over **every** file via `git ls-tree -r HEAD` → `--tree --show "git show HEAD:"` (clean-tree baseline; never assumes merge-base clean). **FAIL-CLOSED** if a push moved refs (`github.event.before != HEAD`, not zero-sha) but the diff-set is empty. Triggers on push **and** pull_request to **both** `claude/whats-happening-LyY9G` **and** `main`. |
| **K2** | CI ran the engine/hooks from the PR's OWN copy → weaken-engine-in-same-PR, re-pinnable engine | **CLOSED (code) / WALL (full anchor)** | New first step fetches `protocol_check.dart` + `protocol_check_selftest.dart` + `gates.tsv` + `.githooks/pre-commit` from `origin/main` into `.trusted/`, and CI judges the PR with **those**, not the checked-out head. Bootstrap fallback (file absent on `main`) emits a loud `::warning::` and uses the PR copy. The FULL anchor (attacker cannot also push to `main`) needs branch-protection + CODEOWNERS on `main` — see THE WALL. |
| **K3** | `cp enforced claimed` compared the registry to itself; `ran <id>` recorded at function ENTRY so a deleted check still "ran" | **CLOSED (CI + foundations) / PARTIAL (per-check coupling for all 90 bash gates)** | CI now **runs** the gate-runner in `PROTOCOL_AUDIT_MODE=1` to produce a **genuine** `ran` ledger and diffs it against `gates.tsv` (no self-copy). The runner emits `ran <id>` **after** each check: `gate_foundations` is fully per-check coupled (deleting any one check drops its id → parity FAILS — proven by regression). The short-circuit exploit (flutter tier skipped on a no-code commit recorded `ran` anyway) is fixed via a `napp` (not-applicable) ledger: a skipped tier records `napp`, a **deleted** gate records neither and FAILS. Remaining bash gate-groups still emit a group `ran` at their (non-short-circuiting) bodies; converting all ~90 to individual per-check `ran` is mechanical follow-up (PARTIAL). |
| **K4** | Gutted-but-executable hook / neutered workflow passed CI's existence + `grep -q job-name` structural check | **CLOSED** | `protocol/pins.sha256` now pins the **3 hooks + both workflows** (content-hash). CI's `K4` step verifies every pin by sha256 **and** asserts the hooks+workflows appear in the pin file (so deleting their pin lines can't un-protect them). The local hook's `PROTECTED_PINNED` mirrors this. (`.claude/*` is WALL — see below.) |
| **K5** | Prod `deploy.yml` shipped to gh-pages/APK with **zero** content gates | **CLOSED** | `deploy.yml` runs the engine **whole-tree** (`--tree`, RC captured) as a **required** step before the gh-pages push and APK build. ERR (rc 2) or crash (other rc) blocks the ship. |
| **K6** | `ENGINE_RC=$?` / `TREE_RC=$?` were DEAD code under `set -euo pipefail` (a non-zero engine call aborted the step before the capture) | **CLOSED** | The engine calls are wrapped in `set +e … rc=$? … set -e`, so the rc is actually captured; tree-mode **always** runs; rc 2 (findings) is distinguished from any other rc (crash/tamper → fail closed). Applied in both `protocol-enforce.yml` (K1 step) and `deploy.yml` (K5 step). |
| **K7** | Enforcement Flutter 3.44.0 ≠ local 3.29.3 — silent | **CLOSED (documented + visible)** | The split is documented (CI/ship = 3.44.0 = what users get; local hook floats). The pre-commit prints a `K7 NOTICE` when local Flutter ≠ `3.44.0` so the divergence is never silent; CI's version-parity gate is the hard anchor across all workflows. |

### Content-engine residuals

| ID | Residual | Status | What changed (in `tool/protocol_check.dart`) |
|----|----------|--------|---------------------------------------------|
| **C1** | Secret entropy gameable (only fired on upper+lower+digit mix) | **CLOSED** | `_looksHighEntropySecret` now fires on SHAPE: a 32+ hex run `[0-9a-fA-F]{32,}` (lowercase / UPPER-only / no-digit / **all-digit**), a base64 blob `[A-Za-z0-9+/]{32,}={0,2}` at high entropy, OR a general high-entropy token — case-mix **agnostic**. Provider fingerprints unchanged. |
| **C2** | Context-line smuggling (forbidden value on an UNCHANGED diff line) | **CLOSED (46/54/48) / PARTIAL-by-design (114)** | `runTreeGates` now also runs **48** (print), **46** (dark surface), **54** (dark ColoredBox) line-locally over each post-image. **114** runs in tree mode as **WARN** (`gateNoKLipskeyInUiTree`) — the mature app has ~21 legit pre-existing `kLipskeyCatalog` uses, so a tree-mode ERR would permanently red the clean baseline; the `--diff` path keeps **114 = ERR** for newly-added uses. Honest split: tree=advisory, diff=blocking. |
| **C3** | `--tree` extension gap | **CLOSED** | `isSecretScannablePath` widened to `.kt/.kts/.swift/.html/.htm/.css/.toml/.cfg/.ini` (plus the existing `.gradle/.xml/...`). Secrets are scanned in native + web + build files. |
| **C4** | Print sinks missed `=print` tear-off, `stdout.add`, unqualified `log(` | **CLOSED** | `_printFinding` adds `stdout/stderr.add(`, `x = print` tear-off, and unqualified `log("…")` (message-shaped only, so `math.log(2.0)` / `log(value)` / `obj.logSomething()` stay clean). |
| **C5** | Gate 65 skipped on ANY line containing "isolate" | **CLOSED** | Skips only a GENUINE bidi context: `Directionality(`, `Bidi.`, `unicodeWrap`, or a literal LRI/RLI/FSI/PDI (`⁦-⁩`). A bare `isolate` substring / variable named `isolate` no longer bypasses. |
| **C6** | Near-black greys `0x2E..0x33` not caught as dark surfaces | **CLOSED** | Dark-luma threshold raised `0.18 → 0.205` (catches `0xFF2E2E2E`/`0xFF333333` grey surfaces) — paired with F4 so only **near-greyscale** dark colours count. |

### False-positives introduced by v3 (a gate that blocks legit code is a real bug)

| ID | False-positive | Status | What changed |
|----|----------------|--------|--------------|
| **F1** | Cross-file diff contamination (gate fired on an out-of-scope co-committed file because the diff was concatenated) | **CLOSED** | `splitDiffByFile` partitions the unified diff back into per-file sub-diffs (flushing on every `diff --git` / `+++`/`---` boundary — even when `---` is absent); `runAllContentGates` runs each gate **only** over the sub-diffs of files matching its own scope predicate. Proven: gate 46 no longer fires on `lib/theme/app_theme.dart` co-committed with a screen; gate 114 no longer fires on `lib/data/lipskey_catalog.dart`. |
| **F2** | SRI / asset hashes flagged as secrets | **CLOSED** | `_integrityContext` + `_isSriDigest` allowlist `sha256-/sha384-/sha512-` and `integrity:`/`checksum`/`digest`/`etag` contexts. Provider fingerprints STILL fire inside an integrity line (AKIA beats the allowlist). |
| **F3** | `0xFF111111`/`0xFF1A1A1A` text ink flagged as a dark SURFACE | **CLOSED** | `hasDarkSurface` requires a surface constructor on the same line; `TextStyle(color: …)` ink is not a surface. Verified against the live tree's 172 `0xFF1A1A1A` inks → 0 flagged. |
| **F4** | Saturated dark blues flagged as "dark" | **CLOSED** | Dark-surface now needs **near-greyscale AND dark** (channel spread ≤ 64), not raw luma. `0xFF0D47A1` (brand blue) / dark-green inks are not "dark surfaces"; near-black greys still are. |

---

## Validation results

- `bash -n .githooks/{pre-commit,pre-push,commit-msg}` → all **OK**.
- `dart run tool/protocol_check.dart --self-test` → **117/117 ok** (`ALL PASS (v4 self-test)`), incl. one regression per close above.
- `flutter test` (full suite) → exit **0** (`flutter_test` mirror at
  `test/protocol_check_engine_test.dart` = **32 groups pass**, incl. v4 C1-C6/F1-F4/C2 mirrors).
- `flutter analyze tool/ test/protocol_check_engine_test.dart` → **0 errors, 0 warnings** (info-level lints only; CI does not block on info).
- **K3 audit parity**: `PROTOCOL_AUDIT_MODE=1 bash .githooks/pre-commit` → genuine ledger of **107** ids == **107** enforced rows in `gates.tsv`, **0** discrepancies either direction. Deleting one check (gate 2) → ledger loses `2` → parity FAILS (regression proven).
- `protocol/pins.sha256` → all **10** pins verify `OK` (engine, selftest, gates.tsv, 2 scripts, 3 hooks, 2 workflows).

### Whole-tree FALSE-POSITIVE scan (the headline check)

Ran the v4 engine over the **live** `app_flutter/lib/` (+ native/web/config), **162 files**:

- **`--tree` mode (the K1/K5 CI path): RC = 0 — ZERO ERR-level findings.** The
  clean-tree baseline holds; the whole-tree CI scan would NOT block.
- Only findings: **7 × WARN gate-114** — the pre-existing legitimate
  `kLipskeyCatalog` uses in screens/logic, correctly downgraded to **advisory** in
  tree mode (C2). These are TRUE advisories about real legacy code, **not**
  false-positives, and they do not block.
- A realistic per-file PR diff (theme `bgDark` + screen `0xFF1A1A1A` ink + blue
  border) → **0 findings** (F1/F3/F4 all clean).

> Honesty note: v3 claimed "0 false-positives" and it was false (gate 46 fired on
> the theme file; gate 114 on the data catalog). v4's claim is scoped and
> verified: **0 ERR-level false-positives** on the live tree; the only live-tree
> emissions are 7 intentional WARN advisories. In `--diff` mode (the real PR
> enforcement) the pre-existing in-scope 62/63/114 matches fire **only if those
> exact lines are changed** — that is correct protocol behavior, not a
> false-positive.

---

## THE WALL — what CANNOT be fixed from code (admin / platform required)

These are NOT code-fixable. The protocol is as hard as code can make it; the last
mile is GitHub configuration + the platform, and the irreducible self-auth limit.

### 1. Branch protection makes CI authoritative (the #1 WALL)
CI runs the full protocol, but it only **blocks a merge** if the repo admin
requires it. In **GitHub → Settings → Branches** (or a Ruleset), for **both**
`main` and `claude/whats-happening-LyY9G`:
1. **Require a pull request before merging** (no direct pushes to the protected branch).
2. **Require status checks to pass** → mark **`protocol-gates`** as **required**.
3. **Require branches to be up to date before merging** (re-runs against the latest base — closes the stale-merge gap K1's whole-tree scan complements).
4. **Do not allow bypassing the above settings** (applies to admins too).
5. **Disallow force pushes** and **disallow deletions** on the protected branch.
6. (Recommended) **Require linear history** (blocks merge-commit laundering).

Without 2+4, CI is advisory only.

### 2. CODEOWNERS on the protocol surface (anchors K2)
K2 makes CI judge a PR with `origin/main`'s engine/runner/registry. That is only a
true anchor if an attacker **cannot also change `main`'s copy** in the same move.
Add a `.github/CODEOWNERS` requiring review from a trusted owner for:
```
/app_flutter/tool/protocol_check*       @trusted-owner
/protocol/                              @trusted-owner
/.githooks/                             @trusted-owner
/.github/workflows/                     @trusted-owner
/.github/CODEOWNERS                     @trusted-owner
```
and enable **Require review from Code Owners** in branch protection. Until then,
K2 is "CLOSED in code, WALL for the full anchor" — documented, not overclaimed.

### 3. `.claude/*` is HARNESS-LOCKED (pre-tool / settings hardening)
`.claude/hooks/pre-tool.sh` and `.claude/settings.json` are denied at the
**environment level** (writes refused before any guard runs). This pass did **not**
attempt them (per instruction). Their hardening is WALL:
- They are intentionally **NOT** in `protocol/pins.sha256` (this repo's
  `update_pins.sh` cannot rewrite a pin on an intentional change to a file it is
  forbidden to edit, which would brick the pin check). Their integrity is the
  platform's responsibility.
- CI still asserts their **presence** (structural step) and the pre-commit still
  asserts their presence (gates 8/9/98/99). Content-hardening them is platform work.

### 4. The irreducible self-authentication limit
A protocol enforced **by code that lives in the same repo it polices** can never be
100% self-securing: whoever can change the enforcement (engine, hooks, workflows,
registry, pins) on the **authoritative ref** can weaken it. v4 raises the cost
(trusted-ref CI, content-hash pins, real runtime parity, whole-tree + pre-ship
scans), but the final trust root is **human/platform**: branch protection +
CODEOWNERS + "no bypass for admins". This is a property of the threat model, not a
bug to be coded away.

---

## What remains for a next pass (code-fixable) vs now-WALL

**Still code-fixable (PARTIAL items):**
- **K3 runner-half**: convert the remaining bash gate-groups (state/planning/
  quality/lang/save-safety/final-safety/learning/knowledge) from a group `ran` to
  individual per-check `ran` coupling (as done for `gate_foundations`). Mechanical;
  each check line gets a trailing `; ran <id>`. The CI audit-parity + the
  `gate_foundations` coupling already deliver the K3 *property*; this widens it to
  every bash gate.
- **C2 / gate 114 in tree mode is WARN, not ERR**, by design (legacy uses). A
  future cleanup that migrates the ~21 in-scope `kLipskeyCatalog` uses to
  `kCatalogProducts` would let tree-mode 114 be promoted to ERR with a clean
  baseline. That is an APP refactor, not an engine fix.

**Now purely WALL (not code-fixable from this repo):**
- Branch protection + required `protocol-gates` + no-bypass (items 1).
- CODEOWNERS review on the protocol surface to fully anchor K2 (item 2).
- `.claude/*` pre-tool/settings content-hardening — harness-locked (item 3).
- The irreducible self-authentication trust root (item 4).
