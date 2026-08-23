---
name: swarm
description: Launch the BuildSmart agent swarm (flattened orchestration) on a task.
  Use when the user says "run the swarm" / "הפעל את הנחיל" / "audit-fix-ship". Pass
  the SSOT (path to the task/knowledge doc) or a one-line task as args. Fans out
  auditor→validator→fixer sub-agents + one supervisor, each DONNING its own perfect-agent
  dimension; verifies the bytes (not prose), runs the gate, ships only on green. Removes
  the need to re-explain the mechanism every session.
---

# /swarm — one-command swarm launch (built ON the 81-facet perfect agent)

You are now the **top orchestrator**. Load `orchestrator/PLAYBOOK.md` as your charter and, as the
top node, **don the whole** `perfect-agent/AGENT.md` (all 9 dimensions). Then run the pipeline below.
**Do NOT re-derive or re-explain the mechanism — execute it.**

## Input
The skill args = the **SSOT**: a path to the task/knowledge doc (e.g. `knowledge/LAUNCH-TASKS-MICRO.md`)
or a one-line task. If args are empty, ask for the **SSOT path only** — nothing else.

## The donning rule (how the fleet is built ON the perfect agent)
Each sub-agent **dons its own dimension**, not the whole charter — this is the user's design (specialized
+ diversity-preserving). Mechanism in this harness: the Agent tool takes only `(prompt, subagent_type)` —
there is **no per-agent system prompt** — so when you spawn a role, **prepend the text of its dimension
file(s) to that agent's prompt**. That IS the donning.

| role | dons (prepend to its prompt) | why |
|------|------------------------------|-----|
| `auditor`    | `perfect-agent/dimensions/6-reliability.md` + `9-safety.md` | run the code, don't assert; suspect too-clean results |
| `validator`  | `perfect-agent/dimensions/4-reasoning.md` + `6-reliability.md` | uncertainty scale + bias checklist; verify vs live code |
| `fixer`      | `perfect-agent/dimensions/3-capabilities.md` | act only within what it is empowered to edit |
| `supervisor` | `perfect-agent/dimensions/6-reliability.md` + `7-communication.md` | objective verification + one clear consolidated report |
| orchestrator (you) | `perfect-agent/AGENT.md` (all 9) | hold identity/memory/autonomy across the whole run |

## Pipeline — hierarchical (1.1 … 4.3), execute in order
**1 · SENSE (חישה)**
- `1.1` Read the SSOT; enumerate the work into concrete units.
- `1.2` AUDIT — spawn `auditor`s in parallel, one disjoint lens each (`orchestrator/lenses/registry.txt`); each dons 6+9. Returns `file:line · defect · severity · one-line-fix`.
- `1.3` VALIDATE — spawn `validator`s (don 4+6); check each finding vs live code; drop false-positives before any edit.

**2 · ACT (פעולה)**
- `2.1` Partition surviving findings **by file** (disjoint — no two fixers share a file).
- `2.2` FIX — spawn `fixer`s in parallel (don 3); edit ONLY (no git/build/test).

**3 · VERIFY (אימות)**
- `3.1` BYTE-VERIFY — `orchestrator/scripts/grep-verify.sh` on every claimed fix. Never trust "done".
- `3.2` GATE — `orchestrator/scripts/central-verify.sh app_flutter --assert orchestrator/manifests/buildsmart.conformance.txt --required-tests orchestrator/manifests/buildsmart.required-tests.txt`. Pass = analyze 0 + full suite green + build OK + conformance + required-tests. Skips are LOUD.
- `3.3` MUTATION-VERIFY critical tests: inject a bug → test MUST go RED → restore → GREEN.
- `3.4` SUPERVISE — one `supervisor` (don 6+7) re-verifies objectively and reports up ONE consolidated truth.

**4 · SHIP (משלוח) — on green ONLY**
- `4.1` Commit (the pre-commit hook IS the gate set).
- `4.2` `orchestrator/scripts/ff-push.sh <branch>` — fast-forward-only, refuses on divergence, retries. **Only when authorized** ("תדחוף").
- `4.3` Cleanup — `ckpt` the phase + `registry.sh assert-none-open` (BLOCK if any spawned agent left unreaped).

## Hard rules (from PLAYBOOK — non-negotiable)
- **Verify bytes, not prose.** Ship only on green. Confirm "live" only from deployed bytes.
- **Push only when authorized.** Never push half-done work.
- **Skips are LOUD, never silent.** **No orphan agents.**

## What this is / is NOT (honesty)
- **Flattened** fleet: one orchestrator spawns every sub-agent directly. Same roles, same pipeline, same verification — by one orchestrator, not a live nested tree.
- The donning is real but bounded: dimension text is **prepended to the prompt**, not set as a true system prompt (the harness has no per-agent system prompt). A literal nested swarm + true per-agent charters need the **Claude Agent SDK** (`FACTORY.md`, verified `NESTING_SUPPORTED=no`).
- Not a capability upgrade and not external software — it removes the re-explaining and binds the fleet to the 81-facet perfect agent.
