# Design — Dimension 2: Knowledge & Onboarding, built RIGHT

> **Layer scope.** This document designs *how the orchestrator system discovers and grounds the
> knowledge it needs to operate on a target repo* — and how that knowledge is turned into **mechanism
> (config/schema/manifest/tool the runtime enforces), not prose** ("e.g. read WIRING.md"). It is the
> input layer that every other layer (audit, validate, gate, push) consumes. If this layer is prose,
> every layer downstream inherits an unbounded, un-auditable assumption.
>
> **The hard lesson, applied to knowledge.** The v2 red-team verdict was "8/9 dimensions still PARTIAL
> because the fixes were prose, not mechanism." For *Knowledge* specifically, the prose holes are:
> - §0 of the PLAYBOOK says *"read the project's rules (**e.g.** `WIRING.md` / `RULES.md`)"* — an
>   `e.g.` is not a procedure. Two orchestrators discover two different rule-sets; nothing fails if one
>   reads nothing.
> - *"Green" = analyze 0 + tests + build* is **defined in a comment** inside one Flutter-hardwired
>   script. The definition lives nowhere a different stack can find it; "adapt before use" is a hope.
> - The **lens set is unenumerated.** The PLAYBOOK says "N disjoint lenses" but never says *which*.
>   The orchestrator picks lenses ad hoc each run → it can silently under-audit and *nothing detects
>   the gap*. (RED-TEAM HIGH: "a named hole is still a hole" — an *unnamed* lens is an invisible hole.)
> - **Invariants are discovered by vibe.** "verbatim-from-legacy strings" is real for THIS repo
>   (Hebrew leaves), but the orchestrator has no machine list of which files/regions are invariant, so
>   a validator's "LEGACY-FAITHFUL vs INTERNAL-BUG" call is a judgment with no ground truth to check.
>
> This design replaces each of those with an artifact a script reads and a gate enforces.

---

## 0. The one idea

**A repo is not safe to operate on until it has declared, in a machine-readable manifest, (a) where its
ground truth lives, (b) what "green" means for its stack, and (c) which regions are invariant. Discovery
is a *procedure that emits that manifest*; grounding is *reading the manifest, not guessing*; and a
preflight gate REFUSES the pipeline if the manifest is absent, malformed, or stale.**

Everything below is the concrete form of that idea. The central new artifact is **`.orchestrator/knowledge.yaml`**
(the **Knowledge Manifest**, "the KM") plus three things that make it trustworthy: a **JSON-Schema** that
validates it, a **discovery tool** (`km-discover`) that *proposes* it from the repo, and a **preflight
gate** (`km-preflight`) that *blocks the pipeline* without a valid one. The KM is the single source of
truth that the old prose pointed at vaguely.

---

## 1. Architecture — components, contracts, enforcement points

### 1.1 Components

| # | Component | Kind | Replaces (former prose) |
|---|-----------|------|--------------------------|
| C1 | **`.orchestrator/knowledge.yaml`** — the Knowledge Manifest (KM) | committed config in target repo | "e.g. WIRING.md / RULES.md" |
| C2 | **`schema/knowledge.schema.json`** — JSON-Schema for the KM | schema in orchestrator kit | (nothing — was unvalidated) |
| C3 | **`lenses/registry.yaml`** — the canonical, enumerated **Lens Taxonomy** | config in orchestrator kit | "N disjoint lenses" (unenumerated) |
| C4 | **`km-discover.sh`** — discovery tool: scans repo, emits a *proposed* KM + a coverage report | shell + small probes | "identify the repo / read the rules" (manual) |
| C5 | **`km-preflight.sh`** — preflight **gate**: validates KM vs schema, checks freshness, prints the resolved facts; **exit≠0 blocks the run** | shell gate | §0 "log these as session facts" (unenforced) |
| C6 | **`green.policy` block inside the KM** + **`central-verify.sh` reads it** | config + script change | "green" defined in a code comment, hardwired Flutter |
| C7 | **`invariants[]` block inside the KM** + **`invariant-check.sh`** (a real diff-region guard) | config + tool | "respect verbatim legacy strings" (vibe) |
| C8 | **`lens-coverage.sh`** — maps the run's auditor lens-IDs against C3 and **fails on an uncovered required lens** | shell gate | (nothing — under-audit was undetectable) |
| C9 | **`km.lock` / `_run.json.km_digest`** — provenance pin: the SHA of the KM the run was planned against | state file field | (nothing — KM could drift mid-run) |

### 1.2 The contracts (data shapes the components exchange)

**The Knowledge Manifest `.orchestrator/knowledge.yaml`** — the load-bearing artifact. Concrete shape:

```yaml
# .orchestrator/knowledge.yaml  — committed to the TARGET repo, at repo root.
schema_version: 1                      # matched against schema/knowledge.schema.json
generated_by: km-discover@<sha>         # provenance: tool + version that proposed this
reviewed_by: human|none                 # see §3 honest-limit H1 — invariants need a human sign-off
generated_at: 2026-06-05T00:00:00Z

repo:
  root: .                               # relative to this file
  default_branch: main                  # km-preflight cross-checks against origin/HEAD (no trust)
  live_branch: claude/whats-happening-LyY9G
  apps:                                 # MULTIPLE app dirs are first-class (PLAYBOOK §0: "may be >1")
    - id: flutter
      dir: app_flutter
      stack: flutter                    # selects the green.policy preset + lens applicability
      status: active                    # active|reference|frozen — fixers may only write to 'active'
    - id: preact
      dir: app
      stack: node-vite-ts
      status: reference                 # bugfix-only; out-of-scope for feature work (mirrors CLAUDE.md)

# ─── (C6) "GREEN" AS CONFIG, not a code comment ───────────────────────────────
green:
  flutter:                              # keyed by app.stack
    deps:    "flutter pub get"
    analyze: { cmd: "flutter analyze --no-fatal-infos --no-fatal-warnings", error_regex: "error •", max_errors: 0, trust_exit_code: true }
    test:    { cmd: "flutter test --reporter=compact", must_pass: true }
    build:   { cmd: "flutter build web --release", artifact: "build/web/main.dart.js" }
    fingerprint: { file: "pubspec.yaml", must_contain: "^name:" }   # scope-targeting trap guard
  node-vite-ts:
    deps:    "npm ci"
    analyze: { cmd: "npx tsc -b --noEmit", error_regex: "error TS", max_errors: 0, trust_exit_code: true }
    test:    { cmd: "npm test --silent", must_pass: true }
    build:   { cmd: "npm run build", artifact: "dist/assets/index-*.js" }
    fingerprint: { file: "package.json", must_contain: "\"name\":" }
    extra_gate:                         # project-specific hard gate (mirrors CLAUDE.md smoke 21/21)
      - { cmd: "node smoke-settings.mjs", expect_substr: "21/21 PASS" }

# ─── ground-truth knowledge sources the auditors/validators must read FIRST ───
knowledge_sources:                      # (C1 core) — the explicit, enumerated answer to "e.g. WIRING.md"
  - { id: wiring,   path: app_flutter/WIRING.md,                 role: state,    required: true }
  - { id: parity,   path: app_flutter/knowledge/PARITY.md,       role: invariant-spec, required: true }
  - { id: rules,    path: app/RULES.md,                          role: rules,    required: true }
  - { id: port,     path: app_flutter/knowledge/port/,           role: corpus,   required: false }
  - { id: legacy_strings, path: app/src/components/menu/,        role: invariant-source, required: true }

# ─── (C7) INVARIANTS AS CONFIG — machine-checkable, not "respect the vibe" ─────
invariants:
  - id: verbatim-hebrew-leaves
    kind: byte-region                   # the protected bytes must not change without explicit waiver
    applies_to:                         # globs; invariant-check.sh diffs these regions
      - "app_flutter/lib/**/*_strings.dart"
      - "app/src/components/menu/**"
    rule: "Hebrew/legacy leaf strings are verbatim from the live Preact app. A diff that ALTERS an
           existing string (vs adds a new one) is an INVARIANT BREAK unless waived."
    authority_source: { id: legacy_strings }   # where 'the truth' is (for LEGACY-FAITHFUL adjudication)
    waiver_label: "INVARIANT-WAIVER: verbatim-hebrew-leaves"   # must appear in the commit msg to pass
  - id: no-push-to-default
    kind: assertion
    rule: "Never ff-push to repo.default_branch without human ALLOW_PROTECTED (handled by ff-push.sh)."
  - id: single-source-of-truth
    kind: pattern-absence
    applies_to: ["app_flutter/lib/store/**"]
    forbid_regex: "// *DUPLICATE STATE"   # example; project declares its own anti-pattern markers

# ─── (C3 binding) which lenses are REQUIRED for this repo (subset of the taxonomy) ──
lenses:
  profile: web-app-flutter              # named preset in lenses/registry.yaml
  required: [logic-correctness, state-management, wiring-completeness, i18n-invariant,
             security-authz, error-handling, dead-control, build-config, test-coverage,
             accessibility, perf-hotpath, dependency-freshness]
  waived:                               # a lens may be skipped ONLY with a written reason (kept, never silent)
    - { id: native-ffi, reason: "no platform-channel/FFI code in this repo (verified: 0 MethodChannel)" }

freshness:
  recheck_volatile_after_days: 30       # version pins, dep freshness — re-verify if KM older than this
  volatile_fields: [green, knowledge_sources, lenses.required]
```

**The Lens Registry `lenses/registry.yaml`** — the canonical taxonomy (full content in §2.2).

**`_run.json` additions** (the orchestrator's durable state, already in §0): add
`km_path`, `km_digest` (sha256 of the resolved KM at planning time), `km_preflight: PASS|FAIL`,
`lenses_planned: [...]`, `lenses_returned: [...]`, `lens_coverage: PASS|GAP`.

### 1.3 Enforcement points (where each contract is *forced*, not suggested)

```
                    target repo
                         │
          ┌──────────────┴───────────────┐
          │  (P0) km-discover.sh  →  proposes .orchestrator/knowledge.yaml + coverage gaps
          │        (human/orchestrator reviews invariants — H1)                │
          └──────────────┬───────────────┘                                    │
                         ▼                                                     │
   ┌───────────── (P1) km-preflight.sh  ── EXIT≠0 BLOCKS the whole pipeline ───┘
   │   validates KM vs JSON-Schema · checks freshness · cross-checks default_branch
   │   vs origin/HEAD · resolves & PRINTS the facts · writes km_digest into _run.json
   ▼
 PLAYBOOK §0 onboarding  ── reads the RESOLVED facts from preflight output, not from "e.g." prose
   │
   ▼
 AUDIT fan-out  ── each auditor is handed exactly ONE lens-ID FROM lenses.required (C3)
   │             ── auditor.md output contract REQUIRES echoing its lens_id back
   ▼
 (P2) lens-coverage.sh  ── set(lenses_returned) ⊇ set(lenses.required \ waived)?  GAP ⇒ run = PARTIAL
   │                       (the orchestrator CANNOT report CLEAN with an uncovered required lens)
   ▼
 FIX fan-out  ── fixers may write only to apps where status==active
   ▼
 (P3) invariant-check.sh  ── after fixers, before the gate: any byte-region invariant broken
   │                          without its waiver_label in the commit msg ⇒ HARD FAIL
   ▼
 (P4) central-verify.sh  ── now reads green.<stack> FROM THE KM (C6); fingerprint asserted
   ▼
 ship / verify-deploy   ── artifact path comes from green.<stack>.build.artifact (no guessing)
```

The four gate points **P1–P4 are scripts that exit non-zero**. That is the difference from v2: knowledge
is not "established as a session fact in the orchestrator's head" (prose) — it is *resolved by a tool,
pinned by a digest, and re-checked by gates that fail the run*.

---

## 2. Mechanisms — one per former-prose item

For each item: **the prose it replaces · the mechanism · the contract/format · what's a quick
config/shell change vs. what is a real build.**

### 2.1 Knowledge discovery & grounding → the KM + `km-discover` + `km-preflight`

**Former prose** (PLAYBOOK §0): *"read the project's rules (e.g. WIRING.md / RULES.md / the legacy-string
parity source) BEFORE fan-out"* and *"identify the repo root, the active app dir(s)…, the live branch."*

**Why prose fails here:** `e.g.` enumerates nothing; "identify" is an instruction to a model, not a
procedure. Two runs ground on two different doc-sets; a run that grounds on *nothing* still "passes" §0.

**Mechanism — three parts:**

1. **`km-discover.sh <repo>` (DISCOVERY as a real procedure).** Scans the repo and emits a *proposed*
   `.orchestrator/knowledge.yaml` plus a **coverage report** of what it could and could not infer.
   Concretely it probes:
   - **App dirs & stacks:** find every dir with a `pubspec.yaml` / `package.json` / `go.mod` / `Cargo.toml`;
     map to a `stack`. (`Glob`+test — deterministic.)
   - **Branches:** `git symbolic-ref refs/remotes/origin/HEAD` → `default_branch`; current → `live_branch`.
   - **Knowledge sources:** grep the repo for the *conventional* truth files by a **search list** (not a
     single name): `WIRING.md`, `RULES.md`, `STATUS*.md`, `PARITY.md`, `ARCHITECTURE*.md`, `CLAUDE.md`,
     any `knowledge/` dir. Each hit becomes a `knowledge_sources[]` entry with `required: false` until a
     human/orchestrator promotes it. **The search list itself is config** (`km-discover.conf`) so it grows
     without editing the tool.
   - **Invariant candidates:** detect verbatim/legacy patterns it cannot self-verify (e.g. files dense with
     non-ASCII string literals → candidate `byte-region` invariant) and emit them **flagged for human
     review** (never auto-`required`).
   - **Green preset:** pick the `green.<stack>` preset from a built-in library keyed by detected stack.
   The tool's last line is a machine summary: `DISCOVERED apps=2 sources=5 invariant-candidates=1
   lenses-preset=web-app-flutter UNRESOLVED=[invariants.reviewed_by]`.

2. **`schema/knowledge.schema.json` (VALIDATION).** A JSON-Schema (draft 2020-12) that the KM must satisfy:
   required keys, enum for `stack`/`status`/`kind`/`role`, `lenses.required` must be a subset of the
   registry IDs, every `invariants[].authority_source.id` must resolve to a `knowledge_sources[].id`,
   every `apps[].dir` must exist. Validated by `ajv` (or a vendored ~40-line Python validator to avoid a
   node dep). **This is the mechanism that makes "malformed knowledge" a hard failure instead of a silent
   misread.**

3. **`km-preflight.sh <repo>` (THE PREFLIGHT GATE — P1).** Run as the very first pipeline step, before
   any fan-out. It:
   - asserts `.orchestrator/knowledge.yaml` exists (absent ⇒ `BLOCK: no knowledge manifest — run km-discover, review, commit`);
   - validates it against the schema (fail ⇒ BLOCK with the schema error);
   - **cross-checks ground truth, doesn't trust the file:** `repo.default_branch` must equal the live
     `git symbolic-ref … origin/HEAD` (mismatch ⇒ BLOCK — protects every downstream branch decision);
     every `apps[].dir` and every `required: true` `knowledge_sources[].path` must exist on disk;
   - **freshness:** if `now - generated_at > freshness.recheck_volatile_after_days`, emit
     `STALE: volatile fields may be out of date — re-run km-discover or bump generated_at after review`
     (this is the Knowledge-dimension *recency* rule, mechanized: §2.5/§2.6 of the spec — "track volatile
     knowledge, re-verify across sessions");
   - **prints the fully resolved facts** (apps, branches, sources, green policy in effect, required lenses)
     and writes `km_digest = sha256(resolved-KM)` into `_run.json`. The orchestrator's §0 now consists of
     *reading this output*, not of independently "identifying" anything.

   The digest pin (C9) closes a Memory/Knowledge hole: if `.orchestrator/knowledge.yaml` changes
   mid-run, the next gate re-reads it, the digest mismatches `_run.json.km_digest`, and the run flags
   `KM-DRIFT` instead of silently operating on a moved foundation (mirrors the spec's "propagate belief
   updates / don't silently revert" rules).

**Build classification:**
- *Quick (shell/config):* `km-preflight.sh`, `km-discover.sh`, `km-discover.conf` (the search list),
  the `green.*` preset library. ~a day. These are the high-leverage 80%.
- *Real build:* `schema/knowledge.schema.json` + a vendored validator (small but must be correct and
  tested) and the **invariant-candidate detector** in `km-discover` (heuristics → needs its own
  fixtures). ~2–3 days incl. tests.

**Honest limit (contained):** discovery *proposes*; it cannot *know* a project's true invariants or which
doc is authoritative — that is human/architect judgment (H1, §3). Containment: invariants and
`required: true` sources land in the KM only after `reviewed_by: <human>`; `km-preflight` BLOCKs while
`reviewed_by: none` on any repo that declared `byte-region` invariants. So an unreviewed guess can never
silently govern a run.

### 2.2 The Lens Taxonomy → `lenses/registry.yaml` (enumerated, machine-readable) + `lens-coverage.sh`

**Former prose** (PLAYBOOK step 1): *"N agents/auditor.md, each a disjoint lens."* — the set of lenses is
nowhere written. **This is the single biggest knowledge hole**: the orchestrator chooses lenses by intuition
each run, so it can under-audit (skip "security", skip "i18n-invariant") and *no mechanism notices*. "A
named hole is still a hole" — an *un-enumerated* lens is a hole with no name at all.

**Mechanism — `lenses/registry.yaml`: the canonical, enumerated, versioned taxonomy.** Each lens is a
record the auditor and the coverage gate both key on:

```yaml
# lenses/registry.yaml  — the orchestrator kit's canonical audit taxonomy. Versioned; PRs add lenses.
taxonomy_version: 1
lenses:
  - id: logic-correctness
    title: "Core logic & control flow"
    question: "Does each function/branch compute the right result for its real inputs, incl. edge cases?"
    signals: ["off-by-one", "inverted condition", "wrong operator", "unhandled nil/empty"]
    applies_when: { always: true }
    disjoint_group: behavior          # lenses in the same group must not overlap files-of-concern
  - id: state-management
    title: "State, lifecycle, reactivity"
    question: "Is state the single source of truth; are updates propagated; no stale/duplicated copies?"
    signals: ["duplicated state", "missing notify/listen", "stale closure", "lifecycle leak"]
    applies_when: { stack_in: [flutter, node-vite-ts] }
    disjoint_group: behavior
  - id: wiring-completeness
    title: "Controls wired to real backing"
    question: "Does every interactive control DO something real, or is it an honest placeholder?"
    signals: ["onTap empty", "styled-but-dead button", "fake success toast"]
    applies_when: { always: true }
    disjoint_group: behavior
  - id: i18n-invariant
    title: "Localization / verbatim-string invariants"
    question: "Are legacy/verbatim strings byte-faithful to their authority source?"
    signals: ["altered legacy string", "machine-translated leaf", "hardcoded English in i18n app"]
    applies_when: { invariant_kind: byte-region }   # auto-required iff the KM declares such an invariant
    disjoint_group: content
  - id: security-authz
    title: "AuthZ / secrets / injection"
    question: "Are privileged actions gated; no secrets in bytes; inputs sanitized?"
    signals: ["missing auth check", "hardcoded token", "unsanitized interpolation", "env-bypass"]
    applies_when: { always: true }
    disjoint_group: cross-cutting
  - id: error-handling
    title: "Failure & edge handling"
    question: "Are errors caught, surfaced honestly, and recovered — not swallowed?"
    signals: ["empty catch", "swallowed await", "silent default on error"]
    applies_when: { always: true }
    disjoint_group: behavior
  - id: dead-control
    title: "Dead / unreachable / orphaned"
    question: "Any unreachable branches, orphaned components, controls with no route in?"
    signals: ["unreferenced widget", "unreachable case", "dangling route"]
    applies_when: { always: true }
    disjoint_group: structure
  - id: build-config
    title: "Build, deps, config integrity"
    question: "Do build/config/manifest files agree; no broken or contradictory config?"
    signals: ["version skew", "missing asset decl", "contradictory flags"]
    applies_when: { always: true }
    disjoint_group: structure
  - id: test-coverage
    title: "Test presence on changed paths"
    question: "Do the riskiest paths have tests; where's the coverage gap the gate won't catch?"
    signals: ["untested branch", "assertion-free test", "test disabled/skipped"]
    applies_when: { always: true }
    disjoint_group: cross-cutting
  - id: accessibility
    title: "A11y / semantics"
    question: "Semantics labels, focus order, contrast, RTL correctness?"
    signals: ["missing semanticLabel", "no focus", "LTR widget in RTL app"]
    applies_when: { stack_in: [flutter, node-vite-ts] }
    disjoint_group: content
  - id: perf-hotpath
    title: "Performance hot paths"
    question: "Rebuild storms, N+1, sync work on the UI thread, unbounded growth?"
    signals: ["build() allocation", "O(n^2) in hot loop", "unbounded cache"]
    applies_when: { always: true }
    disjoint_group: cross-cutting
  - id: dependency-freshness
    title: "Dependency / API recency"
    question: "Are pinned deps/APIs current & non-deprecated for the stack? (VOLATILE — verify, don't recall)"
    signals: ["deprecated API", "EOL pin", "CVE-flagged version"]
    applies_when: { always: true }
    disjoint_group: cross-cutting
    requires_fetch: true              # this lens MUST fetch (spec 2.3 fetch-or-recall): recency-critical
  - id: native-ffi
    title: "Platform channels / FFI"
    question: "Native bridges typed, null-safe, lifecycle-correct across platforms?"
    signals: ["unchecked MethodChannel", "FFI memory leak"]
    applies_when: { code_present_regex: "MethodChannel|dart:ffi" }
    disjoint_group: behavior

profiles:                              # named bundles a KM can reference by one word
  web-app-flutter: [logic-correctness, state-management, wiring-completeness, i18n-invariant,
                    security-authz, error-handling, dead-control, build-config, test-coverage,
                    accessibility, perf-hotpath, dependency-freshness]
  service-backend:  [logic-correctness, state-management, security-authz, error-handling,
                     dead-control, build-config, test-coverage, perf-hotpath, dependency-freshness]
```

**`applies_when` is the anti-under-audit mechanism.** It is machine-evaluable: `always`, `stack_in`,
`invariant_kind` (auto-require i18n-invariant the moment a `byte-region` invariant exists),
`code_present_regex` (auto-require native-ffi iff `MethodChannel|dart:ffi` is grepped present, else it is
*legitimately* waivable with the grep count as proof — exactly the `native-ffi` waiver in the example KM).
So "which lenses must run" is **derived, not chosen**: `km-preflight` computes
`required = profile ∪ {lens : applies_when(lens, repo) is true}` and writes it to `_run.json`. The
orchestrator no longer gets to *forget* the security lens.

**`lens-coverage.sh` (P2 — the gate that makes under-audit impossible).** After the audit fan-out, the
orchestrator records `lenses_returned[]` (each auditor echoes its `lens_id` back — see §2.7 contract).
The script computes `missing = required \ (returned ∪ waived)`. If `missing` is non-empty the run is
forced to `PARTIAL` and the final report MUST list the uncovered lenses. **The orchestrator cannot emit
CLEAN with a required lens uncovered** — the status is computed by the script from the lens-IDs, not
narrated by the model. (This is the structural cousin of `central-verify` for *audit breadth* rather than
*build greenness*.)

`disjoint_group` mechanizes the PLAYBOOK's "disjoint lenses": two lenses in the same group that report
findings on the *same* file flag a `LENS-OVERLAP` warning, so the orchestrator re-partitions instead of
double-auditing one area while missing another.

**Build classification:**
- *Quick (config):* authoring `lenses/registry.yaml` itself (it is data) and the `profiles`. Half a day.
- *Real build:* `lens-coverage.sh` + the `applies_when` evaluator (it must grep the repo for
  `code_present_regex` and read the KM) and the auditor output-contract parser. ~1–2 days incl. fixtures.

**Honest limit (contained):** the taxonomy can be *complete for known failure classes* but cannot
enumerate an unknown-unknown class of bug (H2, §3). Containment: the registry is **versioned and
append-only via PR**; every red-team that finds a class with no lens files a registry PR adding it, so the
taxonomy is a *ratchet* — it only ever gets more complete, and the gap that motivated it is captured as a
named lens, never re-lost.

### 2.3 "Green" as config → `green.*` block in the KM, read by `central-verify.sh`

**Former prose:** *"'Green' = analyze 0 errors + all tests pass + artifact builds, for this project —
adapt before use"* — defined in a **code comment**, hardwired to Flutter, "adapt before use" unenforced.

**Mechanism:** the definition of green moves out of the script comment and into **`green.<stack>` in the
KM** (C6, full shape in §1.2). `central-verify.sh` becomes a thin, stack-agnostic *interpreter* of that
block:

```bash
# central-verify.sh  (re-architected): reads the KM, runs the declared green policy for the app's stack.
# usage: central-verify.sh <repo> <app-id>
APP_DIR=$(km get "apps[?id=='$APP_ID'].dir")          # km = tiny yq/jq wrapper over the manifest
STACK=$(km get "apps[?id=='$APP_ID'].stack")
G="green.$STACK"
# fingerprint (scope-targeting trap, kept from v2):
assert_file_contains "$APP_DIR/$(km get $G.fingerprint.file)" "$(km get $G.fingerprint.must_contain)"
echo "gate target: $APP_DIR · HEAD: $(git -C "$APP_DIR" rev-parse --short HEAD) · stack=$STACK"
run "$(km get $G.deps)"        || fail "deps"
run_analyze "$G"               || fail "analyze"      # honors error_regex/max_errors/trust_exit_code
run_test    "$G"               || fail "tests"
run_build   "$G"               || fail "build"        # records artifact = $G.build.artifact
for x in $(km get $G.extra_gate); do run "$x.cmd" | assert_substr "$x.expect_substr"; done
echo "GATE PASS · stack=$STACK · artifact=$(km get $G.build.artifact)"
```

Now: green for Flutter and green for the Preact app are *both first-class*, defined in one declarative
place; the `extra_gate` array captures project-specific hard gates (the `smoke-settings.mjs 21/21` from
CLAUDE.md) **as config the gate enforces**, not as a rule in a doc that the orchestrator might forget.
The deploy step reads the artifact path from `green.<stack>.build.artifact`, so "download the artifact,
not the HTML shell" (PLAYBOOK step 8) stops being a thing the model has to *remember* — it's a field.

This also fixes the RED-TEAM HIGH "central-verify was Flutter-hardwired, wrong-scope passed silently":
the fingerprint and `trust_exit_code` are preserved, but the *what* is per-stack data, so a Node repo's
gate is as hardened as the Flutter one with zero script edits.

**Build classification:**
- *Quick (config + small shell):* the `green.*` presets and the `km` accessor wrapper (`yq`/`jq` one-liner).
  ~half a day.
- *Real build:* re-architecting `central-verify.sh` into the interpreter with `run_analyze/test/build`
  honoring every policy field, plus tests proving a deliberately-broken policy fails closed. ~1–2 days.

**Honest limit (contained):** green = *consistency*, never *correctness* (the v2 caveat stands — a fix to
uncovered code can pass green). This is **not** solvable by config (H3, §3). Containment: the
`test-coverage` lens (§2.2) is *required by default*, so the audit phase actively hunts the coverage gaps
green can't see; and the PLAYBOOK's "add a test or record accepted risk" stays — but now "record" means
appending to a real `_accepted_risk.md`, surfaced in the final report, not a mental note.

### 2.4 Project-invariant discovery & enforcement → `invariants[]` + `invariant-check.sh`

**Former prose:** *"Respect project invariants … keep legacy-faithful values"*; validator told to "grep the
legacy source; classify INTERNAL-INCONSISTENCY → fix vs LEGACY-FAITHFUL → keep." The validator's call had
**no ground truth to check against** — it was a model judgment with no enforcement and no record of which
regions are sacred.

**Mechanism — two parts:**

1. **`invariants[]` in the KM (DECLARATION).** Each invariant is typed (`byte-region` / `pattern-absence` /
   `assertion`), names its `applies_to` globs and its `authority_source` (the file that *is* the truth for
   adjudication), and — for `byte-region` — a `waiver_label`. This gives the validator the missing ground
   truth: "is this string legacy-faithful?" is answered by diffing against `authority_source`, not by vibe.

2. **`invariant-check.sh` (P3 — ENFORCEMENT, the real new tool).** Runs *after* the fixers, *before* the
   gate. For each `byte-region` invariant:
   - compute the diff of `applies_to` files between the worktree HEAD and the run's base SHA;
   - classify each changed line as **ADD** (new line — allowed; the project grows) vs **ALTER/DELETE** of an
     existing string literal (a potential invariant break);
   - for an ALTER/DELETE, require **either** that the new value still matches the `authority_source`
     (legacy-faithful refactor — allowed) **or** that the commit message carries the exact `waiver_label`
     (explicit, logged human decision). Otherwise: `INVARIANT BREAK: verbatim-hebrew-leaves @ file:line`
     and **exit≠0 — the gate never runs.**
   For `pattern-absence`: grep `forbid_regex` across `applies_to`; any hit fails.

   This is the **mechanism, not the rule**: the v2 system *said* "respect invariants"; this *refuses to
   ship* a fix that silently rewrote a verbatim leaf. And it's the same shape as the push guard's lesson —
   except the bypass here (`waiver_label` in the commit message) is **logged in git history forever**,
   not an ephemeral `ALLOW_PROTECTED=1` env var a shell can set invisibly. The escape hatch is auditable.

**Build classification:**
- *Quick (config):* the `invariants[]` declarations per project. Hours.
- *Real build:* `invariant-check.sh` — the ADD-vs-ALTER diff classifier is the genuinely hard part (it must
  parse a unified diff and tell a new string literal from a changed one, per language), and it needs a
  fixture suite (a faithful refactor must pass; a silent rewrite must fail; a waived rewrite must pass).
  ~2–3 days. This is the second "real coverage-harness-class" tool in this layer.

**Honest limit (contained):** *which* regions are truly invariant is human/architect knowledge — a tool
can detect *candidates* (dense non-ASCII literals) but cannot *decide* sanctity (H1). Containment:
`invariants[]` requires `reviewed_by: <human>`; `km-preflight` BLOCKs an unreviewed invariant set. And the
ALTER classifier is necessarily heuristic per language — contained by failing **closed** (ambiguous ⇒
treat as ALTER ⇒ require waiver), so the error mode is "asks for an explicit waiver," never "ships a
silent break."

### 2.5 Grounding before asserting; volatile-knowledge recency → fields, not exhortations

Several Knowledge-spec rules (2.3 fetch-or-recall, 2.6 version/scope transposition, 2.5/2.6 volatile
recency) were never even prose in the PLAYBOOK — they're implicit. Mechanized cheaply:

- **`requires_fetch: true`** on the `dependency-freshness` lens (§2.2) operationalizes spec 2.3 ("retrieve
  before asserting for facts with a shelf life"). An auditor on that lens whose return shows no fetch
  evidence is flagged `UNGROUNDED-RECENCY` by the coverage gate. (Quick — a registry flag + a check.)
- **`freshness.volatile_fields` + `recheck_volatile_after_days`** in the KM (§1.2) operationalizes
  "track volatile knowledge; re-verify across sessions" (spec 2.5/2.6). `km-preflight` emits `STALE` and
  the run records it. (Quick — config + a date compare in preflight.)
- **`green.<stack>.fingerprint`** (kept from the hardened gate) is the concrete guard against spec 2.6
  *version/scope transposition* at the **scope** level: it refuses to run the Flutter policy against a Node
  dir. (Already partly built.)
- **`km_digest` pin** (C9) operationalizes spec 2.5 *"don't silently revert to stale state / propagate
  updates"*: the foundation the run was planned against is hashed; if it moves, the run says so. (Quick —
  one field + a compare.)

### 2.6 Onboarding sequencing → preflight output IS the onboarding, ground-truth-pinned

**Former prose:** §0 "Onboarding — establish what you don't yet know … Log these as session facts before
any fan-out." Logging to the model's context is exactly the "treating in-context memory as durable state"
anti-pattern the PLAYBOOK itself warns against.

**Mechanism:** onboarding is *reading `km-preflight`'s printed resolution* and the fields it wrote into
`_run.json` (durable, on disk). The orchestrator's §0 becomes a **checklist of preflight assertions**, each
backed by a script exit code:
1. `km-preflight` PASS (KM exists, valid, fresh, branch cross-checked) — else the run cannot start.
2. `lenses_required` computed and written — else audit cannot fan out.
3. `green.<stack>` resolved for each `active` app — else the gate cannot run.
4. `invariants[]` reviewed — else (if any `byte-region` exists) the run cannot start.

No step relies on the model "remembering" a fact; each is a field a later gate re-reads. (Quick — this is
a PLAYBOOK §0 rewrite to *consume* the mechanisms above + the `_run.json` field additions.)

---

## 3. Honest limits — what mechanism CANNOT solve, and how the design contains each

| # | Inherent limit (NOT mechanism-solvable) | Why | How the design CONTAINS it |
|---|------------------------------------------|-----|-----------------------------|
| **H1** | **What is a true invariant / which doc is authoritative is human judgment.** | A tool sees "dense non-ASCII literals"; it cannot know those Hebrew strings are *sacred verbatim copies of a live app*. That is product/architect knowledge. | `km-discover` only *proposes*; `invariants[]` and `required:true` sources need `reviewed_by:<human>`; `km-preflight` **BLOCKs** an unreviewed invariant set. A guess can never silently govern. The human decision, once made, becomes machine-enforced (§2.4). |
| **H2** | **The lens taxonomy cannot enumerate unknown-unknown bug classes.** | You can only require lenses for failure modes someone has named. A novel class has no lens, so coverage can be "100% of required" yet miss it. | Registry is **versioned + append-only via PR**: every red-team gap files a lens. It's a *ratchet* — completeness only increases, and each newly-found class is captured as a named lens, never re-lost. The system reports coverage *of the known taxonomy*, honestly labeled, never "complete." |
| **H3** | **"Green" proves consistency, never correctness.** | A passing build+tests can't see a bug on an untested path. No config makes green mean correct. | `test-coverage` lens required by default (audit hunts the gaps green can't see); unfixable gaps recorded in a real `_accepted_risk.md` surfaced in the final report. Green is *necessary, declared as insufficient.* |
| **H4** | **`applies_when` / invariant ALTER-detection are heuristics; an adversary can dodge a regex.** | `code_present_regex:"MethodChannel"` misses a reflectively-built channel; a diff classifier can be fooged by an obfuscated literal. | **Fail closed:** ambiguous invariant diff ⇒ treat as ALTER ⇒ demand a waiver; a waived-out lens needs a *written, kept* reason with grep-count proof. Error mode is "demands explicit human sign-off," never "silently passes." |
| **H5** | **The underlying model can mis-read a manifest or mis-narrate coverage.** | Same ceiling as the whole study — prompts/specs approach robustness, never transcend model capability. The orchestrator could still *say* "all lenses covered" wrongly. | Don't trust the narration: **status is computed by scripts** (`lens-coverage.sh` from echoed lens-IDs; `central-verify`/`invariant-check` exit codes), not asserted by the model. The supervisor (`agents/supervisor.md`) re-runs the gates against the bytes. A model lie about coverage is caught by the coverage gate, exactly as a fix lie is caught by grep+tests. |
| **H6** | **A repo with NO knowledge artifacts and no human to review.** | First contact with an undocumented repo: discovery proposes, but nobody can sign off invariants. | Degrade *safely, loudly*: `km-preflight` runs in `--unreviewed` mode → proceeds **only** with `invariants:[]` empty and emits `UNREVIEWED-REPO: invariant protection OFF; i18n-invariant lens cannot ground`. The run is allowed but its report is stamped degraded — the *absence* of grounding is itself surfaced, never hidden. |

The throughline: every limit is contained by **failing closed and surfacing the gap**, so the *unsolvable*
part is always *visible* — which is precisely the Knowledge core principle ("knows what it does not know;
acknowledged ignorance over confident confabulation").

---

## 4. Build order (highest safety/leverage first; with dependencies)

Ordered so each step is usable on its own and unblocks the next. **B1–B3 are the quick, highest-leverage
shell/config layer; B4–B6 are the real tooling.**

| Step | Build | Kind | Depends on | Why this order (leverage) |
|------|-------|------|------------|----------------------------|
| **B1** | `lenses/registry.yaml` (the enumerated taxonomy) + `profiles` | config | — | **Highest leverage, zero risk.** The moment lenses are enumerated, "under-audit" stops being invisible even before the gate exists — the orchestrator has a checklist. Pure data; nothing depends on tooling. |
| **B2** | `.orchestrator/knowledge.yaml` for THIS repo (the two apps, green presets, sources, invariants) + `green.*` preset library | config | B1 (references lens IDs/profile) | Turns every former "e.g." into a concrete enumerated list for the real target. Authoring data, not code. |
| **B3** | `schema/knowledge.schema.json` + vendored validator + `km-preflight.sh` (P1) | shell + schema | B1, B2 | **First gate.** Makes a malformed/absent/stale KM a hard BLOCK and cross-checks the default branch — the cheapest, broadest safety win. Schema is the only "real build" bit here. |
| **B4** | `central-verify.sh` re-architected to read `green.<stack>` (C6) + `km` accessor | real build | B2, B3 | The existing gate, now stack-agnostic & multi-app. High value, moderate build; needs the KM (B2) and preflight (B3) to resolve the policy. |
| **B5** | `lens-coverage.sh` (P2) + `applies_when` evaluator + auditor lens-ID echo contract | real build | B1, B3 | **Closes the under-audit hole structurally.** Needs the registry (B1) and the resolved `required` set from preflight (B3). Makes CLEAN-with-a-missing-lens impossible. |
| **B6** | `invariant-check.sh` (P3) — the ADD-vs-ALTER diff classifier | real build (hardest) | B2 (invariants[]), B3 | Last because it's the most complex (per-language diff parsing + fixtures) and only bites at fix-time. Until it lands, invariants are *declared + human-reviewed* (B2/B3) but not byte-enforced — a known, stated interim gap. |
| **B7** | `km-discover.sh` + `km-discover.conf` + invariant-candidate heuristics | real build | B1–B6 (emits artifacts they consume) | **Last, deliberately.** Discovery is a *convenience* that bootstraps the KM for a *new* repo; the *enforcement* spine (B1–B6) is what delivers safety and must exist first so discovery's output has gates to flow into. Building discovery before enforcement would be polishing the on-ramp before laying the road. |

**Critical path for safety:** B1 → B3 → B5 (enumerate lenses → block on bad knowledge → make under-audit
detectable). Those three, all mostly shell/config, deliver most of the Knowledge-layer protection. B4 and
B6 are the two genuine builds (the stack-agnostic gate interpreter and the invariant diff classifier); B7
is the bootstrapping convenience that comes last.

**Cross-layer handoffs:** this layer *produces* `_run.json.{km_digest, lenses_required, lens_coverage}`
and the resolved `green` policy, which the **Reliability** (gate/verify) and **Safety** (push/authz)
layers consume; it *consumes* nothing from them except the existing `ff-push`/`worktree` primitives. The KM
is the contract; if another layer needs a project fact, it reads the KM, never re-discovers.
