# The Factory — hierarchical orchestrator architecture

A self-improving organization of agents: labor at the bottom, supervision rising through dedicated
foremen, a controller at the top pushing continuous improvement back down. Built on the orchestrator
kit (`PLAYBOOK.md` = the brain each orchestrator loads; `agents/` = the roles).

## Structure (3 tiers)
- **Tier 0 — TOP.** Does not manage workers directly; manages orchestrators. Synthesizes the reports
  that rise, and pushes improvements/corrections back down to every level.
- **Tier 1 — ORCHESTRATOR CLONES.** N agents loaded with `PLAYBOOK.md` — each a *full* orchestrator
  ("exactly like the top, one level down"), each owning a module/branch. Tier 0 supervises them.
- **Tier 2 — WORKER FLEETS.** Each Tier-1 clone drives its own fleet (auditor/validator/fixer) PLUS
  exactly **one dedicated `supervisor`** (`agents/supervisor.md`) — the single node whose only job is
  to objectively verify the fleet and report up to its Tier-1 owner.

## The two flows — a closed, continuous control loop
- **UP-PIPE (sensing):** lowest worker → fleet `supervisor` (verifies objectively: runs the gate /
  greps the bytes) → Tier-1 clone → Tier 0. Ground truth rises as ONE consolidated, *verified* report
  per level — never raw prose.
- **DOWN-FLOW (actuation):** Tier 0 synthesizes the rising reports and pushes corrections / refinements
  / better instructions DOWN through every level, to the last worker. No node left un-tuned.
- **CONTINUOUS:** report up → improve down → repeat. The top is the controller that closes the loop.

## Why it actually works (the reliability principle)
Individual agents are unreliable — they mis-narrate ("already done"). The org tolerates that because
oversight is a **structural, dedicated, objective** role at every level: the per-fleet `supervisor`
verifies ground truth before anything is reported up. Supervision ≠ collecting status; supervision =
objective verification. A lie cannot climb a pipe whose every junction re-checks against the bytes.

## EXECUTION MODEL — how it actually runs (tested empirically, not assumed)
Whether a sub-agent can spawn its OWN sub-agents (true runtime nesting) is runtime-dependent. It was
tested directly:

- **Claude Agent SDK / multi-process runtime → FULLY NESTED.** Each Tier-1 clone is its own agent
  process that spawns its Tier-2 fleet (incl. its supervisor). The tree runs live as drawn. This is the
  target runtime for the literal factory.

- **Claude Code (this harness) → FLATTENED ORCHESTRATION.** Empirical test: **NESTING_SUPPORTED=no** —
  a spawned sub-agent has no agent-spawn tool; dispatch is reserved for the top orchestrator. So here the
  *top* runs all tiers itself: it spawns each Tier-2 fleet directly, designates one agent per fleet as the
  `supervisor`, collects the up-pipe reports, and pushes the down-flow improvements. **Same architecture,
  same roles, same loop — executed by one orchestrator instead of a live nested tree.** Functionally
  equivalent for the work; it just doesn't fan the *management* across processes.

Both modes use the identical `PLAYBOOK.md` + `agents/` + `scripts/`. Port to the SDK for true nesting;
run in Claude Code today in flattened mode. **Do not claim a live nested tree in Claude Code — it is not
available (verified); claim the flattened run, which is real.**
