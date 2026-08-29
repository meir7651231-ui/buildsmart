# Dimension 8 — Orchestration & Control, built RIGHT

> **Scope of this layer.** This is the *fleet manager*: the control loop that decides what sub-agents
> run, gives each a bounded mandate, watches them for timeout/hang/empty-return, triages a partial
> fleet at *both* tiers (audit and fix), keeps a durable per-sub-agent registry, detects "stuck", and
> recovers. It sits *above* the gate (`central-verify.sh`) and the push guard (`ff-push.sh`) — those
> are the SAFETY layer (dim 9). This layer's job is to never **stall, hang, or silently drop a
> sub-task**, and to make the manager loop *resumable* and *honest about partials*.
>
> **The lesson that governs every choice here.** v2 closed the 4 CRITICALs with *prose* and 8/9
> dimensions still scored PARTIALLY. The autonomy CRITICAL (#3 in `RED-TEAM.md`) was *"one hung
> sub-agent blocks the run forever"*, and the v2 "fix" is the word **"deadline"** in `PLAYBOOK.md §1`
> and `Fan-out discipline`. **A word is not a deadline.** Below, every control rule is a file, a
> counter, a wrapper script, or a JSON schema that the loop must touch — something whose *absence is
> detectable*, not a sentence an agent can read and ignore.

---

## 0. The honest runtime constraint this entire design is built around

Before any architecture: in **Claude Code (CC)** the spawn primitive is the `Task` tool, and it has two
properties that dictate everything:

1. **`Task` is synchronous and un-cancellable from the calling turn.** When the orchestrator calls
   `Task(auditor, …)`, that call blocks the orchestrator's own turn until the sub-agent returns. The
   orchestrator **cannot** set a wall-clock kill on it, cannot poll it, cannot `TaskStop` it (TaskStop
   targets *background Bash/Monitor* tasks, not `Task` sub-agents). So a *true* per-agent timeout that
   **interrupts** a running sub-agent **does not exist in CC.** Any design claiming "the manager kills
   the agent at T+15m" in CC is prose — the same failure as v2.
2. **A sub-agent cannot spawn sub-agents** (`NESTING_SUPPORTED=no`, verified in `FACTORY.md`). The
   manager loop is therefore **flattened**: one orchestrator turn runs every tier.

What *is* real in CC, and what this design uses as its timing substrate:
- **`Task` returns are batched and parallel within one assistant message.** Launch K `Task` calls in a
  single message → they run concurrently → the turn resumes when *all K* have returned. So the unit the
  manager actually controls is **the batch**, not the individual agent.
- **`Bash(run_in_background)` + `Monitor`** run *out of band* on a real wall clock, survive across
  turns, and can be `TaskStop`-ped. This is the only true clock the orchestrator owns.

**Design consequence (stated honestly up front, expanded in §4):** in CC the per-agent timeout is a
**budget mechanism**, not a kill mechanism. We bound each agent's *work* (step/tool budget in its brief)
and bound the *batch* with an out-of-band wall-clock heartbeat; a sub-agent that ignores its budget and
runs long cannot be force-killed — it is *contained* by (a) shrinking batch width so one long agent
delays less, (b) the heartbeat that converts "silent overrun" into a logged, actionable event, and (c)
the registry making the overrun visible. **True preemptive kill needs the SDK** (§4.4, §1.3). Saying so
plainly is the point of the whole exercise.

---

## 1. Architecture — the manager loop, the registry, tier topology

### 1.1 The three components

```
              ┌──────────────────────────────────────────────────────────┐
              │  FLEET MANAGER  (the orchestrator turn — flattened in CC)  │
              │                                                            │
   reads ───► │   _run.json        (phase, goal, scope, budgets)           │
   first      │   _registry.json   (one row per sub-agent — the spine)     │ ◄── every Task return
              │   _heartbeat.log    (out-of-band wall clock, background)    │     writes one row
              │                                                            │
              │   loop:  PLAN ─► DISPATCH-BATCH ─► REAP ─► TRIAGE ─► next   │
              └──────────────────────────────────────────────────────────┘
                        │ Task() ×K (one message)        ▲ returns ×K
                        ▼                                 │
        ┌───────────┬───────────┬───────────┐    each return → registry row
        │ auditor·1 │ auditor·2 │ auditor·N │    (status, artifact, coverage, caveat)
        └───────────┴───────────┴───────────┘
```

The manager is a **state machine over files**, not a stream of reasoning. Its three durable artifacts:

| file | role | written when |
|------|------|--------------|
| `_run.json` | run-level state: goal, in/out scope, phase, budgets, runtime mode | §0 onboarding; updated at every phase boundary |
| `_registry.json` | **the per-sub-agent spine** — one row per agent ever dispatched | a row is `OPEN`ed at dispatch, `CLOSE`d at reap |
| `_heartbeat.log` | out-of-band wall-clock ticks for the in-flight batch | by a background `Bash`/`Monitor`, independent of the turn |

Plus the existing `_findings.md` / `_confirmed.md` (the data flowing between phases — owned by the
pipeline, not the control layer).

**Why files, not context:** the container is ephemeral (RED-TEAM #4). If the manager holds the registry
"in its head" and the turn dies, every dispatched agent is orphaned and the run restarts blind. The
registry on disk makes the loop **resumable**: on resume the manager reads `_registry.json`, sees which
rows are still `OPEN` (dispatched-but-never-reaped), and re-queues exactly those — not the whole fleet.

### 1.2 The manager loop (one iteration = one phase's fan-out)

```
PLAN      decompose the phase into disjoint sub-tasks; for each, write an OPEN row
          to _registry.json with its budget + acceptance criterion BEFORE dispatch.
          Choose batch width W from the runtime + tier (§4.2).

DISPATCH  arm the heartbeat (§4.3, background). Emit W Task() calls in ONE message,
          each brief carrying {worktree, scope R/EDIT, lens/files, output contract,
          step-budget, acceptance criterion, LEAF constraint, invariants, agent_id}.

REAP      when the message resumes (all W returned OR the harness surfaced them):
          for each return, run reap() (§4.5) → classify GOOD / EMPTY / MALFORMED /
          OVERRUN-FLAGGED → write the CLOSE fields into that agent's registry row.
          Disarm the heartbeat.

TRIAGE    apply the tier's triage policy (§5) over the reaped batch:
          decide PROCEED-WITH-RETURNS / RE-QUEUE-FAILED-SUBSET / STOP — and act.
          Re-queued rows go back to PLAN as a *narrow* second batch, not a full re-run.

next      advance _run.json.phase only when the tier's "enough returned" predicate
          (§5) holds. Never advance on a silent partial.
```

The loop is **identical at every tier** (audit, validate, fix) — only the triage *policy* and batch
*width* differ. That uniformity is what lets one flattened orchestrator run all tiers without bespoke
logic per tier.

### 1.3 Tier topology — flattened (CC) vs nested (SDK)

The factory is 3 logical tiers (TOP → orchestrator clones → worker fleets + per-fleet supervisor). The
**control topology** that realizes them differs by runtime, and the manager must *detect which* in §0
and write it to `_run.json.mode` — never assume.

**CC — FLATTENED (the only thing that runs today).**
- One orchestrator turn IS the fleet manager for *all* tiers. There are no live Tier-1 clone
  *processes*; the orchestrator plays every clone serially-by-module and every fleet by batched `Task`.
- The **supervisor role still exists, but as a manager sub-routine, not a spawned agent.** "Supervise =
  objectively verify before reporting up" becomes the manager's own `reap()` + the gate run — the
  manager *is* the supervisor in flattened mode. (Optionally the manager spawns one `supervisor` Task to
  do the verification read, but the *decision* stays with the manager; a sub-agent can't be trusted to
  gate itself, and it can't spawn either way.)
- **Control loop = the §1.2 state machine.** UP-PIPE = registry rows + reap verdicts; DOWN-FLOW = the
  manager revising the *next* batch's briefs from what the last batch's rows revealed.

**SDK — NESTED (the port target).**
- Each Tier-1 clone is its own OS process running the same `PLAYBOOK.md`; it owns *its* `_registry.json`
  and runs *its* §1.2 loop over *its* fleet, including a genuinely-spawned `supervisor` process.
- TOP runs a §1.2 loop whose "sub-agents" are the clone processes; their returns are the clones' final
  reports. TOP's registry has one row per clone.
- **The same schema and the same loop nest cleanly** because a registry row's contract
  (`OPEN→CLOSE`, budget, acceptance criterion) is recursive: a clone is just a sub-agent whose artifact
  is "a verified module report" instead of "a lens of findings".
- **What nesting buys (and only nesting buys):** a parent process *can* set a real wall-clock kill on a
  child process and `SIGTERM` it on overrun (§4.4). So the per-agent timeout graduates from *budget* to
  *preemption* on the SDK. This is the single most important capability the port adds, and the design is
  shaped so that **only the timeout enforcement changes** — registry, triage, stuck-detection are
  identical.

---

## 2. Mechanisms overview — what is shell/config vs what needs real tooling

| control need | v2 had (prose) | RIGHT mechanism | kind |
|---|---|---|---|
| per-agent timeout | the word "deadline" | step-budget in brief + out-of-band heartbeat (CC) / process-kill wrapper (SDK) | **config + script** (CC); **real tool** (SDK preemption) |
| task registry | "maintain a task registry" (sentence) | `_registry.json` schema + `registry.sh open/close/query` helper + a JSON-schema validator the loop must pass | **script + schema** |
| partial-fleet triage (audit) | "synthesize from those that did, flag the missing" | `triage-audit.sh` → coverage-fraction predicate → PROCEED+FLAG / RE-QUEUE / STOP | **script** |
| partial-fleet triage (fix) | *(none — fix tier had no triage at all)* | `triage-fix.sh` → per-file pass/fail from grep-verify → re-queue *only failed files* on disjoint re-partition / STOP | **script** |
| stuck detection | "if N consecutive steps no progress" (N undefined) | `_run.json.stuck.{N, window, counter}` + a progress predicate the loop decrements; recovery ladder | **config + loop logic** |
| empty/hung return | "empty return = tool failure, re-run" (sentence) | `reap()` classifier: artifact-exists + schema-valid + criterion-met → EMPTY/MALFORMED → bounded retry | **script** |
| heartbeat / wall clock | *(none)* | `Bash(run_in_background)` writing `_heartbeat.log` + `Monitor` alerting on overrun | **harness primitive** |

**Honest tooling boundary.** Everything in CC is shell + JSON + harness primitives — *no* new runtime
needed. The **one** thing that is genuinely "real tooling, not shell" is **preemptive sub-agent kill**,
and it is *unavailable in CC at any price*; it requires the SDK's multi-process model (§4.4). The design
contains that gap (§6) rather than pretending the heartbeat is a kill.

---

## 3. MECHANISM — the task registry (`_registry.json`)

### 3.1 Schema (the spine — one object per sub-agent ever dispatched)

```jsonc
{
  "run_id": "rt2-2026-06-05-audit",
  "schema_version": 1,
  "agents": [
    {
      "agent_id": "audit.security.1",   // {tier}.{lens-or-fileset}.{attempt}
      "tier": "audit",                  // audit | validate | fix | supervisor | clone
      "role": "auditor",
      "mandate": "lens: auth/session reachability",   // the disjoint slice
      "scope": "READ",                  // READ | EDIT:<file-glob>
      "budget": { "max_steps": 40, "wall_soft_s": 600 },  // soft = heartbeat warns; not a kill in CC
      "acceptance": "returns >=1 finding line OR an explicit 'area holds' coverage line, in contract shape",
      "status": "OPEN",                 // OPEN | GOOD | EMPTY | MALFORMED | OVERRUN | FAILED | REQUEUED | ABANDONED
      "attempt": 1,                     // increments on re-queue; >2 → escalate
      "dispatched_at": "2026-06-05T05:50:11Z",
      "closed_at": null,
      "artifact": null,                 // path to the agent's written output, or inline if tiny
      "coverage_note": null,            // the agent's one-line "what I checked"
      "caveat": null,                   // any uncertainty/partial-flag — MUST survive to the final report
      "grep_verify": null,              // fix tier only: PASS|FAIL + the checks run
      "discrepancy": null               // set if reap() found claim≠bytes — a fleet member mis-reported
    }
  ]
}
```

### 3.2 The invariant that makes it a mechanism (not a doc)

A registry the manager *can forget to update* is prose. So the loop is bound by **three machine-checked
invariants**, enforced by `registry.sh` (a thin `jq` wrapper) that is the *only* sanctioned way to touch
the file:

1. **No dispatch without an OPEN row.** `registry.sh open <agent_id> …` is what *prints the agent_id*
   the brief must embed. If a `Task` brief carries an `agent_id` with no OPEN row → that's a
   manager bug, caught because the brief-builder reads the id back from the helper.
2. **No phase advance with an OPEN row.** `registry.sh assert-no-open` is a precondition the loop runs
   before incrementing `_run.json.phase`. A dispatched-but-never-reaped agent is exactly an orphan / a
   silent hang — this invariant *converts that into a hard stop* instead of a quiet skip.
3. **Every CLOSE carries a verdict + (if applicable) a discrepancy/caveat.** `registry.sh close
   <agent_id> --status … --artifact … [--caveat … --discrepancy …]` refuses a close with `status`
   outside the enum or `GOOD` without an `artifact`. This is the mechanism behind PLAYBOOK's "never drop
   a caveat": the caveat field is *required at close time*, so it cannot be lost between reap and report.

`registry.sh` (sketch, ~30 lines `jq`):

```bash
registry.sh open  <id> <tier> <role> <scope> <max_steps> <wall_s> <acceptance>
registry.sh close <id> --status S [--artifact P --coverage C --caveat K --discrepancy D --grep G]
registry.sh assert-no-open                 # exit 1 if any row.status == OPEN  (gate on phase advance)
registry.sh open-ids                       # list OPEN rows (resume: these are the orphans to re-queue)
registry.sh report                         # emit the final-report rows: per-agent verdict + caveats + discrepancies
registry.sh validate                       # jq schema check: enum'd status, required fields per status
```

**Resume path (RED-TEAM #4, mechanized):** on a fresh turn the manager runs `registry.sh open-ids`. Non-
empty → those agents were in-flight when the prior turn died → re-queue *exactly* them at `attempt+1`.
Empty → resume from `_run.json.phase`. No full restart, no blind re-run.

---

## 4. MECHANISM — per-agent timeout (the heart of the RED-TEAM #3 fix, done right)

This is the facet v2 faked with the word "deadline". Here is the real mechanism, split honestly by
runtime.

### 4.1 Two clocks, because CC only gives you one that's real

- **Work clock (the agent's budget):** `budget.max_steps` in the brief — "do at most ~40 tool calls;
  if your lens isn't covered by then, RETURN what you have with a coverage note rather than continuing."
  This is a *soft, cooperative* bound: a well-behaved agent self-limits. It is **not** enforcement (a
  runaway agent ignores it), but it is the cheapest 80% and costs one sentence per brief.
- **Wall clock (the manager's heartbeat):** the only clock the orchestrator *owns* in CC, run out of
  band (§4.3). It cannot stop a sub-agent, but it converts "silent overrun" into a **logged, timed,
  actionable signal** — which is the difference between RED-TEAM #3 ("blocks forever, silently") and a
  contained delay.

### 4.2 Batch width is the real timeout knob in CC

Because the manager controls the **batch**, not the agent, the lever that bounds wall-time is **W (how
many `Task`s per message)** and **how the tier is sliced**:

- **Quick build (cheap, narrow run):** `W = audit:3, validate:1, fix:2`, `max_steps ≈ 25`,
  `wall_soft = 300s`. Few lenses, one validator pass, small fixes. One slow agent stretches a 3-wide
  batch only modestly; total exposure is small.
- **Real build (full audit→ship):** `W = audit:6–8, validate:2–3, fix:3–4`, `max_steps ≈ 40–60`,
  `wall_soft = 600s`. Wider fan-out → more parallelism → *one* slow agent is amortized across the batch,
  and the heartbeat (§4.3) flags it without blocking the others (they already returned).

The point: **shrinking the slice per agent and widening the batch is how you bound the blast radius of a
slow agent when you can't kill it.** That is a *mechanism* (numbers in `_run.json.budgets`, chosen by run
class), not "give it a deadline".

`_run.json.budgets` (config the loop reads — not prose):
```jsonc
"budgets": {
  "class": "real",                              // quick | real
  "audit":   { "W": 6, "max_steps": 50, "wall_soft_s": 600 },
  "validate":{ "W": 2, "max_steps": 40, "wall_soft_s": 480 },
  "fix":     { "W": 4, "max_steps": 45, "wall_soft_s": 540 },
  "batch_hard_s": 1200                          // heartbeat escalation point (§4.3)
}
```

### 4.3 The heartbeat — out-of-band wall clock (the new mechanism CC actually supports)

Right before a `DISPATCH`, the manager arms a background timer keyed to the batch, then emits the `Task`
batch in the *same* assistant message so they run concurrently with the timer:

```bash
# armed via Bash(run_in_background) just before the Task batch; SOFT then HARD tick
( s=0; soft=$WALL_SOFT; hard=$BATCH_HARD
  while :; do sleep 30; s=$((s+30))
    if   [ $s -ge $hard ]; then echo "HEARTBEAT HARD  t=${s}s batch=$BATCH_ID — overrun past hard cap"; break
    elif [ $s -ge $soft ]; then echo "HEARTBEAT SOFT  t=${s}s batch=$BATCH_ID — past soft budget"
    else echo "HEARTBEAT tick  t=${s}s batch=$BATCH_ID"; fi
  done ) >> _heartbeat.log
```

Mechanically what this gives, and its honest limit:
- The timer **survives across turns** and runs on a real clock the agent does not control → the run can
  *never* be in a state where time has passed but nothing recorded it. RED-TEAM #3's "silently" is dead:
  even a hang leaves a growing `_heartbeat.log`.
- **At `REAP`** the manager reads `_heartbeat.log`. If the batch returned before SOFT → clean. Past SOFT
  → mark the slow returns `OVERRUN` in the registry (a caveat, surfaced). Past HARD with the `Task`
  *still not returned* → see the blunt truth below.
- **Blunt truth (contained, not hidden):** in CC the `Task` batch and the orchestrator's turn are the
  *same* turn; the orchestrator literally cannot read `_heartbeat.log` *until* the batch returns and
  hands the turn back. So the heartbeat is a **post-hoc forensic + cross-turn** signal, not a live
  interrupt *within* the blocked turn. Its real power is (a) on **resume** after a killed turn (the log
  proves how long the dead batch ran and the registry shows it `OPEN`) and (b) as the SDK port's live
  trip-wire (§4.4). For *live* mitigation within CC, the lever is §4.2 (width) — accepted limit, §6.

### 4.4 SDK upgrade — the heartbeat becomes a real kill

On the SDK, the parent process spawns each sub-agent as a child it can wait on with a timeout and
`SIGTERM`:

```bash
timeout --signal=TERM "${WALL_HARD}s" run-subagent "$agent_id" "$brief" \
  || registry.sh close "$agent_id" --status OVERRUN --caveat "killed at hard cap ${WALL_HARD}s"
```

Now `wall_hard` is **enforced**: a hung child is reaped at the cap, its row closed `OVERRUN`, and the
batch proceeds. **This is the only place the design needs a runtime change to graduate timeout from
*budget* to *preemption*** — and nothing else in the loop changes, because the registry already models
`OVERRUN` as a first-class close status. Build the loop the same in both; flip this one wrapper on the
port.

### 4.5 `reap()` — hung / empty / malformed return handling (mechanical)

Every `Task` return — *including* a `GOOD`-looking one — passes through `reap()` before its row closes.
This is PLAYBOOK's "empty/structureless return = tool failure, re-run" turned into a decision procedure:

```
reap(agent_id, return_payload):
  1. EXISTS?    artifact file present & non-empty (or inline payload non-trivial)?
                  no  → status=EMPTY
  2. SHAPE?     payload matches the role's output contract (auditor: file:line·defect·sev·fix lines
                  + 1 coverage line; fixer: file:line·before→after·WIRED/MARKED)?
                  no  → status=MALFORMED
  3. CRITERION? meets the row's `acceptance` (e.g. ≥1 finding OR explicit 'area holds')?
                  no  → status=FAILED  (plausible but doesn't meet the bar — dim 8.6: mark it failed)
  4. TRUTH?     (fix tier) grep_verify the claimed bytes; if claim≠bytes → discrepancy=<gap>,
                  status=FAILED, and the discrepancy is flagged to the final report (a member mis-reported)
  5. else status=GOOD; record artifact, coverage_note, and any caveat the agent flagged.
```

Retry policy (bounded, not blind): `EMPTY` or `MALFORMED` → **one** immediate re-dispatch at `attempt+1`
with a *sharpened* brief (the §8.8 rule: don't re-run blind — note *why* it was empty and tighten the
contract). Second failure → leave the row `FAILED` and hand it to TRIAGE (§5). `FAILED` on
criterion/truth is **not** auto-retried with the same brief — it goes straight to triage, because
re-running an identical brief is the diminishing-returns anti-pattern.

**Distinguish tool failure from goal failure (dim 8.8):** `EMPTY`/`MALFORMED` = *tool/operational*
failure → retry path. `FAILED` on criterion with a *coherent* "I couldn't because precondition X is
missing" = possible *goal* failure → do **not** loop; surface to the human if it blocks the phase.

---

## 5. MECHANISM — partial-fleet triage at BOTH tiers

v2's triage existed *only* at audit ("synthesize from those that did") and *only as a sentence*. The fix
tier — where a partial fleet is most dangerous, because a half-applied fix set can pass the gate while
leaving real bugs — had **no triage at all**. Both tiers get a concrete predicate here. The shared shape:

```
triage(batch):
  classify each row → GOOD | RECOVERABLE (re-queue) | DEAD (can't proceed)
  compute the tier's "enough" predicate over GOOD
  enough & no DEAD-blocker → PROCEED-WITH-RETURNS (carry caveats for the non-GOOD)
  not enough but RECOVERABLE → RE-QUEUE the RECOVERABLE subset (narrow batch), loop once
  DEAD-blocker (a required slice cannot be satisfied) → STOP + escalate with evidence
```

The phrase that matters from the task: triage is **proceed-with-returns / re-queue the failed one — not
just STOP.** STOP is the *last* branch, taken only when a *required* slice is genuinely unsatisfiable —
never the reflex.

### 5.1 Audit-tier triage (`triage-audit.sh`) — coverage-fraction, never block on one hung lens

Audit lenses are **disjoint and individually droppable** — missing one lens degrades *coverage*, it
doesn't corrupt anything. So the predicate is a **coverage fraction**, and the policy strongly favors
PROCEED:

```
covered      = count(rows where status==GOOD)
required_set = lenses tagged critical:true in the plan (e.g. security, data-integrity)
total        = count(all audit rows)

if every required lens is GOOD and covered/total >= 0.6:
     → PROCEED-WITH-RETURNS. Synthesize from GOOD rows. For each non-GOOD lens, write an
       explicit "LENS NOT COVERED: <lens> (status=…)" line into _findings.md — a flagged gap,
       never a silent drop. The gap rides to the final report as accepted/known risk.
elif a non-GOOD lens is RECOVERABLE (EMPTY/MALFORMED, attempt<=2):
     → RE-QUEUE just those lenses as a small second batch; merge on return.
elif a *required* (critical:true) lens is DEAD (FAILED twice, or genuinely unsatisfiable):
     → STOP for that lens only is NOT enough — a critical lens uncovered means the ship is unsafe.
       Escalate to the human: "critical lens <X> could not be audited: <evidence>." Do not ship blind.
```

Key property: **one hung non-critical lens never blocks the run** (RED-TEAM #3 closed *mechanically* —
the predicate proceeds at ≥60% with all critical lenses in), yet a missing *critical* lens cannot be
silently swept (it's a DEAD-blocker → escalate). Quick build: `required_set` may be empty and the
fraction floor drops to one GOOD lens — a quick run accepts thinner coverage *by config*, transparently.

### 5.2 Fix-tier triage (`triage-fix.sh`) — per-file, re-queue the failed file, never the whole fleet

Fixers are partitioned by **disjoint file sets**, so a partial fix fleet is *naturally* decomposable:
each file's fix either landed (grep-verify PASS) or didn't (FAIL/empty). The triage is **per-file**, and
re-queue targets *exactly the failed files* on a fresh disjoint re-partition:

```
for each fixer row, reap() already set grep_verify = PASS|FAIL per its file(s).

passed_files = files whose every grep-check PASSed
failed_files = files with any FAIL / from an EMPTY|MALFORMED fixer

if failed_files is empty:
     → PROCEED to the gate (step 5). All fixes landed in the bytes.
else:
     partition failed_files into a NEW disjoint map (still one-fixer-per-file — re-partition,
       never reuse the old map that may have paired two on a file), attempt+1.
     → RE-QUEUE just failed_files as a narrow fix batch. Merge, re-grep-verify.
     if a file FAILS a second time (attempt>2) OR a fixer reports NEEDS-DECOMPOSITION:
        → that file is DEAD for this run. Two sub-branches:
           • the rest are independent → PROCEED-WITH-RETURNS to the gate WITHOUT that file's
             finding; move the finding to the DEFER backlog with the failure evidence (never
             silently dropped — dim 8.5).  ← this is the "proceed-with-returns" branch the task wants
           • the failed file is a *dependency* of a passed fix (its omission would make a landed
             fix incoherent/unsafe) → STOP: you cannot ship a half-coherent change set. Escalate.
```

**Why per-file and not whole-fleet:** the v2 reflex (and the naive reading of "STOP on partial") would
discard *all* fixers' work if any one failed. That throws away good, verified bytes and re-runs them for
nothing — the diminishing-returns anti-pattern. Per-file re-queue keeps every landed fix and re-spends
effort *only* on the holes. The disjoint-file invariant from `PLAYBOOK` is what makes this safe: passed
files are independent of failed ones *by construction*, so proceeding-with-returns can't corrupt them.

**The dependency check is the one place this needs judgment, not pure mechanism** (§6): deciding whether
a failed file's omission makes a *landed* fix unsafe is a correctness judgment. The mechanism *forces the
question to be asked* (the branch is in the script's decision tree) and defaults to the *safe* side
(STOP) when the manager can't establish independence — but the determination itself rides on model
capability. Contained by: the gate (step 5) is the behavioral backstop — if proceeding-with-returns left
an incoherent set, the gate's tests are the second net (and a coverage gap there is itself recorded).

---

## 6. MECHANISM — stuck detection + recovery

v2: *"if N consecutive steps produce no verified progress … recovery protocol"* with **N undefined** and
"verified progress" undefined — pure prose (dim 8.8 itself calls "I'll know stuck when I see it" a
non-protocol). Concrete version:

### 6.1 Define "progress" mechanically (so "no progress" is computable)

`_run.json.progress` carries a **monotonic ledger** the loop *must* advance to claim motion:

```jsonc
"progress": {
  "findings_confirmed": 0,   // grows in validate
  "files_fixed_verified": 0, // grows in fix (grep-verify PASS count)
  "phase": "audit",
  "stuck": { "N": 3, "counter": 0, "window": "per fan-out batch" }
}
```

**A batch made progress** iff at least one of the ledger's tier-relevant counters strictly increased
*after `reap()`* (audit: new GOOD lenses with findings or confirmed coverage; fix:
`files_fixed_verified` up). A batch that returns and moves *no* counter → `stuck.counter += 1`. Any batch
that moves a counter → `stuck.counter = 0`. This makes "no verified progress" a **subtraction on a
file**, not a vibe.

### 6.2 The recovery ladder (triggered at `counter >= N`, N=3 set at run start)

```
counter == 1:  re-PLAN the current batch — re-partition / sharpen briefs (the §4.5 "sharpen" path).
                 Most stalls are a bad brief; fix it at brief-time (dim 8.3: 10× cheaper).
counter == 2:  narrow the slice (smaller max_steps, switch lens/angle per anti-pattern "switch lens
                 or stop"); re-read _run.json goal + last GOOD registry state (the last verified-good
                 anchor, dim 8.8).
counter == N(=3): STOP this phase. Escalate to the human with: the goal, the last verified-good state
                 (from the registry), the exact non-advancing counter, and the briefs already tried.
                 This is a *goal-failure* escalation, not a silent give-up.
```

`N`, `window`, and the per-counter actions live in `_run.json` and the loop's code path — they are read
and decremented, not "kept in mind". Quick build: `N=2` (escalate faster on a cheap run). Real build:
`N=3`.

### 6.3 Tool-failure vs goal-failure fork (dim 8.8, mechanized)

Before incrementing `stuck.counter`, the loop checks *why* the batch made no progress:
- returns were `EMPTY`/`MALFORMED` (tool/operational) → that's the §4.5 retry path, **don't** count it as
  a goal-stall yet (operational noise ≠ the goal being unreachable).
- returns were well-formed but `FAILED` on criterion with coherent "precondition missing / constraints
  contradict" → **immediate** escalate (don't climb the ladder; a contradictory goal won't yield to
  re-prompting — that's the v1→v6 "convergence ceiling" lesson applied to a single run).

---

## 7. How this maps onto the existing kit (what changes, concretely)

This layer is **additive** to the existing files — it does not rewrite the pipeline, it makes the
pipeline's control points enforceable. Deltas:

| existing file | change |
|---|---|
| `PLAYBOOK.md §1` | replace "Give each a **deadline**" with "open a registry row carrying its `max_steps`/`wall_soft`; arm the heartbeat; dispatch the batch" — point to `_run.json.budgets`. |
| `PLAYBOOK.md §4/4b` | after grep-verify, the result is recorded into the fixer's registry row (`grep_verify` field) and feeds `triage-fix.sh`; phase-advance gated on `registry.sh assert-no-open`. |
| `PLAYBOOK.md Fan-out discipline` | "wait up to the deadline; proceed with returns + flag misses" → "REAP→TRIAGE per §5; PROCEED-WITH-RETURNS / RE-QUEUE-FAILED-SUBSET / STOP". |
| `agents/*.md` | each brief template gains a required `agent_id`, `max_steps`, and a one-line `acceptance` (so reap() can check criterion). The auditor/fixer output contracts are already reap-compatible. |
| **new** `scripts/registry.sh` | the `jq` wrapper (open/close/assert-no-open/open-ids/report/validate) — §3.2. |
| **new** `scripts/triage-audit.sh` | the coverage-fraction predicate — §5.1. |
| **new** `scripts/triage-fix.sh` | the per-file re-queue predicate — §5.2. |
| **new** `scripts/heartbeat.sh` | the background wall-clock ticker — §4.3 (CC); the `timeout`-wrapper variant — §4.4 (SDK). |
| `_run.json` | gains `mode` (flattened/nested), `budgets`, `progress.stuck` — §4.2, §6. |

No change to `central-verify.sh` / `ff-push.sh` — those are the safety layer; this layer *feeds* them
(only a clean triage reaches the gate; only an authorized push reaches `ff-push`).

---

## 8. Honest limits — what mechanism CANNOT solve, and how this design contains each

1. **No preemptive sub-agent kill in CC (the big one).** A sub-agent that ignores its step-budget and
   runs long *cannot be force-stopped* from the orchestrator's turn — `Task` is synchronous and
   un-cancellable, `TaskStop` doesn't reach it. *Contained by:* batch-width tuning (§4.2) to bound blast
   radius, the cross-turn heartbeat so an overrun is never *silent* (§4.3), the registry making it
   visible, and the **SDK port** that turns the soft budget into a real `SIGTERM` (§4.4) — the loop is
   pre-shaped for that flip (one wrapper changes). **This is a runtime limit, named, not papered over.**
2. **The step-budget is cooperative.** `max_steps` in a brief is honored only by a well-behaved agent;
   it's a hint, not a sandbox. *Contained by:* it's never the *only* bound — width + heartbeat + reap
   sit behind it; and a runaway shows up as an OVERRUN row, not a hidden cost.
3. **The fix-tier dependency judgment (§5.2) is model judgment, not mechanism.** Deciding whether a
   failed file's omission makes a *landed* fix unsafe is a correctness call. *Contained by:* the
   mechanism *forces the question* (it's a branch, not an afterthought), defaults to STOP when
   independence can't be shown, and the gate's tests are a behavioral backstop. But the determination's
   quality is capped by the underlying model — the SITUATION's stated ceiling.
4. **"Progress" is proxied by counters, and a counter can move without true progress.** A fixer could
   bump `files_fixed_verified` with a change that grep-passes but is behaviorally wrong (the
   grep-vs-fixed gap from RED-TEAM HIGH). *Contained by:* progress is a *stuck*-detector input only — it
   never substitutes for the gate's tests, which are the correctness authority; grep is explicitly the
   weaker signal ("tests beat grep").
5. **Flattened mode is not real parallel supervision.** In CC one turn plays manager + every fleet +
   the supervisor role; there is no independent process objectively watching the manager itself. *Con-
   tained by:* the registry + heartbeat are *external artifacts* a human (or a separate CC session) can
   audit after the fact — the manager's own claims are checkable against files it had to write. True
   independent oversight needs the SDK's separate supervisor process. Honest: in CC the manager grading
   itself is a structural limit; the files make it *auditable*, not *independently enforced*.
6. **The whole layer's ceiling is the model (the v1→v6 lesson).** More registry fields and finer triage
   branches have diminishing returns; past a point they churn. *Contained by:* every mechanism here is
   chosen because its *absence is detectable* (a missing row, a non-advancing counter, a silent
   `OPEN` at phase-advance) — i.e. it buys *detectability of failure*, which is the durable win, rather
   than trying to legislate good behavior the model may not have. We approach robustness; we don't claim
   to transcend the model.

---

## 9. Build order (highest safety/leverage first; each names its dependency)

1. **`_run.json` + `registry.sh` (schema + open/close/assert-no-open/validate).** *Depends on:* nothing.
   *Why first:* the registry is the spine — every other mechanism writes to it, and `assert-no-open` is
   the single invariant that converts "silent hang/orphan" (RED-TEAM #3/#4) into a hard stop. Without it,
   nothing else is enforceable. Ship with `registry.sh validate` self-testing the schema.
2. **`reap()` as a manager sub-routine + the brief-template changes (`agent_id`/`max_steps`/`acceptance`).**
   *Depends on:* the registry (it closes rows). *Why second:* it's the gate on *every* return — empty/
   malformed/criterion handling — and it can't exist before rows do. Now every dispatch is accountable.
3. **`heartbeat.sh` (CC background ticker) + wiring it into DISPATCH/REAP.** *Depends on:* the loop
   structure (1–2). *Why third:* it kills the word "silently" from RED-TEAM #3 at near-zero cost and is
   the substrate the SDK port upgrades to a real kill. Pure harness primitive — no new tooling.
4. **`triage-fix.sh` (per-file re-queue).** *Depends on:* reap()'s `grep_verify` field + the disjoint-
   file map. *Why before audit-triage:* the fix tier is where a silent partial is most *dangerous* (a
   half-applied change set can pass the gate), so its triage carries the most safety leverage.
5. **`triage-audit.sh` (coverage-fraction).** *Depends on:* registry GOOD-counts + lens `critical` tags.
   *Why here:* audit partials degrade coverage, not correctness — lower blast radius than fix — so it
   lands after the dangerous tier is covered.
6. **Stuck-detection ledger + recovery ladder (`_run.json.progress`).** *Depends on:* all triage tiers
   feeding the counters. *Why later:* it's a meta-loop over the per-batch machinery; it can only define
   "no progress across batches" once per-batch progress is itself measured.
7. **SDK preemption wrapper (`timeout --signal=TERM` around child spawn) + the nested topology.**
   *Depends on:* everything above + the SDK runtime. *Why last:* it's the *only* piece needing a runtime
   change, and the design is built so it's a localized swap (§4.4) — graduate timeout from budget to kill
   without touching registry/triage/stuck. Until the port, CC runs items 1–6 in flattened mode, fully.

**Net:** items 1–6 are shell + JSON + harness primitives buildable in CC today; item 7 is the single
SDK-gated upgrade. The ordering front-loads *detectability of failure* (registry → reap → heartbeat)
before *optimization of partial handling* (triage → stuck) before the *runtime upgrade* (preemption).
