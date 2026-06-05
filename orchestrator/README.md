# Orchestrator kit — how to run "another one of me"

This is the distilled behavior of an orchestrator agent that **audits → validates → fixes → verifies
→ ships** a codebase by driving a fleet of parallel sub-agents. It is **config, not application code** —
load it into an agent runtime and you get another orchestrator. One orchestrator is worth its whole
fleet because it keeps the judgment; the fleet keeps the labor.

## What's here
| file | role |
|------|------|
| `PLAYBOOK.md` | the orchestrator's brain — the pipeline + the hard rules. **Load as the system prompt / project instructions.** |
| `agents/auditor.md` | read-only lens-scanner sub-agent (spawn N, one disjoint lens each) |
| `agents/validator.md` | adversarial verifier (drops false-positives before fixing) |
| `agents/fixer.md` | disjoint-file fixer (spawn several, partitioned by file) |
| `agents/supervisor.md` | **one per fleet** — objectively verifies the fleet + reports up (the oversight node) |
| `FACTORY.md` | hierarchical factory architecture (Tier 0/1/2 + the up/down control loop) + the **verified** execution model (nested on the SDK, flattened in Claude Code) |
| `scripts/wt-setup.sh` | fresh worktree per run |
| `scripts/central-verify.sh` | **the gate** — analyze 0 + tests + build (project adapter; current: Flutter) |
| `scripts/grep-verify.sh` | verify the **bytes** of a claimed fix, not the agent's prose |
| `scripts/ff-push.sh` | fast-forward-only push with divergence refusal + retries |

## Spawning a copy

**A) Inside Claude Code (easiest, highest fidelity).** Each Claude Code session that loads this config
*is* one orchestrator. Run several sessions in parallel (different modules/branches) = several
orchestrators — exactly the "six independent agents, each worth six" shape.
- Copy `agents/*.md` into `.claude/agents/` (they become spawnable sub-agents).
- Reference `PLAYBOOK.md` from `CLAUDE.md` (or wrap it in a `.claude/skills/audit-fix-ship/` skill so a
  session can kick the whole pipeline with one command).
- The session then fans out auditor/validator/fixer agents and runs the gate itself.

**B) As a standalone process (programmatic fleet).** When your agent-network needs to deploy many
orchestrators autonomously, build on the **Claude Agent SDK** (the framework for "your own Claude
Code"): use `PLAYBOOK.md` as the system prompt and `agents/*.md` as subagent definitions; launch N SDK
processes = N orchestrators. Same brain, different body.

## Adapting to another project/stack
Only `scripts/central-verify.sh` is stack-specific (it currently runs `flutter analyze/test/build`).
Swap those three blocks for your toolchain (e.g. `tsc && vitest && vite build`). Everything else —
the playbook, the agent roles, worktree/grep/ff-push — is stack-agnostic.

## The one rule that matters most
**Do not trust a sub-agent's prose.** Agents mis-narrate ("already done") even when they did the work —
or claim a fix that isn't there. After the fleet returns, verify the **bytes** (`grep-verify.sh`) and
pass the **gate** (`central-verify.sh`). Ship only on green; confirm "live" only from the deployed bytes.
