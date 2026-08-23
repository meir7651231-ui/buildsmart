# Dimension 4 — Reasoning / Decision / Validation-Logic, built RIGHT

**Scope of this layer.** Not "make the agent think better" (that is model capability — see §5). This layer
governs the **consequential decisions** the pipeline makes between audit and ship, and turns each one from a
*prose rule the orchestrator is trusted to follow* into a **mechanism that holds whether or not it does**:

- **Validation** — is a finding a real bug? (today: `validator.md` prose + PLAYBOOK step 3)
- **Severity** — HIGH/MED/LOW, and who wins on a conflict? (today: "validator adjudicates — don't inherit the first lens", PLAYBOOK step 2)
- **The test-update arbiter** — "update a failing test only if the OLD assertion was proven wrong" (today: one prose sentence in PLAYBOOK step 5; *self-issued* by whoever is editing)
- **Act-vs-ask under ambiguity** — the 4.8 two-step test (today: prose, no threshold, no trigger)
- **DEFER-LARGE** — "written to a backlog, never silently dropped" (today: prose; nothing writes the backlog)

The lesson from the v2 re-attack applies to every one of these: **a named rule that the same agent both
applies and is graded on is not a control — it is a comment.** The whole design below is one move repeated:

> **Separate the JUDGMENT from the AUTHORITY to act on it.** The judgment stays in the model (uncapped,
> un-mechanizable). The *authority* — the gate opening, the test edit landing, the push proceeding — is
> granted by a **deterministic checker reading a typed artifact that a DIFFERENT agent produced**. An agent
> can narrate any conclusion it likes; it cannot grant itself the authority, because the thing that grants
> authority is not the thing that holds the opinion.

This is the reasoning-layer analogue of "trust the bytes, not the prose": **trust the decision-record +
the second reviewer + the deterministic rule — never the deciding agent's own claim that it decided right.**

---

## 1. Architecture — decision points, artifacts, and who arbitrates

### 1.1 The five decision points and the gate each must pass

Every consequential decision in the pipeline is forced through a **typed artifact** on disk and a
**deterministic verifier** (`decision-verify.sh`, §2.0). No decision is "made" by an agent asserting it in
prose; it is made when its record exists, is well-formed, carries a second party's independent verdict where
required, and passes the verifier. The orchestrator's PLAYBOOK step does not *contain* the rule — it *calls
the checker* and obeys the exit code.

```
DECISION POINT          ARTIFACT (typed, on disk)     ARBITER / GATE                        BYPASSABLE BY PROSE?
─────────────────────────────────────────────────────────────────────────────────────────────────────────────
1 Is it a real bug?     _findings.json[].validation   2nd agent (validator) ≠ auditor       NO — verdict carries author id
2 What severity?        _findings.json[].severity     deterministic conflict rule (§2.3)    NO — rule is a script, not a vote
3 May this test edit?   _test-change/<id>.json        2nd agent (test-arbiter) ≠ fixer      NO — gate refuses without it (§2.1)
4 Act or ask?           _decisions.jsonl (act-vs-ask) reversibility×blast script (§2.4)     NO — irreversible class forces ask
5 Defer the big one?    _backlog.jsonl (append-only)  byte-presence check before ship (§2.5) NO — ship gate greps the backlog
```

### 1.2 The three roles, by AUTHORITY not by name

The factory already has auditor / validator / fixer / supervisor. Reasoning-layer authority cuts across them:

- **PROPOSERS** (auditor, fixer) — may *claim* a finding/severity/fix. Their claim is an input, never a
  verdict. They have **no authority to confirm their own claim or to grant a gate.**
- **REVIEWERS** (validator, test-arbiter) — read-only, **structurally distinct from the proposer** (enforced
  by id, §2.6). They issue the verdict that a decision-record carries. A reviewer cannot review its own
  proposal; a reviewer has no Edit tool, so it cannot turn a verdict into a fix.
- **THE DETERMINISTIC LAYER** (`decision-verify.sh`, `severity-rule.sh`, the gate, the ship grep) — not an
  agent at all. Resolves what is mechanizable (well-formedness, conflict winner, presence-in-backlog,
  proposer≠reviewer) with **zero judgment**, so the judgment that remains is small and named (§3).

**Why this is the fix and v2 wasn't:** v2 wrote "the validator adjudicates" into PLAYBOOK prose, then let the
orchestrator self-report that it happened. Here, the orchestrator literally cannot reach step 5 (gate) with a
`_findings.json` whose entries lack a reviewer verdict from a non-proposer id — `decision-verify.sh` exits
non-zero and the gate script refuses to run. The control is in the data contract + the exit code, not in the
orchestrator's good intentions.

### 1.3 Data contracts (the spine)

All reasoning artifacts are JSON/JSONL on the worktree (alongside the existing `_run.json` / `_findings.md`).
Append-only files (`_decisions.jsonl`, `_backlog.jsonl`) are never rewritten — only appended — so history is
a fact, not a current opinion. `_findings.json` is the canonical structured form (`_findings.md` becomes a
*rendered view* of it, satisfying PLAYBOOK's "one source of truth per state"; §2.7).

```jsonc
// _findings.json — one object per finding, the canonical record
{
  "id": "F-014",
  "file": "lib/cart.dart", "line": 88,
  "claim": "qty can go negative; no clamp",
  "method": "abductive",                      // 4.2 — which reasoning mode produced this (named, checkable)
  "evidence": ["lib/cart.dart:88 decrement has no floor", "test/cart_test.dart:0 (no coverage)"],
  "proposer": { "agent": "auditor", "id": "aud-lens-state-3" },
  "severity": { "value": "HIGH", "by": "aud-lens-state-3", "rationale": "user-visible wrong total" },
  "validation": {                              // REQUIRED before gate; author MUST differ from proposer.id
    "verdict": "CONFIRMED",                    // CONFIRMED | FALSE-POSITIVE | ADJUST | DEFER-LARGE
    "by": "val-2",
    "rationale": "reachable from + button; framework does not clamp",
    "severity_override": null,                 // set by reviewer on ADJUST; feeds §2.3
    "confidence": "highly likely",             // 4.6 five-level scale ONLY (enum-enforced)
    "fix_test": "test/cart_test.dart::clamps_qty_at_zero"  // the test that will PROVE it (4b pairing)
  }
}
```

```jsonc
// _test-change/<finding-id>.json — the SECOND-REVIEW GATE for editing a failing test (§2.1)
{
  "finding": "F-014",
  "test_id": "test/cart_test.dart::old_allows_negative",
  "old_assertion": "expect(cart.qty, -1)",        // the literal bytes being changed
  "new_assertion": "expect(cart.qty, 0)",
  "proposer": { "agent": "fixer", "id": "fix-cart-1", "argument": "old asserted the bug as correct" },
  "arbiter": {                                     // author MUST differ from proposer.id AND from fixer fleet
    "by": "test-arbiter-1",
    "ruling": "OLD-WRONG",                         // OLD-WRONG (allow) | OLD-RIGHT (refuse) | UNDECIDABLE (refuse→ask)
    "proof": "spec WIRING.md L42: qty floors at 0; old assertion encoded the defect",
    "spec_anchor": "WIRING.md:42"                  // REQUIRED for OLD-WRONG; a verdict with no anchor is rejected
  }
}
```

```jsonc
// _decisions.jsonl — append-only act-vs-ask + every significant decision (4.5 decision log, made durable)
{"ts":"…","id":"D-07","kind":"act-vs-ask","question":"which dir is the live app?","reversible":true,
 "blast":"local","class":"ACT","interpretation":"app_flutter per CLAUDE.md","chosen":"act","note":"…"}
{"ts":"…","id":"D-08","kind":"act-vs-ask","question":"push to which branch?","reversible":false,
 "blast":"remote-shared","class":"ASK","question_to_user":"confirm target branch","chosen":"ask"}

// _backlog.jsonl — append-only DEFER-LARGE sink; ship gate greps this for every DEFER verdict (§2.5)
{"ts":"…","finding":"F-022","reason":"touches 31 call-sites — not a polish ship","est_files":31,"by":"val-2"}
```

---

## 2. Mechanisms — one per former-prose decision

Each subsection gives: **the prose today → the mechanism → what KIND of change it is → why it can't be
narrated past → the QUICK-vs-REAL build** (quick = shell/config landable now; real = needs tooling).

### 2.0 The foundation — `decision-verify.sh` (the verifier the gate depends on)

**Mechanism.** A single deterministic script the ship gate calls *before* it will run `central-verify.sh`. It
reads `_findings.json` and the `_test-change/` and `_backlog` artifacts and exits non-zero unless every
contract below holds. It makes **no judgment** — it only checks structure, enums, presence, and id-distinctness.

```bash
#!/usr/bin/env bash
# decision-verify.sh <worktree> — the reasoning-layer gate that must pass before central-verify runs.
# Pure structural enforcement of the decision contracts. Zero judgment. usage: decision-verify.sh <wt>
set -uo pipefail
WT="${1:?worktree}"; F="$WT/_findings.json"; fail=0
[ -f "$F" ] || { echo "DV FAIL: no _findings.json"; exit 1; }

# C1 every finding has a validation verdict authored by an id != its proposer id (the SECOND-REVIEW invariant)
jq -e '
  [ .[] | select(
      (.validation == null)
      or (.validation.by == null) or (.validation.by == "")
      or (.validation.by == .proposer.id)                                  # self-review = no review
      or ((.validation.verdict) as $v | (["CONFIRMED","FALSE-POSITIVE","ADJUST","DEFER-LARGE"] | index($v)) == null)
      or ((.validation.confidence) as $c | (["highly likely","likely","unknown","unlikely","highly unlikely"] | index($c)) == null)
  ) ] | length == 0' "$F" >/dev/null \
  || { echo "DV FAIL C1: a finding is unvalidated, self-validated, or has a bad verdict/confidence enum"; fail=1; }

# C2 every CONFIRMED finding names the test that will prove it (4b grep↔test pairing, structural form)
jq -e '[ .[] | select(.validation.verdict=="CONFIRMED" and ((.validation.fix_test // "")==""))] | length==0' "$F" >/dev/null \
  || { echo "DV FAIL C2: a CONFIRMED finding has no fix_test (grep is not proof — a test must exercise it)"; fail=1; }

# C3 every DEFER-LARGE finding is present in the append-only backlog (§2.5) — checked by id, by bytes
for id in $(jq -r '.[] | select(.validation.verdict=="DEFER-LARGE") | .id' "$F"); do
  grep -q "\"finding\":\"$id\"" "$WT/_backlog.jsonl" 2>/dev/null \
    || { echo "DV FAIL C3: DEFER-LARGE $id is not written to _backlog.jsonl — silent drop refused"; fail=1; }
done

# C4 every test-change record has an arbiter != proposer, ruling OLD-WRONG, and a spec anchor (§2.1)
for tc in "$WT"/_test-change/*.json; do [ -e "$tc" ] || continue
  jq -e '
    (.arbiter.by != null and .arbiter.by != "" and .arbiter.by != .proposer.id)
    and (.arbiter.ruling == "OLD-WRONG")
    and (.arbiter.spec_anchor != null and .arbiter.spec_anchor != "")' "$tc" >/dev/null \
    || { echo "DV FAIL C4: $tc — test edit lacks an independent OLD-WRONG ruling with a spec anchor"; fail=1; }
done

[ "$fail" -eq 0 ] && echo "DECISIONS VERIFIED" || echo "DECISION-CHECK FAILED"
exit $fail
```

**Kind:** shell + `jq` (config-level, landable now). **Why un-narratable:** the gate wrapper (§2.1) runs this
first and aborts on non-zero. The orchestrator cannot "consider it done" — there is no path to `central-verify`
that skips a non-zero exit. The check reads *recorded ids*, so a self-review (`validation.by == proposer.id`)
is caught even if the agent's prose says "independently validated."

### 2.1 Validation as a mechanism + the test-update arbiter as a real SECOND-REVIEW GATE

**Prose today.** PLAYBOOK step 5: *"Updating a failing test to make it green is valid ONLY when the OLD
assertion was proven wrong."* `validator.md`: the four verdicts, as guidance. Both are self-issued: whoever
edits the test also decides the edit was allowed, and the validator's verdict lives only in returned prose.

**The mechanism — a chain of three locks:**

1. **Verdict must exist and be foreign.** Validation is not "the validator ran"; it is `validation.by` present,
   from an id ≠ `proposer.id`, with an enum verdict and enum confidence. Enforced by `decision-verify.sh` C1.
   *This converts "adversarial validation is mandatory" from a rule the orchestrator promises into a contract
   the gate enforces.*

2. **A test edit requires a SEPARATE arbiter record — and the gate refuses without it.** This is the headline
   mechanism. The fix fleet **physically cannot edit `test/`** (it is removed from the fixer's writable scope;
   the orchestrator owns test edits — already PLAYBOOK intent, now enforced by §2.6 path-fencing). When a fix
   genuinely invalidates a test's old assertion, the fixer emits a **`_test-change/<id>.json` proposal** (claim
   only — `proposer.argument`). A **`test-arbiter` agent (distinct id, read-only, no Edit)** then rules
   `OLD-WRONG` / `OLD-RIGHT` / `UNDECIDABLE`, and **must cite a `spec_anchor`** (a line in WIRING/RULES/legacy
   source proving the old assertion encoded the bug). Only `OLD-WRONG` *with* an anchor lets the edit through
   (`decision-verify.sh` C4). The actual byte-edit to the test is then applied by the orchestrator and
   **grep-verified** like any other fix.

   **A `central-verify` wrapper makes the order unskippable** (this is what the PLAYBOOK step *calls*, instead
   of *describing*):

   ```bash
   #!/usr/bin/env bash
   # gate.sh <worktree> <app-dir> — the only sanctioned path to green. Reasoning-gate THEN build-gate.
   set -uo pipefail
   WT="${1:?wt}"; APP="${2:?app}"; HERE="$(dirname "$0")"
   # If any test file changed in this run, a matching OLD-WRONG arbiter record MUST exist (no silent green).
   for t in $(git -C "$WT" diff --name-only -- '*_test.dart' 'test/*' 2>/dev/null); do
     base="$(basename "$t")"
     ls "$WT"/_test-change/*.json >/dev/null 2>&1 \
       && grep -ql "$base" "$WT"/_test-change/*.json \
       || { echo "GATE REFUSE: $t was edited with no _test-change arbiter record — a test was changed to go green without a ruling."; exit 3; }
   done
   "$HERE/decision-verify.sh" "$WT" || { echo "GATE REFUSE: decisions unverified (see above)"; exit 3; }
   exec "$HERE/central-verify.sh" "$APP"        # only now may the build gate run
   ```

3. **`UNDECIDABLE` routes to a human, not to the editor's discretion.** If the arbiter cannot prove the old
   assertion wrong from the spec, the ruling is `UNDECIDABLE`, the gate refuses (C4 requires `OLD-WRONG`), and
   the orchestrator must surface the question (§2.4 ASK path). The editor never gets to break the tie in the
   direction of "ship it."

**Kind:** §2.1 lock-1 and lock-3 are shell+jq (now). Lock-2's *path-fencing* (§2.6) is a launch-config change
(now). The `test-arbiter` is a new agent role file (now — one markdown def, reusing the validator's read-only
tool set). **Why un-narratable:** the gate greps the **diff** for any touched test file and demands a matching
arbiter record on disk; the orchestrator cannot claim "the old test was wrong" in prose and proceed — the
record must exist, name a foreign arbiter, and carry a spec anchor, or `gate.sh` exits 3 before the build even
starts. *Self-issuing a clean bill of health is structurally impossible: the file you'd have to forge has a
`proposer.id` field that the verifier compares against `arbiter.by`.*

### 2.2 Validation is mandatory on >1 finding — enforced, not promised

**Prose today.** *"Mandatory on any pass with >1 finding (only legitimate skip: zero findings)."*

**Mechanism.** `decision-verify.sh` C1 already requires a foreign verdict on **every** finding object,
independent of count. The "skip when zero findings" exception is automatic: an empty `_findings.json` (`[]`)
trivially satisfies C1 (the filter is empty). There is no separate "more than one" branch to forget — the
contract is per-finding, so it holds for 2 findings and for 200. **Kind:** already covered by §2.0 (now).
**Why un-narratable:** the count is derived from the array; the orchestrator cannot under-report findings to
dodge validation without *removing them from the canonical file*, which would also remove them from the ship
report (§2.7 renders the report from the same file) — the dodge is self-defeating.

### 2.3 Severity-conflict adjudication as a DETERMINISTIC rule

**Prose today.** PLAYBOOK step 2: *"on a severity conflict the validator adjudicates — don't inherit the first
lens's framing."* This is a *who-decides* rule with no *how*, so in practice "the validator adjudicates" still
means "an agent picks" — exactly the prose trap.

**Mechanism — a total order, computed by a script, with one named tie-break:**

```bash
#!/usr/bin/env bash
# severity-rule.sh <findings.json> — resolves multi-lens severity disagreement DETERMINISTICALLY.
# Rule (in priority order, no agent vote):
#   R1  A reviewer ADJUST severity_override WINS over any proposer severity (the foreign review is authoritative).
#   R2  Absent an override, take the MAX severity any lens assigned (HIGH>MED>LOW) — safety-conservative:
#       a real HIGH must not be down-graded by a lens that only saw it as LOW.
#   R3  Exact tie with NO override and lenses split on the SAME rank → no tie to break (same rank); if ranks
#       differ R2 already decided. The only residual ambiguity — a reviewer ADJUST with no severity_override
#       on a split — is emitted as NEEDS-SEVERITY-RULING (→ §2.4 ask), never silently picked.
set -uo pipefail; F="${1:?findings.json}"
jq -r '
  def rank: {"HIGH":3,"MED":2,"LOW":1}[.];
  .[] | .id as $id
  | (if (.validation.verdict=="ADJUST" and .validation.severity_override!=null)
       then {id:$id, severity:.validation.severity_override, by:"R1-reviewer-override"}
       else {id:$id, severity:.severity.value, by:"R2-max-of-lenses"} end)
' "$F"
```

(The MAX-of-lenses in R2 is computed at synthesis time when duplicate findings across lenses are merged into
one object — the merge keeps `max(severity)` and records all lens claims in `evidence[]`.)

**Kind:** shell+jq (now). **Why un-narratable:** the winner is a pure function of recorded fields
(`validation.verdict`, `severity_override`, the merged `severity.value`). There is no "the orchestrator judged
it HIGH" step — the severity in the ship report is whatever `severity-rule.sh` prints. The only escape hatch
(`NEEDS-SEVERITY-RULING`) routes **out** to a human, not **in** to the agent's preference, so the conservative
default (R2 = max) governs unless a foreign reviewer explicitly overrode it. *This directly kills the named
hole "inherit the first lens's framing": the rule never reads lens ORDER, only lens VALUES + the foreign
override.*

### 2.4 Act-vs-ask under ambiguity as CONCRETE THRESHOLDS

**Prose today.** 4.8 gives a good two-step test but no operational threshold; PLAYBOOK has "hard stop for the
default branch" for *push* but nothing general. So "use sensible defaults" is left to vibe.

**Mechanism — a 2-axis classifier table + a decision-record requirement.** Every decision the agent would
"just make" is classified on two axes it can answer mechanically, and the cell dictates ACT or ASK:

```
                    blast = local/self      blast = repo-wide (in-worktree)   blast = OUTWARD/SHARED
                    (one file, this run)     (many files, still pre-push)      (push/deploy/delete/remote)
reversible (cheap   ACT, log it             ACT, log it + note plan-B          ASK  (irreversible-by-reach)
  undo, no remote)  D-class: ACT            D-class: ACT                       D-class: ASK
irreversible OR     ACT only if 4.8-(1)     ASK — name the single smallest     ASK — hard stop AT the action
  expensive undo    unambiguous reading     clarifying question (4.8-(2))      point (PLAYBOOK step 7 already)
                    exists; else ASK         D-class: ASK                       D-class: ASK
```

Operationalized as a guard the agent must consult and a record it must write:

```bash
#!/usr/bin/env bash
# act-or-ask.sh <reversible:yes|no> <blast:local|repo|outward> — prints ACT or ASK. Deterministic.
set -uo pipefail; rev="${1:?yes|no}"; blast="${2:?local|repo|outward}"
case "$blast" in
  outward) echo ASK; exit 0;;                                    # outward/shared is ALWAYS ask (push/deploy/delete)
  repo)    [ "$rev" = "yes" ] && echo ACT || echo ASK;;          # repo-wide + irreversible → ask
  local)   [ "$rev" = "yes" ] && echo ACT || echo "ACT-IF-UNAMBIGUOUS-ELSE-ASK";;
  *)       echo ASK;;                                            # unknown blast → conservative ASK
esac
```

- **`outward` is a hard ASK, full stop** — this is the same class as the push/deploy/delete guard and it
  subsumes PLAYBOOK step 7. The agent does not get to argue an outward action is "obviously fine."
- **The `ACT-IF-UNAMBIGUOUS-ELSE-ASK` cell is the only place 4.8-(1) judgment lives** — and even there the
  decision must be **logged to `_decisions.jsonl` with the `interpretation` field filled** (4.5 + 4.8 "act on
  it and note the interpretation"). An empty interpretation on an ACT record is a `decision-verify` warning.
- **Mid-task interpretation-break (4.8 final bullet) is a forced re-ask:** if a later finding contradicts a
  logged ACT's `interpretation`, the agent appends a `kind:"interp-break"` record and must ASK before
  continuing — it may not silently re-class to a new reading. (Mechanized as: a `kind:"interp-break"` line in
  `_decisions.jsonl` with no following user-confirmation line blocks the gate, mirroring §2.5's grep pattern.)

**Kind:** shell (now) + the record contract (now). **Why un-narratable for the dangerous cells:** the
`outward`→ASK and `repo+irreversible`→ASK cells are deterministic and the ship gate (§2.5) refuses if an
`outward` action's `_decisions.jsonl` entry is `class:ACT`. The genuinely judgmental cell (`local +
irreversible`) is **deliberately the lowest-blast cell** — that is the containment: judgment is permitted only
where a wrong call costs one file in a throwaway worktree, and even there it must leave a logged interpretation
that a reviewer/human can later catch. **This is the honest seam between mechanism and judgment, placed where
the blast radius is smallest by construction.**

### 2.5 DEFER-LARGE as an ENFORCED backlog write

**Prose today.** *"DEFER-LARGE → written to a backlog, never silently dropped."* Nothing writes a backlog;
nothing checks one.

**Mechanism — append-only sink + a ship-gate grep keyed by id.** A `DEFER-LARGE` verdict is not "decided" until
its id appears in `_backlog.jsonl` (append-only; never rewritten). `decision-verify.sh` C3 already enforces:
for every finding whose verdict is `DEFER-LARGE`, `grep` the backlog by `"finding":"<id>"` — absent ⇒ gate
refuse. The backlog write is therefore a **precondition of shipping**, not a courtesy. The ship report (§2.7)
renders the `DEFERRED (count + why)` line directly from `_backlog.jsonl`, so the count the user sees is the
count on disk — a dropped defer would shrink the report and fail C3 simultaneously.

**Kind:** append-only file + grep (now; the grep is already in §2.0 C3). **Why un-narratable:** "I deferred it"
is meaningless to the verifier; only the byte `"finding":"F-022"` in the append-only file counts. Because the
file is append-only (the orchestrator's writes to it are appends; a rewrite would lose prior lines that the
gate on the *next* run would miss), a defer cannot be quietly un-recorded later.

### 2.6 Proposer ≠ Reviewer, and fixers can't touch tests — PERMISSION-fenced

**Mechanism — identity + path fencing at spawn time (not in prose).**

- **Distinct ids, asserted by the verifier.** Every spawned agent gets an `id` (`aud-lens-state-3`, `val-2`,
  `fix-cart-1`, `test-arbiter-1`) recorded in the artifact it writes. `decision-verify.sh` C1/C4 reject any
  record where `validation.by == proposer.id` or `arbiter.by == proposer.id`. **The reviewer being a different
  agent is thus a data invariant, not a staffing convention.**
- **Reviewers have no Edit tool.** `validator.md` and the new `test-arbiter.md` are spawned with `tools: Read,
  Grep, Glob, Bash` (no Edit) — already true for validator; make it true for test-arbiter. A reviewer
  *cannot* turn its own verdict into a code change; the separation of judgment from authority is enforced by
  the **tool set**, which the sub-agent cannot expand.
- **Fixers cannot write `test/`.** The fixer prompt says "never the test dir," but prose is the v2 trap.
  Mechanize it: the orchestrator's `grep-verify` step (4b) already computes `git diff --name-only` and asserts
  it equals the union of partitions; **extend that assertion to fail if any `test/` or `*_test.*` path appears
  in a fixer's partition diff** (a fixer touching a test = out-of-scope edit = STOP). The only sanctioned test
  edit is the orchestrator's own, gated by §2.1.

```bash
# add to the post-fleet diff check (PLAYBOOK 4b): no fixer may have touched a test file
if git -C "$WT" diff --name-only | grep -qE '(^|/)test/|_test\.[a-z]+$'; then
  echo "STOP 4b: a test file changed during the FIX fleet — only the gated orchestrator test-edit (§2.1) may."
  exit 1
fi
```

**Kind:** spawn-config (tool sets) + shell (now). **Why un-narratable:** an agent cannot grant itself an Edit
tool it wasn't spawned with, and cannot make its `id` equal to two different agents'. The fence is the runtime
boundary, not the instruction.

### 2.7 One source of truth: `_findings.json` → rendered `_findings.md` / report

**Mechanism.** `_findings.md` and the mandatory final-report "findings fixed / DEFERRED / discrepancies" lines
are **rendered from `_findings.json` + `_backlog.jsonl`** by a tiny `render-report.sh` (jq → markdown), never
hand-written. This satisfies PLAYBOOK's "derive a view from the canonical engine over a parallel copy that
drifts" and closes the gap where an agent narrates a rosier report than the data. **Kind:** shell+jq (now).
**Why un-narratable:** the numbers in the report are `jq length` of filtered arrays; the agent cannot inflate
"fixed: 14" while the canonical file holds 9 CONFIRMED — they are the same source.

### 2.8 Quick build vs real build — what's a script/config now vs what needs tooling

| Mechanism | QUICK (lands now: shell/jq/config/md) | REAL (needs tooling beyond this kit) |
|---|---|---|
| `decision-verify.sh` (§2.0) | ✅ shell + `jq` | — (assumes `jq` present; trivial dep) |
| Second-review test-arbiter gate (§2.1) | ✅ `gate.sh` wrapper + `test-arbiter.md` role + jq | The **spec_anchor truth** (does WIRING:42 *actually* say qty floors at 0?) is read by the arbiter agent — model judgment, not script (§3) |
| Severity rule (§2.3) | ✅ `severity-rule.sh` | — |
| Act-vs-ask classifier (§2.4) | ✅ `act-or-ask.sh` + record contract | The `local+irreversible` "unambiguous reading?" call is model judgment (§3) |
| DEFER-LARGE backlog (§2.5) | ✅ append file + grep | — |
| Proposer≠reviewer / no-Edit / test-fence (§2.6) | ✅ spawn config + diff grep | — |
| Canonical findings + rendered report (§2.7) | ✅ jq render | — |
| **grep↔test PAIRING is real proof** (4b) | ⚠️ C2 enforces a `fix_test` is *named* | **Whether the named test actually EXERCISES the buggy path** needs a **coverage harness** (e.g. `flutter test --coverage` + an lcov check that the fix's lines are hit). Until then, C2 enforces *intent*, the gate's pass enforces *green*, but "this test covers this fix" is asserted, not proven. **This is the single most important REAL-tooling item.** |

---

## 3. Honest limits — judgment that cannot be mechanized, and how it's contained

The mandate is "mechanisms, not prose," but the reasoning layer is exactly where some things **cannot** become
mechanism, because they are the model's judgment. Stating this plainly is itself a 4.6/4.9 requirement
(calibrated honesty; don't claim a mechanism you don't have). For each: the limit, then the **containment** —
the structural box that makes the limit safe even though the judgment inside it is fallible.

1. **The truth of a verdict is model judgment, not a checkable fact.** `decision-verify.sh` proves a verdict
   *exists, is foreign, is well-formed* — it cannot prove `CONFIRMED` is *correct*. A wrong-but-well-formed
   `CONFIRMED` passes the verifier.
   **Containment:** (a) the verdict is foreign (a *second* model has to make the same error independently —
   uncorrelated-error reduction, not elimination); (b) `CONFIRMED` is explicitly a **static claim**, and the
   **gate's tests are the behavioral proof** — a wrong CONFIRMED that breaks behavior fails the gate; (c) the
   `confidence` enum surfaces low-confidence verdicts for the orchestrator/human to weight. The judgment is
   boxed between a foreign reviewer and a behavioral gate; it is never the *last* word.

2. **The `spec_anchor` for a test edit is read by a model, so "OLD-WRONG" rests on a model reading a spec
   line correctly.** The script enforces that an anchor is *cited*; it cannot enforce the anchor *says what the
   arbiter claims*.
   **Containment:** the anchor is a **specific, greppable line** (`WIRING.md:42`) a human can audit in seconds;
   the arbiter is a different agent than the proposer; `UNDECIDABLE`/no-anchor → human. The residual risk
   ("agent misreads an unambiguous spec line") is the same residual as the whole system's model-capability
   ceiling — bounded to a single, cheap-to-review edit, never a silent multi-file change.

3. **The `local + irreversible` act-vs-ask cell needs the 4.8-(1) "is there an unambiguous reading?" judgment.**
   No script can decide whether a reading is unambiguous to "any reasonable person who shares the user's goals."
   **Containment (the design's deliberate placement):** this is the *only* cell where judgment may choose ACT,
   and it is the **lowest-blast cell by construction** — one file, in an ephemeral worktree, fully reversible
   at the repo level, with a logged `interpretation` a reviewer/human can later catch and a forced re-ask on
   interpretation-break (§2.4). Every *consequential* cell (outward, repo-wide-irreversible) is deterministic
   ASK. We did not fail to mechanize the dangerous decisions; we mechanized them and **confined judgment to the
   cheap corner.**

4. **"Did I reason well?" — the 4.4 metacognition / 4.9 anti-rationalization checks resist mechanization.**
   Confirmation bias, sunk-cost pull, a sophisticated argument for crossing a constraint — a script cannot
   detect a rationalization that is internally consistent.
   **Containment:** structural, not introspective. (a) Adversarial **separation of roles** — the proposer wants
   its finding confirmed; the reviewer is rewarded for false-positives/defers (validator.md: "a high
   false-positive rate is a *good* outcome"), so the org's incentive structure counteracts confirmation bias
   instead of asking one agent to police its own. (b) The **"better the argument for an unsanctioned action,
   the more suspicious" heuristic (4.9)** is operationalized as: any decision that would *upgrade* an action's
   class toward ACT/ship (e.g. an argument to treat an `outward` action as fine, or to call an `OLD-RIGHT` test
   `OLD-WRONG`) is the exact class the deterministic rules **refuse** — so a persuasive rationalization meets a
   gate that doesn't read arguments. The agent cannot rationalize past `exit 3`. (c) `method` + `evidence[]`
   fields force each finding to *name its reasoning mode and cite an anchor* (4.2/4.6), making a hand-wavy
   conclusion visibly anchor-less to the reviewer.

5. **The model-capability ceiling itself (SITUATION's central lesson).** Two correlated models can both be
   wrong; more rules have diminishing returns and eventually churn.
   **Containment:** we stop adding rules and instead add **gates + foreign review + behavioral proof**, which
   *approach* the ceiling without pretending to transcend it — and we **say so**: the design's value is making
   the residual risk small, named, and human-auditable, not zero. Where a mechanism would just be another
   bypassable comment (the `ALLOW_PROTECTED=1` lesson), we either make it a real boundary (tool set / path
   fence / exit code) or we mark it an honest limit here — we do not ship a hole with a label on it.

**The line, stated once:** *mechanism owns who-may-decide, what-must-be-recorded, who-must-independently-agree,
and what-deterministic-rule-breaks-ties; the model owns whether a specific claim is true. We made the first set
unbypassable and confined the second set to the cheapest possible blast radius, behind a foreign reviewer and a
behavioral gate.*

---

## 4. Build order (highest safety/leverage first; each notes its dependency)

**Phase 0 — the verifier + the gate wrapper (the keystone).**
1. `decision-verify.sh` (§2.0) — *depends on:* `jq`, the `_findings.json` schema (§1.3). Nothing else gates
   correctly until this exists; it is the single chokepoint every later mechanism plugs into.
2. `gate.sh` wrapper (§2.1) that runs `decision-verify.sh` then `central-verify.sh`, and refuses any touched
   test file lacking a `_test-change` record — *depends on:* (1) + existing `central-verify.sh`. **Highest
   safety/leverage: after this, no decision reaches the build gate unvalidated and no test goes green without
   an arbiter.** This is the piece that would have caught the v2-class "prose rule, self-issued" failure.

**Phase 1 — the schemas + canonical source (so the verifier has something true to read).**
3. Adopt `_findings.json` as canonical; `render-report.sh` to derive `_findings.md` + the report (§2.7) —
   *depends on:* schema. Removes the parallel-prose-copy drift.
4. `_decisions.jsonl` + `_backlog.jsonl` append-only contracts (§1.3) — *depends on:* nothing; pure file
   convention the agents append to.

**Phase 2 — the second-review roles + permission fences.**
5. `test-arbiter.md` role (read-only, no Edit), and confirm `validator.md` stays Edit-less (§2.6) — *depends
   on:* the `_test-change` schema. Makes the test-edit second-review a real distinct agent.
6. Path fences: fixer test-dir diff check added to PLAYBOOK 4b; reviewer tool sets pinned at spawn (§2.6) —
   *depends on:* nothing; spawn-config + one grep. Low effort, closes the "fixer edits a test" hole.

**Phase 3 — the deterministic decision rules.**
7. `severity-rule.sh` (§2.3) and `act-or-ask.sh` (§2.4) — *depends on:* the `severity` / `_decisions.jsonl`
   fields. These can land last because Phase 0's verifier already blocks the *unvalidated* and *self-issued*
   failures; these add the *deterministic adjudication* on top.

**Phase 4 — the one REAL-tooling item (after the shell layer is solid).**
8. **Coverage harness** for the grep↔test pairing (§2.8): `flutter test --coverage` + an lcov assertion that
   each CONFIRMED finding's changed lines are *executed* by its named `fix_test` — *depends on:* the toolchain
   + `fix_test` being recorded (C2, already enforced in Phase 0). This upgrades C2 from "a test is *named*" to
   "the test *covers the fix*," closing the deepest reliability gap (a fixer reintroducing a bug under a new
   name that the named test never exercises). It is **last** because everything before it is bypass-proof
   shell that lands today; this one needs a build-integrated harness and is the highest-effort, so it follows
   the cheap wins — but it is the most important *real* tool, not a config tweak.

**Why this order:** Phase 0 alone converts the four headline prose-traps (mandatory validation, second-review
test gate, no silent defer, no self-issued green) into exit codes — maximum safety per unit of build. Phases
1–3 are cheap shell/config that make the verifier's inputs trustworthy and add deterministic adjudication.
Phase 4 is the single thing that genuinely needs new tooling and is sequenced last so the bypass-proof
skeleton ships first and the expensive correctness-proof is layered onto a sound frame.
