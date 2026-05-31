# AGENT_PATTERNS — parallel sub-agent playbook (consolidated from PLAYBOOK §B)

## TL;DR
Parallel sub-agents work cleanly only when each agent writes to **disjoint,
brand-new file paths**, is briefed with **absolute repo paths** (the harness
resets cwd between Bash calls, so worktree isolation is unavailable), and the
API is not under load — 3 concurrent agents is the proven ceiling; on a 529
Overloaded response, fall back to serial, then to supervisor-direct
`Write`/`Bash`.

## What works

- **Disjoint NEW files only** — each agent creates files that no other agent
  (and no supervisor in-flight work) will touch. Zero merge cost. Verified on
  ROADMAP steps 4 / 10 / 92 (docs + 2 state notifiers) and again on 86 / 88 /
  99-100.

- **3 concurrent agents typical** — the proven batch size in one Agent-tool
  call. Results: 5/5 + 6/6 + 194 lines of docs, 0 analyze errors, full suite
  640 → 651.

- **Absolute paths in every brief** — agents cannot rely on a working
  directory; pass full Windows paths into `lib/...`, `test/...`,
  `knowledge/...`. Relative paths are unreliable across the harness.

- **Strict "no modify existing" rule** — must appear verbatim in every brief.
  Agents ADD files, never edit. This is what keeps the deliverables disjoint
  even when scopes are adjacent.

- **10-step decomposition** — supervisor frames each task with the standard
  template (requirement → acceptance → existing-pattern scan → design → red
  test → green impl → analyze → wire UI → scoped+full suite → roadmap+version
  +commit) so each agent follows a uniform protocol.

- **`_test.dart` singular suffix** — `flutter test` auto-discovers
  `**/*_test.dart`; `*_tests.dart` (plural) is silently skipped. Brief agents
  with the singular form and confirm the suite count rose after the merge.

- **Mirror reference file** — point each agent at a known-good sibling (e.g.
  `lib/state/product_favorites.dart` for persistence) to copy patterns, so
  output style stays consistent across the batch.

## What doesn't

- **`isolation: "worktree"` when cwd isn't a git repo root** — fails instantly
  with "Cannot create agent worktree: not in a git repository". The harness
  resets cwd after every Bash call, so a pre-`cd` does not persist. Skip
  worktree isolation entirely; use absolute-path briefing instead.

- **Concurrent agents during API overload (529)** — 3 parallel `Agent` calls
  all returned `API Error: 529 Overloaded` after ~200 s each with
  `tool_uses: 0`. Never blindly resend the same batch — the concurrent load is
  exactly what tripped the limiter. Don't `SendMessage` to resume either;
  they're empty, a fresh spawn is cleaner.

- **Two agents touching the same file** — concurrent edits to a shared file
  (e.g. `catalog_screen.dart`) force manual conflict resolution that erases
  the parallelism win. Keep any shared-file work sequential on one agent.

## Fallback chain

1. **Concurrent (3 agents, one Agent-tool call)** — default when tasks are
   disjoint NEW files and API is responsive.

2. **Serial (one agent at a time)** — first response on 529. Spawn one, wait
   for success, queue the next. If that also 529s, wait a few minutes for
   global capacity to free.

3. **Supervisor-direct (`Write` + `Bash` in this conversation)** — if a single
   agent also 529s, the supervisor already has full context; do the work
   inline. Document the pivot, don't loop on 529.

## Checklist for the next parallel batch

- [ ] Confirm every deliverable is a **new file path** — use `git ls-files` /
      `Glob` to verify no collision with each other or with the supervisor's
      open edits.
- [ ] Brief each agent with **absolute Windows paths** into the repo (no
      relative paths, no `cd`).
- [ ] Include verbatim in every brief: *"ADD only — never modify existing
      files. No git commit or push."*
- [ ] Include the **10-step decomposition** template and the `_test.dart`
      (singular) naming reminder.
- [ ] Point each agent at a **mirror reference file** for pattern/style
      consistency.
- [ ] **Do NOT request `isolation: "worktree"`** — it will fail in this
      harness; absolute paths + strict no-overlap is the working substitute.
- [ ] Cap concurrency at **3 agents** in a single Agent-tool call; on 529,
      drop to serial, then to supervisor-direct.
- [ ] After the batch returns, run `flutter analyze` (0 errors) + full suite,
      and **confirm the test count rose** (catches the silent `*_tests.dart`
      skip).
