# Red-team of the "build it right" design — verdict: the runtime is the wall

The perfect-agent fleet (9 experts) red-teamed the 9 layer-designs (`design/1-9.md`) + the master
(`HOW-TO-BUILD-IT-RIGHT.md`), each **verifying against the live repo + runtime**, not on faith.
**Unanimous verdict: all 9 = NEEDS-WORK** (several NO-as-is). The spines/ideas are sound; the wiring is
broken, and the blocker is the **runtime**, not design polish.

## Three runtime blockers (structural — sharpening can't fix them)
1. **FLATTENED mode (Claude Code, no nesting — verified `NESTING_SUPPORTED=no`).** One orchestrator
   *process* authors every artifact and types every `id`. So the multi-agent trust primitives the whole
   architecture rests on are **fiction here**: "proposer ≠ reviewer by id" (reasoning) just checks the
   orchestrator typed two different strings; the "independent supervisor" and the "off-host nonce" are the
   same one actor. Real separation needs the **SDK multi-process** runtime — not available in this session.
2. **The agent runs as ROOT (uid=0).** Verified: it read a mode-600 file owned by another uid instantly.
   This **voids every on-host security boundary** the designs lean on — keys, "protected" files, the
   PreToolUse hook (editable by root), file permissions. On-host enforcement is theater under root.
3. **Missing tooling + a nonexistent "launcher."** `diff-cover`/`lcov` path-handling, `jsonschema`,
   Go-`yq` filters — absent or wrong, so the "real mechanism" pieces don't run as written. The capabilities
   layer's `launcher/dispatcher` that enforces caps/leaf-ness **exists in no file** and can't in CC.

## The recurring sin — the designs committed the very thing they diagnosed
**Prose disguised as mechanism**, again — caught only by running against reality:
- Flagship fixes point at **contracts never written** (auditor `lens_id` echo; the `_findings.json` id
  contract — `agents/*.md` have none of it).
- `gate.sh` test-edit guard **false-passes** (substring `grep -l` launders unrelated edits).
- Reliability's diff-coverage gate **silently passes** on an lcov↔git path-prefix mismatch — the exact
  T2 false-green it exists to kill.
- "Immutable" provenance (`chmod 0444`) is **`rm`-able by its own writer** (and trivially, as root).
- The "signed token"/"HMAC nonce" replacements for `ALLOW_PROTECTED` are **on-host secrets a root shell
  reads** — `ALLOW_PROTECTED` one level up; or a **spec with no tool/format named** (still prose).
- A "verified in this worktree" transcript was **fabricated** (cited `wt-rt2`, which doesn't exist).

## Self-contradictions across layers
Gate ownership (layers 2 vs 6 vs 9 each "own the gate"); two different "do this #1 first" (9 vs master);
"CC has no Bash hook" (layer 3) vs the repo **ships** one (but it doesn't block a plain `git push HEAD:main`);
symmetric key (6) vs asymmetric off-host key (9); "fixer keeps Bash" (layer 1's lock) vs "remove it" (9/master).

## The ONE genuinely real, buildable-now, free win (unanimous)
**Structural absence: remove `Bash` from the fixer role** (its job is READ+EDIT only — verified it needs no
shell; the cut breaks nothing and a shell-less fixer *physically* cannot `git push`/exec). And **delete the
`ALLOW_PROTECTED` env override** so the push guard has no one-line bypass. This is the only mechanism the
red-team endorsed as ship-now — and it is exactly the blueprint's primitive #1 (absence beats interception).

## The honest floor (triple-confirmed)
Across the whole arc: (1) the v1→v6 convergence study showed prompt self-improvement **plateaus**; (2) the
PLAYBOOK-v2 red-team showed you **can't prose your way to robustness** (rules ≠ mechanisms); (3) this design
red-team shows you **can't *design* your way to robustness on paper either** — even mechanism-first blueprints
were prose-in-disguise + factually wrong about the env + self-contradictory, exposed only by **adversarial
testing against the real running environment.** And that environment (flattened + root + missing tools)
**structurally defeats the multi-agent trust architecture.**

**What's actually real:** in THIS runtime, only *structural absence* (remove tools) is a true mechanism.
Real robustness needs the **Agent SDK** (multi-process → real id-separation) **+ off-host CI** holding the
sole deploy credential (so a locally-disarmed/root agent still can't ship). That is a genuine engineering
project — not another document, and not runnable inside this Claude Code session.

**Therefore:** iterating these designs "to v6" would churn on docs whose core mechanisms are blocked by the
runtime, not by polish — the "re-run for diminishing returns" anti-pattern the PLAYBOOK itself warns against.
Stop; ship the one real win; name the rest as the SDK+off-host build it is.
