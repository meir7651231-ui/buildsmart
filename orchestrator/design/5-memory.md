# Dimension 5 — STATE & PERSISTENCE, built RIGHT

**Scope of this layer.** Everything that must outlive a single agent turn or a destroyed container:
the **resumable checkpoint**, the **resume protocol**, the **provenance store** (sub-agent payloads on
disk), and the **phase guards** that make the pipeline restart-safe. This is the answer to red-team
CRITICAL #4: *"no state persistence → an ephemeral-container interruption = total restart."*

The shipped "fix" for #4 is **prose**: PLAYBOOK §0 says *"Write a run-state file (`_run.json`…); on
resume, read it first."* That is a named convention with **zero enforcement** — an orchestrator that
forgets it, writes it late, writes it malformed, or never reads it on resume violates nothing. A named
hole is still a hole. This document replaces the convention with **mechanism**: a typed checkpoint a
script writes-and-validates, append-only provenance the orchestrator cannot retro-edit, and phase
guards that **refuse to run the next stage unless the checkpoint proves the previous one completed.**

> Design rule observed throughout (the v1→v6 lesson): where I can make the machine enforce it, I write
> a script/schema/guard. Where only the model can do it (judgment, honest narration), I say so plainly
> in §C and show how the mechanism *contains* the failure instead of pretending to prevent it.

---

## A. ARCHITECTURE — what is persisted, where, and the schema

### A.0 The three tiers, mapped onto THIS system (per dimension 5.1)

| Tier (5.1) | In this orchestrator | Lives in | Lifetime |
|---|---|---|---|
| **Working context** | the orchestrator's conversation window | RAM / model context | one turn; **lost on container death** — never treated as durable |
| **Episodic** | what each phase did + each sub-agent returned, timestamped | `state/checkpoint.json` (phase log) + `prov/*.json` (payloads) | one pipeline run |
| **Semantic** | run-invariant facts: goal anchor, repo/branch/scope, pinned project invariants | `state/checkpoint.json` `anchor` + `facts` blocks | one run; `facts` re-injected after every compaction |

The orchestrator's context window is **finite and lossy by design** (5.1). The whole layer exists so
that the durable tiers are the source of truth and context is just a fast cache over them. *"Treating
in-context memory as durable state"* is a named PLAYBOOK anti-pattern; this layer is what makes that
rule have teeth.

### A.1 The durability question — WHERE, and why it survives a restart

Ground truth (verified in this very worktree):

```
$ cat /home/user/wt-rt2/.git
gitdir: /home/user/buildsmart/.git/worktrees/wt-rt2
$ git rev-parse --git-common-dir   →  /home/user/buildsmart/.git
```

The **container is ephemeral; the shared git directory is not.** A worktree's private admin dir lives
at `<common-git-dir>/worktrees/<name>/`. That gives a place that is (a) on durable shared storage that
outlives the container, (b) **outside the working tree**, so checkpoint files can never appear in
`git diff --name-only` (which PLAYBOOK 4b asserts must equal the fix partition — a stray file there is
a false "out-of-scope edit"), and (c) **impossible to commit by accident** (it is not a tracked path).

**Canonical state root** — computed, never hard-coded:

```bash
STATE_DIR="$(git -C "$WT" rev-parse --git-path orchestrator-state)"   # → <common>/worktrees/<wt>/orchestrator-state
```

`git rev-parse --git-path` resolves the per-worktree admin dir correctly in **both** the
flattened (Claude Code) and nested (SDK) runtimes, and for a detached worktree (this run is detached
HEAD) — so the same line works everywhere. Layout under `$STATE_DIR`:

```
orchestrator-state/
├── checkpoint.json        # THE checkpoint — typed, validated, atomically written (the schema, §A.3)
├── checkpoint.json.bak    # last-known-good copy (kept by the writer before each overwrite)
├── checkpoint.schema.json # JSON Schema; the validator enforces it on every write & every resume
├── journal.ndjson         # append-only phase-transition journal (audit trail; never rewritten)
├── prov/                  # PROVENANCE store — one immutable file per sub-agent payload (§A.4)
│   ├── audit/  validate/  fix/  supervise/
│   └── INDEX.ndjson       # append-only index: which payloads exist, their hash, verdict
├── locks/RUN.lock         # single-writer lock (PID + heartbeat) — prevents two orchestrators on one run
└── findings.md confirmed.md backlog.md   # human-readable views, DERIVED from checkpoint (not authoritative)
```

> **One source of truth per state** (a PLAYBOOK hard rule). `checkpoint.json` is canonical for *machine
> state*; `findings.md`/`confirmed.md`/`backlog.md` are **derived views** regenerated from it (§B.6), so
> they cannot drift. This corrects the *current* kit, which names `_findings.md`/`_confirmed.md` as if
> they were primary — two parallel stores that can disagree.

A second, run-independent semantic store (`facts.ndjson`) lives in the **repo's** common dir, keyed by
project, for facts that should survive across runs (e.g. "default branch is X", "gate adapter verified
for this stack on <sha>"). It is the only cross-run memory and is explicitly small and inspectable.

### A.2 What is persisted, and exactly WHEN (the write points)

A checkpoint write is forced at **every phase boundary** — but "forced" here is not a request to the
model, it is **the phase guard refusing to advance otherwise** (§B.3). Write points = the pipeline
seams in PLAYBOOK: `init → setup → audit → synthesize → validate → fix → byteverify → gate → docs →
authorize → push → verifydeploy → done`. At each seam the orchestrator calls `ckpt advance`, which
validates, atomically swaps, and appends to the journal. Between seams, **sub-agent payloads** are
written the instant a sub-agent returns (§A.4) — before the orchestrator does anything with the
content — so a crash mid-phase still leaves every returned payload on disk.

### A.3 THE CHECKPOINT SCHEMA (`checkpoint.json`)

Real JSON Schema (Draft 2020-12), enforced by `ckpt` on every write and every resume. Field rationale
follows dimension-5 directly (decisions-not-just-facts 5.2; provenance 5.3; anchor 5.5; confidence 5.3).

```jsonc
{
  "schema_version": 2,
  "run_id": "rt2-2026-06-05T05-48Z-3f9c",      // stable id; part of every provenance filename
  "updated_at": "2026-06-05T06:12:04Z",
  "updated_by": "orchestrator-prime@<container-id>",

  // ── SEMANTIC / ANCHOR (5.5): the goal is the LAST thing compressed out, FIRST thing restored ──
  "anchor": {
    "goal": "Audit→fix→ship app_flutter polish pass N",   // original mandate, verbatim
    "current_subgoal": "validate 7 synthesized findings",  // updated each phase
    "mandate_hash": "sha256:…"   // hash of the loaded PLAYBOOK mandate; resume re-checks it (5.6/identity)
  },

  // ── WORKTREE LOCATOR (the restart needs to FIND its workspace) ──
  "worktree": {
    "path": "/home/user/wt-rt2",
    "repo_common_dir": "/home/user/buildsmart/.git",
    "base_sha": "4a11b57…",            // commit the worktree was created at (ff-push expected base)
    "branch": "claude/whats-happening-LyY9G",  // target branch (null if detached audit-only)
    "is_default_branch": false,        // precomputed so the push guard's premise is auditable
    "app_dirs": ["/home/user/wt-rt2/app_flutter"],   // gate scope (PLAYBOOK §0)
    "gate_adapter_verified": true,     // §0 "adapt the gate" actually done? guard blocks gate if false
    "gate_fingerprint": "name: buildsmart"   // what central-verify asserted; resume re-asserts
  },

  // ── PHASE STATE (the resume point) ──
  "phase": "validate",                 // enum — see PHASES below; the ONE authoritative cursor
  "phase_status": "in_progress",       // not_started | in_progress | complete | failed
  "phase_history": [                   // episodic, ordered, immutable-by-convention (journal is the hard log)
    {"phase":"setup","status":"complete","at":"…","note":"wt at 4a11b57"},
    {"phase":"audit","status":"complete","at":"…","note":"5/6 lenses returned; perf lens MISSED"}
  ],

  // ── PER-SUB-AGENT STATUS (the fleet ledger; one row per dispatched agent, ALL runs) ──
  "fleet": [
    {
      "agent_id": "audit-3",
      "role": "auditor",
      "lens": "null-safety & async",     // or file-set for fixers
      "dispatched_at": "…",
      "deadline_at": "…",                // PLAYBOOK per-agent deadline — persisted so resume can detect a miss
      "status": "returned",              // dispatched | returned | timed_out | missing | superseded
      "payload_ref": "prov/audit/audit-3.json",   // POINTER to provenance, NOT the payload (keeps ckpt small)
      "payload_sha256": "…",             // binds the row to exact bytes; tamper/truncation is detectable
      "self_report_verified": "pending"  // pending | confirmed | CONTRADICTED  (the "fleet member lied" flag)
    }
  ],

  // ── FINDINGS PIPELINE (decisions WITH rationale, 5.2) — canonical; md views derived ──
  "findings": [
    {
      "id": "F-007",
      "origin_agent": "audit-3",         // provenance: which lens raised it (5.3 recall-with-provenance)
      "file": "lib/x.dart", "line": 142,
      "defect": "…", "severity": "HIGH",
      "verdict": "CONFIRMED",            // null | CONFIRMED | FALSE_POSITIVE | ADJUST | DEFER_LARGE
      "verdict_by": "validate-1",        // which validator adjudicated (provenance)
      "rationale": "guard absent on async path; reachable from build()",  // WHY (5.2)
      "fix_assignee": "fix-2",           // fixer that owns it (disjoint-file map)
      "byte_check": {"present":"_guard","absent":"!oldExpr","result":"pending"}, // feeds grep-verify
      "test_ref": "test/x_test.dart::guards_async",  // the behavioral proof PLAYBOOK 4b demands
      "confidence": "high"               // high|medium|low (5.3) — set at write time, never blank
    }
  ],
  "backlog": [ /* DEFER_LARGE items — same shape; PLAYBOOK forbids silent drop */ ],

  // ── SHIP STATE (so a restart never re-pushes or loses an authorization) ──
  "ship": {
    "gate_status": "not_run",           // not_run | PASS | FAIL  (mirrors central-verify exit)
    "gate_proof": null,                 // captured stdout tail with target+HEAD line
    "human_authorization": null,        // null until the §7 stop; {by, at, target_sha, scope_hash}
    "pushed_sha": null,                 // set ONLY after ff-push exit 0 — the re-push guard reads this
    "deploy_verified": null             // {marker, fix_string, method:"from-bytes", at} or {status:"VERIFY-BLOCKED"}
  }
}
```

`PHASES` (closed enum, ordered) — the resume cursor and the guard's vocabulary:

```
init ▸ setup ▸ audit ▸ synthesize ▸ validate ▸ fix ▸ byteverify ▸ gate ▸ docs ▸ authorize ▸ push ▸ verifydeploy ▸ done
```

### A.4 PROVENANCE STORE — payloads on disk, not in context (the core ask)

**Why it must exist on disk.** The PLAYBOOK promises: *"Surface any sub-agent whose self-report
grep-verify contradicted — a fleet member lied; the user must know."* If that claim lives only in the
orchestrator's context, a container restart **erases the evidence** — and a restarted orchestrator,
re-reading a checkpoint, has no way to re-derive "agent X lied" because the lie was a *delta between a
returned payload and the bytes*, and the payload is gone. So every sub-agent payload is written
**verbatim, immutably, the moment it returns**, before synthesis:

```
prov/audit/audit-3.json
{
  "agent_id":"audit-3", "role":"auditor", "run_id":"…",
  "received_at":"2026-06-05T05:59:11Z",
  "lens":"null-safety & async",
  "raw_payload":"<<the sub-agent's FULL returned text, verbatim — no summary>>",
  "claimed_findings":[ {"file":"lib/x.dart","line":142,"defect":"…","severity":"HIGH"} ],
  "coverage_note":"checked providers a,b; perf NOT in scope",
  "self_reported_fixes":[],                 // for fixers: their "before→after / WIRED|MARKED" claims
  "sha256":"<hash of raw_payload>"          // written into the fleet row; mismatch ⇒ tamper/truncation
}
```

Properties (mechanism, not etiquette):
- **Append-only & content-addressed.** The file is written once, then the writer `chmod 0444` it
  (read-only). `prov/INDEX.ndjson` gets one append line `{agent_id, path, sha256, received_at}`. The
  orchestrator **cannot retro-edit a payload** to hide a contradiction — the read-only bit + the hash
  in the checkpoint + the append-only index make tampering detectable and non-silent.
- **Survives restart.** Because it is under the durable shared git dir (§A.1), a restarted orchestrator
  re-reads every payload and **re-runs the contradiction check** (`grep-verify` the claimed fix bytes
  vs. the worktree) to reconstruct "agent X lied" from ground truth — the claim is **reproducible after
  restart**, which is the whole point.
- **Keeps the orchestrator context lean** (5.5 budget). The checkpoint holds *pointers + hashes*, not
  payloads; the orchestrator works from `findings.md` (a derived view) and pulls a full payload from
  disk only when it needs one. This directly serves PLAYBOOK "keep your context lean: work from files
  on disk, not a full window."

---

## B. MECHANISMS — the concrete enforcement (quick build vs. real build)

Each mechanism states what it enforces, the **artifact** (shell/script/schema/config), and whether it
is a **QUICK** change (shell/config, buildable now with `bash`+`jq`+`sha256sum`, all verified present)
or a **REAL** build (needs genuine tooling). Where only the model can do the thing, it is in §C, not here.

### B.1 `ckpt` — the only writer of `checkpoint.json` (QUICK: bash + jq)

A single small script (`scripts/ckpt.sh`) is the **sole** path that mutates the checkpoint. Subcommands:

```
ckpt init     <wt> <goal> <branch> <app-dirs…>     # create checkpoint + state dirs + lock; validate
ckpt advance  <wt> <phase> [--status complete|failed] [--note "…"]   # the phase-boundary write
ckpt set      <wt> <jq-path> <value>               # narrow field update (e.g. ship.gate_status)
ckpt show     <wt> [<jq-path>]                     # read (for resume / humans / other guards)
ckpt fleet-add / fleet-set <agent_id> <field> <val>   # ledger mutations
ckpt verify   <wt>                                 # validate ONLY (no mutation) — used by resume + CI
```

Every mutating subcommand performs the **atomic, validated write** (B.2). Nothing else — not the
orchestrator, not a sub-agent — writes the file by hand. This converts *"remember to update
`_run.json`"* (prose) into *"the act of advancing a phase IS the write"* (mechanism): you cannot
advance without producing a valid checkpoint, and you cannot produce a checkpoint except by advancing.

### B.2 Atomic + schema-validated write (QUICK: jq + mktemp + mv + sha256sum)

The failure this kills: a half-written or malformed checkpoint after a crash mid-write — which is
*worse* than no checkpoint, because resume would trust garbage (and 5.6 forbids acting on a corrupt
memory as if confirmed). Algorithm inside `ckpt`:

```bash
write_checkpoint() {              # $1 = new JSON on stdin
  tmp="$STATE_DIR/.ckpt.$$.tmp"
  cat > "$tmp"
  # 1) well-formed?         jq parses or we abort, leaving the old file untouched
  jq -e . "$tmp" >/dev/null    || { echo "CKPT ABORT: not valid JSON"; rm -f "$tmp"; return 3; }
  # 2) schema-valid?        every field present + typed + phase in enum (validator, B.5)
  ckpt_validate "$tmp"         || { echo "CKPT ABORT: schema invalid"; rm -f "$tmp"; return 3; }
  # 3) monotonic phase?     never silently go backwards (guard, B.3)
  assert_phase_monotonic "$tmp" || { echo "CKPT ABORT: phase regression"; rm -f "$tmp"; return 4; }
  # 4) keep last-known-good, then ATOMIC swap (rename is atomic on one filesystem)
  [ -f "$STATE_DIR/checkpoint.json" ] && cp -p "$STATE_DIR/checkpoint.json" "$STATE_DIR/checkpoint.json.bak"
  mv -f "$tmp" "$STATE_DIR/checkpoint.json"          # <-- the only moment the file changes
  # 5) append to the immutable journal (never rewritten)
  jq -c '{at:.updated_at, phase, phase_status, by:.updated_by}' "$STATE_DIR/checkpoint.json" \
     >> "$STATE_DIR/journal.ndjson"
}
```

A crash before the `mv` leaves the prior valid checkpoint intact; a crash after it leaves the new valid
one. There is **no window where the canonical file is malformed.** This is the mechanism behind 5.6's
*"after an update, confirm the new value is stored before discarding the previous; on write failure,
retain the previous value and surface the error."*

### B.3 PHASE GUARDS — the next stage refuses to run without proof of the previous (QUICK: bash preconditions)

This is the heart of "mechanism not prose." Today the pipeline order is **advice in a doc**; an
orchestrator can call the gate before validating, or push without an authorization, and nothing stops
it. Mechanism: a `guard` function gates the *entry* to each phase by **reading the checkpoint** and
asserting the precondition. The orchestrator is instructed to call `guard <phase>` first, **and** the
expensive/dangerous scripts call it themselves so it cannot be skipped (defense in depth):

| Entering | `guard` asserts (read from `checkpoint.json`) | If false |
|---|---|---|
| `audit` | `worktree.gate_adapter_verified == true` AND `worktree.base_sha` resolves | REFUSE: "§0 not done" |
| `validate` | `findings` non-empty AND `phase_history` contains `synthesize:complete` | REFUSE |
| `fix` | every targeted finding has `verdict==CONFIRMED\|ADJUST`; **fix_assignee map is disjoint** (no file twice) | REFUSE: "unvalidated/overlap" |
| `gate` | every `fix`-targeted finding `byte_check.result==pass` (4b) | REFUSE: "byte-verify incomplete" |
| `authorize` | `ship.gate_status == PASS` AND `git diff --name-only == union(partitions)` | REFUSE: "gate not green / scope" |
| `push` | `ship.human_authorization != null` AND its `target_sha == HEAD` AND `scope_hash` matches the diff | REFUSE (see B.4) |
| `verifydeploy` | `ship.pushed_sha != null` | REFUSE |

The disjoint-file assertion is computed from the checkpoint's `fix_assignee` map, turning the PLAYBOOK
"build an explicit file→fixer map; a file twice → re-partition" rule into a guard that **fails the
fan-out** rather than trusting the orchestrator to notice. `guard` is pure-read (never mutates) so it
is safe to call repeatedly, including on resume.

### B.4 Push idempotency + authorization binding (QUICK: extend `ff-push.sh` to read the checkpoint)

Two restart hazards the current kit does not close:
1. **Double-push after a restart.** Container dies *after* `ff-push` succeeded but *before* the
   orchestrator recorded it → restart re-enters `push` and pushes again.
2. **Stale/forged authorization.** A `human_authorization` recorded for sha A is reused to push sha B.

Mechanism — `ff-push.sh` takes `--checkpoint "$STATE_DIR/checkpoint.json"` and, **as a precondition**:
- if `ship.pushed_sha` is already set AND `== HEAD` → exit 0 "ALREADY-PUSHED (idempotent), no-op";
- require `ship.human_authorization.target_sha == HEAD` (push exactly what was authorized);
- require `ship.human_authorization.scope_hash == sha256(git diff)` (authorized *content*, not just a sha label);
- on success, the push path calls `ckpt set ship.pushed_sha <sha>` **before returning** (record-then-return).

This makes authorization a **typed, sha-bound, single-use token in durable state**, not a sentence the
orchestrator remembers. It deliberately does **not** touch the `ALLOW_PROTECTED` question — that is a
genuine human-judgment boundary handled by the safety layer; see §C.1 for why this layer cannot and
must not try to "mechanize away" the human.

### B.5 The validator: a checked-in JSON Schema, exercised in CI (QUICK schema; the harness is REAL-ish)

`checkpoint.schema.json` lives in `scripts/` (checked in) and is the contract. `ckpt_validate`:
- **QUICK path (always on):** `jq` assertions — required keys present, `phase` ∈ enum, `phase_status` ∈
  enum, every `fleet[].status`/`findings[].verdict`/`confidence` in its enum, every `payload_ref`
  exists on disk and its `payload_sha256` matches the file. (Pure `jq`+`sha256sum`; no new dependency.)
- **REAL path (CI / when available):** run a standards JSON-Schema validator (e.g. `ajv`,
  `check-jsonschema`) against `checkpoint.schema.json` for full Draft-2020-12 coverage. A
  `state-contract.test` in the orchestrator's own test suite feeds (a) a known-good checkpoint → must
  pass, (b) a corrupt one (bad enum, missing anchor, payload hash mismatch) → must fail. This is the
  "coverage harness" analogue the SITUATION names: the schema is only trustworthy if something
  *adversarially exercises* it, exactly as grep is only trustworthy paired with a test.

### B.6 Derived views — `findings.md` / `confirmed.md` / `backlog.md` (QUICK: `ckpt render`)

`ckpt render <wt>` regenerates the three markdown files **purely from `checkpoint.json`**. They are
output, never input. This removes the dual-store drift risk in the present kit (where `_findings.md`
and `_confirmed.md` are written by hand and could disagree with reality), honoring "one source of truth
per state." Humans read the md; machines read the json.

### B.7 Single-writer lock + heartbeat (QUICK: bash + flock/mkdir + PID file)

In flattened Claude Code one orchestrator runs everything, but the **factory** explicitly contemplates
multiple orchestrator clones, and a botched resume could spawn a second orchestrator onto the same run.
`locks/RUN.lock` holds `{pid, container_id, run_id, heartbeat_at}`. `ckpt init`/resume acquires it; a
heartbeat is refreshed on every `advance`. A second orchestrator that finds a **fresh** lock refuses
("run owned by <pid> as of <t>"); a **stale** lock (heartbeat older than a threshold, e.g. 3× the
longest phase deadline → the owner's container is gone) is reclaimed *with a journal entry recording the
takeover* (so it is never silent). This is the storage-layer enforcement of "one writer," not a polite
request — and it directly protects the 5.9 tenant-isolation principle from being violated by two runs
sharing a state dir.

### B.8 Context-budget compaction hook (QUICK: a documented orchestrator procedure + `ckpt` support)

5.5 mandates pre-emptive compaction at 70% context. The mechanism the orchestrator is given:
`ckpt show <wt> anchor` and `ckpt show <wt> facts` always reconstruct the **anchor + pinned facts**
from durable state, so the documented recovery after *any* compaction or restart is a single command
pair, not "hope the model remembers the goal." The anchor is, by construction (§A.3), the first thing
written and the cheapest thing to restore — satisfying "the anchor is the last item compressed out,
restored first."

---

## B-RESUME. THE RESUME PROTOCOL — what a restarted container does, in order

This is a fixed, checkable sequence (the orchestrator runs it as step −1, before anything else; a
`resume-preflight.sh` automates it and exits non-zero to *block* work if state is inconsistent):

```
0. Locate state:   STATE_DIR = git -C $WT rev-parse --git-path orchestrator-state
                   No STATE_DIR / no checkpoint.json → this is a FRESH run, go to PLAYBOOK §0 (init).
1. Validate:       ckpt verify $WT.  Invalid → try checkpoint.json.bak; both invalid → STOP,
                   surface "CHECKPOINT CORRUPT" (5.6: a retrieval FAILURE is not a confirmed absence —
                   do NOT proceed as if fresh, that would silently restart and re-push).
2. Re-anchor:      restate anchor.goal + anchor.current_subgoal; re-inject worktree.facts/pinned
                   invariants into context (5.5/5.8). Re-check anchor.mandate_hash vs the loaded
                   PLAYBOOK — mismatch ⇒ refuse (someone swapped the mandate mid-run; identity guard).
3. Reattach WT:    assert worktree.path exists and HEAD == base_sha (or pushed_sha if past push).
                   Worktree gone (e.g. host pruned) → STOP "WORKTREE-LOST"; do not silently re-setup
                   over uncommitted fixes.
4. Reconcile fleet vs. provenance (the integrity step):
     for each fleet[] row:
       - status=dispatched but a prov/ payload exists ⇒ mark returned, ingest it (a return we hadn't
         recorded — the crash was between return and record);
       - status=returned but no payload / hash mismatch ⇒ mark missing, surface "lost/tampered payload";
       - deadline_at in the past and no payload ⇒ timed_out (PLAYBOOK: proceed-with-returns, flag miss).
5. Re-derive "who lied": for every returned fixer payload, re-run grep-verify of its self_reported_fixes
     against the live bytes; any contradiction ⇒ set self_report_verified=CONTRADICTED. This RE-BUILDS
     the "a fleet member lied" finding from ground truth after restart — the central reason provenance
     is on disk.
6. Resume at the cursor: read phase + phase_status, then enter via the PHASE GUARD (B.3):
     - phase_status=complete  ⇒ guard the NEXT phase and proceed.
     - phase_status=in_progress ⇒ the phase is idempotent-resumable (audit/validate/fix re-dispatch
       only the rows still missing/timed_out; gate just re-runs; push is idempotent via B.4); re-enter it.
     - phase_status=failed ⇒ do NOT auto-advance; surface the failure + journal tail for a decision.
7. Render views (ckpt render) and continue the PLAYBOOK from that phase.
```

The guarantee: **for every phase, re-entering it is safe** — either it is a pure recompute (gate, byte-
verify, deploy-verify), a partial re-dispatch keyed off the fleet ledger (audit/validate/fix), or an
idempotent no-op (push). That property is what turns "ephemeral container" from a CRITICAL into a
shrug.

---

## C. HONEST LIMITS — what mechanism CANNOT solve, and how this design CONTAINS it

The SITUATION's whole thesis is that prompts *approach* robustness and never transcend the model. Per
that, here is what this layer **cannot** enforce, stated plainly, with the containment.

### C.1 The human authorization at §7 is not mechanizable — and must not be (INHERENT)
B.4 binds an authorization to a sha+scope and makes it single-use, but it **cannot manufacture the
authorization itself**, nor verify the approver is human. (The `ALLOW_PROTECTED=1` override is the exact
trap the red-team named: its "human-only" rule is a comment a shell-wielding agent ignores.) **This
layer deliberately does not try to fake a solution.** Containment: state records *that* an
authorization exists and *what* it was bound to, so the boundary is **auditable and non-replayable**;
the actual "is this a human / should we ship to prod" decision is owned by the **safety/autonomy
layer**, and this layer simply refuses to push until that layer writes a sha-bound token. We narrow the
window and make abuse leave a trace; we do not pretend to close a judgment gap with a script.

### C.2 The checkpoint records *claimed* state; only re-verification makes it *true* (INHERENT, contained)
A checkpoint is itself **memory**, and 5.6 says memory must be re-verified before consequential action.
A malicious or buggy orchestrator could `ckpt set` a false `gate_status=PASS`. The schema guarantees
the value is *well-typed*, not that it is *true*. Containment, layered: (a) the **phase guards** for
consequential phases re-derive from ground truth, not from the field alone — `authorize` re-runs
`git diff --name-only` and (cheaply) re-confirms the gate proof tail rather than trusting the boolean;
`push` re-hashes the live diff. (b) The **journal + read-only provenance** make a forged field
*detectable after the fact* even if it slipped through. (c) The **factory's supervisor** is the human-
designed structural check: its job is to re-run the gate independently and report up, so a self-
asserted PASS is caught one level up. The checkpoint is a *cache of claims*, trusted only as far as the
guards re-prove — never presented as correctness.

### C.3 Honest narration into the checkpoint is a model behavior, not a guarantee (INHERENT)
The orchestrator must call `advance` with a *truthful* `--note` and not mark a `failed` phase
`complete`. No schema can force honesty. Containment: the consequential transitions don't *rely* on the
note — they re-derive from bytes (C.2); the `journal.ndjson` is append-only so a later "complete" can't
erase an earlier "failed"; and provenance hashes mean a "fixed" claim is checkable against the file. We
make dishonesty **expensive and visible**, which is the realistic ceiling.

### C.4 Durability is "shared-git-dir survives the container," not true HA (RUNTIME limit, contained)
This design's persistence rests on `/home/user/buildsmart/.git` outliving the container (verified true
here). It is **not** replicated storage; if the host disk dies, state dies. Containment: the model is
honest about the boundary — state is *run-scoped* and recovery is *resume*, not disaster-recovery;
nothing here claims HA. For the SDK/multi-process target this same layout maps onto a real shared volume
or object store with no schema change (the only runtime-specific line is the `STATE_DIR` resolution,
which already works in both modes). Cross-run memory is deliberately tiny (`facts.ndjson`) to keep the
blast radius of loss small.

### C.5 Concurrency is single-writer-per-run by lock, not multi-writer transactional (BOUNDED by design)
The lock (B.7) serializes writers on one run; it does **not** give multiple agents concurrent
transactional writes to one checkpoint. That is an intentional simplification: the architecture has
**exactly one writer per run** (the owning orchestrator), so a full transaction manager would be
over-engineering. Sub-agents never write the checkpoint — they only *return payloads*, which land in
the append-only provenance store where single-writer ordering is sufficient.

> Net: every limit above is either a genuine human judgment, a model-honesty property, or a
> runtime/storage fact — none is a thing a better script could fix. The design's contribution is to
> **contain** each: narrow the window, re-derive from bytes at the dangerous moments, and leave an
> immutable trace so the failure is *visible*, never silent. (5.6: a silent miss is the worst outcome.)

---

## D. BUILD ORDER — highest safety/leverage first, with dependencies

Ordered so that each step makes the *next* restart safer, and nothing depends on something unbuilt.
"QUICK" = shell/jq/schema, buildable now (all of `bash`, `jq 1.7`, `sha256sum` verified present in this
env). "REAL" = needs a genuine test/validation harness.

1. **`checkpoint.schema.json` + `ckpt verify`/`ckpt show`** *(QUICK — depends on nothing).*
   The contract and the read path first: even before anything *writes* a checkpoint, resume can read &
   validate one. Highest leverage because every later guard and the resume protocol read through it.

2. **`ckpt init` / `advance` / `set` with atomic+validated write (B.1, B.2)** *(QUICK — needs #1).*
   Now state can be *produced* and is never malformed. This alone closes the bulk of CRITICAL #4: a
   crash leaves a valid resumable checkpoint.

3. **Provenance writer + `prov/INDEX.ndjson` + read-only bit + hashes (A.4)** *(QUICK — needs #2 for
   the fleet rows).* Payloads survive on disk the instant they return. This is what lets a restart
   reconstruct "who lied," so it ranks above the guards.

4. **`resume-preflight.sh` (B-RESUME steps 0–5)** *(QUICK — needs #1–#3).*
   The actual restart path: locate, validate, re-anchor, reattach, reconcile fleet↔provenance, re-derive
   contradictions. After this, "container died" is recoverable end-to-end.

5. **Phase guards `guard <phase>` (B.3) + wire them into `central-verify.sh`/`ff-push.sh`** *(QUICK —
   needs #1, #2).* Turns pipeline ordering and the disjoint-file/authorization rules from prose into
   refusals. Includes B.4 push idempotency+binding (extends the existing `ff-push.sh`).

6. **Single-writer lock + heartbeat (B.7)** *(QUICK — needs #2).*
   Protects against a double-owner after a botched resume; lower than the guards because flattened
   Claude Code is single-orchestrator by default, but required before the factory/SDK multi-clone mode.

7. **`ckpt render` derived views (B.6)** *(QUICK — needs #2).*
   Cosmetic-but-important: kills the dual-store drift. Last of the QUICK items.

8. **State-contract test harness — `state-contract.test` + standards JSON-Schema validator in CI
   (B.5 REAL path)** *(REAL — needs #1, #2).*
   The adversarial exercise of the schema (good→pass, corrupted→fail), analogous to "pair every grep
   with a test." Make the schema *trustworthy*, not just present.

**Critical path for closing red-team #4 honestly: #1 → #2 → #3 → #4.** Steps 5–8 harden it from
"resumable" to "resumable and hard to fool." Every artifact in 1–7 is buildable today with the verified
toolset; only #8's standards-validator/CI wiring is the "real tooling" piece.

---

### Appendix — mapping each dimension-5 facet to its mechanism here (traceability)

| 5.x facet | Mechanism in this design |
|---|---|
| 5.1 three tiers, context lossy | §A.0; checkpoint=episodic/semantic, context=working (never durable) |
| 5.2 store decisions w/ rationale | `findings[].rationale`, `verdict_by`, `phase_history.note` |
| 5.3 stable schema, confidence, provenance | §A.3 schema; `confidence` enum; `origin_agent`/`payload_ref`; A.4 |
| 5.4 conflict surfacing / temporal | findings carry verdict+verdict_by; backlog never dropped; journal is time-ordered |
| 5.5 anchor, pre-emptive compaction | `anchor` block; `ckpt show anchor`; B.8; resume step 2 |
| 5.6 verify before trust, write-confirm, miss≠absence | B.2 atomic write; C.2 re-derive; resume step 1 (corrupt≠fresh) |
| 5.7 accurate shared history | provenance is verbatim payloads, not summaries → exact recall after restart |
| 5.8 autonomous persist, periodic audit | `advance` is forced at every seam; journal = audit trail |
| 5.9 isolation, protection, deletion log | state under access-controlled git dir; lock = tenant isolation; journal/INDEX = audit log |
```