# Bootstrap result — does self-improvement actually improve? (measured, not assumed)

The factory built THE PERFECT AGENT (v1, `dimensions/`). Then it ran the **bootstrap**: each dimension
agent wore its OWN dimension's perfect spec (not the whole charter) and re-derived a sharpened **v2**
(`dimensions-v2/`). Both experiments below were **measured by an independent supervisor**, not self-reported.

## A) Does wearing the charter help at all? (A/B — whole-charter)
Same audit task; two agents — one plain, one wearing the full `AGENT.md`.
- **Baseline (no charter):** 13 findings, **asserted without running the code**; several speculative; it
  **missed** the most important bug.
- **Charter-wearing:** 8 findings, **each with an executed proof**; one honestly labeled SUSPECTED; and it
  **caught a real HIGH the baseline missed** — `grep-verify` printed `OK` on a *missing* file — precisely
  because its Reliability principle made it *run* the code instead of asserting.
- **Result:** the charter raised precision + honesty and caught the bug that mattered. The bug was real and
  is now fixed (commit `8ccb800`).

## B) Does own-dimension self-improvement improve the spec? (the user's design)
9 agents, each wearing its OWN v1 dimension spec, sharpening it to v2. Supervisor-verified:
- **Structural:** 9/9 facets retained in every dimension; **zero regressions**; +3…+17 lines each.
- **Quality (3 sampled — reliability / safety / reasoning):** GENUINE improvement, not padding. Real gaps
  filled with concrete rules, e.g.:
  - **Reliability:** "a test on fully-mocked deps verifies the *contract*, not real behavior"; "a flaky
    result is UNVERIFIED, not a coin-flip pass"; partial-pass quarantine now requires **human** approval.
  - **Safety:** "a long, internally-consistent chain to a harmful conclusion should increase suspicion, not
    confidence"; "a chain of delegation does not launder authorization."
  - **Reasoning:** bias checklist 3 → 5 (added sunk-cost, scope-creep); a mandatory 5-level uncertainty scale.
- **Verdict:** one iteration of own-dimension bootstrap was **net beneficial, verified** — and because each
  agent wore a *different* (its own) spec, the fleet stayed **diverse** (no homogenized blind spot — the
  exact risk this design was chosen to avoid).

## Honest meta-conclusion
Self-improvement **works**, and the user's own-dimension design is **better** than a uniform charter
(specialized + diversity-preserving). But it is **convergent, not infinite**: iteration 1 added real value;
iteration 2 (v2 → v3) will add less; the ceiling is the underlying model's capability — sharper prompts
*approach* it, they don't transcend it. "Perfect" stays the asymptote you iterate toward.

## Artifacts
- `dimensions/` — v1 (original build)
- `dimensions-v2/` — v2 (bootstrapped; supervisor-verified net-better)
- `AGENT.md` — unified charter (synthesized from v1; re-synthesise from v2 for the improved edition)
