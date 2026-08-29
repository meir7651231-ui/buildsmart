# Red-team of the orchestrator PLAYBOOK — by the perfect-agent fleet

The matured **perfect-agent (v6)** fleet was pointed at this kit's own `PLAYBOOK.md` and told to
adversarially **tear it apart** — each of the 9 dimensions attacking from its angle (reliability hunts
verification holes, safety hunts authorization holes, reasoning hunts logic flaws, …). It found ~50 real
flaws (4 CRITICAL). The built critiquing the builder; the loop closed on the foundation. **PLAYBOOK v2 +
the scripts are the response.** (Adversarial "tear apart" surfaced CRITICAL holes that 6 *constructive*
self-improvement iterations never did — attack mode ≠ build mode.)

## CRITICAL — fixed
1. **Safety:** `ff-push.sh` had **no default-branch guard** — a wrong/injected `$BRANCH` arg could push to
   `main` (the divergence check passes if main hasn't moved). → hard REFUSE on default/protected branches
   (`ALLOW_PROTECTED=1` human-only override); a failed fetch now aborts (no silent stale-ref pass).
2. **Capabilities/Autonomy:** PLAYBOOK said "spawn a fleet" but Claude Code can't nest (FACTORY proved
   `NESTING_SUPPORTED=no`) and never said so — an agent loading only the PLAYBOOK would stall/hallucinate.
   → §0 runtime check + flatten instruction; sub-agents declared **LEAF** (no further spawn).
3. **Autonomy:** "wait for all" had **no timeout** → one hung sub-agent blocks the run forever, silently.
   → per-agent deadline + proceed-with-returns + flag-missing-lenses.
4. **Memory:** **no state persistence** → an ephemeral-container interruption = total restart.
   → `_run.json` / `_findings.md` / `_confirmed.md` written at phase boundaries; resume reads them first.

## HIGH — fixed / hardened
- **Reliability (deepest):** grep-verify proves a token **EXISTS**, not that the bug is **FIXED** (a fixer can
  reintroduce the same logic under a new name). → PLAYBOOK pairs every grep-check with the test that exercises
  the path; **tests beat grep**; grep-verify is a numbered MANDATORY step (4b), not advice.
- **Reliability/Knowledge:** `central-verify.sh` was Flutter-hardwired, "green" undefined, wrong-scope passed
  silently. → script asserts a `pubspec.yaml` fingerprint, **prints target + HEAD**, no longer swallows
  `pub get`, and trusts `flutter analyze`'s **exit code** (not only a regex). §0 makes adapting the gate a prerequisite.
- **Reasoning:** green = consistency, not correctness — and self-defeatable (update a failing test → green).
  → caveat: add coverage or record the gap; only update a test when the OLD assertion was proven wrong.
- **Communication:** "relay conclusions not transcripts" dropped sub-agent caveats. → never drop a caveat/
  uncertainty; surface any self-report grep-verify contradicted; a mandatory final-report shape.
- **Safety:** no human pause before push; `worktree remove --force` could destroy uncommitted work. → step 7
  hard authorization stop; cleanup only after commit+push, never `--force` on a dirty tree.
- **Identity:** the orchestrator had no mandate/name. → an explicit named mandate that makes grunt-work a scope
  violation and honesty a mandate term; refuses mid-session mandate redefinition.
- **Autonomy/Reasoning:** no partial-fleet triage; the ff rule had no divergence-recovery. → both added.

## Method
9 dimension-attackers, each wearing its own `dimensions-v6/N` spec → consolidated by the orchestrator → fixes
applied to PLAYBOOK + scripts, bash-syntax-checked, the new default-branch guard **self-tested** (refuses
`main`), and shipped through the now-hardened `ff-push.sh`.
