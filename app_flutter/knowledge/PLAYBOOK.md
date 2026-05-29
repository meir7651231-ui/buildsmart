# PLAYBOOK — continuous learning log (read me first)

## Working mode — NO STOPPING
Keep building, verifying, and pushing **without pausing for confirmation**. A
step that looks "blocked" is **not** a stop — try **dozens of different
approaches** first: local stubs, synthetic/mock data, heuristics, alternative
libraries, placeholders, workarounds, re-framings. Only declare a **wall** when
it is genuinely impassable *and* cannot be broken or bypassed after many honest
attempts (e.g. it fundamentally requires a live external server, real device
hardware, or paid third-party access that does not exist here). When you do hit
such a wall, document it below **with every approach you tried** and move on to
the next thing you *can* advance — never idle.

Cadence: run the **full test suite every ~5 steps**; bump version + push on a
clean checkpoint; keep momentum.

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

---

## H. Synthetic catalog products (pattern)
- To model items the real catalogue lacks (hot-water gear, cut-to-length pipes): build a `LipskeyCatalogProduct` like `lipskey_hotwater.dart::_hw(...)` (productType derives from the name via `kLipskeyTypes`, so name a pipe "צינור …") and register its `VerifiedSpec` in `kVerifiedSpecs` (it's a mutable `final Map` — `putIfAbsent`). They stay out of the product carousel because that filters on `kLipskeyCatalog`.
