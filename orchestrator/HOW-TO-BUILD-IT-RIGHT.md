# How to build it right — unified blueprint

Synthesized by the orchestrator from 9 parallel layer-designs (`design/1-9.md`), each produced by the
matured perfect-agent expert for its dimension, given the full situation (`SITUATION.md`) and the hard
lesson: **prose ≠ mechanism.** This is the blueprint for building the system *right*.

## The thesis — only TWO kinds of mechanism actually hold
Everything else (comments, env flags, "hard rules" in a doc, on-host hooks) is defeatable. The designs
converged on exactly two robust primitives:

1. **Structural absence — least-privilege by what is NOT in the process.** A fixer that has no shell tool
   *cannot* `git push` / `rm` / exec — there is nothing to intercept. The deploy capability exists in
   *only* the depth-0 orchestrator (or, better, nowhere on-host). Absence beats interception. (caps/§3, §9)
2. **Off-host authority — the credential and the final gate live where the agent cannot edit them.** The
   sole deploy credential is held by CI on neutral hardware; the production gate re-runs there; pushing a
   protected branch requires a **human-minted, agent-unforgeable, single-use, SHA-bound token** (verified
   against a key whose private half is not on the host). This *replaces* the `ALLOW_PROTECTED=1` prose-hole.
   (§1, §5, §6, §7, §9)

**Verified the hard way:** the safety designer found the live on-host hook was BOTH a false-positive
(blocked its own read-only commands) AND evadable by obfuscation — proof that on-host enforcement alone is
not a mechanism. Containment is real only because CI off-host holds the credential.

## The 9 layers — each layer's #1 mechanism · #1 honest limit
| # | Layer | #1 mechanism (real, not prose) | #1 honest limit |
|---|---|---|---|
| 1 | Identity/authority | PreToolUse hook denies push/deploy/delete without a human-minted authorization **nonce** the model can't forge (repo *already* has `.claude/hooks/`+`.githooks/`+`protocol-enforce.yml`) | 3 clauses (don't-claim-human, anti-sycophancy, honest-conflict) are model-judgment — protect *consequences*, not cognition |
| 2 | Knowledge/onboarding | `.orchestrator/knowledge.yaml` manifest: schema-validated, preflight-**gated**; enumerated lens registry (no CLEAN with a missing lens); green-as-config | "what is a true invariant" is human judgment → `reviewed_by:<human>` gate |
| 3 | Capabilities/runtime | `caps/<role>.caps.json` = the single grant source; ship capability lives only in depth-0 process | CC has no Bash pre-exec hook (deny-list cooperative) → contained by structural absence of creds |
| 4 | Reasoning/decision | `decision-verify.sh`: a verdict must be authored by id ≠ its proposer (second-review **gate**); test-edits refused without a separate OLD-WRONG arbiter | a verdict's *truth* is model judgment → foreign reviewer + behavioral tests + lowest-blast cell |
| 5 | Memory/state | `checkpoint.json` in the durable git-admin dir; **phase-guards** refuse the next stage unless the checkpoint proves the prior completed (baked into the gate + push) | the human push decision can't be manufactured → bound to a single-use sha+diff token |
| 6 | Reliability/verify | **diff-coverage gate** (`diff-cover --fail-under=100` over changed lines) + grep + mutation spot-check, behind an HMAC-signed SHA-bound verdict a server-side required-check reads | proves PASS, never CORRECT — spec/intent is undecidable by mechanism |
| 7 | Communication/HITL | `approve-gate.sh`: the push blocks behind a single-use, action-bound HMAC nonce the agent's uid can't read (authorization is a *gate*, not a post-hoc report) | a human can rubber-stamp → made one-screen-cheap + stale-approval refused |
| 8 | Autonomy/orchestration | `_registry.json` + `assert-no-open` as a phase-advance precondition (a dispatched-but-unreaped sub-agent = hard stop, not a silent skip); per-tier triage | CC can't preemptively kill a sub-agent → cooperative budget + heartbeat; SDK port = real `timeout --signal=TERM` |
| 9 | Safety/security | remove `Bash` from fixer (+ trim auditor/validator) so it *physically* can't ship; delete `ALLOW_PROTECTED`; replace with off-host approval (branch protection + CI-held deploy cred) | on-host enforcement is disarmable → contained ONLY by off-host CI holding the sole credential |

## The convergence (independent corroboration the design is right)
Four layers — identity, memory, communication, safety — *independently* arrived at the **same** mechanism:
a human-minted, agent-unforgeable, single-use token + an off-host credential, as the real replacement for
the `ALLOW_PROTECTED` prose-hole. When four experts attacking different angles converge on one primitive,
that primitive is load-bearing.

## The irreducible limit (the honest floor)
Every layer bottoms out at the **same** floor: genuine human judgment — *is this CONFIRMED actually
correct? did the human really read the diff? is this a true invariant?* — **cannot be mechanized.** The
design does not fake fixing it. It **contains** it: make the human decision one-screen-cheap, bound it to
an unforgeable token, and guarantee it is the ONLY model-judgment node ever upstream of an irreversible
action, with an off-host backstop — so a judgment failure yields at worst bad text, never an unauthorized
ship. The ultimate ceiling is the model's own capability; **mechanisms protect consequences, not cognition.**

## Build order (highest safety/leverage first; dependencies respected)
1. **Off-host root of trust** — git-server branch protection + CI holds the *sole* deploy credential and
   re-runs the gate on neutral hardware. (Nothing below matters if the credential is on-host.) [§9]
2. **Structural least-privilege** — `caps/<role>.caps.json`; fixer/auditor/validator lose tools they don't
   need (fixer: no shell). [§3, §9]
3. **The verification gate** — diff-coverage + grep + mutation, emitting an HMAC-signed SHA-bound verdict the
   CI required-check consumes. [§6]
4. **Checkpoint + registry** — resumable state, unskippable phase order, no silent sub-agent skips. [§5, §8]
5. **Knowledge manifest + lens registry + decision second-review gate.** [§2, §4]
6. **Structured report + approve-gate + identity/authority hooks.** [§7, §1]

**Grounding:** the repo already ships `.claude/hooks/pre-tool.sh` + `.githooks/` + `protocol-enforce.yml`
— so steps 1, 2, 6 *generalize existing infrastructure* rather than building from scratch.

## Details
Full per-layer blueprints (architecture · mechanisms · limits · build order): `orchestrator/design/1-9.md`.
