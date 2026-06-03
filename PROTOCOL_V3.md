# BuildSmart Protocol v3 — Hardening against the 6-agent red team

Built ON TOP of v2 (`1e1a305`) on branch `claude/agent-network-proto-build`.
v3 fixes the **8 root causes** behind ~380 proven bypass vectors. Each root closes
a whole class. This doc records, per root: **what changed**, **status**, the
**OLD→NEW** where relevant, the **regression tests**, and what is **DEFERRED**.

> Reading guide: the authoritative protection layers are, in order of trust:
> **CI (`protocol-enforce.yml`) + GitHub branch protection** (R1) ≫ pre-commit /
> pre-push (local, skippable) ≫ `.claude` pre-tool (advisory). v3 makes CI the
> un-skippable backstop so the local layers being bypassable no longer matters.

---

## Status summary

| Root | Title | Priority | Status |
|---|---|---|---|
| R1 | CI is the only un-skippable layer | MUST | **COMPLETE** (+ admin branch-protection step documented) |
| R4 | Semantic/allowlist/argv, not literal/substring/denylist | MUST | **COMPLETE (engine)** · **pre-tool.sh: BLOCKED by harness — patch below** |
| R3 | Fail CLOSED everywhere | MUST | **COMPLETE** |
| R6 | Prove gates RAN + integrity-pin engine/registry/scripts | MUST | **COMPLETE** |
| R8 | One pinned Flutter version everywhere | MUST | **COMPLETE** |
| R2 | Scan the committed TREE, not `--cached`/`+` lines | SHOULD | **COMPLETE (value gates)** — positional gates stay diff-scoped (documented) |
| R5 | Content/coverage, not `-f`; tamper-evident baselines | SHOULD | **MOSTLY COMPLETE** — 32/33/56/111 done; 42/71/87 symbol-ref DEFERRED |
| R7 | Don't trust env/forgeable tokens | SHOULD | **COMPLETE** (replay from on-disk state; SKIP_BUILD token-gated) |

---

## R1 — CI is the only un-skippable layer **[MUST · COMPLETE]**

**The hole:** every local layer is skippable — `commit -n`, `-c core.hooksPath=`,
`GIT_DIR`/`GIT_CONFIG`, `chmod -x` the hook, merge/FF a dirty branch into a
protected one, plumbing (`git commit-tree`). v2's CI was *partial* (a few greps)
and scoped to a couple of branches.

**What changed (`.github/workflows/protocol-enforce.yml`, full rewrite):**
- Runs on **push AND pull_request** to **BOTH** `claude/whats-happening-LyY9G`
  **AND** `main`. **No branch-scoping** — CI runs the full suite regardless of
  branch.
- Computes the diff vs the **merge-base** (`git diff origin/main...HEAD`, or the
  PR base SHA) and scans the **RESULTING TREE** with `--no-replace-objects` (so a
  planted `git replace` can't launder a blob).
- Runs the **FULL protocol**: `dart run tool/protocol_check.dart` (all content
  gates, diff + tree mode) + registry parity + malformed-row check + structural
  checks + engine self-test + integrity pins + `flutter analyze`
  (errors fatal repo-wide; **warnings fatal for changed files**) + `flutter test`
  + `flutter build web` + `flutter build appbundle` (release) + version-sync.
- One pinned Flutter version via `env.FLUTTER_VERSION` (R8), with a parity gate.

### Admin step that makes CI AUTHORITATIVE (do this in GitHub settings)
CI only *blocks merges* if branch protection requires it. The repo admin must, for
**both** `main` and `claude/whats-happening-LyY9G`:

1. **Settings → Branches → Add branch protection rule** (one per branch, or a
   ruleset covering both).
2. **Require a pull request before merging** (no direct pushes to the protected
   branch).
3. **Require status checks to pass before merging** → add the **`protocol-gates`**
   check as **required**. Enable **Require branches to be up to date before
   merging** (forces re-run against the latest base — closes the stale-merge gap).
4. **Do not allow bypassing the above settings** (applies to admins too).
5. **Disallow force pushes** and **disallow deletions** on the protected branch.
6. (Recommended) **Require linear history** to block merge-commit laundering, and
   require the **`flutter-version-parity`** outcome (part of `protocol-gates`).

Without step 3+4, CI runs but is advisory. WITH them, no change reaches a
protected branch without a green full-protocol run — which is the property the
local layers cannot guarantee.

---

## R4 — Semantic / allowlist / argv, not literal / substring / denylist **[MUST]**

**The hole:** v2 matched **literal substrings** of the very strings it forbade, so
every gate fell to a trivially-different spelling: lowercase hex, `fromARGB`,
off-by-one channels, a secret split across two string literals, *any* new emoji
not in the 5-item denylist, `// LTR` comment to dodge the RTL gate, a runtime-built
persistence key, an aliased import, `stdout.write` instead of `print`. And the
pre-tool guard matched the raw command string, so `chmod`/`tee`/`perl -i`/`GIT_DIR`
walked past it.

### Engine (`app_flutter/tool/protocol_check.dart`) — **COMPLETE**

| Gate | OLD (v2) | NEW (v3) |
|---|---|---|
| 46/54/69 colors | `l.contains('0xFF111111')` / `ColoredBox.*0xFF[0-3][0-3]` | parse `0x..` (case-insensitive, 6/8-digit) + `Color.fromARGB`/`fromRGBO`/`HSLColor.fromAHSL` → **luminance**; reject `< 0.18`. **Surface-scoped** (ColoredBox/Container/backgroundColor/BoxDecoration/Scaffold…) so dark **text ink** (`0xFF1A1A1A`, used ~18× legitimately) is **not** a false-positive. Legacy `0xFF111111`/`BsTokens.bgDark` token still fires unconditionally. |
| 52 secrets | name-keyed regex (`api_key|secret|token…`) on `.dart` only | **name-AGNOSTIC**: Shannon-**entropy** (≥4.0 + mixed-case) **+ provider fingerprints** (`AKIA`,`AIza`,`ghp_`,`xox[bp]-`,`sk-`,`-----BEGIN`,JWT). **JOIN adjacent/`+`-concatenated string literals** before matching (kills split-secret). `.`/`=`/`/` in the value class. Path/asset/dotted-id/regex-named values excluded (false-positive class). Scans `.dart/.arb/.json/.yaml/.yml/.txt/.properties/.env/.gradle/.xml`. |
| 64 emoji | 5-emoji **denylist** (🎯🎨🎮🎪🎲) | **INVERTED to an allowlist** over the 297 legacy pictographic runes harvested from the live `app_flutter/` + `app/`. Warns on ANY Extended_Pictographic rune outside it; strips VS-16/VS-15/ZWJ/skin-tone; decodes `\u{…}`/`\uXXXX` escapes. |
| 62 RTL inset | `padding.*\b(left\|right):` **warn** | `EdgeInsets.only(.. left\|right:)` **+ `fromLTRB`**, excludes Directional, **ERR**. |
| 63 TextAlign | `TextAlign.(left\|right)` warn | same match, **ERR**. |
| 65 ltr | skip on `//`/`LTR`/`isolate` substring | skip ONLY a whole-line comment or a genuine `isolate`; the `// LTR` escape is gone. |
| 95 NxN | `[א-ת]+ [0-9]+×[0-9]+` | adds ASCII `x` and `*` multiply signs. |
| 73 key | single-quote literal only | **both quote styles**; flags **interpolated** (`'bs.x.v$n'`) / **concatenated** (`'bs.x.'+v`) keys; feature segment allows snake_case (live `bs.saved_projects.v1`). |
| 114 kLipskey | `l.contains('kLipskeyCatalog')` | resolves **`as` aliases** (`import … as lk; lk.kLipskeyCatalog`); ignores comment lines; does NOT ban the bare type-only import (15 files import it legitimately for the type). |
| 48 print | `print(` only | adds `stdout/stderr.write(ln)`, `developer.log`, bare-`print` tear-off; strips string literals & line-comments first so `"please print"` / `// print()` don't fire. |
| ALL | fired on tests/docs too | **path-scoped**: tests, `*.g.dart`, `knowledge/*.md`, the engine, `gates.tsv`, build scripts are EXEMPT (the #1 false-positive class). |

### `.claude/hooks/pre-tool.sh` — **BLOCKED by the harness; patch provided below**

> **Honest status:** the runtime harness **denies `Write`/`Edit` to any file under
> `.claude/`** in this environment (verified: both tools returned
> *"Permission to use … has been denied"* for `.claude/hooks/pre-tool.sh` and
> `.claude/settings.json`). The project's own bypass (`.allow_protocol_edit`) was
> satisfied, but the *harness* gate is a separate, harder boundary I will not
> circumvent. So the v3 pre-tool rewrite is delivered here as a **ready-to-apply
> patch** for whoever has `.claude` write access.
>
> **This is acceptable because R1 makes the pre-tool layer non-load-bearing.** The
> pre-tool guard is a *seatbelt* against an accidental local bypass; CI + branch
> protection are the real gate. Every class the pre-tool patch closes
> (`chmod`/`tee`/`GIT_DIR`/`commit -n`/unknown write-tool) is ALSO closed by CI
> scanning the resulting tree on every push/PR.

The hardened `pre-tool.sh` (full content) is in **Appendix A**. Apply it verbatim,
and change `.claude/settings.json` PreToolUse matcher from
`"Bash|Edit|Write|NotebookEdit"` to `"*"` (default-deny unknown write-tools).
What it adds:
- **FAIL CLOSED** (exit 2) on empty/invalid JSON or missing `tool_name`.
- **DEFAULT-DENY any write under a protected dir, regardless of tool** — it
  `realpath`s every path arg & redirect target and checks containment under
  globbed roots `.githooks/**`, `.git/hooks/**`, `.claude/**`,
  `.github/workflows/**`, `.git/config`. Covers chmod/truncate/perl -i/tee/dd/
  install/ed/ex/xargs/ln/python/ruby/awk without enumerating them.
- **ENV inspection**: denies `GIT_CONFIG*`,`GIT_DIR`,`GIT_WORK_TREE`,
  `GIT_REFLOG_ACTION`,`GIT_INDEX_FILE` (in the environment AND as inline
  `VAR=… cmd` prefixes) and inline `BUILDSMART_SKIP_BUILD`/`VERIFIED_UI`.
- **`commit -n`** short-form blocked (in addition to `--no-verify`).
- Per-segment command splitting (`tr '|&;<>(){}'`) so a benign `rm /tmp/x`
  combined with an unrelated protected path no longer false-blocks (a v2 bug).

---

## R3 — Fail CLOSED everywhere **[MUST · COMPLETE]**

**The hole:** v2 swallowed the engine exit code with `2>/dev/null` and used only
the parsed lines, so an engine *crash* (Dart broken / file truncated) produced no
findings and **passed**. `mktemp` failures were unchecked. analyze warnings were
ignored. A proto push with `flutter` missing silently skipped the build gate.

**What changed:**
- **pre-commit `run_content_engine`**: captures `rc`; `rc ∉ {0,2}` (0=clean,
  2=findings) is a **HARD block** with the engine's stderr shown — never swallowed.
  All three `mktemp`s are checked; a failure blocks.
- **pre-commit analyze (gate 31)**: warnings in **changed files** are now **fatal**
  (was: only `^error •`). Scoped to changed files so pre-existing warnings
  elsewhere don't false-block.
- **pre-push**: a proto push with **`flutter` missing** is a HARD fail (was: silent
  skip). `BUILDSMART_SKIP_BUILD` now requires the signed token (R7).
- **pre-tool** (Appendix A): exit 2 on empty/invalid JSON / missing `tool_name`.
- **CI**: every step is `set -euo pipefail`; analyze errors fatal repo-wide,
  warnings fatal for changed files.

---

## R6 — Prove gates RAN + integrity-pin engine/registry/scripts **[MUST · COMPLETE]**

**The hole:** v2 compared a **static constant** (`HOOK_GATE_IDS`) to the registry.
The constant could list a gate that was **commented-out / never executed**, and
parity still passed — the constant *lied*. (Indeed v2's registry claimed gates
**67/93/109** as `enforced` while NONE of them actually ran — `gateAppHebrewString`
was dead code; 93/109 were never called. v2 parity passed anyway.) The engine
itself wasn't integrity-checked, and malformed `gates.tsv` rows were silently
skipped.

**What changed:**
- **Runtime ledger** (`$RAN_LEDGER`): every gate calls `ran <id>` when its code
  path executes; `err()`/`warn()` also record (a finding implies the gate ran).
  The engine emits `RAN\t<id>` for each content gate via `--emit-ran`. Gate `reg`
  compares **`sort -u $RAN_LEDGER`** (what actually ran) to the registry's
  `enforced` set — runs **LAST**, after the Flutter tier. A commented-out gate
  ⇒ its id is absent ⇒ **parity FAILS**. *Verified: the runtime ledger == the 107
  enforced ids, exactly.*
- **Closed the 67/93/109 lie honestly**: gate **67** is now wired into the engine
  (`gateAppHebrewString` over `app/` Preact files); gates **93** (ROADMAP
  done-marker) and **109** (sub-protocol → CARRY_FORWARD) are now **really
  implemented** in bash. Registry `engine` column corrected `dart→bash` for
  23/25/93/109 (they were always bash) to stop lying.
- **Integrity pins** (`protocol/pins.sha256`, generated by `scripts/update_pins.sh`):
  `protocol_check.dart`, `protocol_check_selftest.dart`, `gates.tsv`,
  `gen_version.sh`, `generate_stuck_regression.sh` are sha256-pinned and verified
  in `gate_engine_integrity` (pre-commit) and in CI. A tampered file FAILS before
  any gate trusts it.
- **Self-test as a BLOCKING gate**: `dart run tool/protocol_check.dart --self-test`
  runs in the cheap tier (pre-commit) and in CI; failure blocks.
- **Malformed rows FAIL**: `parseRegistry` returns errors for `<9` cols, blank-id,
  duplicate-id, unknown-status; `--verify-registry` exits 2 on any. (No more skip.)

---

## R8 — One pinned Flutter version everywhere **[MUST · COMPLETE]**

**The hole (gate≠ship):** the gate ran on **3.29.3** (`protocol-enforce.yml`,
`catalog-qa.yml`) while what actually **ships** built on **3.44.0**
(`deploy.yml`, `android-package.yml`). A version-specific break could pass the gate
and ship broken.

**Decision:** converge **everything to `3.44.0`** — the **ship** version — so the
gate now matches what users get. (Chosen over 3.29.3 because deploy + android
already build & test green on 3.44.0; aligning the gate up is lower-risk than
downgrading the proven ship pipeline.)

**What changed:** `protocol-enforce.yml` `3.29.3→3.44.0`; `catalog-qa.yml`
`3.29.3→3.44.0`; `deploy.yml`/`android-package.yml` already `3.44.0`. New
**`flutter-version-parity`** gate in `protocol-enforce.yml` greps every workflow's
`flutter-version` and **fails if any diverges** from `env.FLUTTER_VERSION`.
*Verified: all 4 workflows now pin exactly `3.44.0`.*

**Residual (documented, not a gate≠ship gap):** the **local** pre-commit/pre-push
discover whatever `flutter` is on PATH (here `3.29.3`). That's a local-dev
convenience; **CI is authoritative** and runs 3.44.0. If desired, a future pass can
pin the local toolchain via an `.fvmrc`/`fvm` and assert it in `session-start.sh`.

---

## R2 — Scan the committed TREE, not `--cached`/`+` lines **[SHOULD · COMPLETE for value gates]**

**The hole:** scanning only `+` lines of a unified diff misses a value that the
diff **splits across hunk boundaries**, and `--cached` misses `commit -a`/partial
divergence.

**What changed:**
- New **`--tree` mode**: fetches the **post-image** of each touched file
  (`git show :path` for the index; `git --no-replace-objects show HEAD:` in CI),
  reads it as one string, and runs the **VALUE-oriented** gates (secrets with
  literal-joining, persistence-key, emoji, local-uri, ColoredBox/dark-surface,
  manual-container). Used in CI on the resulting tree (R1) and available to
  pre-commit.
- **`joinAdjacentLiterals`** reconstructs split/`+`-joined string literals before
  the secret match.
- pre-commit detects `commit -a`/partial-stage divergence is **DEFERRED** (see
  below) — the CI tree-scan already covers the post-merge tree, which is the
  property that matters for a protected branch.

**Honest scoping decision (verified against the live tree):** the **positional /
style** gates (62/63/65/95/51, and 114's symbol use) are **NOT** run in tree mode.
Dart `build()` methods are giant single expressions that legitimately mix a surface
constructor with dark **text** ink and contain pre-existing `EdgeInsets.only(left:)`
/ `TextAlign.left`; re-scanning a whole touched file would **re-flag pre-existing
lines** (a false-block) and a positional pattern can't be "split" anyway. Those
gates stay on the line-local `--diff` path, where they only see newly-added lines.
A full-tree scan of the live `lib/` is **clean** under this scoping.

**DEFERRED:** `git diff HEAD` vs `--cached` divergence detection in pre-commit
(`commit -a`/partial-stage). Rationale: low marginal value once CI scans the
post-merge tree; can be added to `gate_quality` later.

---

## R5 — Content/coverage, not `-f`; tamper-evident baselines **[SHOULD · MOSTLY COMPLETE]**

**What changed:**
- **Gate 32 (baseline)** — count parsed from the **SUMMARY line only**, anchored
  to `^NN:NN +P -F:` (a test printing `+99 -0` as data can't spoof it). The failing
  test **NAMES must be a SUBSET of `known_failing.txt`** — a NEW failure blocks even
  if the count is within baseline (defends swapping one known-fail for a new one).
- **Gate 33 (monotonic)** — reads a machine-readable `^tests: N` from STATUS.md
  (falls back to the legacy marker), live count from the anchored SUMMARY line.
- **Gate 56 (helper test)** — the test must **REFERENCE a public symbol** added to
  the changed helper (or import the helper file); an empty placeholder test no
  longer satisfies it.
- **Gate 111 (stuck-regression)** — **byte-diffs** the regenerated test (via a new
  `STUCK_REGEN_OUT` temp-output override in `generate_stuck_regression.sh`) against
  the committed one — a manual edit is caught. **Monotonic-non-decreasing**
  antipattern count vs `^antipatterns: N` baseline.

**DEFERRED:** gates **42/71/87** symbol-reference (only 56 got the symbol-ref
upgrade this pass); the knowledge-file gates (gate 2) still use `-f` existence
rather than min-size/required-content. Both are straightforward follow-ups.

---

## R7 — Don't trust env / forgeable tokens **[SHOULD · COMPLETE]**

**The hole:** v2 detected rebase/amend "replay" from **`$GIT_REFLOG_ACTION`** —
trivially forged (`GIT_REFLOG_ACTION=amend git commit`) to **skip the test gate**.
`BUILDSMART_SKIP_BUILD` and `VERIFIED_UI` were ungated env flags.

**What changed:**
- **pre-commit replay detection** is now ONLY from **on-disk state**:
  `$GIT_DIR/rebase-merge` or `rebase-apply` existence. `GIT_REFLOG_ACTION` is no
  longer consulted (and the pre-tool patch denies it as an env/inline var).
- **pre-push `BUILDSMART_SKIP_BUILD`** now requires the signed `.emergency_token`
  (≥16 chars, matched) and is audited; without it, skipping the build is refused.
- **`VERIFIED_UI`** inline assignment is denied by the pre-tool patch (Appendix A).

**DESIGN-only (documented):** a fully server-signed emergency token / state-outside-
the-tree is out of scope for a repo-local protocol; the `.emergency_token` file +
audit-log is the pragmatic equivalent and is what v3 gates on.

---

## Validation performed

- `bash -n` on **all** hooks (`pre-commit`, `pre-push`, `commit-msg`,
  `generate_stuck_regression.sh`, `update_pins.sh`): **clean**. (pre-tool.sh patch
  in Appendix A also `bash -n` clean.)
- `dart run tool/protocol_check.dart --self-test`: **ALL PASS** (v3 suite, every
  closed root has a named regression test).
- `flutter test test/protocol_check_engine_test.dart`: **+21 All tests passed**
  (the flutter_test mirror).
- **Full-tree engine scan** over the live `app_flutter/lib/` (122 files) and the
  `.json/.yaml/.arb` data files: **0 findings** (no false-positives) after the
  surface/secret/scoping fixes.
- **Runtime parity**: union of bash `ran` ids + engine `--emit-ran` ids ==
  registry `enforced` set, **exactly 107 ids**, 0 missing, 0 orphan.
- **Integrity pins** verified to match (`sha256sum --check` compatible).
- **Planted-violation end-to-end**: a lib/screens diff with a split secret +
  lowercase-dark ColoredBox + bad key + non-legacy emoji ⇒ ERR 46/52/54/73 + WARN
  64, exit 2; the SAME content in a test file ⇒ exit 0 (scoped out).
- **Flutter version parity**: all 4 workflows pin `3.44.0`.
- **Full `flutter test` suite** (local 3.29.3): see the run referenced in the
  report. (CI re-runs on 3.44.0, the ship version.)

## Files changed (in `wt-proto-build`)
- `app_flutter/tool/protocol_check.dart` — semantic engine, tree mode, runtime
  parity, malformed-row detection, `--emit-ran`, path scoping.
- `app_flutter/tool/protocol_check_selftest.dart` — v3 regression suite.
- `app_flutter/test/protocol_check_engine_test.dart` — flutter_test mirror (v3).
- `app_flutter/scripts/generate_stuck_regression.sh` — `STUCK_REGEN_OUT` override.
- `.githooks/pre-commit` — R3 fail-closed engine, R6 ledger + integrity gate +
  parity-last, R7 replay-from-disk, R5 baseline/33/56/111, gates 93 implemented.
- `.githooks/pre-push` — R7 token-gated SKIP_BUILD, R3 flutter-missing hard-fail.
- `.github/workflows/protocol-enforce.yml` — R1 full protocol on push+PR to both
  branches, tree scan, R8 version-parity gate, R3 warnings-fatal-for-changed.
- `.github/workflows/catalog-qa.yml` — R8 pin `3.44.0`.
- `protocol/gates.tsv` — engine-column corrections (23/25/93/109 → bash).
- `protocol/pins.sha256` (new), `scripts/update_pins.sh` (new) — R6 integrity pins.
- `PROTOCOL_V3.md` (this file).

## NOT changed / DEFERRED (honest)
- `.claude/hooks/pre-tool.sh` + `.claude/settings.json` — **BLOCKED by harness
  write-deny**; patch in Appendix A (R4/R3/R7 pre-tool items + matcher `*`).
- R2 `commit -a`/partial-stage divergence in pre-commit — DEFERRED (CI covers tree).
- R5 gates 42/71/87 symbol-ref + knowledge-file min-size — DEFERRED.
- R8 local-toolchain pin (fvm) — DEFERRED; CI authoritative on 3.44.0.

---

## Appendix A — hardened `.claude/hooks/pre-tool.sh` (apply manually)

> Could not be written by this agent (harness denies `.claude/` writes). Apply
> verbatim, then set `.claude/settings.json` PreToolUse matcher to `"*"`.
> `bash -n` clean. This is a seatbelt; CI (R1) is the real gate.

```bash
#!/bin/bash
# BuildSmart Protocol v3 — PreToolUse guard (DEFAULT-DENY on protected dirs).
# FAIL CLOSED on bad input; realpath every path arg; default-deny any write under
# a protected dir regardless of tool; inspect ENV (GIT_*, BUILDSMART_*); block
# commit -n; matcher = * in settings.json.
set -uo pipefail
deny()  { echo "🔒 חסום (pre-tool v3): $1" >&2; exit 2; }
allow() { exit 0; }

input=$(cat 2>/dev/null || true)
[[ -z "${input//[[:space:]]/}" ]] && deny "קלט ריק — fail closed"
echo "$input" | jq -e . >/dev/null 2>&1 || deny "JSON לא תקין — fail closed"
tool=$(echo "$input" | jq -r '.tool_name // empty')
[[ -z "$tool" ]] && deny "חסר tool_name — fail closed"
command=$(echo "$input" | jq -r '.tool_input.command // ""')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
notebook_path=$(echo "$input" | jq -r '.tool_input.notebook_path // ""')
REPO=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
PROTECTED_GLOBS=(".githooks" ".git/hooks" ".claude" ".github/workflows")
PROTECTED_FILES=(".git/config")

if [[ -n "${BUILDSMART_EMERGENCY_DISABLE:-}" ]]; then
    TOKEN_FILE="${REPO}/.emergency_token"
    if [[ -f "$TOKEN_FILE" ]]; then
        EXPECTED=$(tr -d '[:space:]' < "$TOKEN_FILE")
        GIVEN=$(echo "${BUILDSMART_EMERGENCY_DISABLE}" | tr -d '[:space:]')
        if [[ ${#EXPECTED} -ge 16 && "$GIVEN" == "$EXPECTED" ]]; then
            echo "[$(date -Iseconds)] EMERGENCY_DISABLE used tool=$tool" >> "${REPO}/.git/protocol_audit.log" 2>/dev/null
            exit 0
        fi
    fi
fi

is_protected_path() {
    local p="$1" root abs repo_abs r f rf
    [[ -z "$p" ]] && return 1
    case "$p" in /*) abs="$p" ;; *) abs="${REPO:-$PWD}/$p" ;; esac
    abs=$(realpath -m -- "$abs" 2>/dev/null || echo "$abs")
    repo_abs=$(realpath -m -- "${REPO:-$PWD}" 2>/dev/null || echo "${REPO:-$PWD}")
    for root in "${PROTECTED_GLOBS[@]}"; do
        r=$(realpath -m -- "$repo_abs/$root" 2>/dev/null || echo "$repo_abs/$root")
        [[ "$abs" == "$r" || "$abs" == "$r/"* ]] && return 0
    done
    for f in "${PROTECTED_FILES[@]}"; do
        rf=$(realpath -m -- "$repo_abs/$f" 2>/dev/null || echo "$repo_abs/$f")
        [[ "$abs" == "$rf" ]] && return 0
    done
    return 1
}
bypass_allows_edit() {
    local B="${REPO}/.allow_protocol_edit" age len
    [[ -f "$B" ]] || return 1
    age=$(( $(date +%s) - $(stat -c %Y "$B" 2>/dev/null || echo 0) ))
    [[ "$age" -gt 86400 ]] && return 1
    len=$(grep -v "^$" "$B" 2>/dev/null | tr -d '[:space:]' | wc -c)
    [[ "$len" -lt 30 ]] && return 1
    echo "[$(date -Iseconds)] bypass tool=$tool age=${age}s" >> "${REPO}/.git/protocol_audit.log" 2>/dev/null
    return 0
}
for cand in "$file_path" "$notebook_path"; do
    [[ -z "$cand" ]] && continue
    if is_protected_path "$cand"; then
        bypass_allows_edit && allow
        deny "כתיבה ל-$cand תחת תיקיית-הגנה דורשת .allow_protocol_edit"
    fi
done
[[ "$tool" != "Bash" ]] && allow

for e in GIT_CONFIG GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG_COUNT GIT_DIR GIT_WORK_TREE GIT_REFLOG_ACTION GIT_INDEX_FILE; do
    [[ -n "${!e:-}" ]] && deny "$e מוגדר בסביבה — עלול לעקוף hooks/config."
done
echo "$command" | grep -qE '(^|[^A-Za-z0-9_])(GIT_CONFIG[A-Z_]*|GIT_DIR|GIT_WORK_TREE|GIT_REFLOG_ACTION|GIT_INDEX_FILE)[[:space:]]*=' && deny "GIT_* inline."
echo "$command" | grep -qE '(^|[^A-Za-z0-9_])(BUILDSMART_SKIP_BUILD|VERIFIED_UI|BUILDSMART_EMERGENCY_DISABLE)[[:space:]]*=' && deny "BUILDSMART_*/VERIFIED_UI inline."

normalized=$(echo "$command" | tr '|&;<>(){}' '\n')
while IFS= read -r seg; do
    [[ -z "$seg" ]] && continue
    redir=$(echo "$seg" | grep -oE '>>?[[:space:]]*[^[:space:]]+' | sed -E 's/^>>?[[:space:]]*//')
    for tok in $seg $redir; do
        tok="${tok%\"}"; tok="${tok#\"}"; tok="${tok%\'}"; tok="${tok#\'}"
        case "$tok" in
            */.githooks/*|.githooks|.githooks/*|*/.git/hooks/*|.git/hooks|.git/hooks/*|*/.claude/*|.claude|.claude/*|*/.github/workflows/*|.github/workflows|.github/workflows/*|*/.git/config|.git/config)
                if is_protected_path "$tok"; then
                    echo "$seg" | grep -qE 'cp[[:space:]]+[^[:space:]]*\.githooks/[a-z-]+[[:space:]]+[^[:space:]]*\.git/hooks/[a-z-]+[[:space:]]*$' && continue
                    deny "פעולה על נתיב-הגנה ($tok)."
                fi ;;
        esac
    done
done <<< "$normalized"

echo "$command" | grep -qE -- '(^|[^A-Za-z0-9_])--no-verify' && deny "--no-verify."
if echo "$command" | grep -qE 'git[[:space:]]+([^|&;]*[[:space:]])?commit([[:space:]]|$)'; then
    echo "$command" | grep -qE 'commit[[:space:]]+[^|&;]*(-[a-zA-Z]*n[a-zA-Z]*|--no-verify)' && deny "commit -n / --no-verify."
fi
echo "$command" | grep -qE 'git[[:space:]]+(-c[[:space:]]+)?core\.hooksPath[[:space:]]*=' && deny "-c core.hooksPath=."
echo "$command" | grep -qE 'git[[:space:]]+-c[[:space:]]+core\.hooksPath' && deny "-c core.hooksPath."
if echo "$command" | grep -qE 'git[[:space:]]+config.*core\.hooksPath'; then
    echo "$command" | grep -qE 'core\.hooksPath[[:space:]]+\.githooks([[:space:]]|$)' || deny "core.hooksPath must be .githooks."
fi
echo "$command" | grep -qE 'push.*(-{1,2}force|--force-with-lease|--force-if-includes|-f[[:space:]]|-f$)' && deny "force push."
echo "$command" | grep -qE 'git[[:space:]]+push[[:space:]]+[^[:space:]]+[[:space:]]+\+' && deny "refspec force push."
if echo "$command" | grep -qE 'git[[:space:]]+config[[:space:]]+alias\.'; then
    echo "$command" | grep -qE '(no-verify|force|hooksPath)' && deny "bypassing alias."
fi
echo "$command" | grep -qE 'eval[[:space:]]+.*git[[:space:]]+(commit|push)' && deny "eval git commit/push."
exit 0
```

### Appendix A.1 — `.claude/settings.json` change
```json
"PreToolUse": [
  { "matcher": "*",
    "hooks": [ { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-tool.sh" } ] }
]
```
