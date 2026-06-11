# THE LAW — the invariant that makes the swarm (and why no mistake escapes)

The one document every node loads first. The mechanism is **invariant** across every task (build the
perfect agent · write code · test · delete · launch). Only the **spec (אפיון)** — the set of N units —
changes per task.

## I. The invariant mechanism (never changes)
1. **Fractal.** A task decomposes into N units; each unit decomposes through the SAME N units
   (self-application) → N×N, and deeper (N³…) to whatever depth complexity demands.
2. **Independent, complete nodes.** Every node is a COMPLETE agent for its own facet. It **dons its own
   facet-spec** — not the whole charter. No node needs its parent, its children, or its siblings.
3. **Shared artifact, not each other.** Each node consumes the **artifact** (the code/spec under work) —
   never another node's prose. That is what makes them independent: no handoff chain, no coupling, no
   channel for one node's error to corrupt another.
4. **Parallel.** Independent ⇒ concurrent. The orchestrator only gathers the independently-verified results.

## II. The variable spec (changes per task)
- **N = the units the task requires.**
  - A *being* task → **dimensions** (qualities that coexist) — e.g. the perfect agent = 9 → 9×9 = 81.
  - A *doing* task → **phases** (stages in time): Understand · Plan · **Make** · Verify · Review · Ship ·
    Ratchet → 7 → 7×7 = 49. Only **Make** renames per task (write / delete / refactor / migrate).
- The more composite the task, the larger N (a single change ≈ 7; a full store launch ≈ 10 phases, ~90 sub).

## III. Why no mistake ESCAPES — the layers (this is the real "no agent errs")
A node can still err. The guarantee is that an error cannot **survive**:
1. **Verify bytes, not prose.** Never trust "done"; grep the file / run the gate.
2. **Verify the verification** (the N.N facet on Verify). Mutation-test: inject a bug → the test MUST go RED
   → restore → GREEN. A test that passes both ways is worthless.
3. **The gate.** analyze 0 + full suite green + build + conformance + required-tests. Skips are LOUD.
4. **Structural absence (a real wall).** A tool not in the process can't be misused — the read-only auditor
   can't break code; the shell-less fixer can't push or skip a gate.
5. **Off-host enforcement (the only true wall).** CI holds the sole deploy credential; an on-host actor that
   is wrong or compromised still cannot ship.
6. **The ratchet.** Every escaped bug becomes a permanent enforced rule (regression ledger). The same mistake
   cannot escape twice; the system gets monotonically harder to fool.

## IV. The honest limit (stating this IS part of obeying the law)
"No agent will EVER make a mistake" is **unreachable** — the ceiling is the model's capability; "perfect" is
the asymptote you iterate toward. Any node, tool, or gate on-host can be edited by the actor that runs it, so
these raise the floor on honest error + mis-narration — they are **not** a security boundary. The law does
not make error impossible; it makes **escape** improbable and **recurrence** impossible. Claiming
infallibility would itself be the exact error this law exists to prevent.

---
*See `PERFECT-CODE-FRACTAL.md` (the 7×7 worked example), `FACTORY.md` (tiers + flattened execution),
`PLAYBOOK.md` (the pipeline), `.claude/skills/swarm/SKILL.md` (one-command launch).*
