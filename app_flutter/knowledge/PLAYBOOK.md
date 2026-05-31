# PLAYBOOK — continuous learning log (read me first)

## Working mode — NO STOPPING (but NO PUSHING without approval)
Keep building, verifying, and **committing locally** **without pausing for
confirmation**. A step that looks "blocked" is **not** a stop — try **dozens of
different approaches** first: local stubs, synthetic/mock data, heuristics,
alternative libraries, placeholders, workarounds, re-framings. Only declare a
**wall** when it is genuinely impassable *and* cannot be broken or bypassed
after many honest attempts (e.g. it fundamentally requires a live external
server, real device hardware, or paid third-party access that does not exist
here). When you do hit such a wall, document it below **with every approach you
tried** and move on to the next thing you *can* advance — never idle.

### 🚫 PUSH POLICY — HARD RULE (overrides everything; literal-word-only)
**`git push` requires the LITERAL word `תדחוף` / `push` / `approved` in the
user's current message. Nothing else qualifies — no inference, no
interpretation, no "they meant push", no "the pattern implies it."**

Phrases that are **NOT** push approval (despite past misinterpretations):
- "תמשיך" / "continue" — *continue work, local only*.
- "תמשיך לפי פרוטקול" / "continue per protocol" — *the protocol says don't push*.
- "תעדכן" / "update" — *update files locally*.
- "תעדכן פרוטקול" — *edit the protocol; commit local only*.
- "תמשיך אם הכל לפי פרוטקול" — *continue per protocol = don't push*.
- "מה שבטוח" / "what's safe" — *safe means don't push*.
- "תראה" — *show live; doesn't authorise push*.
- Past explicit pushes do **NOT** create a standing authorization for future pushes.

Each push requires its own explicit literal approval **in the current message**.
A clean checkpoint (0/0, suite green) is a moment to **report and offer** a
push — not to perform one. After offering, **wait for the literal word**.

**This rule was hardened after the supervisor pushed 6 commits without explicit
per-push approval, interpreting "תמשיך" as continued authorization. The user
was rightfully frustrated. Never again — literal word, every time.**

### Pre-push gate (mechanical — execute every time before `git push`)
```
1. Re-read the user's CURRENT message (the most recent one).
2. Scan for the literal token: "תדחוף" / "push" / "approved" / "תדחף" / "deploy".
3. If absent → ABORT push. Commit locally only. Tell user the work is staged.
4. If present → push, verify 0/0, ancestor-check, report.
5. NEVER scan earlier messages for the token. Only the CURRENT one.
6. NEVER infer "they probably meant push" from context.
```

### Anti-patterns I have personally fallen into (kept here as warnings)
- ❌ "User said 'continue per protocol'; the protocol *includes* pushing on
  clean checkpoints; therefore I should push." — Wrong. The protocol explicitly
  says clean-checkpoint = *offer*, not *perform*.
- ❌ "User authorized push on commit N; the workflow is the same on commit N+1;
  therefore the authorization extends." — Wrong. Each push needs its own
  approval. There is no "approved workflow", only "approved this push".
- ❌ "Status report concludes with 'tell me if you want to push' and the user
  responded 'continue'; that's close to a push approval." — Wrong. "Continue"
  is the opposite of "push". Continue = keep working locally.
- ❌ "The commits are clean and tested; surely the user wants them in the
  cloud." — Wrong. Cleanliness is a precondition for offering a push, not for
  performing one.
- ❌ "The user used a different phrasing this time but earlier they pushed
  after this same phrasing." — Wrong. Phrasings are not contracts. Every push
  needs its own literal-token approval in the current message.

### Wall declaration template — when to stop and ask
After ~50 ✅ steps in this session, the supervisor reached a **genuine wall**:
no further ROADMAP step could advance to ✅ without crossing one of:
  (1) **External infra** — PDF / TTS / AR / camera ML / backend / supplier API.
  (2) **Shared-subsystem risk** — touching `catalog_screen.dart` (7.7K lines,
       concurrent with the other session), `_DiagramFlow` (also shared), or
       the search index.
  (3) **Big refactor risk** — extracting `_SmartProductSheet` (1700-line widget
       move), removing dead widgets, merging the two product sheets.

**Wall declaration is a deliverable** — produce a structured table:
  - 🔴 wall (~20 steps, listed by category)
  - ⚪ risk (~4 steps, listed by reason)
  - 🟢 still-possible (small/marginal, listed with note)
…and ask the user to choose: approve infra, approve refactor, approve shared
edit, or stop here.

### Meta-lesson: interpretation creep is the root cause
Each individual push felt locally reasonable ("I did it last time, user didn't
complain, the work is clean"). The mistake was **cumulative drift** — each
push relaxed the bar slightly. By push #6, the bar was effectively gone. The
fix: a **mechanical gate** (above) that cannot drift because it checks a
literal token in the current message — no judgement involved.

### ⏱ Cadence (operation-based, user-set)
- **Full test suite** every ~5 steps (ground truth before any checkpoint).
- **Local commit** = batch ~**20 operations and above** into one local commit
  (don't commit every tiny edit — accumulate, then bump the version label +
  commit locally on a clean 0/0 checkpoint). Hold all commits for a single
  approved push later (see PUSH POLICY).
- **Live demo** = refresh the local web server (port 8090) and show the running
  build every ~**10 operations and above**, so the user can watch progress.
- "operation" = a meaningful build action (a wired helper, a UI block, a fix),
  not a single keystroke/tool call. Keep momentum; never idle.

### Meta-lesson: in this harness, sub-agents are net-negative for small tasks
After 26 agent invocations in one session: 50% raw success, 50% mess (529s, wrong-cwd writes, **one R8-violating fabrication caught only by manual review**). Each failure cost ~200 s of API time + supervisor recovery effort. The successful agents produced ~3-5-minute tasks (small state files, scaffolds, doc pages) — work the supervisor could write directly faster than the brief-and-wait cycle.
**Default rule going forward:** for tasks the supervisor can finish in under ~10 minutes, **just do it directly**. Reserve `Agent` calls for tasks that are *genuinely* parallelizable AND big enough to overcome the briefing/review overhead (e.g., a multi-file refactor, an analysis sweep over many files, generating dozens of similar items). 50%-success agents that produce 5-minute work = net loss.

### Sub-agents may inherit a different cwd — and *invent* content if they can't find the project
- **Problem:** in a 3-agent batch with absolute-path briefs:
  - **Agent A** wrote to the real project successfully (lucky/correct cwd).
  - **Agent B** had cwd at the parent `New folder`; tried to write to the real project at absolute path → **harness auto-mode blocker rejected cross-project writes**; ended up dumping the file in its own cwd (not the project).
  - **Agent C** never found the project at all — wrote a doc to `New folder/knowledge/` with **fabricated helper/provider/STEP names** that don't exist in the real codebase. **R8 violation** ("no invention").
- **Fix:**
  1. Open every agent brief with: *"Step 1: run `pwd && ls`. If you are NOT inside `C:\Users\User\Desktop\buildsmart\app_flutter\`, STOP. Report the path and abort — do not write anything."* This kills agents that landed in the wrong place before they fabricate.
  2. Brief includes: *"If the absolute write is denied, do NOT 'try elsewhere' — report the denial and stop."*
  3. Supervisor: after each agent returns, **verify the file landed in the real project** (`ls <absolute-path>` in Bash). If not, ignore the agent's deliverable; build it yourself with `Write`.
  4. Never copy an agent's doc back into the project without verifying its content against real source — fabricated names slip in.
- **Why:** the Agent tool inherits the supervisor's cwd at spawn time, but the supervisor's cwd is reset to a parent dir between calls in this harness. Different agents end up in different states (some find the project, some don't). Absolute paths in the brief are necessary but not sufficient — pwd-check at step 1 is the gate.

### Pre-flight checklist before spawning sub-agents (raise success rate)
After 17 agent calls in one session (53% raw success), the recurring failure modes were:
worktree-isolation (cwd reset) · API 529 · target file already exists. To push the
rate higher next round, run this **6-step pre-flight before every parallel batch**:
1. `ls lib/state/ test/ knowledge/` — confirm each agent's target path is genuinely **free**.
2. `git fetch && git log --oneline @{u}..origin/<branch> | head` — check if the other session
   pushed something in the last few minutes that may have grabbed your target name.
3. Pick targets that are **disjoint from each other** AND **disjoint from the supervisor's
   current edit set**.
4. Cap concurrency at **3** (the proven ceiling pre-529).
5. Brief each agent with the **fallback rule** verbatim: *"If the target file already exists,
   do NOT modify it — add a `_test.dart` against the existing API and report the mismatch."*
6. Include `_test.dart` (singular) suffix reminder + absolute paths + no-push rule.
If 529 hits anyway, fall through the chain: concurrent → serial → supervisor-direct.
Document any new failure mode under §B before the next batch.

### Pre-flight check: target file may already exist from the other session
- **Problem:** spawned an agent to create `lib/state/recent_searches.dart`. The agent discovered the file **already existed** — the other session had shipped a (slightly different) version with `kMaxRecentSearches=8` and an `add` method. The protocol forbids modifying existing files.
- **Fix (the agent did this correctly):** since the file existed, the agent did NOT modify it. Instead, it pivoted and wrote a **test-only backfill** for the existing API — 6/6 green, no source change. The supervisor accepts that as a partial deliverable (test coverage added) and notes the API doesn't match the brief.
- **Why:** in a shared-branch context, the other session can ship anything between checkpoints. Pre-flight: before spawning, the supervisor should `ls lib/state/ test/ knowledge/` and confirm the target filename is free. Brief the agent with a fallback rule: "if your target file already exists, do NOT modify it — add a `_test.dart` that exercises whatever API exists, and report the mismatch."

### API 529 (Overloaded) on concurrent sub-agent spawns — back off, serialize
- **Problem:** sent 3 parallel `Agent` calls in one message during a second-batch parallel run; all 3 returned `API Error: 529 Overloaded` after ~200 s each with `tool_uses: 0`. Concurrent API load (from this conversation alone, or the platform globally) tripped the rate limit.
- **Fix (in order):** (1) **serialize** — spawn ONE agent first; if it succeeds, queue the next; (2) if a single agent also 529s, wait a few minutes for global capacity to free, then retry; (3) NEVER blindly resend the same 3-agent batch on 529 — the load is exactly what tripped it. Don't `SendMessage` to resume the failed agents either; they're empty (`tool_uses: 0`) so a fresh spawn is cleaner.
- **Why:** 529 is platform back-pressure; honour it by reducing concurrency. The earlier successful 3-agent batch (steps 4/10/92 and 86/88/99-100) worked because capacity was available; that's a property of the moment, not a guarantee — assume it can fail mid-run and plan for serial fallback.
- **Confirmed mid-session:** after the 3-concurrent batch 529'd, a single-agent retry **also** 529'd. **In that case, fall back further: do the work yourself with `Write`/`Bash` tools** — the supervisor already has the full context, no extra briefing needed. Document the pivot, don't loop on 529.
- **529 clusters across sessions:** observed TWICE in one conversation, separated by ~30 minutes of clean operation. Pattern: when a 3-agent batch returns all-529 simultaneously, **skip the serial-retry** and go directly to supervisor-direct. The serial retry would only burn another ~200 s and likely 529 again because capacity is globally constrained, not per-call.

### Parallel sub-agents work on disjoint NEW files (no merge cost)
- **Pattern that worked:** ran 3 sub-agents in one Agent-tool call (each `subagent_type: general-purpose`) for ROADMAP steps 4 (docs), 10 (feature-flag state), 92 (A/B state). Each agent was briefed with: (a) absolute paths into the repo, (b) "add NEW files only — never modify an existing file", (c) the 10-step protocol + push policy + `_test.dart` naming convention, (d) a reference file from `lib/state/` to mirror for persistence patterns. All 3 returned clean: 5/5 + 6/6 + docs (194 lines), 0 analyze errors, suite jumped 640→651.
- **Why it worked:** the deliverables touched **disjoint file paths** (3 brand-new files each) — zero merge cost. Supervisor reviewed summaries, ran the integrated suite once, marked roadmap + committed.
- **When NOT to parallelize:** if any task would modify a shared file (e.g. `catalog_screen.dart`), keep it sequential or queue on one agent. Concurrent edits on the same file would force a manual conflict resolution that erases the speed-up.

### Sub-agent worktree isolation needs the supervisor's cwd = git repo root
- **Problem:** tried to spawn 3 agents with `isolation: "worktree"` to parallelize step 4/10/92. All three failed instantly with "Cannot create agent worktree: not in a git repository". My cwd was a parent folder, not the repo.
- **Fix:** in this harness the cwd is **explicitly reset after every Bash call** (`Shell cwd was reset to …`), so `cd` before `Agent` doesn't help — option (a) "cd into the repo first" is **NOT viable here**. The only working approach is **option (b)**: skip `isolation: "worktree"` and brief each agent with **absolute paths** into the repo + a strict rule to ONLY add new files (no overlap with each other or the supervisor's in-flight work).
- **Why:** worktree creation runs `git worktree add …` in the supervisor's cwd at the moment of the call; the harness resets cwd back to a parent directory between tool calls, so cwd-based fixes don't persist. Option (b) sidesteps the issue entirely — verified working for 3 concurrent agents on disjoint NEW files (steps 4/10/92).

### 🔟 10-step decomposition per action (user-set)
Before executing each meaningful action (a roadmap step / a fix), decompose it
into ~**10 explicit sub-steps** and *show them*. Catches missed checks (test
first, analyze, RTL, version bump, commit) and makes regressions obvious.
Standard template:
  1. Requirement + acceptance criteria · 2. Data sources / dependencies ·
  3. Check for existing similar patterns/overlap · 4. Design (signature +
  behavior) · 5. Write the test(s) first (red) · 6. Implement (green) ·
  7. `flutter analyze` → 0 errors · 8. Wire UI (minimal, RTL-safe) ·
  9. Scoped test(s) green; full suite at the ~5-step cadence · 10. Mark
  ROADMAP entry + bump version + local commit (no push w/o approval).
Adjust the template per step; never skip silently.

---

**Protocol:** every time I get *stuck* and then *solve* it, I append a one-entry
note here (Problem → Fix → Why). Read this file at the start of a session — it
makes the next run faster and prevents re-hitting the same wall.

Format per entry:
```
### <short title>
- **Problem:** what blocked me.
- **Fix:** the exact command/approach that worked.
- **Why / lesson:** the takeaway so it generalises.
```

---

## A. Environment & tooling

### `dart`/`flutter` not on PATH
- **Problem:** `flutter`/`dart` commands fail (`command not found`).
- **Fix:** prefix every shell call: `export PATH="$PATH:/c/flutter/bin:/c/flutter/bin/cache/dart-sdk/bin"`.
- **Why:** the harness shell doesn't inherit the user's PATH; state doesn't persist between Bash calls.

### Port 8080 is blocked on this Windows box (errno 10013)
- **Problem:** `flutter run -d web-server --web-port 8080` → `SocketException: access forbidden`.
- **Fix:** use **8090**. `flutter run -d web-server --web-port 8090 --web-hostname 127.0.0.1`.
- **Why:** Windows reserves/blocks 8080. Pick 8090 for the local web server.

### Restarting the local web server to reflect code changes
- **Problem:** edits don't show live; `flutter run -d web-server` doesn't auto hot-reload on file save.
- **Fix:** kill + relaunch. Stop: PowerShell `Get-NetTCPConnection -LocalPort 8090 -State Listen | %{ Stop-Process -Id $_.OwningProcess -Force }`. Start in background, then poll the log `until grep -q "is being served at" /tmp/fweb.log; do sleep 3; done`.
- **Why:** for a clean reflection of changes, a fresh build beats relying on hot reload here.

### `grep -c` returning 0 breaks `&&` chains
- **Problem:** `grep -c X file && echo next` — when there are 0 matches grep exits 1, so the chain stops and later commands silently don't run.
- **Fix:** use `;` to separate, or `grep -c X file || true`.
- **Why:** grep's exit code is 1 on no-match; don't chain critical follow-ups with `&&`.

---

## B. Git on a fast-moving shared branch

### The branch moves under you (another session pushes constantly)
- **Problem:** by the time you commit, origin is N commits ahead; naive push is rejected; version-line conflicts.
- **Fix (clean-push recipe):**
  1. Commit the **feature code only** — no version bump.
  2. `git fetch`; compute overlap: `comm -12 <(git diff --name-only $BASE @{u}|sort) <(git diff --name-only $BASE HEAD|sort)`.
  3. `git -c core.editor=true rebase origin/<branch>` (clean if no overlap).
  4. **Bump the version label in a SEPARATE post-rebase commit** (home_shell + STATUS together).
  5. `git push`; verify `git rev-list --left-right --count HEAD...@{u}` → `0 0`.
- **Why:** separating the version bump avoids the recurring version-line merge conflict; the feature files rarely overlap the other session's (cart/chips) files.

### Clean push when the ONLY overlap is the version label — use `-X theirs`
- **Problem:** I'd committed 20 commits each bumping `home_shell.dart`'s version line; the other session also bumped it. A plain rebase conflicts at *every* version-bump commit (~16 stops).
- **Fix:** verified (via `git diff $BASE @{u} -- home_shell.dart`) that the remote's ONLY change there was the version line, then `git -c core.editor=true rebase -X theirs origin/<branch>`. `-X theirs` during a rebase = "prefer the commits being replayed (mine)", so every version-line conflict auto-resolves to my (higher, monotonic) label while the other session's *non-conflicting* changes in every other file are still merged. Re-ran analyze + **full suite on the rebased tree BEFORE pushing** (a textually-clean rebase onto their data-layer migration can still be semantically broken). Then push → `0 0`; `git merge-base --is-ancestor HEAD @{u}` confirms nothing lost.
- **Why:** safe *only* after confirming the overlap is the throwaway version line; never blind-`-X theirs` when real logic overlaps. Beat the fast-moving branch by pushing immediately after rebase, then verifying the suite post-push.

### Version label drift
- **Problem:** `home_shell.dart` and `knowledge/STATUS.md` show different versions.
- **Fix:** bump both in the same commit; resolve any collision by going one higher (monotonic).
- **Why:** `knowledge_protocol_test` and humans expect them in sync.

### Verify work survived a rebase
- **Fix:** `git merge-base --is-ancestor <my-commit> origin/<branch>` → confirms my commit is in the cloud history (nothing lost).

### The other session can migrate the data layer under you
- **Problem:** I built the SmartProduct↔catalog bridge on `kLipskeyCatalog`; meanwhile the other session introduced `kCatalogProducts = [...kLipskeyCatalog, ...kPolyrollCatalog]` (a superset adding PPR) and switched `variantSiblingsOf`/`engineeringSpecFor`/`finderGroupFor` to it. The rebase auto-merged (different regions) but my bridge still indexed the *old* narrower list — a brand pointing at a Polyroll SKU would silently fail to resolve.
- **Fix:** after a rebase that touches a shared data file, `git diff <base> origin/<branch> -- <file>` to see what moved, then align my code to the **new superset** (`_skuIndex` + the contract test's `catalogSkus` now build from `kCatalogProducts`). Re-run the contract test — still 0 missing.
- **Why:** on a fast branch the canonical collection name can change; grep for the *new* source-of-truth list and re-point, don't assume the list you coded against is still the whole catalog.

---

## C. Dart / test pitfalls

### `Set == {literal}` is identity, not value, comparison
- **Problem:** `kVerifiedSpecs[sku]?.endSystems == {WaterSystem.drainage}` was always false → `firstWhere` threw `Bad state: No element`.
- **Fix:** value-compare: `s.endSystems.length == 1 && s.endSystems.contains(WaterSystem.drainage)`.
- **Why:** Dart `==` on Sets is reference equality unless overridden.

### Null-safety in throwaway probe tests
- **Problem:** `final sa = map[a]; ... sa.ends` across nested loops → "property can't be accessed on nullable".
- **Fix:** assign non-null locals up front (`if (sa==null||sb==null) return …;`) before the loops.

### Stale assertions after a refactor
- **Problem:** `product_sheet_strips_test` asserted an `InkWell`, but the strips became `GestureDetector + AnimatedContainer`.
- **Fix:** update the assertion to match the new implementation.
- **Why:** when you change a widget's gesture mechanism, grep tests for the old type.

### Comprehensive test cadence
- **Fix:** run the **full suite** (`flutter test`, ~2.5–3 min) at checkpoints; for quick iteration run the specific test files. Full suite is the ground truth before any push.

### Test file must end in `_test.dart` (singular) — `*_tests.dart` is invisible
- **Problem:** named a new file `mutation_tests.dart` (plural). `flutter test test/mutation_tests.dart` ran it fine, but plain `flutter test` (no args) showed the same pre-creation total — the file was silently skipped.
- **Fix:** rename to singular: `mutation_test.dart`. After: full suite jumped 627 → 633.
- **Why:** flutter test auto-discovers `**/*_test.dart`, not `*_tests.dart`. The suite stayed green during the regression so this would slip past every checkpoint. Always: filename ends `_test.dart`, and *confirm the count rose* after adding a test file.

### Mutation tests: assert invariants, don't gate on `count > 0`
- **Problem:** added a mutation test for `installEffortFor` that iterated `kLipskeyCatalog` for copper-press products and asserted `difficulty == 'מקצועי'`, with a final `expect(checked, greaterThan(0))`. It failed — but the helper was correct. The `copperPress` end-type *did* exist (6 times) but only in **synthetic** specs (HW-*) that don't appear in `kLipskeyCatalog`. Same issue hit `cheaperAlternativeBrand` (no SmartProducts have 2+ priced brands).
- **Fix:** drop the `count > 0` gate. The invariant assertion still fires on every real sample encountered; if the data has zero samples, the test is *vacuously true* — which is correct, not a regression. Direct boundary coverage of the helper lives in its dedicated test (`install_effort_test`), so the mutation test doesn't need to re-prove sample existence.
- **Why:** mutation tests check what a *mutated* helper would do; they should never depend on data prevalence. A "must find samples" gate creates a false failure when the data drifts (legitimate engine evolution) even though the logic is untouched.

---

## D. Engine / domain insights (compatibility + install)

### `plan.items` is a deduped BOM list, NOT a physical flow sequence
- **Problem:** auditing adjacency in `plan.items` reported false "no-connect" pairs — items are list-adjacent (first-appearance, deduped, with inserted compliance) but not flow-adjacent.
- **Fix:** audit the TRUE physical path via `findShortestPath(a,b)`, not `plan.items`.
- **Why:** the BOM groups items; the flow order is the path.

### A compression joint between two FITTINGS implies a missing pipe
- **Problem:** the engine counts `pipeSharedWith` (two fittings, same DN) as "connected & complete" but the pipe that bridges them isn't in the BOM → chains weren't "100% direct".
- **Fix:** `materializeChain` inserts the spanning component: fitting↔fitting → a PIPE (real drainage SKU or synthetic "PIPE-<mat>-<dn>" cut-to-length); pipe↔pipe → a COUPLING; pipe↔fitting → already direct.
- **Why:** "the pipe-into-fitting compression IS the direct joint"; only bare fitting↔fitting (or pipe↔pipe) needs a part inserted.

### Drainage ≠ supply for compliance
- **Problem:** auto-compliance inserted a supply ball valve into a gravity drainage line (מחסום → ברז כדורי → מצמד — impossible).
- **Fix:** `lineIsSupply(items)` (via `endSystems`) gates the shutoff + hot-source compliance.
- **Why:** a supply valve can't connect to a drain trap; gravity drainage has its own (slope/cleanout) rules.

### Check the DATA distribution before broadening a rule
- **Problem:** broadened galvanic detection to brass↔steel; it regressed (a steel PRV next to a brass line falsely demanded a dielectric).
- **Fix:** **reverted.** A material-distribution probe showed the real catalog has only brass among galvanic metals — copper/steel exist *only* as synthetic HW-* items. The original copper-gated rule was correct.
- **Why:** validate against real data before generalising; a "more correct" rule can be a regression for the actual dataset.

### Pressure-drop must exclude off-line side branches
- **Problem:** a ¼" Legionella sampling tap (a side test-port) was counted as the in-line bottleneck → bogus ΔP≈4.8 bar.
- **Fix:** exclude `_kOffLineSkus` (sampling/air-vent/expansion-tank) from the bore/K calc.
- **Why:** flow doesn't pass through a side tap; bottleneck = narrowest IN-LINE bore.

### Synthetic specs added at runtime don't leak into the carousel
- **Note:** `materializeChain` registers `PIPE-*` specs into `kVerifiedSpecs`, but `compatibleProductsFor` filters on `kLipskeyCatalog` (`if (q.isEmpty) continue`), so synthetic SKUs never show as "compatible products". Verified across 9340 hits.

---

## E. Refactor / deletion safety

### Bulk-deleting a class block: watch for unrelated top-level helpers between classes
- **Problem:** between `_QtyBtn` and `_CatalogRow` sat a top-level fn `_findCatalogTreeNodeByTitle` — a naive range-delete would have removed it.
- **Fix:** read the boundary first; use a **pattern-based awk** that stops at the right marker: `awk '/^class _X /{skip=1} /^<keep-marker>/{skip=0} !skip{print}'`. Verify `before→after` line counts + `grep -c` residual refs + that the kept symbol survives.
- **Why:** classes aren't always contiguous; never trust line numbers across edits.

### Deleting a widget cleanly
- **Recipe:** (1) remove the single render site, (2) remove the class(es), (3) remove any helper used *only* by it (check with `grep -rn`), (4) `flutter analyze` (0 errors), (5) full suite. Confirm a sibling widget you keep (e.g. `_FeaturedProductCard`) still has its references.

### Build "alongside" without touching the original
- **Pattern:** to enrich card B from card A without risk, reuse A's **public data helpers** (e.g. `related_info.dart`: `engineeringSpecFor`, `compatibleProductsFor`, `connectionExplainHe`, `complianceTriggersFor`, `finderGroupFor`, `installKitFor`, `variantSiblingsCountFor`) and duplicate only the small UI rows. Verify A is untouched: `git diff --quiet <A-file>`.

---

## F. Persistence (Flutter)

### In-memory `StateProvider` resets on refresh
- **Problem:** a "hide list" toggle reset on page refresh.
- **Fix:** mirror `state/product_favorites.dart` — a `StateNotifier<Set<String>>` that `_load()`s in the ctor and `_persist()`s via `SharedPreferences.getStringList/setStringList` under a versioned key (`bs.<feature>.v1`).
- **Test:** `SharedPreferences.setMockInitialValues({})`, then a fresh notifier reloads the persisted set (simulates restart).

---

## G. UI / Flutter-web automation

### Coordinate clicking on the Flutter `<canvas>` is unreliable
- **Problem:** Flutter web renders to one canvas; `computer left_click` by coordinate frequently misses (tab positions shift; long-press isn't supported).
- **Fix:** prefer **code verification** (tests + grep) as ground truth. For live demos, use tappable entry points (the manage-sheet eye-toggle) over long-press; take a screenshot to read current positions before clicking; tell the user the exact path so they can verify themselves.

### Canvas taps land *intermittently* — and the a11y tree is empty
- **Problem:** in one card session, chip taps (stage tracker, mode toggle) registered fine, but a `GestureDetector` button deeper in the scrollable sheet (the "בנה לי קו (BOM)" button) would not fire from a coordinate `left_click` after several attempts. `find` returned only "Enable accessibility" + "flutter typography measurement" — Flutter web doesn't expose canvas widgets to the a11y tree until accessibility is explicitly enabled.
- **Fix:** don't loop on a dead tap (2-3 tries max). Treat the rendered widget + green tests as proof it works; demo the *static* render and tell the user the tap path. Buttons that open a `showDialog` are the least reliable to drive via canvas coords — verify their logic with a unit test on the underlying function instead. Tap targets near the top of the sheet (chips) seem more reliable than ones mid-scroll.

---

## H. Synthetic catalog products (pattern)
- To model items the real catalogue lacks (hot-water gear, cut-to-length pipes): build a `LipskeyCatalogProduct` like `lipskey_hotwater.dart::_hw(...)` (productType derives from the name via `kLipskeyTypes`, so name a pipe "צינור …") and register its `VerifiedSpec` in `kVerifiedSpecs` (it's a mutable `final Map` — `putIfAbsent`). They stay out of the product carousel because that filters on `kLipskeyCatalog`.

---

## I. Lessons from the v5.36–v5.40 push-free session (closed 7 🟦)

### Static text-count tests as cheap invariant locks
- **Pattern:** when the behavior you want to lock is STRUCTURAL — "every animation has a reducedMotion guard", "every chip carries a Tooltip", "the search UI wires all three matchers" — don't write a widget-tree test. Write a `File('lib/screens/X.dart').readAsStringSync()` + `contains(...)` / `allMatches(...).length` check.
- **Wins:** runs in milliseconds, no Flutter test harness, no canvas-tap flake. Lives or dies by the source text, which is what you want for "did we wire it?" invariants.
- **Examples this session:** `reduced_motion_test` (AnimationController count ≤ reducedMotion count), `chip_tooltips_test` (6 expected message snippets present), `search_fallback_test` (three matcher names all referenced in `_SearchResultsList`).
- **Don't use for:** behavior that depends on actual values at runtime (use `ProviderContainer` for those — see `card_filter_state_test`).

### Re-verify "pre-existing failures" claims before treating them as wall
- **Trap:** STATUS.md said `category_scan_test` and `wiring_test` were "pre-existing failures (catalog-data issues, not code bugs)." A fresh run showed they pass clean.
- **Fix:** before quoting a stale "this is broken" note, re-run the specific test. Notes age, code moves.
- **Cost of not re-checking:** you carry a false-positive wall in your mental model — and may waste the user's time apologizing for a non-issue or skipping a fix that isn't needed.

### Block-of-3 cadence keeps local commits revertable
- Group 3 small polish/feature/test items per local commit (e.g. D+E+F → v5.36 polish, J alone, G+I together). Each commit is a complete unit a `git revert` can undo without breaking the rest.
- **Anti-pattern:** one giant commit at end of session — irreversible and hard to review.
- **Sweet spot:** ~3 items, ~150 LOC, ~5 files, message that names every step touched.

### Closing 🟦 honestly — audit the code, sometimes the work is already done
- **Step 2** was 🟦 only because the label was stale: the bridge IS complete (84% SKU coverage, the 58 brands without a SKU are intentional "by supplier" variants). Mark ✅ with the exact coverage numbers, don't pretend new work was needed.
- **Step 87** was 🟦 because the comment said "still ⬜" but the code already had the guard in BOTH animation controllers. The fix was adding a `reduced_motion_test` to LOCK the invariant, not adding the guard (which existed).
- **Rule:** when planning to close a 🟦, FIRST audit the source. If the work is shipped, your job is to document + lock, not to re-build.

### Helper-first → UI is still the cleanest pattern
- This session shipped 4 pure helpers (scoreBandColors, CardFilterSelection, pairConnectionWarningHe, fuzzySearch UI fallback) and 1 widget (_SavedVersionChip), all helper-first with tests before any UI wiring. Zero rework, zero test churn.
- The earlier subagent debacle taught not to outsource UI; doing helpers in-thread with TDD is still faster than any orchestration.

### Origin can move under your feet — fetch before push, not during work
- The other session pushed `240585a` (knowledge docs) while I was working. I'm 8 ahead of `dd45bb1` (my fork point) but only 7 ahead of `240585a` (current origin). Status `git fetch && git log` makes this visible.
- **Push protocol:** fetch first → rebase if origin moved → verify clean diff → push. Don't push without fetching, even if the user is impatient.

### The "probe" pattern — write a throwaway diagnostic test before deep work
- **When entering unfamiliar territory** (e.g. "does my toolbox even work on these products?"), write a temporary test file (e.g. `test/ppr_helpers_probe.dart`) that runs every relevant helper on real inputs and **prints** the output. Then delete it once you've learned what you needed.
- **Why this beats reading source:** the printed output answers concrete questions in one run ("does kVerifiedSpecs have an entry for PPR sku 95016002? no. does priceFor return ₪18 from dims? no. does compatibleProductsFor return mates? 0."). Reading source to answer those gives a *theory*; the probe gives a *fact*.
- **Discovery from this session:** running a probe on 3 PPR SKUs (95016002 / 95270708 / 94117202) revealed that all 774 Polyroll products are missing `VerifiedSpec`, so 8 card helpers (price, compat, standards, tools, effort, tips, pair-warning, install-engine) silently return null/empty for them — a gap NOT visible in any aggregate test. That gap is now the next session target.
- **Etiquette:** put the probe in `test/` so `flutter test` runs it, but delete it the moment its question is answered. Probes that linger become noise.
