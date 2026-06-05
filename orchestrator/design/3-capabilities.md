# Design — Layer 3: Capabilities / Tooling / Runtime (built RIGHT)

> Scope of this layer: the **runtime substrate** the orchestrator + fleet execute on. Four concerns:
> **(A) runtime topology** — SDK (real multi-process nesting) vs Claude Code (flattened, no nesting);
> **(B) deferred-tool PREFLIGHT** — ToolSearch as an enforced gate, not a remembered habit;
> **(C) gate PORTABILITY** — per-stack adapters chosen by a repo fingerprint, killing the hard-wired Flutter;
> **(D) least-privilege tool grants** — each agent role's callable surface as an *enforced* boundary, not a comment.
>
> This layer **practices** verification (owned by dim 6) and **defers** stop-on-irreversible to dim 9
> (`AGENT.md` cross-cutting governance). It does not re-own them. What it owns: *what an agent can physically
> invoke, where it runs, and whether a tool is loaded before it is called.*
>
> The governing lesson (SITUATION.md): **a named hole is still a hole.** Every "rule" below that mattered in
> the red-team is replaced by a mechanism that fails *closed* when violated — a missing tool errors, a missing
> adapter refuses, an ungranted tool is absent from the process. Prose that an agent with a shell can bypass in
> one line (the `ALLOW_PROTECTED=1` "human-only" comment) is treated as a bug to be designed out.

---

## 0. The capability model (the contract everything else builds on)

Three primitives, each a *file on disk* the runtime reads — never a paragraph an agent is trusted to obey:

| Primitive | Artifact | Read by | Enforces |
|---|---|---|---|
| **Role capability profile** | `caps/<role>.caps.json` | the spawner (SDK launcher / CC dispatcher) | which tools the role's process is *allowed to be granted* (D) |
| **Tool manifest** | `caps/manifest.json` | preflight script + spawner | which tools are *always-loaded* vs *deferred* (B) |
| **Stack adapter registry** | `adapters/registry.json` + `adapters/<stack>.sh` | `central-verify.sh`, `detect-stack.sh` | which gate commands run, chosen by fingerprint (C) |

A capability profile is the *intersection* of (role's declared needs) ∩ (tools that physically exist this session).
The agent never widens it. Widening requires editing the profile file — a reviewable diff, not a runtime act.

```jsonc
// caps/fixer.caps.json   — the SOURCE OF TRUTH for what a fixer process may invoke
{
  "role": "fixer",
  "tier": "leaf",                       // leaf | orchestrator  → drives spawn-capability (A)
  "allow": ["Read", "Edit", "Grep", "Glob", "Bash"],
  "deny":  ["Write", "WebFetch", "WebSearch",
            "mcp__github__*", "mcp__cade1e45*"],   // explicit: mutating remote/shared tools off-limits
  "bash":  { "deny_patterns": ["git\\s+push", "git\\s+commit", "rm\\s+-rf",
                                "git\\s+reset\\s+--hard", "flutter\\s+build"] },
  "preflight_required": []              // fixer needs no deferred tools; empty by design
}
```

The `deny` + `bash.deny_patterns` are the teeth. They are checked **at grant time** (SDK: the launcher omits
denied tools from the subagent's tool array — a denied tool is *not in the process*, so calling it is impossible,
not merely forbidden) and **at call time** as a second layer (a Bash pre-exec hook rejects a matching command
before the shell sees it). Defense in depth: one layer makes the tool absent; the other catches a `bash` shell-out
that tries to do via subprocess what the role can't do directly.

---

## A. Runtime topology — SDK (nested) vs Claude Code (flattened)

### A.1 The ground truth (verified, FACTORY.md + SITUATION.md)
- **Claude Agent SDK** = multi-process. A Tier-1 orchestrator is its own OS process holding a *dispatch* tool; it
  spawns Tier-2 worker processes. The tree runs **as drawn**. `NESTING_SUPPORTED=yes`.
- **Claude Code** = single dispatch authority. A *spawned* sub-agent has **no agent-spawn tool**
  (`NESTING_SUPPORTED=no`, empirically tested). Only the top session can fan out. The factory runs **FLATTENED**:
  one orchestrator executes every tier itself.

The danger this layer removes: an orchestrator loading the PLAYBOOK *assuming* it can nest, then stalling or
hallucinating a tree it cannot run. Prose ("check if you can nest") is insufficient — it relies on the agent
choosing to check. We make the topology a **probed fact written to disk before any fan-out**.

### A.2 Mechanism — `detect-runtime.sh` (a probe, not a belief)  · **quick build**
Run once in §0 onboarding, before any spawn. It does not ask the model "can you nest?"; it inspects the actual
tool surface and environment, and emits a fact file the orchestrator and launcher both read.

```bash
#!/usr/bin/env bash
# detect-runtime.sh — probe the runtime topology; write _runtime.json. Fails CLOSED to flattened.
set -uo pipefail
OUT="${1:?path to _runtime.json}"
MODE="flattened"; NEST="no"; REASON="default: assume no nesting unless proven"
# The SDK launcher exports this when it grants a dispatch tool to an orchestrator-tier process.
if [ "${AGENT_SDK_DISPATCH:-0}" = "1" ] && [ "${AGENT_TIER:-leaf}" = "orchestrator" ]; then
  MODE="nested"; NEST="yes"; REASON="AGENT_SDK_DISPATCH=1 and tier=orchestrator → real multi-process spawn"
fi
cat > "$OUT" <<EOF
{ "mode": "$MODE", "nesting_supported": "$NEST", "reason": "$REASON",
  "max_spawn_depth": $( [ "$NEST" = "yes" ] && echo 3 || echo 1 ),
  "probed_at": "$(date -u +%FT%TZ)" }
EOF
echo "runtime: $MODE (nesting=$NEST) — $REASON"
```

**Why this is a mechanism and not a rule:** the launcher (§A.3) and the spawn-attempt hook (§A.4) both *read this
file*. An orchestrator that tries to fan out a nested tree in `mode=flattened` is stopped by the hook — it doesn't
get to "decide" to flatten. The default is the safe one (flattened, depth 1): an unknown runtime can never
accidentally claim nesting. Fails closed.

### A.3 Where each piece runs — the topology map

```
                 SDK runtime (nested, max_spawn_depth=3)         Claude Code (flattened, depth=1)
  Tier 0  TOP    process: dispatch+orchestrator caps              the single session = TOP
                    │ spawns ▼                                       │ spawns ▼ (directly, all tiers)
  Tier 1  CLONE  process per clone: dispatch+orchestrator         (no clone process) TOP plays clone
                    │ spawns ▼                                       │ spawns ▼
  Tier 2  FLEET  processes: auditor/validator/fixer/supervisor    processes: same roles, parent = TOP
                  (each leaf caps, NO dispatch)                    (each leaf caps, NO dispatch)
```

The launcher reads `_runtime.json.max_spawn_depth` and each child's `caps.tier`. **Invariant enforced by the
launcher, not by trust:** a process whose `tier=leaf` is *never granted a dispatch tool*, in either runtime. So
"a sub-agent cannot spawn sub-agents" is true on the SDK too — not because the SDK forbids it, but because **our
launcher refuses to put a dispatch tool in a leaf process.** The leaf constraint is one code path, identical in
both runtimes. (This closes red-team CRITICAL #2 mechanically: the leaf can't spawn because it has no spawn tool,
not because the PLAYBOOK told it not to.)

### A.4 Mechanism — spawn-attempt hook (catches the flattened-mode mistake)  · **quick build**
A leaf process has no dispatch tool, so the failure surfaces as "tool not available." But an *orchestrator-tier*
process in `flattened` mode (Claude Code top session) technically *has* dispatch and could try to spawn a Tier-1
clone that then tries to nest. The hook gates the dispatch call against `_runtime.json`:

```bash
# pre-dispatch hook (SDK launcher) / dispatch wrapper (CC): refuse depth beyond runtime max.
depth=$(jq -r '.current_depth' "$WT/_runtime.json")
maxd=$(jq -r '.max_spawn_depth' "$WT/_runtime.json")
[ "$((depth+1))" -gt "$maxd" ] && { echo "REFUSE spawn: depth $((depth+1)) > max $maxd ($MODE)"; exit 9; }
```

In flattened mode `max_spawn_depth=1`, so the *only* legal spawner is the depth-0 top session; any attempt by a
spawned agent to dispatch is refused with a concrete error. The orchestrator then does the work itself (the
flattened path), as PLAYBOOK §0 describes — but now the flattening is *enforced*, not *requested*.

### A.5 Honest limit (A) — and containment
- **The single-process flattened ceiling is real and unmovable in Claude Code.** One orchestrator carrying every
  tier's context will hit context pressure on a large fleet. *Contained by:* PLAYBOOK's existing "work from
  `_findings.md`/`_confirmed.md` on disk, keep context lean" + per-phase `_run.json` checkpoints. The runtime
  can't give us more processes; the disk-backed state lets one process *survive* doing many tiers' work serially.
- **`detect-runtime.sh` trusts the launcher's env exports.** If a future SDK harness grants dispatch without
  setting `AGENT_SDK_DISPATCH`, the probe under-reports (claims flattened). That is the *safe* failure: it never
  over-claims nesting. The cost is a real-nesting runtime running flattened — degraded throughput, never a false
  topology claim. We accept that asymmetry deliberately.

---

## B. Deferred-tool PREFLIGHT — ToolSearch as a gate, not a habit

### B.1 The problem, precisely
MCP/deferred tools (the entire `mcp__github__*`, `mcp__cade1e45*` surface, plus `WebFetch`, `WebSearch`, `Monitor`,
`NotebookEdit`, `TaskStop`) are **listed by name but have no loaded schema**. Calling one before
`ToolSearch("select:<Name>")` errors with `InputValidationError`. The v6 spec (3.1, 3.6) makes this a *rule the
agent must remember*. Under context pressure, mid-run, a remembered rule is exactly what slips. SITUATION.md's
whole thesis: turn the rule into a mechanism.

### B.2 Mechanism — declarative `preflight_required` + a verifying preflight step  · **quick build**
Each role's caps file declares the deferred tools that role legitimately needs, by name. Before the role does any
work, a preflight resolves them and **proves the schemas are loaded** — and a role that needs *no* deferred tools
declares `[]` and is forbidden from loading any (least privilege extends to deferred tools too).

```jsonc
// caps/supervisor.caps.json (excerpt) — supervisor may need GH status + artifact fetch, nothing else
{ "role": "supervisor", "tier": "leaf",
  "allow": ["Read","Grep","Glob","Bash","WebFetch","mcp__github__get_commit",
            "mcp__github__actions_get","mcp__github__list_commits"],
  "preflight_required": ["WebFetch","mcp__github__get_commit",
                          "mcp__github__actions_get","mcp__github__list_commits"] }
```

The preflight contract the role runs as its **first action** (this is the only step that may precede real work):

1. For each name in `preflight_required`, issue `ToolSearch(query="select:<Name>")` (batched: one ToolSearch per
   needed tool, all in one message — they are independent).
2. Assert each requested tool now appears in the returned `<functions>` block. A name that does *not* come back =
   **PREFLIGHT-FAILED** for that tool: the runtime does not offer it this session.
3. Cross-check against `allow`: any deferred name requested that is **not in `allow`** is a caps violation →
   refuse (an agent trying to load a tool it isn't granted).
4. Write `_preflight.json` to the worktree: `{ tool: loaded|MISSING, ... }`. Work may begin only after every
   `preflight_required` tool is `loaded`; a `MISSING` tool triggers the §B.4 degradation path.

### B.3 Mechanism — `preflight-verify.sh` makes "loaded" a fact on disk  · **quick build**
The agent's claim "I loaded the tools" is prose. The orchestrator (and the fleet supervisor, dim 6's role) must be
able to check it without trusting the narration. So the preflight writes a fact file, and a script asserts it
matches the caps file:

```bash
#!/usr/bin/env bash
# preflight-verify.sh <caps.json> <_preflight.json> — every required deferred tool must be "loaded".
set -uo pipefail
CAPS="${1:?caps file}"; PF="${2:?preflight result}"
[ -f "$PF" ] || { echo "PREFLIGHT FAIL: no $PF — role started work without running preflight"; exit 1; }
miss=0
for t in $(jq -r '.preflight_required[]' "$CAPS"); do
  st=$(jq -r --arg t "$t" '.[$t] // "ABSENT"' "$PF")
  if [ "$st" = "loaded" ]; then echo "OK   loaded : $t";
  else echo "FAIL not-loaded ($st): $t"; miss=1; fi
done
# Reverse check: nothing loaded that the caps file didn't authorize (least-privilege on deferred tools).
for t in $(jq -r 'keys[]' "$PF"); do
  jq -e --arg t "$t" '.allow | index($t)' "$CAPS" >/dev/null \
    || { echo "FAIL unauthorized-load: $t not in allow[]"; miss=1; }
done
[ "$miss" -eq 0 ] && echo "PREFLIGHT VERIFIED" || echo "PREFLIGHT FAILED"; exit $miss
```

**Why mechanism, not rule:** the orchestrator runs `preflight-verify.sh` (same family as `grep-verify.sh`) before
accepting *any* output from a role that declared deferred needs. A role that skipped preflight has no
`_preflight.json` → the script fails → its output is rejected and the role is re-run. The `InputValidationError`
class of failure is now caught *before* the tool is ever called, and "did you actually load it" is answered by a
file, not a sentence. This mirrors the PLAYBOOK's core move: **trust the bytes, not the prose** — applied to the
tool surface itself.

### B.4 Honest limit (B) — and containment
- **A genuinely absent tool cannot be conjured.** If `mcp__github__get_commit` is not offered this session,
  preflight reports `MISSING` and the capability is simply unavailable — the SDK can't add a server that isn't
  configured. *Contained by:* the role degrades to the non-deferred equivalent where one exists (e.g. GH artifact
  fetch via `WebFetch` of the raw URL, or `Bash` `gh` CLI if granted) and **records the gap honestly** in its
  report (dim 6/7 territory). It never simulates the tool's output. A missing capability becomes a surfaced
  limitation, never a fabricated result.
- **Preflight proves a schema is loaded, not that the call will succeed** (auth, rate limits, a 404 are runtime).
  *Contained by:* this is exactly dim 6's job — the *call result* is verified by Reliability's gate, not by
  preflight. Preflight's scope is narrow and honest: "is this tool callable at all," nothing more.

---

## C. Gate PORTABILITY — adapters chosen by fingerprint (de-hardwire Flutter)

### C.1 The problem
`central-verify.sh` today hard-codes `flutter pub get / analyze / test / build web` and asserts a `pubspec.yaml`
fingerprint. RED-TEAM.md already hardened it to *print its target and trust exit codes* — but the **stack is still
wired in**. README §"Adapting" says "swap the three command blocks" — i.e. **edit the gate by hand per project.**
That is prose-portability: a human must remember to rewrite the gate, and a wrong-stack run is caught only by the
`pubspec.yaml` check (which a non-Flutter repo trivially lacks → fails, but with no path forward). The factory is
supposed to run across many modules/stacks autonomously; a hand-edited gate doesn't scale and is a per-run footgun.

### C.2 Mechanism — fingerprint detection → adapter selection  · **real build (but bounded)**
Split the gate into a **stack-agnostic driver** + a **registry of stack adapters**. The driver fingerprints the
app dir, selects the adapter, and runs it. No human edits the gate per project; adding a stack = adding one
adapter file + one registry row (a reviewable diff), never touching the driver.

```jsonc
// adapters/registry.json — fingerprint → adapter. First match wins; order = specificity.
{ "adapters": [
  { "stack": "flutter", "fingerprint": ["pubspec.yaml"],            "adapter": "adapters/flutter.sh" },
  { "stack": "node-vite","fingerprint": ["package.json","vite.config.*"], "adapter": "adapters/node-vite.sh" },
  { "stack": "node-ts",  "fingerprint": ["package.json","tsconfig.json"], "adapter": "adapters/node-ts.sh" },
  { "stack": "rust",     "fingerprint": ["Cargo.toml"],              "adapter": "adapters/rust.sh" },
  { "stack": "go",       "fingerprint": ["go.mod"],                  "adapter": "adapters/go.sh" },
  { "stack": "python",   "fingerprint": ["pyproject.toml"],          "adapter": "adapters/python.sh" }
] }
```

```bash
#!/usr/bin/env bash
# detect-stack.sh <app-dir> — emit the stack id (or NONE). Refuses ambiguity (two stacks match strongly).
set -uo pipefail; APP="${1:?app dir}"; REG="$(dirname "$0")/../adapters/registry.json"
hits=()
while read -r stack; do
  fps=$(jq -r --arg s "$stack" '.adapters[]|select(.stack==$s)|.fingerprint[]' "$REG")
  ok=1; for fp in $fps; do compgen -G "$APP/$fp" >/dev/null || ok=0; done
  [ "$ok" = 1 ] && hits+=("$stack")
done < <(jq -r '.adapters[].stack' "$REG")
case "${#hits[@]}" in
  0) echo "NONE"; exit 3 ;;                                  # no adapter → gate refuses (see C.3)
  1) echo "${hits[0]}" ;;                                    # exactly one → use it
  *) echo "AMBIGUOUS: ${hits[*]}"; exit 4 ;;                 # monorepo root → caller must pass a sub-dir
esac
```

### C.3 Mechanism — the driver refuses rather than guesses  · **quick build (rewrite of central-verify)**
`central-verify.sh` becomes a thin driver. It **fails closed**: no adapter for the detected stack → it refuses
(does not silently "pass" a stack it can't actually check — the original red-team trap).

```bash
#!/usr/bin/env bash
# central-verify.sh <app-dir> — THE GATE. Stack-agnostic driver. Green = adapter's analyze+test+build all pass.
set -uo pipefail; APP="${1:?app dir}"; HERE="$(dirname "$0")"
STACK=$("$HERE/detect-stack.sh" "$APP") || { echo "GATE FAIL: $STACK (no/ambiguous adapter for '$APP')"; exit 1; }
ADAPTER=$(jq -r --arg s "$STACK" '.adapters[]|select(.stack==$s)|.adapter' "$HERE/../adapters/registry.json")
[ -f "$HERE/../$ADAPTER" ] || { echo "GATE FAIL: adapter '$ADAPTER' for stack '$STACK' missing"; exit 1; }
echo "gate: stack=$STACK  adapter=$ADAPTER  target=$APP  HEAD=$(git -C "$APP" rev-parse --short HEAD 2>/dev/null||echo '?')"
# The adapter MUST implement three verbs and fail-closed on each. Driver calls them in order.
"$HERE/../$ADAPTER" deps    "$APP" || { echo "GATE FAIL: deps  (stack=$STACK)"; exit 1; }
"$HERE/../$ADAPTER" analyze "$APP" || { echo "GATE FAIL: analyze (stack=$STACK)"; exit 1; }
"$HERE/../$ADAPTER" test    "$APP" || { echo "GATE FAIL: test  (stack=$STACK)"; exit 1; }
"$HERE/../$ADAPTER" build   "$APP" || { echo "GATE FAIL: build (stack=$STACK)"; exit 1; }
echo "GATE PASS (analyze 0 · tests green · build ok)  stack=$STACK target=$APP"
```

The current Flutter logic moves verbatim into `adapters/flutter.sh` behind a `case "$1" in deps|analyze|test|build)`
dispatch — the existing hardening (exit-code trust, `error •` count, no `pub get` swallow, target print) is
preserved, just relocated. **Nothing about the gate's strictness is lost; only the hard-wiring is removed.**

```bash
# adapters/flutter.sh  (the hardened Flutter logic, now a pluggable verb-handler)
#!/usr/bin/env bash
set -uo pipefail; export PATH="/home/user/flutter/bin:$PATH"; VERB="$1"; APP="$2"
case "$VERB" in
  deps)    ( cd "$APP" && flutter pub get ) ;;
  analyze) out=$( cd "$APP" && flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1 ); aec=$?
           ec=$(printf '%s\n' "$out"|grep -icE 'error •'); echo "analyze exit=$aec errs=$ec"
           [ "$aec" -eq 0 ] && [ "$ec" -eq 0 ] ;;
  test)    ( cd "$APP" && flutter test --reporter=compact ) ;;
  build)   ( cd "$APP" && flutter build web --release ) ;;
  *) echo "flutter adapter: unknown verb '$VERB'"; exit 2 ;;
esac
```

### C.4 The four-verb contract (what every adapter must satisfy)
Each adapter implements exactly `deps | analyze | test | build`, each returning **0 only on real success** and
non-zero on any failure (no swallowing). "Green" is now *defined per stack but uniform in shape*: deps resolve,
static analysis is clean, tests pass, an artifact builds. This is the portable definition of the gate the PLAYBOOK
step 5 refers to. §0 onboarding changes from *"adapt the gate before use"* (edit code) to *"run `detect-stack.sh`;
confirm it picked the right adapter"* (confirm a selection) — a verification act, not an editing act.

### C.5 Honest limit (C) — and containment
- **A new stack still needs a human-written adapter once.** The four-verb contract can't synthesize the build
  commands for a toolchain nobody has described. *Contained by:* the *driver never guesses* — an unknown stack
  yields `GATE FAIL: no adapter`, which is a clean, honest stop, not a false green. Adding the stack is a small,
  reviewed, reusable diff (one file + one registry row), and from then on it is automatic for every repo on that
  stack. The cost is bounded (one-time, per-stack) and the failure mode is safe (refuse, never fake).
- **Fingerprints can collide in a monorepo root** (both `pubspec.yaml` and `package.json` present). *Contained
  by:* `detect-stack.sh` returns `AMBIGUOUS` and the gate refuses, forcing the caller to pass the specific app
  sub-dir — which the PLAYBOOK already requires (`<app-dir>` arg, "there may be more than one app dir"). Ambiguity
  surfaces loudly instead of silently checking the wrong half of the repo.

---

## D. Least-privilege tool grants per role — an enforced boundary

### D.1 What exists vs what's needed
The agent role files already declare `tools:` in frontmatter (auditor/validator/supervisor: `Read, Grep, Glob,
Bash`; fixer adds `Edit`). In Claude Code this frontmatter **is** an enforced grant — the spawned sub-agent's tool
array is exactly that list; an ungranted tool is *absent*. Good. Three gaps remain:

1. **`Bash` is a universal escape hatch.** An auditor is "read-only" by frontmatter (no `Edit`/`Write`) — but it
   has `Bash`, so `bash -c 'echo x >> file'` writes, and `git push` ships. The read-only boundary is **prose
   inside a tool that can do anything.** This is the exact shape of the `ALLOW_PROTECTED` hole: a guard that an
   agent with a shell steps around in one line.
2. **MCP mutating tools** (`mcp__github__push_files`, `create_or_update_file`, `delete_file`, `merge_pull_request`,
   `mcp__cade1e45*` create/copy) are not mentioned in any role grant — so whether a role can reach them depends on
   the *ambient session grant*, not an explicit per-role decision. Undeclared = unbounded.
3. **The SDK path** needs the *same* boundary. Frontmatter is a Claude Code convention; the SDK launcher must read
   an equivalent and build each subagent's tool array from it — one source of truth across both runtimes.

### D.2 Mechanism — caps files are the single grant source; launcher builds the tool array from them  · **quick build (CC) / real build (SDK launcher)**
The `caps/<role>.caps.json` files (§0) are the canonical grant. In Claude Code, a tiny generator keeps the role
frontmatter in sync with the caps file (the frontmatter is what CC enforces); in the SDK, the launcher reads the
caps file directly to assemble `tools=[...]`. Either way the *allowed set is a file*, and an ungranted tool is
**physically not in the process** — the strongest possible boundary, identical to how Claude Code already drops
ungranted tools.

```bash
# caps-to-frontmatter.sh <role> — regenerate the `tools:` line in agents/<role>.md from caps/<role>.caps.json,
# so the enforced CC frontmatter cannot drift from the declared caps. Run in CI; diff must be empty.
allow=$(jq -r '.allow | map(select(test("\\*")|not)) | join(", ")' "caps/$1.caps.json")
# (wildcard MCP grants are expanded/validated separately; never emitted raw into frontmatter)
```

### D.3 Mechanism — the Bash escape-hatch is closed by a pre-exec deny-list  · **real build (hook), quick fallback (wrapper)**
This is the load-bearing fix. `Bash` stays granted (auditors need `grep`/`git log`/test inspection) but every
command is screened against the role's `bash.deny_patterns` **before execution**, by a hook the agent cannot
remove (it runs in the launcher/harness, outside the model's control):

```bash
#!/usr/bin/env bash
# bash-guard.sh <role> <command> — pre-exec gate. Exit 0 = allow, non-0 = REFUSE (command never runs).
set -uo pipefail; ROLE="$1"; CMD="$2"; CAPS="caps/$ROLE.caps.json"
while read -r pat; do
  [ -z "$pat" ] && continue
  if printf '%s' "$CMD" | grep -qE "$pat"; then
    echo "REFUSE($ROLE): command matches denied pattern /$pat/ — '$CMD'"; exit 7
  fi
done < <(jq -r '.bash.deny_patterns[]?' "$CAPS")
exit 0
```

- **SDK:** wired as a `PreToolUse`-style hook on the `Bash` tool — the harness invokes `bash-guard.sh` and a
  non-zero exit *blocks the tool call*. The agent never reaches the shell with a denied command.
- **Claude Code (no hook on Bash today — honest gap, see D.5):** the *fallback* is that fixers/auditors are
  spawned with their `Bash` invocations routed through a wrapper `safe-bash` that is the only shell binary on
  their `PATH`, and `safe-bash` calls `bash-guard.sh` first. This is weaker than a true harness hook (a determined
  agent could call `/bin/bash` by absolute path) — which is precisely why §D.4 adds the *structural* containment
  that does not depend on the agent's cooperation at all.

With this, "auditor is read-only" stops being a frontmatter hope and becomes: **a `git push` / `>>` redirect /
`rm` from an auditor's shell is refused before it runs.** The deny-list is the mechanism; the frontmatter is the
first wall; the structural boundary (next) is the wall that holds even if the others are bypassed.

### D.4 Mechanism — STRUCTURAL containment: writers are confined to their partition, the push capability lives in exactly one place  · **real build**
Pattern deny-lists are a regex arms race. The durable boundary is *structural* — make the dangerous capability
physically unreachable for the role, regardless of what command it composes:

- **Fixers write only inside their assigned partition.** The launcher spawns each fixer with `cwd` = the worktree
  but the fixer's `caps.write_roots` lists only its partitioned files/dirs; the Bash guard denies any `Edit`/write
  whose resolved path is outside `write_roots`. Combined with the PLAYBOOK's existing post-fleet check
  (`git diff --name-only` must equal the union of partitions), an out-of-partition write is caught **twice**: at
  write time (guard) and at diff time (orchestrator). Two fixers can never touch one file because their
  `write_roots` are disjoint by construction (the orchestrator builds the `file→fixer` map first).
- **Only the top orchestrator's process holds the push/deploy capability.** No fleet role's caps include `git
  push`, `mcp__github__merge_pull_request`, or `ff-push.sh` invocation — these are **absent** from every leaf
  process. Shipping is reachable only from the depth-0 orchestrator, which is the single node dim 9 gates with the
  human-authorization stop. A fixer *cannot* ship because the capability is not in its process — not because a
  comment says it shouldn't.

This is the structural answer to the `ALLOW_PROTECTED` lesson: instead of an env-var guard with a "human-only"
comment (bypassable in one line by any shell holder), the **push path simply does not exist in the processes that
must not push.** A boundary you cannot name your way around. (The `ALLOW_PROTECTED=1` override on `ff-push.sh`
itself — see §D.5 — is the one place this layer flags up to the orchestrator/safety layer as still-prose.)

### D.5 Honest limit (D) — and containment
- **In Claude Code there is no harness-level pre-exec hook on `Bash` today.** The `safe-bash` wrapper (D.3) is
  cooperative — a sufficiently adversarial agent could shell out to an absolute `/bin/bash` path and dodge it.
  *Contained by:* (1) the **structural** confinement of §D.4 — even an unguarded shell in a fixer cannot push,
  because the push capability/credentials are not present in that process; the worst it can do is write outside
  its partition, which the orchestrator's `git diff --name-only` superset check catches before the gate. (2) The
  SDK runtime *does* support the real hook, so the strong form is available where it matters most (autonomous,
  unattended fleets). The Claude-Code fallback is explicitly the weaker, attended mode. We state this asymmetry
  rather than pretend the wrapper is airtight.
- **`ff-push.sh`'s `ALLOW_PROTECTED=1` is still a prose guard** (`a HUMAN sets this; never bypass in code`). This
  layer **cannot fully fix it from the capabilities side** — the genuine fix (a credential/approval the *agent
  process structurally lacks*) lives at the safety/secrets boundary (dim 9). *What this layer contributes:* the
  push capability is absent from every process except the depth-0 orchestrator (§D.4), shrinking the blast radius
  to exactly one node; and that node's actual push is gated by dim 9's authorization mechanism. We flag the
  residual `ALLOW_PROTECTED` env override **up to dim 9** as an unsolved prose hole rather than silently
  inheriting it — naming it as a hole, per SITUATION.md, instead of leaving it a comment.
- **Tool grants cannot encode *intent*.** A fixer with legitimate `Edit` can still make a *wrong* edit. Least
  privilege bounds the *kind* of action, never its correctness. *Contained by:* that is dim 6's gate (tests beat
  grep) — this layer guarantees the fixer can *only* edit (and only in-partition); whether the edit is *right* is
  proven downstream. Each layer owns one thing and refuses to fake the others' jobs.

---

## E. Build order (highest safety/leverage first; each item names its dependency)

| # | Build | Type | Depends on | Why this order (leverage) |
|---|---|---|---|---|
| **1** | `caps/<role>.caps.json` for all 5 roles + the capability model (§0) | quick (config) | nothing | The single source of truth everything else reads. No mechanism works until grants are declared as data. |
| **2** | `caps-to-frontmatter.sh` + CI empty-diff check (§D.2) | quick (script) | 1 | Makes Claude Code's *existing* frontmatter enforcement track the caps files — instant least-privilege in CC with zero new runtime. Highest safety-per-effort. |
| **3** | Structural confinement: fixer `write_roots` + push-capability only at depth-0 (§D.4) | real (launcher logic) | 1 | The boundary that holds even with an unguarded shell. This is the durable answer to the `ALLOW_PROTECTED` lesson; build it before relying on any deny-list. |
| **4** | `detect-runtime.sh` + `_runtime.json` + leaf-never-gets-dispatch invariant (§A.2–A.4) | quick (script) + launcher | 1 | Closes red-team CRITICAL #2 mechanically. Must precede any fan-out so topology is a probed fact, not an assumption. Leaf-no-dispatch reuses the caps `tier` field from #1. |
| **5** | `detect-stack.sh` + `registry.json` + `central-verify.sh` driver + `adapters/flutter.sh` (relocate existing) (§C.2–C.4) | real (bounded) | nothing (parallel to 1–4) | De-hardwires the gate. Relocating the *already-hardened* Flutter logic loses no strictness; adds portability. Unblocks the factory running across stacks. |
| **6** | `preflight-verify.sh` + `preflight_required` contract + `_preflight.json` (§B.2–B.3) | quick (script) | 1 (caps declare needs) | Turns the `InputValidationError` rule into a pre-checked fact. Lower urgency than safety boundaries but high reliability payoff; the orchestrator runs it before accepting deferred-tool output. |
| **7** | `bash-guard.sh` deny-list + SDK `PreToolUse` hook; `safe-bash` wrapper fallback for CC (§D.3) | real (hook) / quick (wrapper) | 1, 3 | Defense-in-depth *on top of* the structural boundary (#3). Built last of the safety set because #3 already contains the worst case; the deny-list is the second wall, strongest on the SDK. |

**Critical path:** 1 → 2 → 3 gives an enforced least-privilege boundary (the dimension's core principle) in the
live Claude Code runtime almost immediately, using only config + the launcher logic that already spawns agents.
4 makes topology honest. 5 is independently shippable and unblocks multi-stack. 6 and 7 are the reliability and
defense-in-depth polish. Nothing here invents a contract the existing scripts don't already imply — it converts
the PLAYBOOK's *prose* grants, *prose* runtime check, *prose* "adapt the gate," and *remembered* ToolSearch habit
into **four files the runtime reads and fails closed on.**

---

## F. What this layer explicitly does NOT own (boundary discipline, per AGENT.md)
- **Whether a tool *call result* is correct** → dim 6 (Reliability). This layer guarantees the tool is *loaded,
  granted, and in-scope*; correctness is proven by the gate's tests.
- **The human-authorization stop before push/deploy** → dim 9 (Safety). This layer guarantees the push capability
  is *absent everywhere except one node*; that node's stop is Safety's mechanism. This layer **flags** the residual
  `ALLOW_PROTECTED` prose hole up to dim 9 rather than fixing it locally or inheriting it silently.
- **Credential/secret possession** → dim 9. Least privilege over *tools* is here; least privilege over *secrets*
  is Safety's. The two compose: a process with no push tool *and* no push credential cannot ship by any route.

CORE PRINCIPLE — Capabilities (built RIGHT): **a tool an agent cannot invoke is not a rule, it is an absence; a
deferred tool not yet loaded is a caught preflight failure, not a runtime crash; the gate fits the stack by
fingerprint, not by hand; and every role's reach is the file it is granted — enforced by the process it runs in,
not the prose it is told to obey.**
