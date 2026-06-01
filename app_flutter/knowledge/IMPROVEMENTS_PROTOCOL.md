# Improvements Protocol — round 2 (post-SIZE_FILTER)

> Branch `claude/whats-happening-LyY9G`. Owner: this session.
> Started 31.5.26. Built on the foundation of `SIZE_FILTER_PROTOCOL.md`
> (P1-P16 closed).
> Style: **fix → verify → log lesson** per step. Local-only until approval.

## 🛑 Rules of engagement
- **Local only** — no `git commit`, no `git push` until explicit user approval.
- Each improvement gets its own sub-protocol with tests-first + audit.
- When a sub-protocol surfaces a new bug it gets a `P{n}` entry in the parent
  SIZE_FILTER protocol; this file tracks **forward-looking improvements**.
- Before push: re-fetch origin (parallel sessions push too), resolve, re-verify.

---

## I — Improvements (ranked by user-visible win, then code quality)

| # | Improvement | Where | User-visible win |
|---|-------------|-------|------------------|
| **I1** ✅ | **Replace empty-box group emojis with 3D product icons** (v5.44) | `finder_screen.dart` — `kFinderGroupImage` + `finderGroupGlyph()` render a designer 3D product PNG per group (home circle + breadcrumb), with an `errorBuilder`/no-image fallback to `kFinderGroupIcons`/`finderGroupIcon` (Material). | the 10 home rows rendered an empty rectangle (canvaskit font lacks 🚰🚽🕳️…). First shipped Material icons (v5.42), then upgraded to designer 3D product icons: a sprite + a standalone green PPR pipe were sliced into 10 transparent PNGs (`assets/lipskey/categories/`) via a pure-Python PNG decode/encode (no PIL/ImageMagick). Data keeps `g.emoji` for text contexts. Guarded by `finder_group_icons_test` (image+icon mapping completeness + uniqueness). |
| **I2** | **Finder-card chip-label consistency test** | NEW `test/finder_card_consistency_test.dart` | P9/P12 escaped unit tests because no test pumped a category screen and compared what the user sees on a card to what the filter chip says; without this guardrail the next refactor can reintroduce the drift |
| **I3** | **Unify card+filter chip display via one `SizeChipLabel` widget** | NEW `lib/widgets/size_chip_label.dart`; consumed by `_AttrChip` AND `_chip` (finder) | the three-gate pipeline (tokenize/classify/render) currently lives in three files; a single widget makes future drift impossible (closes LL-07 / LL-14 categorically) |
| **I4** | **`scripts/post_build.sh` re-applies canvaskit patch** | NEW `scripts/post_build.sh` | every `flutter build web --release` overwrites `build/web/flutter_bootstrap.js` and the puppeteer/local serve breaks until manually patched (LL-03 — 12+ repeats this session alone) |
| **I5** | **M/S/L → secondary "מידה" axis on the finder** | `finder_screen.dart` `_narrowAxis` | clamps cards show `M`/`S` as plain text — user can't filter by them today; surface as a `_chipRow('מידה', …)` when present |
| **I6** | **Variant picker: group-by-DN when N > 12** | `_AttrChip` picker (size kind) | PPR Faser shows `1/39` variants — the picker is a flat scroll that's painful to navigate |
| **I7** | **Cross-dim → split into 2 axes for PPR** | `_size_norm.dart` family adjustments | `20×2.8` carries OD + wall; sort key is only OD; PPR users want to filter wall thickness separately |
| **I8** | **Chip row scroll-affordance** | `_chipRow` widget | when a row overflows, no indicator → users don't know there are more chips |
| **I9** | **Rename `_size_norm.dart` → `display_size.dart`** | leading-underscore is the Dart convention for FILE-private; this file is used from 3 places |
| **I10** | **Analyzer cleanup** | `flutter analyze` reports 3002 issues (mostly trailing-commas, pre-existing); separate sweep |

## Order of attack (low risk → high yield)

1. **I4** (post_build.sh) — saves friction every build for the rest of the session
2. **I2** (consistency test) — anchors the guarantees before more refactors
3. **I1** (Material icons for groups) — immediate visual win on the home screen
4. **I3** (SizeChipLabel widget) — root-cause cleanup
5. **I5** (M/S/L axis) — small UX win
6. **I8** (scroll affordance) — small UX win
7. **I9** (rename) — mechanical
8. **I6** (variant grouping) — bigger UX
9. **I7** (cross-dim split) — biggest scope
10. **I10** (analyzer sweep) — separate dedicated session

---

## 🪵 Live Log — issues encountered, solutions, lessons

(filled as each I-step executes)

### LL-I4 — `scripts/post_build.sh` shipped
**Problem**: 12+ times this session, after a `flutter build web --release`, the puppeteer screenshot loaded canvasKit from gstatic CDN (slow / blank). Manual repatch every time.
**Solution**: Idempotent Python-in-bash script that detects the unpatched shape, replaces the `_flutter.loader.load({...})` block with one carrying `canvasKitBaseUrl`, and exits cleanly if already applied. Runs in <0.1s.
**Lesson**: When a build step keeps clobbering a local-only patch, automate the patch — don't memorize it. The cheapest fix is a 30-line bash script; the most expensive is to retype it every build.

### LL-I1 — group emojis → Material icons (the P13 pattern, applied to UI)
**Problem**: The home screen's 10 group circles showed empty boxes — the same canvaskit-can't-draw-the-glyph issue as P13 (`⅜"`), but for plumbing emoji (🚰🚽🕳️…).
**Solution**: A display-only map `kFinderGroupIcons` keyed by group label → Material `IconData`, rendered as `Icon(...)` at the two circle sites. Data keeps `g.emoji` (still used in text-interpolation contexts elsewhere). A test asserts every group is mapped AND icons are unique.
**Lessons**:
1. The P13 "fold what the renderer can't draw" pattern generalizes from text glyphs to UI iconography — same root cause (bundled font), same fix shape (display-layer substitution keyed by stable identity, data untouched).
2. Two other sites (`lipskey_product_sheet.dart`, `catalog_screen.dart`) interpolate `g.emoji` into strings and still show the box; converting those needs a string→widget restructure — logged as I1-followup, not done in this pass (scope discipline).

### LL-I2 — consistency test exposed P17 on first run
**Problem**: Wrote `finder_card_consistency_test.dart` to lock in P9/P12/P16 guarantees. First run failed with 799 mismatches; refining to "finder ⊆ card" still flagged ~50 real pipeline mismatches (`finder: '200 ס"מ'` vs `card: '200'`).
**Solution**: The drift is a real bug — **P17** is "card word-tokenizer splits `200` from `ס"מ`; finder regex captures `200 ס"מ` as one token". The right fix is I3 (unify both through one helper). Parked the strict drift assertion with `skip:` + a TODO; kept 4 regression sentinels green so the file still earns its keep right now.
**Lessons**:
1. A consistency test you write to "lock in fixes" is also the cheapest bug-finder you have — if it surfaces something new on first run, take the finding seriously.
2. When a test reveals work bigger than the test, `skip:` with a referent (issue/protocol id) is better than `expect.tolerance(50)`; the next session sees an explicit todo, not a silent loosening.

---

### LL-I1b — designer 3D icons: slice without image tools + headless can't screenshot them
**Problem**: User rejected Material icons + a hand-coded CustomPainter ("חלש מאוד"), wanted real product imagery. The sandbox has NO image stack (no PIL/ImageMagick/rsvg, no network, no image-gen model) — so I couldn't generate photos NOR slice a delivered sprite the usual way.
**Solution**: The designer delivered a 1536×1024 transparent sprite (9 icons) + later a standalone PPR pipe. Wrote a **pure-Python PNG codec** (zlib + manual unfilter/encode, stdlib only) to: detect each icon via connected-components, crop to square transparent PNGs, and composite a circle preview. Wired via `kFinderGroupImage` + `finderGroupGlyph` with a Material-icon fallback.
**Lessons**:
1. "No image tools" ≠ "can't process images" — a PNG is just zlib + filtered scanlines; a ~60-line pure-Python codec slices/crops/encodes when PIL is absent.
2. **canvaskit in headless puppeteer renders NO `Image.asset`** — proven by existing product photos also showing blank. So a screenshot can't verify image features here; I composited a circle preview from the cropped PNGs instead. Verify image work by previewing the assets, not by app-screenshot, in this environment.
3. Be honest about generation limits early — I can author vectors (weak) and process pixels (codec), but cannot synthesize photoreal imagery. The user supplies the art; I do the engineering.

### LL-I1c — multi-agent coordination: shared WIRING.md + stuck_log gates
**Problem**: Committing the icons hit gate 24 (WIRING.md not updated) then gate 102 (stuck_log not updated). I wrongly assumed WIRING.md was the protocolist's (it's at repo root, shared). The rebase then conflicted on the hook-AUTO-GENERATED `stuck_regression_test.dart` (both sides added an "antipattern #39").
**Solution**: Per `AGENT_COORDINATION.md`: any agent touching `lib/screens`/`lib/state` documents its own wiring in the shared root `app_flutter/WIRING.md`, and records solved problems in `stuck_log.md` (problem/solution/ANTIPATTERN/RULE, shell-meta-free for gate 103). Resolved the auto-gen test conflict by keeping BOTH antipatterns (renumbered mine #39→#40).
**Lessons**:
1. `WIRING.md` and `stuck_log.md` are SHARED logs every code-touching agent appends to — not protocolist-owned. A new provider/map in `lib/screens` needs a same-commit WIRING row.
2. When a hook auto-generates a file (`stuck_regression_test.dart` from stuck_log ANTIPATTERN lines), rebase conflicts on it are numbering collisions — keep both entries, renumber, don't pick one side.
3. Don't bypass a hook gate — satisfy it (or report to the protocolist per the template). Every gate here has a real reason.

---

## 🎓 Lessons carry-forward (distilled at the end)

- A PNG is zlib + filtered scanlines — a pure-Python codec slices/crops/encodes when no image tools exist (LL-I1b).
- canvaskit-in-headless renders no `Image.asset`; verify image features via an asset preview, not an app screenshot (LL-I1b).
- `WIRING.md` (repo root) + `stuck_log.md` are shared across the 4 agents; any `lib/screens` change documents its wiring + any solved gate in the SAME commit (LL-I1c).
- Hook-auto-generated files (e.g. `stuck_regression_test.dart`) conflict by numbering — keep both, renumber (LL-I1c).
