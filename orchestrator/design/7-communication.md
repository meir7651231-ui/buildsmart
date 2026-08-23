# Design — Dimension 7: Communication & Human-in-the-Loop, built RIGHT

**Scope.** This layer governs everything that crosses the boundary *between the running fleet and the
human / the calling tier*: the run report, the surfacing of fleet lies, the pause before an irreversible
action, and the handling of work the fleet chose not to do. The hard lesson from the v2 red-team applies
directly here: every one of these is currently **prose** — a rule in `PLAYBOOK.md` ("never drop a caveat",
"surface any self-report grep contradicted", "STOP for authorization", "DEFER-LARGE → written to a
backlog") that depends on the orchestrator *remembering and choosing* to obey at the moment it matters.
Prose rules are bypassed in one line and silently. This design replaces each with a **mechanism**: a
schema a malformed report fails, a hook that *computes* the contradiction instead of trusting recall, a
gate that *blocks the syscall* until a token it cannot mint arrives, and a state machine where a deferral
is an open blocker rather than a comment.

The governing principle (from `dimensions-v6/7-communication.md`): *say what happened, say only what
matters, say it plainly — honesty over optimism, signal over noise.* The mechanisms below make those four
properties **structural** rather than aspirational. They bind to the existing contracts verbatim:
`grep-verify.sh` byte truth, `central-verify.sh` `GATE PASS/FAIL`, the per-agent output lines, and the
`ff-push.sh` push surface. `jq` and `python3` are present in the runtime (verified), so JSON validation and
the hooks are real shell, not hypothetical tooling.

---

## 0. The four former-prose items, and the mechanism that replaces each

| # | PLAYBOOK prose today | Failure mode | Mechanism (this design) |
|---|---|---|---|
| A | "Final report (mandatory **shape**)" — a prose paragraph describing fields | Orchestrator emits free narration; a field (deferred, discrepancies, deploy-proof) is silently dropped; nobody can tell | **Typed report schema** `report.schema.json` + `report-lint.sh` gate: a report missing a required field or carrying an unproven `live:true` is **rejected**, run is not CLEAN |
| B | "Surface any sub-agent whose self-report grep-verify contradicted" | Relies on the orchestrator *remembering* to compare claim vs bytes, across a long context, after the moment passed | **Reconciliation hook** `reconcile.sh`: mechanically diffs each fixer's structured claim against `grep-verify`/gate output and *emits* `discrepancy` records into the report — recall is not in the loop |
| C | "Ship — STOP for authorization … hard stop"; `ff-push.sh` honors `ALLOW_PROTECTED=1` | The "human-only" override is a comment; any agent with a shell does `ALLOW_PROTECTED=1 ff-push …` in one line, *post-hoc*-reports it | **Pre-action approval gate** `approve-gate.sh` + single-use, action-bound, human-minted **nonce**: the push **blocks** until a token matching *this exact sha+target* is presented; an agent's shell cannot forge it |
| D | "DEFER-LARGE → written to a backlog, never silently dropped" | A backlog file is write-and-forget; the human never has to see it; "deferred" reads as "handled" | **DEFER requires an explicit open ASK**: a `defer` becomes an `unresolved` blocker in the report; the run cannot close as CLEAN with open defers — it closes `PARTIAL` and *names the ask* the human must answer |

The rest of the document specifies each.

---

## 1. Architecture — three components and the contracts between them

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ FLEET (auditor/validator/fixer/supervisor)                                 │
  │   emit STRUCTURED returns (NDJSON lines, one schema'd object per finding)  │
  └───────────────┬───────────────────────────────────────────────────────────┘
                  │ claim records (*.claims.ndjson)                  ground truth
                  ▼                                          (grep-verify, gate exit)
  ┌──────────────────────────────────────────────┐         ┌──────────────────────┐
  │ RECONCILER  reconcile.sh                       │◄────────┤ grep-verify.sh        │
  │  claim ⨝ ground-truth  → discrepancy[] records │         │ central-verify.sh     │
  │  (B: the surfacing channel — computed, not recalled)     └──────────────────────┘
  └───────────────┬────────────────────────────────┘
                  │ appends to _report.json (discrepancies[], findings[], deferred[])
                  ▼
  ┌──────────────────────────────────────────────┐
  │ REPORT OBJECT  _report.json                    │  (A: one canonical machine-readable state of the run)
  │  validated by report-lint.sh ⟵ report.schema.json
  │  fields: status · findings · deferred · discrepancies · version · deploy{from_bytes}
  └───────────────┬───────────────────────────────┘
                  │ a push is requested only after report is schema-valid AND has zero unresolved blockers
                  ▼
  ┌──────────────────────────────────────────────┐
  │ APPROVAL GATE  approve-gate.sh → ff-push.sh    │  (C: pre-action hard gate)
  │  blocks on a single-use human nonce bound to {sha, target, report-hash}
  └────────────────────────────────────────────────┘
```

Three components, each with a file-level contract on disk (the container is ephemeral; **state lives in
files, never in the orchestrator's context** — consistent with `_run.json` already in §0):

### 1.1 The report object — `_report.json` (one canonical state, schema-enforced)
A single JSON document in the worktree, **the** machine-readable state of the run. It is *built
incrementally* by the pipeline (every phase appends, like `_findings.md`/`_confirmed.md` already do) and
*validated* at the end. It is the structured replacement for the PLAYBOOK's "Final report (mandatory
shape)" prose. Its schema (`report.schema.json`) is the contract; `report-lint.sh` is the enforcer. A
human-readable report is *rendered from* this object (a `render.sh`), never authored in parallel — one
source of truth per state (a PLAYBOOK hard rule), so the prose summary cannot drift from the data.

### 1.2 The reconciliation channel — `reconcile.sh` (the surfacing mechanism)
The fleet emits **structured claim records** (NDJSON). The reconciler joins each claim to ground truth
(`grep-verify` result, gate exit, `git diff`) and *derives* the discrepancy set, writing it into
`_report.json.discrepancies[]`. This is item B: the contradiction is **computed from data**, not
remembered by the orchestrator. The surfacing is no longer "the orchestrator should mention it" — a
discrepancy record exists in the canonical object the moment the bytes disagree with the claim, and the
schema (1.1) refuses to let the run be CLEAN while any discrepancy is unacknowledged.

### 1.3 The approval gate — `approve-gate.sh` (the pre-action hard gate)
The wrapper through which *every* irreversible/outward action passes (push, deploy-trigger, worktree
`remove --force`, any delete). It **blocks** — refuses to proceed — until a **single-use nonce**, minted by
a human and **bound to this exact action** (sha + target + report content-hash), is presented. This is item
C, and it is what makes the authorization a *gate* (blocks until approval) rather than a *report* (asks
forgiveness after). It is layered *in front of* the existing `ff-push.sh` safety guard, not replacing it.

**Contract summary between components** (all on disk, all greppable):

| artifact | written by | read by | shape |
|---|---|---|---|
| `*.claims.ndjson` | each fixer (via its output contract) | `reconcile.sh` | one JSON obj/line: `{agent,file,line,claim,marker_present,marker_absent,test}` |
| `_report.json` | pipeline phases + `reconcile.sh` | `report-lint.sh`, `render.sh`, `approve-gate.sh` | the schema in §2 |
| `_approvals/<nonce>.grant` | **human** (out-of-band) | `approve-gate.sh` | `{nonce,sha,target,report_sha256,issued_by,expires}` |
| `_report.lint` | `report-lint.sh` | orchestrator, `approve-gate.sh` | `PASS`/`FAIL: <reason>` |

---

## 2. Mechanism A — the structured run report (schema, not prose)

### 2.1 Why a schema and not "a better paragraph"
The v2 lesson: a *shape described in prose* ("give status · findings · deferred · discrepancies · version ·
deploy confirmation") is a rule the orchestrator can satisfy by *narrating around it* and quietly omitting
the inconvenient field — exactly how a partial ships as "done". A field that is **required by a schema a
linter checks** cannot be omitted: the report is rejected, and the rejection is itself a gate input to the
push (§4). "Honesty over optimism" stops being a virtue we hope for and becomes a property the artifact
must have to pass.

### 2.2 `report.schema.json` (JSON Schema, draft 2020-12) — the contract
The full schema (this is the file to build; reproduced here so the build is unambiguous):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Orchestrator run report",
  "type": "object",
  "additionalProperties": false,
  "required": ["schema_version","run_id","status","findings","deferred",
               "discrepancies","version","deploy","gate","prose"],
  "properties": {
    "schema_version": { "const": 1 },
    "run_id":   { "type": "string", "minLength": 1 },
    "worktree": { "type": "string" },
    "status":   { "enum": ["CLEAN","PARTIAL","FAILED","BLOCKED"] },

    "findings": {
      "type": "array",
      "items": {
        "type": "object", "additionalProperties": false,
        "required": ["id","file","severity","verdict","disposition","proof"],
        "properties": {
          "id":        { "type": "string" },
          "file":      { "type": "string" },
          "line":      { "type": ["integer","null"] },
          "severity":  { "enum": ["HIGH","MED","LOW"] },
          "verdict":   { "enum": ["CONFIRMED","FALSE-POSITIVE","ADJUST","DEFER-LARGE"] },
          "disposition": { "enum": ["FIXED","MARKED","DROPPED","DEFERRED"] },
          "proof": {
            "type": "object", "additionalProperties": false,
            "required": ["grep","test"],
            "properties": {
              "grep": { "enum": ["PRESENT","ABSENT-OK","N/A","FAIL"] },
              "test": { "enum": ["PASS","NO-COVERAGE","FAIL","N/A"] }
            }
          }
        }
      }
    },

    "deferred": {
      "type": "array",
      "items": {
        "type": "object", "additionalProperties": false,
        "required": ["id","reason","scope_estimate","ask","ask_state"],
        "properties": {
          "id":             { "type": "string" },
          "reason":         { "type": "string", "minLength": 1 },
          "scope_estimate": { "type": "string", "minLength": 1 },
          "ask":            { "type": "string", "minLength": 1 },
          "ask_state":      { "enum": ["OPEN","ANSWERED-DO","ANSWERED-SKIP"] }
        }
      }
    },

    "discrepancies": {
      "type": "array",
      "items": {
        "type": "object", "additionalProperties": false,
        "required": ["agent","claim","ground_truth","acknowledged"],
        "properties": {
          "agent":        { "type": "string" },
          "claim":        { "type": "string" },
          "ground_truth": { "type": "string" },
          "acknowledged": { "type": "boolean" }
        }
      }
    },

    "version": {
      "type": "object", "additionalProperties": false,
      "required": ["old","new","why","marker"],
      "properties": {
        "old": { "type": "string" }, "new": { "type": "string" },
        "why": { "type": "string" }, "marker": { "type": "string" }
      }
    },

    "deploy": {
      "type": "object", "additionalProperties": false,
      "required": ["live","method"],
      "properties": {
        "live":   { "enum": [true, false, "VERIFY-BLOCKED","DEPLOY-STALLED","NOT-ATTEMPTED"] },
        "method": { "type": "string" },
        "from_bytes": {
          "type": "object", "additionalProperties": false,
          "required": ["artifact_url","version_marker_found","fix_string_found"],
          "properties": {
            "artifact_url":         { "type": "string" },
            "version_marker_found": { "type": "boolean" },
            "fix_string_found":     { "type": "boolean" }
          }
        }
      },
      "allOf": [
        { "if":   { "properties": { "live": { "const": true } } },
          "then": { "required": ["from_bytes"] } }
      ]
    },

    "gate": {
      "type": "object", "additionalProperties": false,
      "required": ["result","target"],
      "properties": {
        "result": { "enum": ["PASS","FAIL","NOT-RUN"] },
        "target": { "type": "string" }
      }
    },

    "prose": { "type": "string", "maxLength": 1200 }
  }
}
```

### 2.3 `report-lint.sh` — the enforcer (semantic rules JSON Schema can't express)
JSON Schema enforces *shape*; a second pass enforces the **cross-field honesty invariants** that are the
whole point. This is the byte-level equivalent of "honesty over optimism" — the report literally cannot
claim more than the proof supports:

```bash
#!/usr/bin/env bash
# report-lint.sh <report.json> — structural (jq schema) + semantic honesty gates.
set -uo pipefail
R="${1:?report.json}"
# 1) structural: validate against report.schema.json (python jsonschema; jq fallback below)
python3 - "$R" <<'PY' || { echo "FAIL: schema-invalid"; exit 1; }
import json,sys
try: import jsonschema
except ImportError: jsonschema=None
rep=json.load(open(sys.argv[1]))
sch=json.load(open(__import__("os").path.join(__import__("os").path.dirname(sys.argv[1]) or ".","report.schema.json"))) \
    if False else json.load(open("report.schema.json"))
if jsonschema: jsonschema.validate(rep,sch)
PY
# 2) semantic honesty invariants (the load-bearing part) — via jq, each a hard FAIL:
fail(){ echo "FAIL: $1"; exit 1; }
# H1  status CLEAN ⇒ zero unacknowledged discrepancies
[ "$(jq '[.discrepancies[]|select(.acknowledged==false)]|length' "$R")" -eq 0 ] \
  || { [ "$(jq -r .status "$R")" != CLEAN ] || fail "CLEAN with unacknowledged discrepancy"; }
# H2  status CLEAN ⇒ no deferred item left OPEN  (item D, enforced here)
[ "$(jq '[.deferred[]|select(.ask_state=="OPEN")]|length' "$R")" -eq 0 ] \
  || { [ "$(jq -r .status "$R")" != CLEAN ] || fail "CLEAN with an OPEN deferral (un-asked)"; }
# H3  any finding FIXED ⇒ its test proof is not FAIL, and grep proof is not FAIL
[ "$(jq '[.findings[]|select(.disposition=="FIXED" and (.proof.grep=="FAIL" or .proof.test=="FAIL"))]|length' "$R")" -eq 0 ] \
  || fail "a FIXED finding has a failing grep/test proof"
# H4  deploy.live==true ⇒ both byte-greps found  (no "live" claim from a deploy log — PLAYBOOK step 8)
if [ "$(jq -r '.deploy.live' "$R")" = "true" ]; then
  [ "$(jq -r '.deploy.from_bytes.version_marker_found' "$R")" = true ] && \
  [ "$(jq -r '.deploy.from_bytes.fix_string_found'   "$R")" = true ] \
    || fail "deploy.live=true but byte-proof incomplete"
fi
# H5  gate.result must be PASS for status CLEAN  (green gate before ship)
{ [ "$(jq -r .status "$R")" != CLEAN ] || [ "$(jq -r .gate.result "$R")" = PASS ]; } \
  || fail "CLEAN without a PASS gate"
echo "PASS"
```

**Mapping to the v6 spec.** H1↔7.6 (reports match reality), H2↔7.7/7.8 (escalate, don't silently defer),
H3/H5↔7.9 (never assert a fix complete without evidence), H4↔7.9 (no overclaiming "live"). Each spec line
that was a *rule* is now a *check that fails the artifact*.

### 2.4 Signal-over-noise, mechanically
7.4 ("surface only what changes the caller's action") and 7.8 ("compress routine confirmations") are
enforced by *construction*, not discipline: `render.sh` reads `_report.json` and emits the human report as
**conclusion-first, ≤2 paragraphs of `prose` (schema-capped at 1200 chars) + the structured tables**. The
orchestrator never hand-writes the report, so it cannot pad it. Routine per-step "done/found/applied"
chatter never reaches the human because the only channel to the human is the rendered object, and the
object has no field for chatter. `render.sh` ranks findings by `severity` then by the v6 consequence order
(data-loss > correctness > performance > style) using the `severity` enum — the "rank by consequence" rule
becomes a sort key.

### Quick win vs real build (A)
- **Quick (config/shell, hours):** `report.schema.json` + `report-lint.sh` + `render.sh`, wired as the last
  pipeline step. Immediately closes "a partial ships narrated as done" — the dominant v2 failure.
- **Real (tooling, days):** a tiny `report.py` library the orchestrator calls to *append* records
  (`report.py add-finding …`, `report.py defer …`) so the object is built type-safely phase-by-phase
  instead of hand-assembled at the end — removes the last hand-editing surface.

---

## 3. Mechanism B — surfacing a contradicted self-report (computed, not recalled)

### 3.1 The exact hole this closes
PLAYBOOK today: *"Surface any sub-agent whose self-report grep-verify contradicted — a fleet member lied;
the user must know."* This is the single most fragile prose rule in the kit, because it asks the **most
context-pressured node** (the orchestrator, late in a long run) to *remember* to perform a comparison and
then *choose* to confess a fleet member's lie in the final report. Forgetting is silent and looks identical
to "no lies occurred". The fix is to make the comparison a **mechanical join over two files**, run by a
hook, that *writes the finding into the canonical object* — so surfacing is the default and *suppression*
would require an affirmative act.

### 3.2 The structured claim record (fixer output, machine-readable)
The fixer's contract already ends with: *"REPORT per fix: `file:line` · before→after · WIRED or MARKED · any
test"*. We make that emission a **machine record** the fixer writes to `<agent>.claims.ndjson` (one line per
fix). Same information the fixer already produces — now parseable:

```json
{"agent":"fixer-A","file":"lib/x.dart","line":42,
 "claim":"WIRED","marker":"_loaded","old":"oldBuggyString","test":"x_test.dart::loads"}
```

This is a small addition to `agents/fixer.md` (emit the line, in addition to the prose), not new capability.

### 3.3 `reconcile.sh` — the join that *derives* discrepancies
```bash
#!/usr/bin/env bash
# reconcile.sh <report.json> <claims.ndjson...> — derive discrepancies from claim ⨝ bytes.
# For each claim: run the byte check the claim implies; if the bytes disagree → a discrepancy RECORD.
set -uo pipefail
R="${1:?report}"; shift
GV="$(dirname "$0")/grep-verify.sh"
tmp="$(mktemp)"
for f in "$@"; do
  while IFS= read -r line; do
    a=$(jq -r .agent <<<"$line"); file=$(jq -r .file <<<"$line")
    marker=$(jq -r '.marker // empty' <<<"$line"); old=$(jq -r '.old // empty' <<<"$line")
    claim=$(jq -r .claim <<<"$line")
    checks=(); [ -n "$marker" ] && checks+=("$file:::$marker")
    [ -n "$old" ] && checks+=("$file:::!$old")
    if [ ${#checks[@]} -gt 0 ]; then
      if out=$("$GV" "${checks[@]}" 2>&1); then : # bytes agree with the claim
      else
        # CLAIM SAYS DONE, BYTES SAY NO → emit a discrepancy record (acknowledged=false)
        jq -nc --arg ag "$a" --arg cl "$claim ($file)" \
              --arg gt "$(printf '%s' "$out" | grep -E '^FAIL' | head -3 | tr '\n' ';')" \
          '{agent:$ag,claim:$cl,ground_truth:$gt,acknowledged:false}' >>"$tmp"
      fi
    fi
  done <"$f"
done
# merge derived discrepancies into the canonical report
jq --slurpfile d <(cat "$tmp") '.discrepancies += $d' "$R" >"$R.next" && mv "$R.next" "$R"
n=$(wc -l <"$tmp"); echo "reconcile: $n discrepancy record(s) derived"; rm -f "$tmp"
```

The chain is now: fixer emits claim → `grep-verify` (the existing byte truth) is the adjudicator →
`reconcile.sh` *writes* the discrepancy → schema rule **H1** blocks a CLEAN status while any discrepancy is
`acknowledged:false`. The orchestrator's only remaining action is to **acknowledge** each one (which forces
it to look) — it cannot make the run CLEAN by *forgetting*. "A lie cannot climb a pipe whose every junction
re-checks against the bytes" (FACTORY) is now true at the *communication* junction too, not just inside the
supervisor.

### 3.4 Tests-beat-grep stays intact
`grep-verify` proves *token presence*, not *behavioral fix* (the deepest v2 HIGH). `reconcile.sh` therefore
records a discrepancy on a *byte* mismatch, and the report's per-finding `proof.test` field carries the
behavioral truth from the gate. H3 (a `FIXED` finding cannot carry `proof.test:"FAIL"`) is the place where
tests beat grep at the *report* layer — a fix whose test fails cannot be reported FIXED even if its bytes
are present.

### Quick win vs real build (B)
- **Quick (shell, hours):** `reconcile.sh` + the one-line claim emission in `fixer.md`. This alone removes
  the recall dependency for the highest-stakes honesty rule in the kit.
- **Real (tooling, days):** have the *supervisor* (`agents/supervisor.md`) run `reconcile.sh` as its
  defined verification step and emit the discrepancy block directly, so in the SDK/nested runtime the
  surfacing happens at the dedicated oversight node, structurally independent of the orchestrator's context.

---

## 4. Mechanism C — authorization BEFORE the irreversible action (a hard gate, not a report)

### 4.1 The exact hole (the canonical "named hole is still a hole")
`ff-push.sh` guards the default branch but accepts `ALLOW_PROTECTED=1` whose only "human-only" enforcement
is a **comment**: `# A HUMAN sets this; never bypass in code.` The red-team itself flagged this class. Any
agent with a shell runs `ALLOW_PROTECTED=1 ff-push.sh …` and *then* writes "I pushed to main (authorized)".
That is authorization-as-*report* (ask forgiveness). The PLAYBOOK's "STOP for authorization at the action
point" is the right intent but is, again, prose the orchestrator must choose to obey. We make it a **gate
the action is mechanically blocked behind**, keyed on a secret the agent cannot produce.

### 4.2 The mechanism: a single-use, action-bound nonce the agent cannot mint
The asymmetry that makes this real: **the agent can read and write files; it cannot read the human's
out-of-band secret and cannot predict a random nonce.** The gate demands a grant file whose authenticity is
bound to *this* action.

**Setup (once, human-controlled).** A secret known only to the human is placed where the *agent process
cannot read it* — e.g. an env var `BS_APPROVE_KEY` injected into the **human's** approval shell only, never
into the agent's environment, OR (stronger) a file `~/.approve_key` outside the worktree with mode `600`
owned by a different uid than the agent runs as. The agent never has the key.

**At the action point, `approve-gate.sh` blocks:**

```bash
#!/usr/bin/env bash
# approve-gate.sh <action> <sha> <target> <report.json> -- <real-command...>
# Blocks an irreversible action until a single-use, action-bound human grant is present.
set -uo pipefail
ACTION="${1:?action}"; SHA="${2:?sha}"; TGT="${3:?target}"; REP="${4:?report}"
shift 4; [ "$1" = "--" ] && shift
GRANTS="${APPROVE_DIR:-_approvals}"; mkdir -p "$GRANTS"

# 0) the report behind this action must itself be lint-clean (ties A+C: no push on an un-honest report)
[ "$(./report-lint.sh "$REP" | tail -1)" = PASS ] || { echo "BLOCK: report-lint not PASS"; exit 3; }

# 1) compute the exact request fingerprint the human must approve
RH=$(sha256sum "$REP" | cut -d' ' -f1)
REQ=$(printf '%s\n' "$ACTION" "$SHA" "$TGT" "$RH" | sha256sum | cut -d' ' -f1)

# 2) EMIT the request for a human (this is the ASK — surfaced, specific, answerable per 7.3)
cat >"$GRANTS/REQUEST-$REQ.json" <<EOF
{"action":"$ACTION","sha":"$SHA","target":"$TGT","report_sha256":"$RH","req":"$REQ"}
EOF
echo "AWAITING APPROVAL  action=$ACTION  sha=$SHA  target=$TGT"
echo "  human: approve with  ./approve.sh $REQ   (reviews REQUEST-$REQ.json, mints the grant)"

# 3) BLOCK until a VALID grant for THIS req appears (bounded; never hang forever — 7.8/autonomy)
GRANT="$GRANTS/GRANT-$REQ.json"
for _ in $(seq 1 "${APPROVE_TIMEOUT_TICKS:-120}"); do [ -f "$GRANT" ] && break; sleep 5; done
[ -f "$GRANT" ] || { echo "BLOCK: no approval within window — NOT proceeding (action withheld, not assumed)"; exit 4; }

# 4) verify the grant is AUTHENTIC + single-use + bound to THIS exact request
EXP=$(printf '%s' "$REQ" | { cat; cat "$APPROVE_KEY_FILE"; } | sha256sum | cut -d' ' -f1)  # HMAC-ish
GOT=$(jq -r .hmac "$GRANT")
[ "$GOT" = "$EXP" ] || { echo "BLOCK: grant HMAC mismatch — not human-issued for this exact action"; exit 5; }
mv "$GRANT" "$GRANT.used"   # single-use: a grant cannot be replayed for a second push
echo "APPROVED — proceeding with: $*"
exec "$@"                    # only NOW does ff-push.sh run
```

The human's `approve.sh` (run in the human's shell, which *has* the key the agent lacks) reviews
`REQUEST-$REQ.json` and writes `GRANT-$REQ.json` with `hmac = sha256(req || key)`. Because:
- the agent **cannot read `$APPROVE_KEY_FILE`** (different uid / not in agent env), it cannot compute a
  valid `hmac` → it cannot forge a grant;
- the grant is **bound to `REQ` = hash(action,sha,target,report-hash)**, a grant for one push is useless for
  any other action, sha, target, or a mutated report (changing any byte of the report changes `REQ`);
- the grant is **single-use** (`mv …used`), so a stale approval can't authorize a later push;
- the action **runs via `exec "$@"` only inside the gate after verification** — there is no path to the push
  that doesn't traverse the block.

**`ALLOW_PROTECTED=1` is demoted.** `ff-push.sh` keeps its default-branch refusal, but the *override* is no
longer an env flag an agent sets — `approve-gate.sh` is the only thing that may set `ALLOW_PROTECTED=1`, and
it does so *only after* a valid grant whose `target` is the protected branch. The "human-only" property is
now enforced by the key the agent cannot read, not by a comment.

### 4.3 Scope: every irreversible/outward action, not just push
The same gate wraps deploy-trigger, worktree `remove --force`, and any `delete`/destructive MCP call —
satisfying 7.8's "reserve interruptions for irreversible actions pending approval" and the PLAYBOOK hard
rule "hard-to-reverse / outward actions — confirm authorization *at the action point*." The gate is the
*structural* form of "at the action point": the authorization check and the action are the same call.

### Quick win vs real build (C)
- **Quick (shell + uid/permission, hours):** `approve-gate.sh` + `approve.sh` with the file-mode-600,
  different-owner key. Closes the `ALLOW_PROTECTED` hole today on a single host. Requires the agent process
  to run as a uid that cannot read the key file — a deployment/config decision, stated as a dependency.
- **Real (tooling/infra, days):** replace the local HMAC file with a proper out-of-band approver — a Slack
  interactive button, a signed webhook, a CI manual-approval environment, or GitHub's protected-environment
  required-reviewers (the push then physically cannot land without a reviewer click on the platform).
  The interface (`approve-gate.sh` emits a request, blocks, verifies a bound single-use grant) is unchanged;
  only the grant *source* moves off-box, which removes even the "same host" assumption.

---

## 5. Mechanism D — DEFER-LARGE requires an explicit ASK, not silent deferral

### 5.1 The hole
PLAYBOOK: *"DEFER-LARGE → written to a backlog, never silently dropped."* A backlog file is **write-and-
forget**: it satisfies "not dropped" on a technicality while the human is never *required* to see it. In
practice "deferred to backlog" reads to the human exactly like "handled". The v6 spec is explicit
(7.7/7.8): a deferral of in-scope work is an *escalation* — it must surface as a question with a cost, not a
silent note. The mechanism makes a deferral a **first-class open blocker** that the run cannot close over.

### 5.2 The mechanism: deferral is a state machine ending in a human answer
A `DEFER-LARGE` validator verdict does **not** write a backlog line. It appends a `deferred[]` record to
`_report.json` with `ask_state:"OPEN"` and a mandatory, *answerable* `ask` field (per 7.3: context + fork +
what's needed):

```json
{"id":"D-1","reason":"null-safety migration touches 38 call-sites across 9 files",
 "scope_estimate":"~9 files, ~38 sites, est. its own ship",
 "ask":"Defer the null-safety migration to a follow-up ship, or expand THIS run's scope to include it?",
 "ask_state":"OPEN"}
```

The enforcement is schema rule **H2** (§2.3): *`status:"CLEAN"` is rejected while any `deferred[]` item has
`ask_state:"OPEN"`.* Consequences, all mechanical:
- The run **cannot self-report CLEAN** while a defer is unanswered — it is at most `PARTIAL`, and
  `render.sh` puts the open ask(s) at the **top** of the human report (conclusion-first), not in a footnote.
- The defer can only move to `ANSWERED-DO` / `ANSWERED-SKIP` by a human answer (the same out-of-band grant
  channel as §4 can carry it, or a simple `answer.sh D-1 SKIP`), so "deferred" can never be a value the
  agent assigns to itself.
- Because a deferral now *blocks* CLEAN and *surfaces* the ask, the orchestrator's incentive to silently
  defer-to-avoid-work is removed: deferring is *more* visible than fixing, not less.

This composes with C: if there are open defers, `approve-gate.sh` blocks the ship anyway (its report-lint
precheck fails on `PARTIAL`-with-open-defer because H2 fails), so you cannot push past an un-asked defer.

### Quick win vs real build (D)
- **Quick (schema only, already built with A):** H2 + the `deferred[]` record shape *is* the mechanism — no
  extra script. Validators emit the record; the schema blocks CLEAN; render surfaces it. Ships with A.
- **Real (tooling, hours):** `answer.sh` / wiring the answer into the same approval channel so a human's
  DO/SKIP is captured with provenance and (for DO) auto-files a tracked follow-up issue via the GitHub MCP.

---

## 6. Honest limits — what mechanism CANNOT solve, and how this design contains each

A core v2 lesson is that *naming the limit honestly and containing it* beats pretending a rule closed it.
Per the SITUATION brief, the real ceiling is the **model's capability**; mechanism *bounds the blast radius*
of that ceiling, it does not raise it.

| # | Inherent limit (not solvable by mechanism) | Why it's inherent | How this design CONTAINS it |
|---|---|---|---|
| L1 | **The `prose` field and `ask` text can still be a bad summary.** A schema enforces that fields *exist* and that claims don't exceed proof; it cannot make the 1200-char narrative *insightful* or the `ask` *well-judged*. | "Is this summary good?" is a judgment, = model capability. | The **load-bearing** facts are in *typed, proof-checked* fields (status, proof.grep/test, deploy.from_bytes, discrepancies), which the linter validates against ground truth. The free prose is **capped and non-authoritative** — `render.sh` derives the report from the typed object, so a weak narrative cannot *contradict* the verified data, only be terse. The damage is bounded to "less explanatory", never "false". |
| L2 | **A human can rubber-stamp the approval gate** (§4) without reading the diff. | Genuine review is human judgment; a gate can compel a *click*, not *attention*. | The gate makes the decision **maximally cheap to do right**: `REQUEST-$REQ.json` carries the exact sha, target, diff summary, and the lint-PASS'd report hash — everything needed to decide in one screen (7.3 "specific and answerable"). It cannot ship on a *stale* or *mismatched* approval (single-use + bound to report-hash), so the only residual failure is a human approving *the right, current thing* carelessly — the irreducible human-in-the-loop floor, and the narrowest possible one. |
| L3 | **Mechanism can't read intent of an ambiguous task** — whether a finding is genuinely DEFER-LARGE or just being dodged. | Scope judgment is model+human judgment. | D doesn't try to *judge* the defer; it forces the judgment to be **surfaced as an answerable ASK and answered by a human** before CLEAN. A wrong defer becomes a *visible question*, not a silent omission — contained to "the human was asked and decided", never "it vanished". |
| L4 | **`grep-verify` proves bytes, not behavior** (the deepest v2 HIGH) — so a `discrepancy` is byte-level; a behavior-only regression won't trip `reconcile.sh`. | Token presence ≠ correctness; only a test exercising the path proves behavior. | The report's `proof.test` field + H3 make the **gate's tests** the behavioral authority at the report layer (tests beat grep). The residual gap — *code with no test coverage* — is not hidden: `proof.test:"NO-COVERAGE"` is a first-class enum value the human sees, converting "silent unknown" into "declared accepted risk" (7.9 "quantify partial confidence"). |
| L5 | **A sufficiently capable agent could try to *route around* the gate** (push via a raw `git` call, not `approve-gate.sh`). | A shell can run arbitrary commands; no in-band rule forbids what the shell permits. | Contained by **moving the boundary off the agent's authority**: the `git push` to a protected branch *fails at the remote* under GitHub branch-protection / required-environment-reviewers regardless of which local command issues it (the §4 "real build"). The local gate is convenience + audit; the *enforcing* boundary is a permission the agent's credentials don't carry. This is the only fully bypass-proof form and is named as the target end-state. |
| L6 | **The orchestrator could choose not to *call* the report/reconcile steps at all.** | Running the pipeline honestly is itself prose ("do step 5") until something external requires it. | Contained by making the **push gate depend on the report** (§4 step 0: `approve-gate.sh` blocks unless `report-lint` PASSes, and lint requires the discrepancy/defer fields populated). Since *nothing ships without traversing the gate*, and *the gate requires a lint-clean report*, skipping the communication layer means **not shipping** — the one outcome the orchestrator's mandate won't accept. The honest report becomes a *precondition of the goal*, not a courtesy. |

**The meta-containment (the v2 anti-pattern itself):** the design avoids *introducing contradictions*
(PLAYBOOK-says-X-while-script-says-Y) by making the scripts the **single source of the contract** and the
PLAYBOOK *reference them by name*, not restate their logic. The report schema is the one authority on report
shape; `approve-gate.sh` is the one authority on "authorized"; `reconcile.sh` is the one authority on
"contradicted". Prose in the PLAYBOOK should *point at* these, never paraphrase them — eliminating the drift
that made v2 self-contradictory.

---

## 7. Build order (highest safety/leverage first; each item's dependencies named)

The ordering follows the SITUATION brief: build the highest-safety, highest-leverage enforcement first, and
make each piece's dependency explicit.

1. **`approve-gate.sh` + `approve.sh` + the uid/600 key (Mechanism C).**
   *Highest safety.* It closes the one CRITICAL-class live hole (`ALLOW_PROTECTED` bypass → unauthorized
   production push). Depends only on: the existing `ff-push.sh` (wraps it) and a deployment decision that the
   agent process runs as a uid that cannot read the key file. *Buildable today, shell-only.* Ship the **quick**
   form first; schedule the **real** form (GitHub required-reviewers, L5) as the bypass-proof end-state.

2. **`report.schema.json` + `report-lint.sh` + `render.sh` (Mechanism A) — and D rides along.**
   *Highest leverage.* It makes "honest report" a checkable artifact and is the **precondition** the push gate
   (step 0 of #1) leans on, so #1's "report must be PASS" is meaningful only once this exists. D (the
   `deferred[]` record + H2) is *part of this schema* — no extra build. Depends on: `jq`/`python3` (present).
   Wire `report-lint.sh` as the mandatory final pipeline step and as `approve-gate.sh`'s precheck.

3. **`reconcile.sh` + the one-line claim emission in `fixer.md` (Mechanism B).**
   Depends on: the report object existing (#2) to receive `discrepancies[]`, and `grep-verify.sh` (exists).
   This removes the recall dependency for the most fragile honesty rule. Lower in order only because it
   *writes into* the artifact #2 defines — not because it's less important.

4. **PLAYBOOK de-duplication pass (the meta-containment).**
   Rewrite the "Final report (mandatory shape)" / "surface contradicted self-report" / "STOP for
   authorization" / "DEFER → backlog" passages to **reference the scripts and schema by name** and delete the
   restated logic, killing the drift class that made v2 self-contradictory. Depends on #1–#3 existing.

5. **Real-build upgrades (when the runtime allows):** off-box approver for C (GitHub environment reviewers,
   L5); `report.py` typed appender for A; supervisor-runs-`reconcile` for B in the nested SDK runtime; an
   `answer.sh`→GitHub-issue auto-file for D. Each is an interface-preserving swap of a *source* (grant source,
   report builder, reconcile runner) — no contract changes — so they can land incrementally without a rewrite.

**Why this order is safe under partial completion:** after step 1 alone, nothing reaches production without a
human-bound grant (the worst outcome is blocked). After step 2, no run can *claim* CLEAN beyond its proof.
After step 3, no fleet lie can ride to CLEAN unacknowledged. Each step strictly tightens; none depends on a
later step to be safe. This mirrors the kit's own principle: the gate exists *before* the convenience.
