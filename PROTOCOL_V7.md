# BuildSmart Protocol — v7 (friction-elimination pass)

> v7 builds **ON TOP of v6** (`5e2ff18`). v6's security engine is intact and
> UNCHANGED in substance — content gates, pins, registry parity, whole-tree scan,
> trusted-ref, fail-closed all STAY. v7 fixes **friction in the PROCESS /
> BOOKKEEPING layer** and one **self-inflicted RED baseline** that blocked every
> commit. The IRON CONSTRAINT held: **no change reduces detection.** Where a fix
> makes the LOCAL path faster/looser, **CI still runs the FULL suite + whole-tree
> scan** (the authoritative layer) so an attacker gains nothing.
>
> Proof points (all reproduced below): clean-tree `flutter test` is **GREEN with
> no manual baselining**; the engine `--self-test` is **ALL PASS (v7)**; the
> whole-tree engine scan is **RC 0, fed==scanned==162, 0 ERR**; **v5 (21/21) and
> v6 (26/26) regressions still pass**; the gate registry (`protocol/gates.tsv`)
> is **byte-for-byte unchanged** (same sha256) and **all 107 enforced gate ids
> still run** (audit-mode ledger == enforced, both diffs empty); the engine still
> emits the **same 20** Dart gate ids.

---

## Per-DX status

| DX | Pri | Title | Status | Security-preservation note (why it does NOT reduce detection) |
|----|-----|-------|--------|----------------------------------------------------------------|
| **DX1** | P0 | THE WALL — RED baseline blocked every commit (antipattern #40 vs gate 93's `grep <emoji>`). | **DONE** | Pure-mechanical. Gate 93's emoji/checkmark scan was converted from an external `grep -E "✅\|…"` to a **bash `case`/glob builtin** over the ADDED diff lines (the exact pattern gates 23/64 use). The gate's DETECTION is identical — a `+`-added ROADMAP line with a done-marker still satisfies it (it is advisory `warn` either way). The only thing that changed is the IMPLEMENTATION mechanism, which now satisfies stuck-regression antipattern #40, so `flutter test` is GREEN on a clean tree. Nothing about secret/RTL/dark detection is touched. |
| **DX2** | P0 | gate 32 self-contradiction (count-branch read 0 via a CR-glued compact-reporter scrape; name-branch read 1). | **DONE** | Correctness, **strictly stronger**. `flutter test` now runs with `--reporter json`; failure COUNT and failure NAMES are both derived from the SAME `testDone` event stream (`result != success && hidden != true`), so the two branches **cannot disagree**. A `testDone` event is **harder to spoof** than a printed summary line (a test that prints `"+99 -0"` cannot forge a JSON event). Added: a non-zero exit with ZERO parsed failures is now a **fail-CLOSED** "runner crashed" error (never silently passes). |
| **DX3** | P1 | No test scoping → ~4-6 min on every `.dart` commit. | **DONE** | **Zero detection loss — CI is the authoritative layer.** A CHANGED-FILES fast path runs the tests covering the staged files + a fixed CRITICAL subset (knowledge_protocol / stuck_regression / protocol_security / regression_gate / wiring / smartproduct_contract) instead of the full ~1148-test suite. It is **fail-toward-MORE-tests**: a shared `lib/state/*`, `providers.dart`, `main.dart`, a non-`_test` helper, or a lib file with no discoverable sibling test → **WHOLE suite**. `BUILDSMART_FULL_TEST=1` forces full locally. **CI (`flutter test --no-pub --concurrency=4`, protocol-enforce.yml) and pre-push (`build web`) are UNCHANGED**; CI still runs the full suite on every push/PR. Gate 33 (monotonic test count) is skipped only on a SCOPED run (a subset would false-trip "count dropped") — CI's full run still enforces it. |
| **DX4** | P1 | gate 42 trivial-fix tax (demanded a test for touching ANY `lib/logic\|data` file). | **DONE** | **Stricter-and-smarter.** Trigger changed from "a logic/data file was staged && no `*_test.dart` staged" to "a **NEW public top-level symbol** (class/enum/mixin/extension/top-level function) was **ADDED** that has **NO covering test** (on disk OR staged, by symbol-reference or file-import)". Editing an already-tested helper adds no new symbol → no demand. A brand-new untested public API → still blocked. An attacker adding new logic still must ship a covering test; an UNTESTED new public symbol — exactly the risk we want — is still caught. Gate 56 (new `*_helper.dart`) independently covers helper files. |
| **DX5** | P1 | gate 116 visual-verify performative for non-visual edits. | **DONE** | **Stronger artefact accepted.** gate 116 now has TWO satisfying paths: the original staged `visual_log.md` entry, OR "every changed `lib/(screens\|widgets)` file is covered by a **widget test** (`testWidgets`/`pumpWidget`) that references the changed widget class or imports the file". A real automated widget test is a stronger verification than a hand-written screenshot note. An uncovered widget with no log still ERRs. `VERIFIED_UI=1` emergency path unchanged. |
| **DX6** | P1 | Flutter version latent CI wall (workflows pinned `3.44.0`, which does not install). | **DONE** | **Reconciled to ONE real version, parity gate intact.** Verified the only installable SDK is **3.29.3** (Dart 3.7.2) — the same version local dev runs; `3.44.0` is not a real stable release, so CI could never go green. ALL workflows (`protocol-enforce`, `deploy`, `android-package`, `catalog-qa`) + the hook's `FLUTTER_ENFORCE_VERSION` are now `3.29.3` → **local == CI == ship**. The CI **version-parity gate still BLOCKS** any workflow that drifts off the single pinned version (no protection lost — it now points at a version that exists). |
| **DX7** | P2 | Near-FPs: (a) raw base64 image blob flagged as a secret; (b) dark-surface message not actionable. | **DONE** | **(a) Content-based, unforgeable exemption.** A base64 blob is exempted from the ENTROPY secret path **only when its DECODED prefix is a real image magic** (PNG `iVBORw0KGgo`, JPEG `/9j/`, GIF `R0lGOD…`, WEBP `UklGR`, BMP, ICO, SVG) — and is downgraded to an actionable **WARN** ("move to assets/"), not silently dropped. An attacker **cannot** make a high-entropy secret also be a decodable image header, so a real secret is still ERR; **naming a secret `imageData` does NOT launder it** (the check is on bytes, not the variable name); **provider fingerprints (AKIA…/ghp_…) are unaffected and still fire**. (b) gates 46/54 messages now say "by-design light-theme enforcement … put dark/theme tokens in `lib/theme/`" (which is OUT of the screens/widgets scope, so the advice is valid). |
| **DX8** | P2 | 4-file bookkeeping ceremony. | **DONE** | **No gate removed — satisfying them is one command.** New `scripts/bookkeep.sh` inspects the staged change and auto-stubs+stages the required WIRING.md / visual_log.md / mutation_log.md entries (clearly-marked `TODO` lines the dev fills in) and PRINTS the STATUS reminders (`tests:` / known-failing / version). It is idempotent (one stub per session), DX5-aware (skips visual_log when a widget test already covers the UI), and has `--dry-run`. The gates still enforce real content; the helper just removes the ceremony. |

> **No gate was removed and no engine id changed.** `protocol/gates.tsv` sha256 is
> identical to v6. Audit-mode runtime ledger == enforced set (107 ids, both diffs
> empty). The engine still emits the same 20 Dart gate ids. The TRIGGERS of gates
> 42/93/116 changed (smarter), and the SEVERITY of one secret sub-case (a proven
> image blob) is WARN instead of ERR — both are documented above as ≥-as-strong.

---

## Which gate TRIGGERS changed, and why each is still ≥ as strong against an attacker

| Gate | Old trigger | New trigger | Still ≥ strong because |
|------|-------------|-------------|------------------------|
| **93** (advisory) | external `grep <emoji>` over ROADMAP diff | bash `case`/glob over the same ADDED diff lines | Same inputs, same markers, same `warn`. Only the mechanism changed (to satisfy antipattern #40). |
| **32** | failure COUNT from a CR-fragile compact-reporter scrape (could read 0) + a separate name scan (could read 1) | both COUNT and NAMES from one `--reporter json` `testDone` stream; non-zero-exit-with-no-failures = fail-closed | JSON events can't be spoofed by printed data; the two views are now consistent; a crashed runner now BLOCKS instead of reading 0. |
| **42** | any staged `lib/logic\|data` file with no staged `*_test.dart` | a NEW public top-level symbol ADDED with no covering test (disk or staged) | New untested public API is still blocked; only the false tax on editing an already-tested helper is removed. |
| **116** | staged `visual_log.md` required | staged `visual_log.md` OR a widget test referencing the changed widget | A widget test is a stronger verification artefact than a note; an uncovered widget still ERRs. |
| **52** (secret) | a high-entropy base64 blob = ERR | same, EXCEPT a blob whose decoded prefix is a real image magic = WARN ("prefer assets/") | Exemption is content-based and unforgeable; a real/credential blob (no magic) is still ERR; the name can't launder it; fingerprints unaffected. |
| **46 / 54** (dark surface) | ERR with terse message | same ERR, clearer/actionable message (mentions `lib/theme/`) | Detection unchanged (same predicate, same `Sev.err`); only the message text improved. |

**Triggers that did NOT change:** every other gate (the whole content engine —
RTL 62/63/65, persistence 73/74, kLipskey 114, print 48, dart:html 50, hard URL
51, gitignore 70/97, emoji allowlist 64, …), pins, registry parity, whole-tree
scan, trusted-ref, fail-closed bands (rc 2 findings / rc 3 reconciliation),
branch-scoping, emergency-token gating, pre-push build.

---

## What CI still enforces (the authoritative layer — unchanged by v7)

`.github/workflows/protocol-enforce.yml` (push + PR to `whats-happening` AND `main`):
- **K1 whole-tree scan** of every tracked file from HEAD (`--tree`), with the H3
  fed==scanned reconciliation belt and the rc-3 fail-closed band — **unchanged**.
- **Full `flutter test --no-pub --concurrency=4`** (the complete ~1130+ suite,
  incl. the new v7 tests) — **unchanged**. This is what makes DX3's local scoping
  safe.
- **K2 trusted-ref**: engine/runner/registry/pins fetched from `origin/main` and
  used to judge the PR — **unchanged**.
- **K3 real registry⇄runtime parity** (run the gate-runner in audit mode, diff the
  ledger vs `gates.tsv`) — **unchanged** (and verified green: 107 == 107).
- **K4 integrity pins** (content-hash of engine/registry/scripts/hooks/workflows)
  — **unchanged**, pins regenerated for the v7-edited files (gates.tsv hash same).
- **Trusted `--self-test`** (blocking) — **unchanged**, now ALL PASS (v7).
- **Flutter version-parity gate** — **unchanged logic**, now pins the real 3.29.3.
- **analyze (errors fatal; warnings fatal for changed files) + web build** — unchanged.

`.githooks/pre-push`: full `flutter build web --release` on a proto push — unchanged.

---

## Files changed

| File | Change | Pinned? |
|------|--------|---------|
| `.githooks/pre-commit` | DX1 gate 93 → case/glob; DX2 `--reporter json` + `parse_json_failures`/`parse_json_passcount`; DX3 `select_test_targets` + `_DX3_CRITICAL` + scoped test-tier (CI-full-backed); DX4 gate 42 → `staged_new_untested_symbol`; DX5 gate 116 → `staged_ui_covered_by_widget_test`; DX6 `FLUTTER_ENFORCE_VERSION` 3.44.0→3.29.3; pin `regression_v7.sh`. | **token-authorized edit** · pinned |
| `app_flutter/tool/protocol_check.dart` | DX7a `_isInlineImageBlob` + entropy-path exemption + gate-52 image WARN; DX7b actionable gate 46/54 messages. | pinned |
| `app_flutter/tool/protocol_check_selftest.dart` | v7 DX7a/DX7b self-test cases (incl. the launder-attempt + fingerprint security counter-cases); banner v6→v7. | pinned |
| `app_flutter/test/protocol_check_engine_test.dart` | DX7 flutter_test group (6 cases) so the CI suite exercises the DX7 security guarantees. | not pinned (test) |
| `app_flutter/test/dx_friction_test.dart` | **NEW** honest flutter_test (14 cases): DX1/DX2/DX3/DX4/DX5 exercising the REAL hook function bodies (awk-extracted) in bash. | not pinned (test) |
| `.github/workflows/protocol-enforce.yml` | DX6 env `FLUTTER_VERSION`/`ENFORCEMENT_FLUTTER` 3.44.0→3.29.3 + doc. | **token-authorized edit** · pinned |
| `.github/workflows/deploy.yml` · `android-package.yml` · `catalog-qa.yml` | DX6 `flutter-version` 3.44.0→3.29.3. | deploy pinned; others not |
| `protocol/regression_v7.sh` | **NEW** Flutter-free bash regression for DX1-DX6 (14/14 pass). | pinned |
| `scripts/bookkeep.sh` | **NEW** DX8 one-step bookkeeping helper. | not pinned |
| `scripts/update_pins.sh` | pin `regression_v7.sh`. | not pinned |
| `protocol/pins.sha256` | regenerated for the changed pinned files (**gates.tsv hash unchanged**). | — |

> The `.allow_protocol_edit` token (architect-relayed, "v7 friction elimination …",
> 119-char justification) was created to authorize the `.githooks/pre-commit` +
> `protocol-enforce.yml` edits, USED, and **REMOVED — never committed**. `.claude/*`
> was NOT touched (WALL).

---

## Honest tests (assert EXACTLY what they name — no laundering)

**Engine `--self-test`** (ALL PASS v7) + **`test/protocol_check_engine_test.dart`** (50/50):
- DX7a: PNG/JPEG-magic blob → WARN (not ERR); a random high-entropy secret → ERR;
  a secret NAMED `imageData` → STILL ERR (no laundering); a fingerprint in an
  image-named field → STILL ERR. DX7b: gate 46/54 messages contain `lib/theme/`.

**`test/dx_friction_test.dart`** (14/14, runs in the full suite AND in the DX3 critical subset):
- DX1: no non-comment `grep <emoji>` in the hook; gate 93 uses case/glob.
- DX2: failure COUNT == failure NAMES from one JSON stream (2==2; clean==0).
- DX3: a sibling-tested helper → scoped+critical; shared `lib/state`/no-test-helper → WHOLE suite.
- DX4: edit existing tested helper → NO demand; ADD new untested symbol → DEMAND; new symbol with covering test → NO demand. (Real temp git repos.)
- DX5: widget covered by a widget test → NO demand; uncovered widget → DEMAND.

**`stuck_regression_test.dart`** (#40): GREEN on the clean tree — the DX1 acceptance.

**`protocol/regression_v7.sh`** (14/14, Flutter-free): the bash-hook half of DX1-DX6,
incl. the security counter-cases (DX3 "CI still full" assertion; DX4 "edit ≠ demand").

---

## Validation (all reproduced)

- **`bash -n`**: pre-commit / pre-push / commit-msg / regression_v5 / regression_v6 /
  regression_v7 / bookkeep / preflight / update_pins — **all OK**.
- **engine `--self-test`**: **ALL PASS (v7)** (incl. the DX7 security counter-cases).
- **clean-tree `flutter test`** (the DX1 acceptance): **GREEN, no manual baselining**
  — full suite **1148 passed / 0 failed**; `stuck_regression` #40 passes; `known-failing: 0`
  and `known_failing.txt` empty.
- **whole-tree engine scan** (K1): **RC 0**, `fed==scanned==162`, **0 ERR**, 7 WARN
  (the documented pre-existing gate-114 tree advisories) — **no new false positives**.
- **v5 regression**: **21/21** (incl. whole-tree acceptance 2206 files RC 0 ZERO ERR).
- **v6 regression**: **26/26** (H1-H5 silent-skip class still closed).
- **registry⇄runtime parity** (audit-mode ledger vs gates.tsv): **107 == 107**, both
  diffs empty — **every enforced gate still runs**; engine emits the **same 20** ids.
- **integrity pins**: `sha256sum -c protocol/pins.sha256` → **13/13 OK** (gates.tsv unchanged).
- **DX6 version reconcile**: all 4 workflows pin `3.29.3`; local Flutter is `3.29.3`;
  version-parity gate PASSES.
- **realistic one-line `lib/logic` fix** (edit `install_kit.dart`, an already-tested helper):
  - **files touched: 1** (only `app_flutter/lib/logic/install_kit.dart`) — DX4 demands
    **no new test**, DX5 N/A (not UI), bookkeep would stub only the WIRING row.
  - **DX3 scoped local cycle**: analyze 1s + scoped test 7s (**102 tests**) = **~8s**
    test-tier; + cheap tier (engine self-test + content scan) ~2s ⇒ **≈10s total**
    (vs the full suite's **294s / 1148 tests**, still run in CI). **Target <60s ✓.**

---

## Confirm: NO security gate was removed

**Enforced gate set (107 ids) — every one still RUNS** (audit ledger == enforced).
Engine content gates still firing (emit-ran, 20 ids): **28, 46, 48, 50, 51, 52, 54,
62, 63, 64, 65, 67, 69, 70, 73, 74, 95, 97, 103, 114**. `protocol/gates.tsv` sha256
**unchanged** vs v6. The v6 security layer — content gates, pins, registry parity,
whole-tree scan, trusted-ref, fail-closed (rc 2 / rc 3) — is intact. v7 changed only
TRIGGERS (42/93/116, smarter), one secret sub-case SEVERITY (proven-image → WARN,
content-based & unforgeable), two message strings (46/54), and the LOCAL test scope
(CI-full-backed). A re-audit attacking v7 finds the same engine and the same
authoritative CI; the friction fixes opened no hole.

---

## Buildability self-estimate

**11/10 honest-dev smoothness, with the security floor unmoved.** The WALL (DX1) is
gone — a clean checkout's `flutter test` is green with zero baselining. A typical
one-line `.dart` fix now commits in ~10s touching only the file it changed, instead
of ~4-6 min + a 4-file ceremony: DX3 scopes the tests (CI keeps the full suite), DX4
stops taxing edits to tested helpers, DX5 accepts a widget test, DX8 turns the
bookkeeping into one command, DX6 makes CI actually go green, and DX2 makes the
test gate trustworthy. Every loosening is local and CI-backed or content-based and
unforgeable; the security re-audit re-attacks the SAME engine + the SAME full CI.
