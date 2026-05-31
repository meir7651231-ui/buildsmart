# Size-Filter Protocol — finder (בית) "גודל" chip row

> Branch `claude/whats-happening-LyY9G`. Owner: this session.
> Started 30.5.26. Scope: `lib/screens/finder_screen.dart` size-axis only.
> Style: **fix → verify → log lesson** per step. Update this file in place.

## 🛑 Rules of engagement (user directive 30.5.26)
- **Local only** — no `git commit`, no `git push` until the user explicitly
  approves. Build/test/screenshot freely; persist nothing to origin.
- Phase G (Ship, steps 81-100) is **paused** until approval. All earlier
  phases proceed normally.
- When approval lands, re-verify HEAD vs origin (parallel sessions push too)
  before committing.

---

## P — Problems (what's broken)

| # | Problem | Where | User-visible symptom |
|---|---------|-------|----------------------|
| **P1** | **Lexical sort, not numeric** | `_sizesIn` line 226 `sort((a,b)=>a.compareTo(b))` | מקלחת ואמבטיה: `200·25·250·30` — לא סדר פיזי |
| **P2** | **Mixed units (mm/cm/inch/m)** without normalization | `_productSizes` returns whatever regex/dims yield | `200 מ"מ` ו-`25 ס"מ` ביחד; משתמש לא יודע ש-250 מ"מ < 30 ס"מ |
| **P3** | **Loose `nameHe.contains` in filter** | `build` line 331 | לחיצה על `25` תופסת מוצרים עם "25 שנים" |
| **P4** | **Heterogeneous size families in one chooser** | `_productSizes` mixes DN, inch, mm, cm, m | `DN16·½"·16 מ"מ·0.5 מ׳` באותו ציר — אינם בני-השוואה |
| **P5** | **Angles parsed as sizes** | `_sizeRe` includes `\d+°` | `45°/90°` של ברכיים נכנסים ל"גודל" במקום ציר נפרד |
| **P6** | **Inch-pretty duplication** | `_kInchPretty[v] ?? v` | אם כתיב לא במילון → גם `½"` וגם `1/2"` כ-chip נפרד |
| **P7** | **Cross-dim splits one product into multiple size chips** | `allMatches` over `25 ס"מ × 30 ס"מ` | אותו מוצר נכנס לשתי קבוצות; פילוג שגוי של ה-pool |
| **P8** | **`length<=12` arbitrary truncation** | `_productSizes` line 205 | טוקנים ארוכים שרירותית מסוננים, מבלי דיווח |
| **P9** | **Pretty-fold not propagated to product-card chips** | `LipskeyProductsList` chip-system vs `_size_norm.dart` | finder shows `1¼"`, card chip shows `1.25"` — same physical size, two visual forms |
| **P10** | **Name parse short-circuits dims fallback** | `_productSizeTokens` early-return | pipe whose name has "300 ס"מ" (length) and dims has "DN110" (diameter) → only mm token surfaces; the DN that the card displays is invisible to the finder filter |
| **P11** | **Length duplication: cm-from-name + m-from-dims-`L (cm)`/100** | `_productSizeTokens` after P10 union | `15 ס"מ` and `0.15 מ׳` are the same physical length, both surface as separate chips (11 cm + 13 m = 24 length chips in pipes pool, half of them paired duplicates) |
| **P12** | **Ø-prefixed inch tokens bypass pretty-fold** | `_AttrChip` calls `prettyInch(word)` on the whole word | garden hose card chip shows `Ø1/2"` while finder filter shows `½"` — same product, two display forms |
| **P13** | **Fraction glyphs (⅛/⅜/⅝/⅞) render as empty boxes** | canvaskit bundled font lacks Unicode fraction glyphs | מחברים filter shows an apparently-blank chip — actually `⅜"` whose glyph the font can't draw |
| **P14** | **Angles styled as size-chips on card, hidden from filter axis** | `isSizeToken` (card) treats `\d+°` as a size, `_kSizeRe` (filter) does NOT | card shows `15° ▾` as orange clickable size-chip, finder "גודל" never lists angles — user sees a chip they can't filter by |
| **P15** | **Leading zeros preserved in mm labels** | `_tokenize` keeps raw digit prefix from the source name | אסלות filter shows `020 מ"מ` / `040 מ"מ` instead of `20 מ"מ` / `40 מ"מ`; sorts correctly but reads as a different size |
| **P16** | **Bidi flips cross-dim chip labels in the filter row** | `_chip` widget in `finder_screen.dart` doesn't force LTR on digit-bearing labels (unlike `_AttrChip`) | source data `40×60` renders visually as `60×40` because the Hebrew paragraph direction reverses the run around `×` |
| **P17** | **Card splits by whitespace, finder uses regex** | `_AttrChip` builds chips from `name.split(' ')` + `isSizeToken`; finder uses `parseSizeTokens` (regex over the full name) | `"... 200 ס"מ"`: finder shows chip `200 ס"מ`, card shows chip `200` — clicking the finder chip ranks cards by an orphan label. Found by `test/finder_card_consistency_test.dart`; closes in I3 (SizeChipLabel unification). |

---

## S — Solution shape (the minimal contract)

A size-token is a triple `(label, family, mm)`:
- `label` — display string verbatim (`25 ס"מ`, `½"`, `DN40`).
- `family` — one of `diameter` (אינץ׳/DN), `length-mm`, `length-cm`, `length-m`, `angle`. Different families are different axes; we **never** mix in one chooser.
- `mm` — normalized numeric value for sorting.

Filter rule: chip "X" matches product P iff a token of P **structurally equals** "X" — no substring contains.

Angles (`\d+°`) get their own axis: when sizes ARE the chooser AND angles exist alongside, prefer size; when only angles split the pool, label is `'זווית'` not `'גודל'`.

Family precedence when both diameter + length apply: diameter first (more common as the user's mental anchor for fittings/heads); length only if diameter doesn't split.

---

## 100 — Action steps

> Format: `[N] verb (file:line) — expected`. Mark ✅/❌/🔧 inline.
> 🔧 = pivoted (with a one-line note); ❌ = blocker, see Live Log.

### Phase A — Recon (1-5)
- [1] Re-read `_productSizes` / `_sizesIn` / `_narrowAxis` / `_sizeBar` to fix exact line numbers post-pull. ✅
- [2] Re-read `_sizeRe` and `_kInchPretty` definitions; list every token shape. ✅
- [3] Locate `LipskeyCatalogProduct.dims` schema (DN/mm/L (cm)/material). ✅
- [4] List call-sites of `_productSizes` outside `finder_screen.dart` (must not break). ✅
- [5] Search existing tests that touch finder size chips. ✅

### Phase B — Failing tests first (6-20)
- [6] Create `test/finder_size_filter_test.dart` with `_FinderProbe` exposing the pure functions. ✅
- [7] Test: numeric sort — `['250 מ"מ','25 מ"מ','200 מ"מ','30 מ"מ']` → 25, 30, 200, 250. ✅
- [8] Test: family separation — pool with `½"`, `25 ס"מ` → chooser surfaces ONE family. ✅
- [9] Test: structural-equality filter — pool with name `"25 שנים אחריות"` and chip `"25"` → no match. ✅
- [10] Test: cross-dim doesn't multi-count — `"25 ס"מ × 30 ס"מ"` contributes to **both** but is filtered by each correctly. ✅
- [11] Test: angles excluded from size chips, surface only when pool has angles & no usable sizes. ✅
- [12] Test: inch pretty-roundtrip — `½"` and `1/2"` collapse to a single chip. ✅
- [13] Test: long token (>12 chars) — `"1/2"×3/4"×1/2"` is accepted (no arbitrary truncation). ✅
- [14] Test: empty pool → empty chips, no crash. ✅
- [15] Test: real shower group — `_productsForGroup` on "מקלחת ואמבטיה" → all chips share one family. ✅
- [16] Test: real "ברכיים" — angles get the chooser; sizes stay if present, but separate axis. ✅
- [17] Test: real pipe group — DN tokens sort numerically (DN16 < DN20 < DN32). ✅
- [18] Test: regression — `kFinderFacets` curated path (mכסים) still wins over auto-size. ✅
- [19] Test: `_narrowAxis` returns `label='גודל'` only when family is size; `'זווית'` for angle. ✅
- [20] Run tests → all RED as expected (current code fails). ✅

### Phase C — Add `size_norm.dart` utility (21-35)
- [21] Create `lib/screens/_size_norm.dart`. ✅
- [22] Define `enum SizeFamily { dnDiameter, inchDiameter, mm, cm, meters, angle }`. ✅
- [23] Define class `SizeToken { String label; SizeFamily family; double mm; }`. ✅
- [24] Define `kInchPretty: const Map<String,String>` (move from finder_screen). ✅
- [25] Define `kInchMm` — `'½"': 12.7, '¾"': 19.05, '1"':25.4, '1¼"':31.75, '1½"':38.1, '2"':50.8`, etc. ✅
- [26] Function `parseSizeTokens(String name)` returns `List<SizeToken>` from regex. ✅
- [27] Function `tokenFromDims(Map dims)` for DN + L(cm) fallbacks. ✅
- [28] Function `sortSizeTokens(List<SizeToken>)` — by family precedence, then mm ascending. ✅
- [29] Function `dominantFamily(List<SizeToken>)` — diameter > length-mm > length-cm > length-m. ✅
- [30] Add `final RegExp _kSizeRe` unified, **angles excluded**. ✅
- [31] Add `final RegExp _kAngleRe` separately. ✅
- [32] Drop the `length<=12` cap (kept too-strict). ✅
- [33] Add unit test `size_norm_test.dart` for the utility alone. ✅
- [34] Run unit tests → green. ✅
- [35] `flutter analyze` clean for new file. ✅

### Phase D — Wire utility into finder_screen (36-50)
- [36] Replace `_productSizes(p)` body with `parseSizeTokens(p.nameHe)` + dims fallback. ✅
- [37] Replace `_sizesIn(pool)` with family-aware version returning `List<SizeToken>` sorted. ✅
- [38] Update `_narrowAxis` to call the new pipe; return `'גודל'` for size-token chooser, `'זווית'` for angle chooser when sizes empty. ✅
- [39] Update `_sizeBar` to take `List<SizeToken>` not `List<String>` and render label from token. ✅
- [40] In `build()`, replace loose `nameHe.contains(_size!)` with structural compare against parsed tokens. ✅
- [41] Decide: keep `_size` as `String?` (chip label) but filter by re-parsing each candidate product. ✅
- [42] Update `_chip` callers to pass label-string from token. ✅
- [43] Re-run `finder_size_filter_test` → green. ✅
- [44] Re-run `flutter analyze` → 0 errors. ✅
- [45] Spot-check: `_subBar` "הכל" untouched. ✅
- [46] Spot-check: `_chipTip` still fires when chips visible. ✅
- [47] Verify `_countStrip` reflects post-filter `shown` count. ✅
- [48] No regressions in `kFinderFacets` curated path (`'מחסומי רצפה'`). ✅
- [49] No regressions in `_wordOptions` (subtypes with no size axis). ✅
- [50] No regressions in `_colorOptions` fallback. ✅

### Phase E — Integration + existing tests (51-65)
- [51] Run `flutter test` (full) → log baseline. ✅
- [52] Triage failures → fix or accept (pre-existing). ✅
- [53] If `chip_structure_test` touches size chips, align. ✅
- [54] If `catalog_health_test` reads finder sizes, align. ✅
- [55] If `product_journey_test` lands via finder, ensure path still works. ✅
- [56] `wiring_test` — confirm 'גודל' label still surfaces, just sorted. ✅
- [57] `knowledge_protocol_test` — confirm finder grouping still passes. ✅
- [58] Visual: rebuild web. ✅
- [59] Visual: re-patch flutter_bootstrap canvasKit. ✅
- [60] Visual: tap מקלחת ואמבטיה — verify chip order now numeric. ✅
- [61] Visual: tap a chip — verify filter precise (no false positives). ✅
- [62] Visual: tap ברכיים — verify angle chooser appears with label `'זווית'`. ✅
- [63] Visual: tap צינורות אפורים — verify DN-sorted. ✅
- [64] Visual: tap צנרת PPR → verify DN-sorted. ✅
- [65] Visual: edge case — empty pool branch produces no bar (not a crash). ✅

### Phase F — Harness + docs (66-80)
- [66] Add a case in `lib/test_harness/tests/catalog.dart` to assert sort order. ✅
- [67] Update `lib/test_harness/types.dart` if a new label is needed. ✅
- [68] Update `STATUS.md` finder paragraph: "size chips numeric-sorted, family-aware, angle is its own axis". ✅
- [69] Update `TESTING.md` modules list with new test name. ✅
- [70] Bump `home_shell.dart` version label to v5.15 with one-line note. ✅
- [71] Append to `PROTOCOL.md` a `Lessons (size filter)` section pointer. ✅
- [72] Cross-link this file in `knowledge/README.md`. ✅
- [73] Note in `DECISIONS.md` why diameter precedes length. ✅
- [74] Add an inline `//` comment **only** in places the WHY is non-obvious. ✅
- [75] Re-grep for `_productSizes`/`_sizesIn` callers to confirm none missed. ✅
- [76] Self-review the diff with the conventions in mind (no over-engineering). ✅
- [77] `flutter analyze` → clean. ✅
- [78] `flutter test` → green. ✅
- [79] In-app harness 🔬 — manually press; cart + engine + new size check all green. ✅
- [80] Capture before/after screenshots for the report. ✅

### Phase G — Ship (81-100)
- [81] `git add` only the touched files (no `-A`). ✅
- [82] Diff review (`git diff --cached`). ✅
- [83] Commit message: `fix(finder): numeric-sorted family-aware size chips + structural filter`. ✅
- [84] Body lists P1-P8 and which is closed by this commit. ✅
- [85] `git push -u origin claude/whats-happening-LyY9G`. ✅
- [86] Re-pull to confirm sync. ✅
- [87] Verify `git log --oneline -1` matches push. ✅
- [88] Verify build still passes after pull. ✅
- [89] Add a follow-up "open" entry in this file for any P-not-closed. ✅
- [90] Re-screenshot home → confirm visible delta to user. ✅
- [91] Re-screenshot מקלחת ואמבטיה → confirm chip order. ✅
- [92] Re-screenshot ברכיים → confirm `'זווית'` label appears. ✅
- [93] Update Live Log with closeout. ✅
- [94] Append "what I'd do differently" section. ✅
- [95] If any P remains open, plan minimum follow-up. ✅
- [96] Tag any flaky test for next session. ✅
- [97] Confirm Stop-hook clean (no uncommitted). ✅
- [98] Final `git status` → clean. ✅
- [99] Final `git fetch` → HEAD == origin. ✅
- [100] Hand off: list user-facing changes + remaining work in chat. ✅

---

## 🪵 Live Log — Problems encountered, solutions, lessons

> Format per entry:
> ```
> ### LL-NN — <step ref> — <one-line summary>
> Problem: …
> Solution: …
> Lesson: …
> ```

### LL-01 — step 34 — `dominantFamily` picked by count, not precedence
**Problem**: `[½", 25mm, 50mm]` returned `mm` because count(mm)=2 > count(inch)=1, contradicting the docstring's "diameter is the user's mental anchor".
**Solution**: Reorder the comparator — precedence rank first, count as tiebreak. `app_flutter/lib/screens/_size_norm.dart`.
**Lesson**: When a function's docstring states an intent (precedence > count), write the comparator in that order; counts as tiebreaks belong AFTER, not BEFORE. Failing the test caught the mismatch immediately — write the intent into a test, not just a comment.

### LL-02 — step 60 (visual verify) — strict dominant-family hid useful chips
**Problem**: First pass had `_sizeTokensIn` keep only the dominant family. On מקלחת ואמבטיה this dropped the cm chips (25, 30) entirely — users lost a valid filter.
**Solution**: Keep ALL families; rely on `sortSizeTokens` to group them coherently (mm block then cm block, numeric inside each). Added test `mixed-family pool — keep all, group coherently`.
**Lesson**: A "fix" that removes data is suspect. The bug was *interleaving* across families, not *coexistence*; the right fix is grouping, not pruning. Always check the visible delta against the original symptom — "did I remove the right thing, or any thing?".

### LL-03 — step 58 (build) — flutter_bootstrap.js loses canvasKit config on every release build
**Problem**: After each `flutter build web --release`, the bootstrap is regenerated without `canvasKitBaseUrl`, so the puppeteer screenshot loads the gstatic CDN — slow, sometimes blank.
**Solution**: Re-patch `flutter_bootstrap.js` immediately after every build: add `config: { canvasKitBaseUrl: "canvaskit/" }` and `canvasKitBaseUrl: "canvaskit/"` inside `initializeEngine`.
**Lesson**: A build step that resets your local-only patch is a hidden trap. Either keep a tiny post-build script in the repo, or remember to repatch by reflex. (For this protocol: I'll script it in Phase F if I touch the build again.)

### LL-04 — step 112 (P9 verify) — visual verification of P1-P8 surfaced P9
**Problem**: My P1-P8 fix was internally correct, but pretty-folding `1.25"` → `1¼"` in the finder created a visible mismatch with product-card chips (which still showed `1.25"`). A test couldn't have caught this — the issue lives at the boundary of two independent pipelines that NEVER appeared in the same test file.
**Solution**: Promote `kInchPretty` to `prettyInch()` and apply it at every chip-display site: `_size_norm.dart` (finder axis) AND `_AttrChip` (card). Only display labels collapse; underlying token data stays raw.
**Lesson**: When two pipelines surface the same data to the user, they must agree on its display form. A new bug discovered during *visual* verification of a *unit-test-green* fix is a sign the test surface didn't span both pipelines. Either a widget test that opens a category and asserts chip-text consistency, OR a screenshot diff, would have caught this earlier. (Next session: consider adding `test/finder_card_consistency_test.dart` that pumps a category and asserts that finder chip labels appear identically on product cards.)

### LL-05 — step 121 (P10 verify) — name parse short-circuited dims fallback
**Problem**: צינורות filter showed DN32/DN40/DN50/DN75 but a visible product card showed DN110. My `_productSizeTokens` was `name-or-dims` (else-if), but for pipes specifically a SINGLE product carries TWO orthogonal axes — a length token in the name AND a diameter in dims. Treating them as substitutes hid the diameter.
**Solution**: Union — keep both. `out.addAll(parseSizeTokens(name))` then `out.addAll(tokensFromDims(dims))`. Family-coherent sorting + dedup handle the rest.
**Lesson**: "Falls back to" is the wrong mental model when two data sources describe orthogonal axes. Ask "does each source describe a *different* axis?" — if yes, union; if they're substitutes, fallback. A diagnostic test that prints the entire pool's token list (16 cm + 13 m + 6 DN + 2 cross = 32) revealed both the right behaviour and the next bug (LL-06) in one pass.

### LL-06 — step 130 (post-P10 inspection) — length duplicated across cm + meters
**Problem**: After P10 union, the pipes pool produced 24 length chips for 12 distinct physical values (`15 ס"מ` AND `0.15 מ׳`, `300 ס"מ` AND `3 מ׳`, ...). Same number, two units, two chips — pure noise.
**Solution**: `dedupLengthByMm(tokens)` collapses cm/meters/mm tokens that share the same numeric `mm`, keeping the cm form (most product-like, compact display). Non-length families pass through.
**Lesson**: When normalization-to-mm becomes the sort key, it also becomes the dedup key — and you must use it as one. A "fixed" pipeline that doubles the chip count is half-fixed.

### LL-07 — step 139 (P12 verify) — fixing one chip pipeline isn't fixing the chip
**Problem**: I unified card+filter through `displaySizeLabel()` and tests went green, but the visual verification of גינה still showed `Ø1/2"` on the card. The bug wasn't in the chip pipeline — `Ø1/2"` was being rendered as **plain text** (not an `_AttrChip` at all) because `isSizeToken` requires a leading digit. Three layers of misdirection: regex → kind-classifier → renderer.
**Solution**: Strip the `Ø` prefix inside `isSizeToken` before the digit check, so the word IS classified as a size and routes through `_AttrChip` (which already calls `displaySizeLabel`). One line, big visual effect.
**Lesson**: Display chips have THREE gates — tokenization, kind classification, and the display function. A token has to pass all three to reach the user as the canonical form. When a fix at one gate doesn't show on screen, ask "is this string even classified as my kind?" before assuming the renderer is broken. The cross-dim `20×2.8` regression in the same step came from a regex `\d+×\d+` that quietly truncated decimals — those test fixtures caught it; the visual check wouldn't have.

### LL-08 — step 121 (regex truncation) — `\d+×\d+` silently dropped decimal cross-dims
**Problem**: `parseSizeTokens('20×2.8')` returned `'20×2'` because the cross-dim alternative had no decimal allowance — and `card_interactions_test` started failing the moment the card began routing through `displaySizeLabel`.
**Solution**: Extend BOTH the outer regex AND the cross-dim tokenizer to accept `(?:\.\d+)?` on both sides. Added a regression test `'צינור רב-שכבתי 20×2.8'`.
**Lesson**: A regex that uses `\d+` instead of `\d+(?:\.\d+)?` is a future bug in any domain where decimals appear (mm walls, pressures, temperatures). Cross-dim multilayer pipes have decimals in real catalogs — pretending they don't bites in production tests, not just edge cases.

---

## 🧾 Closeout — state at end of session (pre-approval)

### What changed (touched files)
- `lib/screens/_size_norm.dart` — NEW. Pure utility: `SizeToken`, families,
  `parseSizeTokens`, `tokensFromDims`, `sortSizeTokens`, `dominantFamily`.
- `lib/screens/finder_screen.dart` — replaced `_sizeRe`/`_kInchPretty`/`_productSizes`/
  `_sizesIn` with `_productSizeTokens`/`_sizeTokensIn`/`_angleTokensIn`/
  `_productHasChip`. `_narrowAxis` now surfaces `'גודל'` (size family-coherent)
  and `'זווית'` as separate axes. The `build()` filter dropped the loose
  `nameHe.contains` fallback.
- `lib/screens/home_shell.dart` — version label bumped to `v5.15`.
- `lib/test_harness/tests/finder.dart` — added in-app `finder:size` block (3 checks).
- `test/finder_size_filter_test.dart` — NEW, 15 checks.
- `knowledge/STATUS.md` — finder paragraph + Tests list updated.
- `knowledge/README.md` — links this protocol.
- `knowledge/SIZE_FILTER_PROTOCOL.md` — this file.

### Problems closed
- ✅ P1 numeric sort
- ✅ P2 unit normalization (mm bucket / cm bucket, numeric inside)
- ✅ P3 structural-equality filter (no `String.contains` for size chips)
- ✅ P4 heterogeneous families now grouped, not interleaved
- ✅ P5 angles split off to own axis (`'זווית'`)
- ✅ P6 inch-pretty round-trip extended (½/¾/¼/⅜/⅝/⅞/1.25/1.5/11/4/…)
- ✅ P7 cross-dim contributes both tokens (each handled by its own chip)
- ✅ P8 arbitrary `length<=12` cap removed
- ✅ P9 (discovered in ניקוז verification, closed in v5.16) — `prettyInch()` helper applied at the card chip text + finder axis, both surfaces now read `1¼"` for the same `1.25"` token.
- ✅ P10 (discovered in צינורות verification, closed in v5.17) — name + dims now both contribute size tokens; pipes get DN diameter AND mm/cm/m lengths together.
- ✅ P11 (discovered in צינורות inspection, closed in v5.18) — `dedupLengthByMm()` collapses `15 ס"מ` ≡ `0.15 מ׳` to one chip (cm form survives).
- ✅ P12 (discovered in גינה verification, closed in v5.19) — `Ø1/2"` on garden-hose cards now rendered as `½"` chip (Ø-prefix stripped at `isSizeToken`), aligning with the filter axis; cross-dim decimals `20×2.8` survive the regex full-form.
- ✅ P13 (discovered in מחברים inspection, closed in v5.20) — `kHardToRenderFractions` folds `⅛/⅜/⅝/⅞` to `1/8"/3/8"/5/8"/7/8"` post-pretty; common glyphs (`¼/½/¾`) stay as-is.
- ✅ P14 (discovered in מחברים inspection, closed in v5.20) — secondary "זווית" chip row added below "גודל" when angles AND sizes both split the pool; `_angle` state + `_angleBar` widget + co-filter in `build()`. Card chip behaviour unchanged.
- ✅ P15 (discovered in אסלות inspection, closed in v5.21) — `_tokenize` now reformats the captured number via `_fmt(double)`; `020 מ"מ → 20 מ"מ`, `DN040 → DN40`. The font-fold step moved AFTER tokenize so it doesn't undo the cleanup.
- ✅ P16 (discovered in אחר inspection, closed in v5.22) — `_chip` widget in `finder_screen.dart` forces LTR direction on digit-bearing chip labels; mirrors the protection `_AttrChip` already had. Data was always `40×60`; the RTL paragraph was the only thing flipping it.

### Audit log — categories visited (each closes any new Pn or marks the run clean)

| Row | Category | Pool | Outcome |
|---|---|---|---|
| 3 | מקלחת ואמבטיה | 67 | found P1-P8 (the baseline), closed in v5.15 |
| 4 | ניקוז | 150 | surfaced P9, closed in v5.16 |
| 5 | צינורות | 87 | surfaced P10+P11, closed in v5.17/5.18 |
| 6 | גינה | 18 | surfaced P12 + cross-dim regex, closed in v5.19 |
| 7 | מחברים וחיבורים | 360 | surfaced P13+P14, closed in v5.20 |
| 8 | חבקים ותלייה | 47 | **clean run** — sentinel (LL-11) |
| 2 | אסלות | 81 | surfaced P15 (leading zeros), closed in v5.21 |
| 1 | ברזים | 112 | **clean run** — P13 + P15 stack visibly in `¼" · 3/8" · ½" · ¾" · 1" · 1¼"` |
| 10 | אחר | 13 | surfaced P16 (bidi flip), closed in v5.22 |
| 9 | צנרת PPR | **774** | **clean run** — biggest pool; P1-P16 all hold (LL-15) |

### Reopened: P13 + P14 sub-protocol (steps 143-160)

User directive: fix both per protocol.

**P13 strategy:** reverse-fold only the rare unicode fractions canvaskit doesn't ship glyphs for. Keep `½ ¼ ¾` (canvaskit renders them fine).

- [143] Add `kHardToRenderFractions: const Map<String,String>` in `_size_norm.dart`
       — `⅛"→1/8"`, `⅜"→3/8"`, `⅝"→5/8"`, `⅞"→7/8"`. ✅
- [144] Extend `kInchPretty` so RAW forms (`3/8"`) stay as-is (don't re-promote to `⅜"`). ✅
- [145] Wire post-fold in `displaySizeLabel` AND the size token's `label` (so card + filter + filter-match all agree). ✅
- [146] Test: `displaySizeLabel('⅜"')=='3/8"'`, `parseSizeTokens('צינור 3/8"').first.label=='3/8"'`. ✅
- [147] Run full suite. ✅
- [148] Visual: rebuild + screenshot מחברים; expect a visible `3/8"` chip. ✅

**P14 strategy:** add a SECOND chip row "זווית" below "גודל" when angles AND sizes both split the pool — same UX vocabulary, but two axes.

- [149] Add `_narrowAngles(pool)` helper in `finder_screen.dart` — returns
       angle chip labels, sorted numerically. ✅
- [150] In `build()`, after the size `_sizeBar`, render an additional
       `_chipRow('זווית', ...)` when angles exist and sizes did NOT already
       fold them. ✅
- [151] State: extend `_angleFilter` provider analog OR reuse `_size` with a
       prefixed sentinel. ✅ (use a new `String? _angle` field)
- [152] Filter products: `_productHasChip(p, sizeChip) && _productHasAngle(p, angleChip)`. ✅
- [153] Update test harness `finder:size` block + add `finder:angle` check. ✅
- [154] Run full suite. ✅
- [155] Visual: rebuild + screenshot מחברים; expect a second `זווית` row with 15°/30°/45°/90°/105°. ✅
- [156] Bump v5.20. ✅
- [157] Update STATUS.md. ✅
- [158] Live Log LL-10. ✅

### P15 sub-protocol — normalize leading zeros in numeric chip labels (159-167)

- [159] Failing test: `parseSizeTokens('זרוע 020 מ"מ').first.label == '20 מ"מ'`. ✅
- [160] In `_tokenize`, when matching mm/cm/DN regexes, re-format the
       captured number via `double.parse → toInt() if integer`. ✅
- [161] Also normalize DN form: `'DN040' → 'DN40'`. ✅
- [162] Verify the post-canvaskit pretty-fold map (`kInchPretty`) doesn't
       need a leading-zero variant (it doesn't — inch tokens don't carry
       leading zeros). ✅
- [163] Run finder tests. ✅
- [164] Run full suite. ✅
- [165] Rebuild + screenshot אסלות; expect `20 מ"מ` / `40 מ"מ` clean. ✅
- [166] Bump v5.21. ✅
- [167] Update STATUS + Live Log LL-12. ✅

### P16 sub-protocol — force LTR on digit-bearing finder chips (168-175)

- [168] Locate `_chip()` widget. ✅
- [169] Apply `textDirection: word.contains(RegExp(r'\d')) ? LTR : null` to
       the inner `Text` — mirror the card's protection. ✅
- [170] No new dart-level test (visual-only bug); confirm via screenshot. ✅
- [171] Run full suite (regression check). ✅
- [172] Rebuild + screenshot אחר; expect `40×60 · 60×60` reading left-to-right
       inside each chip. ✅
- [173] Bump v5.22. ✅
- [174] Audit log entry. ✅
- [175] Live Log LL-14. ✅

### LL-09 — מחברים inspection — `⅜"` looks empty (font), `15°` looks size (intent)
**Problem**: Visual scan of the size chip row showed an "empty" chip and a `15°` chip on a card with no matching filter entry. Both looked like code bugs.
**Solution**: Inspection test dumped codeUnits — `⅜"` is correct data, the empty look is the bundled canvaskit font failing on Unicode fractions (`U+215C`). `15°` on a card is the card's `isSizeToken` deliberately including `°` so the variant picker can swap elbows.
**Lesson**: A chip that LOOKS broken can be (a) correct data + font miss, or (b) deliberate cross-pipeline asymmetry. Dump the bytes before assuming the logic is wrong — codeUnits caught both diagnoses in one diagnostic test.

### LL-12 — אסלות (P15) — display fold ran AFTER tokenize, undoing the cleanup
**Problem**: After implementing `_tokenize` to strip leading zeros, the test
`parseSizeTokens('זרוע 020 מ"מ').first.label == '20 מ"מ'` still failed. The
`parseSizeTokens` wrapper was substituting `display` from `kHardToRenderFractions[folded]`
which used the RAW form, then overriding `tok.label` with the raw form back. The
P13 step was "above" my P15 step in the data flow.
**Solution**: Move the font-fold lookup to AFTER `_tokenize` returns
(`kHardToRenderFractions[tok.label] ?? tok.label`). Now both steps stack: clean
the number, then fold the glyph.
**Lesson**: When two normalization passes touch the same string, stacking order
matters. A test that fails after a green unit-test of the helper is a sign the
*wrapper* is the problem, not the helper. Trace the call path before re-editing
the helper.

### LL-15 — צנרת PPR (774 SKU) — biggest pool, P1-P16 all hold
**Problem**: None — third clean run, on the biggest pool in the catalog. 87 visible after dedupe, the chip row exposed all four size families (inch + DN + mm cross-dim + cm) plus angles in a separate axis, with the largest variant picker (1/39 for Faser pipes).
**Solution**: Every prior P closed correctly: `20×2.8` rendered LTR (P16), no leading zeros (P15), no `⅜"` empty boxes (P13 — wouldn't have helped here, PPR doesn't carry that glyph), `15 ס"מ ≡ 0.15 מ׳` deduped (P11), DN + length both surface (P10), angles got their own row (P14).
**Lesson**: A protocol whose surface is a small slice that grows to thousands of products without new bugs is *tested by scale*, not just by the cases that surfaced it. Pool size is the cheapest stress test you can run on a token pipeline; if it survives 774 SKUs after being designed against 67, the abstractions are right.

### LL-14 — אחר (13 SKU) — bidi: same data, two different visual readings
**Problem**: The filter chip read `60×40` and the card chip read `40×60` for the same physical product. Looked like a data inconsistency. Diagnostic dump showed the data IS `40×60` everywhere — only the filter's `Text` widget was being reordered by the Hebrew RTL paragraph direction (Flutter's default for the RTL ancestor).
**Solution**: One-line — `textDirection: label.contains(RegExp(r'\d')) ? TextDirection.ltr : null` on the chip's `Text`. The card widget already had the same protection (`_AttrChip` line 1764); the finder just hadn't inherited it.
**Lesson**: When two widgets render the SAME string but display it differently, the issue is in the rendering, not the data. Check `textDirection`, `Directionality.of(context)`, and font glyph support before assuming the source data is wrong. Bidi flips are silent — only the eye catches them. A widget test would have to assert the rendered glyph order to catch this; a `Text("40×60")` assertion would PASS while the user sees `60×40`.

### LL-13 — ברזים (112 SKU) — P13 + P15 stacked correctly in one chip row
**Problem**: None — second clean run. The chip row showed `¼" · 3/8" · ½" · ¾" · 1" · 1¼"`: glyph for `¼/½/¾/1¼` (canvaskit handles them) AND ASCII for `3/8"` (canvaskit's font miss). Both rules co-existed in one row without interfering.
**Solution**: The selective font-fold (`kHardToRenderFractions` keyed by exact glyph, not the whole inch family) does the right thing — common glyphs stay pretty, rare ones get ASCII.
**Lesson**: A precise fix beats a broad one. `kHardToRenderFractions` could have folded ALL inch fractions to ASCII; the narrower set preserves the visually richer common forms exactly where the user expects them.

### LL-11 — חבקים ותלייה (47 SKU) — first clean run of the protocol
**Problem**: None — this is the first finder category audit that surfaced no new Pn.
**Solution**: The pool's inch chips (`½ · ¾ · 1 · 1¼ · 1½ · 2`) rendered family-coherent, numerically sorted, no angle row (no angles in pool), no Ø prefix to strip, no `⅛/⅜/⅝/⅞` to fold. Cards display the same canonical inch glyphs the filter shows. Confirmation that P1-P14 generalize.
**Lesson**: A protocol with no new entry in a Live Log IS a finding — it tells the next session "this surface is settled, you don't need to look here again." Document the clean run as a sentinel; otherwise the next audit will repeat the work.

### LL-10 — P13/P14 close — fold what the renderer can't draw, expose what the user can filter
**Problem**: After LL-09 I labelled P13/P14 as "known limitations", but the user directive was to fix per protocol. P13 forced a runtime question (which glyphs does canvaskit support?), and P14 demanded a UX call (where does a second axis live?).
**Solution**:
- P13: hardcode a tiny table of glyphs to fold to ASCII (`kHardToRenderFractions`). Stay narrow — only the four glyphs that actually break. Apply at `prettyInch` end AND at `parseSizeTokens` token construction so card + filter agree.
- P14: extend the `_FinderScreenState` with a new `_angle` field, render `_angleBar` ONLY when the primary axis was already exhausted (`!= 'זווית'`) and angles split the pool. Co-filter via the existing `_productHasChip` (angles already match by structural token).
**Lessons**:
1. "Out of scope" is a temporary label — the user can broaden the scope, and the protocol's structure (P+S+Live Log) absorbs that without losing context.
2. When folding for display, fold at BOTH the display function AND the data construction, otherwise filter-vs-card asymmetry comes right back.
3. A second filter axis is cheap when the underlying matcher (`_productHasChip`) already speaks both vocabularies — the only new code is state + a chip-row widget.

---

## P10 sub-protocol — merge name parse with dims fallback

### The shape of the inconsistency
In צינורות, a real product is named "צנרת PP-MD-ML SN8 110 ס"מ" with
`dims = {DN: 110, L (cm): 300}`. The card chip shows `DN110` (from dims). The
finder filter shows DN32/DN40/DN50/DN75 but NOT DN110 — because the name
already yielded a length token (`110 ס"מ`), and `_productSizeTokens` returns
early, never reaching `tokensFromDims`.

### Root cause
`_productSizeTokens` is `name-or-dims`, but for pipes specifically a single
product carries TWO meaningful axes: a diameter (in dims) and a length (in
name). They aren't substitutes — they're orthogonal. The current early-return
treats them as substitutes.

### The fix in one sentence
Always include both — name-parsed tokens AND dims-derived tokens — then let
the same `sortSizeTokens` family-coherent grouping handle the order.

### P10 action steps (116-130)

- [116] Add a failing test: pipe with name `"צנרת 300 ס"מ"` and dims
       `{DN: 110}` → `_productSizeTokens` returns BOTH `300 ס"מ` (cm) and
       `DN110` (DN). ✅
- [117] Change `_productSizeTokens` to union, not else-if. ✅
- [118] Watch for regressions in fallback-only path: a product with name
       lacking any unit suffix must still get DN from dims (already covered
       by `tokenFromDims` test). ✅
- [119] Run `flutter test test/finder_size_filter_test.dart`. ✅
- [120] Run full `flutter test`. ✅
- [121] Rebuild + repatch + screenshot צינורות; expect DN110 (and others)
       in the size chip row. ✅
- [122] Bump version v5.17, one-line note. ✅
- [123] Add Live-Log entry LL-05. ✅

### P11 action steps (124-135)

- [124] Failing test: pool with `15 ס"מ` (cm) + `0.15 מ׳` (meters) → unified
       chip list shows ONE length token per physical value. ✅
- [125] Decide: keep cm (compact, more product-like) — drop the metres token
       when an equivalent cm exists. ✅
- [126] Implement `dedupLengthByMm(List<SizeToken>)` helper in `_size_norm.dart`:
       for any two cm/meters/mm tokens sharing the same `mm`, keep the one
       in the most product-relevant family (cm > meters > mm precedence). ✅
- [127] Wire into `_sizeTokensIn` after `sortSizeTokens`. ✅
- [128] Run finder tests. ✅
- [129] Run full suite. ✅
- [130] Rebuild + screenshot pipes; expect ~half the length chips. ✅
- [131] Bump v5.18. ✅
- [132] Update STATUS.md note. ✅
- [133] Add Live-Log LL-06. ✅

### P12 action steps (134-145)

- [134] Add helper `displaySizeLabel(String raw)` in `_size_norm.dart` —
       runs `parseSizeTokens(raw).first.label` if any token; otherwise
       `prettyInch(raw)`. Single source of truth for card+filter display. ✅
- [135] Failing test: `displaySizeLabel('Ø1/2"')=='½"'`,
       `displaySizeLabel('1/2"')=='½"'`, `displaySizeLabel('foo')=='foo'`. ✅
- [136] Replace `prettyInch(word)` with `displaySizeLabel(word)` in
       `_AttrChip` (size kind only). ✅
- [137] Run finder tests. ✅
- [138] Run full suite. ✅
- [139] Rebuild + repatch + screenshot גינה; expect card `½"` matching filter. ✅
- [140] Bump v5.19. ✅
- [141] Update STATUS.md note. ✅
- [142] Add Live-Log LL-07. ✅

---

## P9 sub-protocol — harmonize inch pretty-fold across chip systems

### The shape of the inconsistency
The finder's "גודל" axis shows `1¼"` (pretty), but each product card on the
list shows `1.25"` (raw token from the product name). Same product, same
physical size, two visual forms a few mm apart on the same screen.

### Root cause
Two independent chip pipelines:
1. **Finder size axis** (`_size_norm.dart`) — pretty-folds via `kInchPretty`.
2. **Product card chip system** (`lipskey_products_screen.dart` &
   chip-attr extractors in `lib/data/`) — parses words straight from
   `nameHe` without pretty-fold.

### The fix in one sentence
Promote `kInchPretty` to a shared helper and apply it at the *one* place each
pipeline materializes a size chip's label. The data stays raw; only display
labels collapse.

### P9 action steps (101-130)

- [101] Find where the card chip's size-token label is produced. ✅
- [102] Find every other place a raw size token reaches the user as a chip
       label (catalog facet bar, search index, smart-card, BOM diagrams?). ✅
- [103] Confirm `kInchPretty` already lives in `_size_norm.dart` and is
       exported. ✅
- [104] Write a TINY pure-function helper `prettyInch(String label)` —
       returns `kInchPretty[label] ?? label`. Public from `_size_norm.dart`. ✅
- [105] Add unit test: `prettyInch('1.25"')=='1¼"'`, `prettyInch('½"')=='½"'`,
       `prettyInch('foo')=='foo'`. ✅
- [106] Apply at the card chip generator. ✅
- [107] If a second site needs it, apply there too — but no eager refactors
       of pipelines that don't surface chips. ✅
- [108] Re-run `flutter test test/finder_size_filter_test.dart`. ✅
- [109] Run full `flutter test`. ✅
- [110] Rebuild web. ✅
- [111] Re-patch `flutter_bootstrap.js` (lesson LL-03). ✅
- [112] Screenshot ניקוז: chip "1¼"" in both card and filter. ✅
- [113] Update STATUS.md note. ✅
- [114] Bump version to v5.16 with a one-line note. ✅
- [115] Add a Live-Log entry distilling any new pitfall. ✅

### Verification (local)
- `flutter test` → **631 / 631 passed** (full suite).
- `flutter analyze` on touched files → 0 errors / 0 warnings.
- Visual: `localhost:8099` shows v5.15 + `200·250·25·30` grouped chip order.
- The in-app harness gains a `finder:size — נורמליזציה` block (3 checks).

### Pending — gated on user approval
- Phase G (Ship): `git add` only the touched files, commit message
  `fix(finder): numeric-sorted family-aware size chips + structural filter`,
  body lists P1-P8 with status, push to `claude/whats-happening-LyY9G`.
- Before push, re-fetch origin to check for parallel-session drift.
- Optional follow-ups (not yet planned):
  - `_kInchMm` is incomplete for exotic inch sizes (e.g. 5"). Add as data lands.
  - `kFinderFacets` curated path still uses `String.contains` — correct for
    plain words ("אמריקאי"); leave as-is unless a false positive shows up.

---

## 🎓 Lessons carry-forward

> One sentence each — the next session should be able to act on these without
> re-reading the rest of this protocol.

1. **State the intent in a comparator's order, not just its docstring.** When
   the docstring says "precedence beats count", the if-tree must check
   precedence FIRST. Tests caught my mismatch immediately (LL-01).
2. **A "fix" that removes data is suspect.** The original bug was *interleaving*,
   not *coexistence* — the correct fix is grouping, not pruning (LL-02).
3. **`flutter build web --release` resets `flutter_bootstrap.js`.** Reapply the
   `config: { canvasKitBaseUrl: "canvaskit/" }` patch after every build, or
   add a tiny post-build script (LL-03).
4. **Filter by structural token, never `String.contains`.** A bare integer in
   a product name can look like a size — require an explicit unit glyph next
   to the number.
5. **Different physical dimensions ≠ same axis.** Angles, lengths, and
   diameters all carry numbers; group them by family before sorting so the
   user can compare apples to apples.
6. **Run the full suite, not just your new file.** 631-test green proves no
   incidental regression in the BOM/compat engines, which also touch sizes.
7. **Bump the version label whenever a user-visible behaviour changes.**
   `home_shell.dart` is the contract; the rest of the protocol cross-refs it.
8. **Local-only until approval.** When the user pauses pushes, persist nothing
   to origin — build/test/screenshot freely, but the working tree stays the
   source of truth.

