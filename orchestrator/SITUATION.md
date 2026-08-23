# Situation brief — design "how to build this RIGHT"

Read this, then design your layer. This is a DESIGN task (constructive), not a critique — but it is
informed by a hard lesson below. Be exhaustive and concrete: **mechanisms, not prose rules.**

## What exists (the system so far)
An **orchestrator kit** (`orchestrator/`): a `PLAYBOOK.md` (the orchestrator's brain) + sub-agent role
defs (`agents/auditor|validator|fixer|supervisor.md`) + scripts (`wt-setup`, `central-verify` = the gate,
`grep-verify` = byte check, `ff-push` = guarded push). It drives a fleet: **audit (disjoint lenses) →
adversarial validate → disjoint-file fix → central-verify gate → ff-push → verify-deploy-from-bytes.**
A **fractal "factory"** (`FACTORY.md`): top orchestrator → orchestrator clones → worker fleets + a
dedicated per-fleet supervisor; a bidirectional control loop (ground truth rises, improvements descend).
A **perfect-agent spec** (`perfect-agent/`): 9 orthogonal dimensions (identity · knowledge · capabilities ·
reasoning · memory · reliability · communication · autonomy · safety), each decomposed through the same 9
(9×9 = 81 facets), iterated v1→v6 to convergence.

## What we learned (the hard lesson — this is the point)
The perfect-agent fleet RED-TEAMED the PLAYBOOK twice. v1: ~50 real flaws (4 CRITICAL). We "hardened" it to
v2 with better **rules**. The re-attack on v2: the 4 CRITICALs were closed in the bytes, but **8 of 9
dimensions still returned "PARTIALLY"** — because:
- **The fixes were PROSE (rules in a doc), not MECHANISM (enforcement in code).** "A named hole is still a
  hole." e.g. the push guard added an `ALLOW_PROTECTED=1` env override whose "human-only" rule is just a
  comment — any agent with a shell bypasses it in one line.
- **Patching with prose INTRODUCED contradictions:** the PLAYBOOK says "do NOT rebase" while the script says
  "rebase first"; the PLAYBOOK says "never --force" while `wt-setup` prints a `--force` cleanup hint.
- **Convergence ceiling:** like the v1→v6 study, adding rules has steep diminishing returns and eventually
  just churns. The real ceiling is the **underlying model's capability** — prompts *approach* robustness,
  never transcend it.

## Runtime facts (ground truth, verified)
- **Claude Code: a sub-agent CANNOT spawn sub-agents** (`NESTING_SUPPORTED=no`). True nesting needs the
  **Agent SDK** (multi-process). In Claude Code the factory runs FLATTENED (one orchestrator runs all tiers).
- MCP/deferred tools must be loaded via ToolSearch before use, or they error.

## Your task — design how to build THIS the best way
Given all the above, design **your layer** of a properly-built version of this system — the autonomous
multi-agent audit→fix→ship + agent-building machine — done RIGHT. For your dimension:
1. **The right architecture** — components, where enforcement lives, the data/contracts between them.
2. **MECHANISMS, not rules** — for each thing that was "prose" before, give the concrete enforcement (a
   guard that can't be bypassed, a gate that can't be skipped, a schema, a tool, a permission boundary).
   Name what is a shell/script/config change vs. what needs real tooling (e.g. a coverage harness).
3. **Honest limits** — say plainly what CANNOT be solved by mechanism and is an inherent limit (model
   capability, genuine human judgment, the runtime) — and how the design *contains* that limit safely.
4. **Build order** — what to build first (highest safety/leverage), and what each piece depends on.
Be thorough ("full-full"). Concrete over abstract. This is the blueprint we will build from.
