# WIRING CONTRACT — app_flutter

What every interactive button / setting is expected to do, and its status.
**This contract is enforced by `test/wiring_test.dart`** (the wired-behavior rows
marked ✅ have an executable regression check). Keep this file and that test in
sync — if you change a behavior, update both.

Status legend: ✅ wired (real effect) · 🚧 בבנייה (placeholder toast) ·
⛔ blocked (needs price/rating/geo data, a server, or telephony that don't exist).

---

## Catalog settings (`catalog_settings_screen.dart` → `catalog_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| שמור היסטוריית חיפוש | gates recording recent searches; recents persist across launches via `recentSearchesProvider` (`addRecentSearch`, key `bs.recent-searches.v1`) | ✅ |
| סרגל מיון מהיר במוצרים | shows/hides the "מיון לפי" control | ✅ |
| גודל תמונות | product image size (small/med/large) — list rows (image column w/h) **and** grid cards (`gridCardImageMetrics`: image padding + emoji) | ✅ |
| מצב קומפקטי | product row height/margins (list) **and** grid card name-box/paddings | ✅ |
| הנפשות מופחתות | disables explode/diagram/pulse animations (app-wide) | ✅ |
| ניגודיות גבוהה | high-contrast theme (app-wide) | ✅ |
| גודל טקסט | global text scale (app-wide) | ✅ |
| סוג תצוגה (רשת/רשימה) | product grid ↔ list | ✅ |
| עמודות בתצוגת רשת | grid column count | ✅ |
| ניקוי היסטוריה / איפוס | clears recents / restores defaults | ✅ |
| מחירים/מע"מ/מטבע/מחיר-יחידה/השוואה | — | ⛔ no price data |
| דירוג/מרחק/ספקים מקומיים · AI×4 · יחידות/עשרוני · מיון-ברירת-מחדל · רדיוס | — | ⛔ no data/engine |

## Catalog search panel tools (`catalog_screen.dart` · `_SearchToolsRow`)

| Tool | Behavior | Status |
|---|---|---|
| 🎤 קולי | `VoiceService.listen` (browser speech) | ✅ |
| 📷 ברקוד | `openBarcodeScanner` | ✅ |
| ⚙️ פילטרים | sheet → `searchImageOnlyProvider`; live results filtered by `filterByImage` (הכל / עם תמונה בלבד) | ✅ |
| ↕️ מיון | sheet → `catalogProductSortProvider` (`_sortProducts`): ברירת מחדל / שם א-ת / שם ת-א / מק"ט, applied to live results | ✅ |
| ▦ קטלוג | closes the panel + jumps to the קטגוריות section | ✅ |
| filter "עם מחיר" / price sort | — | ⛔ no price data |

## Catalog search — product matching (`catalog_screen.dart` · `catalogProductMatchesQuery`)

| Behavior | Detail | Status |
|---|---|---|
| forgiving product search | matches across name + category + SKU + colour, word-by-word (order-independent); folds Hebrew gershayim/geresh (״ ׳ → " ') so a Hebrew-keyboard size query matches; expands everyday words via `kSearchSynonyms` (kept precise — e.g. שירותים → toilet fixtures only, not branch connectors); AND-match with a graceful any-word fallback (`requireAll:false`) so a reasonable query never dead-ends | ✅ |
| relevance ranking | default order sorts results by `searchRelevance` (name match > category-only > synonym/colour), so the product the user meant surfaces first; an explicit ↕️ sort overrides it | ✅ |

## Catalog בית — finder home (`finder_screen.dart`)

| Behavior | Detail | Status |
|---|---|---|
| default landing | `catalogSectionProvider` defaults to `'בית'` — the app opens straight on the finder home (`active=='בית' ⇒ FinderScreen`), the least-technical path to a product | ✅ |
| type groups | `kFinderGroups` — 8 plain-language groups + אחר catch-all; groups are pairwise disjoint and every catalog product is reachable. Each row shows `desc` (plain-Hebrew description) + a product-count badge, same idiom as the קטלוג category rows | ✅ |
| group glyph | `finderGroupGlyph(label)`: each home group circle (+ breadcrumb) renders a designer 3D product icon — `kFinderGroupImage` (label → `assets/lipskey/categories/{faucets,toilets,shower_bath,drainage,pipes,garden,connectors,clamps,ppr,other}.png`), with an `errorBuilder` fallback to a Material icon `kFinderGroupIcons`/`finderGroupIcon`. Replaces the empty-box emoji canvaskit's font can't draw. Guarded by `finder_group_icons_test` (every group mapped, images+icons unique). | ✅ |
| sub-types | curated `kFinderSubs` (ברזים · ניקוז) cover every group category that has products, with unique labels and no 1-item junk chips; other groups auto-derive sub-types from `categoryHe`, merged by cleaned label | ✅ |
| narrow chips | `_narrowOptions`: curated facets (`kFinderFacets` — incl. floor-drain open/closed/shower words instead of opaque DN codes) → sizes (`_sizeRe`; confusing inch forms folded to clean fractions, e.g. 11/4"·1.25" → 1¼") → colours → distinguishing words | ✅ |
| results | render through the shared `LipskeyProductsList` (variant dedup + quantity wheel) | ✅ |
| chip-row scroll hint | `_ChipScroll` wraps every narrow chip row (סוג/גודל/זווית): when chips overflow, a soft edge-fade + ‹ chevron (`Key('chip-scroll-more')`) appears on the END edge (left in RTL) and hides once scrolled to the end / when nothing overflows — so clipped chips are discoverable | ✅ |
| letter-size axis | `_letterBar`/`_letterOptions` + `letterSizeTokens` (`_size_norm.dart`): a secondary `'מידה'` chip row (S/M/L…) appears when a pool has >1 letter sizes (e.g. clamp collars `אוגן כפול M`/`S`), co-filtering with גודל + זווית. Excludes the `L=` length prefix (gray pipe `L=50 ס"מ` is not a size). State `_letter`, reset on group/sub/back nav. | ✅ |
| wall-thickness axis | `_wallBar`/`_wallOptions` + `wallTokens` (`_size_norm.dart`): a secondary `'עובי'` chip row appears when a cross-dim pool has >1 distinct wall (`20×2.8` vs `40×5.5`). PPR/multilayer pipes ship the SAME OD at different walls (PN ratings — verified: 9/13 ODs have ≥2 walls), so wall narrows beyond the גודל (OD) axis. Co-filters with size/angle/letter. State `_wall`, reset on nav. | ✅ |
| chip display contract | one shared path keeps the filter chip and the product-card chip identical: `displaySizeLabel` (label text — P9/P12/P13) + `chipLabelDirection` (LTR for digit labels so `40×60` doesn't RTL-flip — P16). Drift is guarded by `finder_card_consistency_test` (finder chip set ⊆ card chip set over the whole catalog). | ✅ |
| group-emoji glyph fallback | sites that showed a finder group emoji (🚰🚽🕳️ — empty box in canvaskit) now render an icon instead: product-sheet "נמצא ב" strip uses `Icons.travel_explore` (`_StripDef.icon`), and the catalog overview "מאתר" row drops the emoji (label only). Home circles already use `finderGroupGlyph` (I1). | ✅ |
| code hygiene (I10-partial) | `dart fix` sweep on `finder_screen.dart` + `_size_norm.dart` (44 mechanical fixes: trailing commas, redundant args, combinators ordering, unnecessary raw strings, omitted local types). Both files lint-clean. No user-visible behavior change. | ✅ |

## Chat settings (`chat_settings_screen.dart` → `chat_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| בוט (botEnabled) | enables the canned auto-reply | ✅ |
| חיווי הקלדה | shows "מקליד..." before a bot reply | ✅ |
| אישורי קריאה | sent ticks blue ✓✓ vs grey ✓ | ✅ |
| רטט (chatVibration) | haptic on send | ✅ |
| ברכת פתיחה | seeds a greeting in a fresh chat | ✅ |
| זמן מקוון אחרון (lastSeenPrivacy) | nobody → hides "פעיל כעת" + online dot (`showOnlinePresence`) | ✅ |
| מדיה/גיבוי/שפה/שעות-עסקיות/פרטיות/lock-preview/auto-archive/spam | — | ⛔ media/server |

## Chats screen (`chats_screen.dart`)

| Button | Behavior | Status |
|---|---|---|
| חיפוש / פילטר צ'יפים | filter thread list | ✅ |
| לחיצה על שיחה | opens conversation | ✅ |
| החלקה לארכוב + ביטול | archive/restore (persistent) | ✅ |
| תפריט ⋮ → שיחה חדשה | opens an empty conversation with the contact | ✅ |
| תפריט ⋮ → ארכיון שיחות | opens the archive screen (restore per row) | ✅ |
| תפריט ⋮ → השתק הכל / בטל | mutes/unmutes all threads (persistent, toggles label) | ✅ |
| תפריט ⋮ → הגדרות | opens ChatSettingsScreen | ✅ |
| שליחת הודעה | adds bubble (+ auto-reply if bot on) | ✅ |
| וידאו/שיחה/עוד · מצלמה/צירוף/אמוג'י/מיקרופון | — | 🚧 |

## Notifications (`notifications_screen.dart` → `notif_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| סוגי התראות: הזמנות/משלוחים/מבצעים/ירידות-מחיר | hide that category from the list (`notifMutedSections`) | ✅ |
| חשיבות (importanceFilter) | important/critical → only high-priority rows (`passesImportance`) | ✅ |
| snooze banner | mutes notifications temporarily | ✅ |
| push/email/sms/whatsapp · שעות-שקט · סיכומים · צליל/רטט · lock-screen · לפי-תפקיד | — | ⛔ no notif engine |

## Store (`store_screen.dart` → `store_settings.dart`)

| Setting / button | Behavior | Status |
|---|---|---|
| defaultPayment | seeds the cart payment method | ✅ |
| selfPickupDefault | seeds delivery = pickup | ✅ |
| vatInclusive | VAT shown embedded vs added; total adjusts | ✅ |
| minOrderAmount | blocks checkout below the minimum | ✅ |
| confirmLargeOrder + largeOrderThreshold | confirm dialog at checkout | ✅ |
| cart stepper (+ / − / לעגלה) | `qtyForKey` / `setQtyForKey` | ✅ |
| saveCartToProject | show/hide the cart project selector | ✅ |
| summary chips (פריטים בסל / הזמנות פתוחות / הצעות ספקים) | derived live: `cartItemCount` (cart+smart lines), `isOrderOpen` over `_kOrders`, offers single-sourced from the מכרז ספקים row badge | ✅ |
| כתובות/חשבוניות/ספקים/השכרה/אחריות/ביומטרי/אשראי-יומי | — | ⛔ server/data |

## Install Studio (`install_studio_screen.dart` → `logic/install_engine.dart`)

Entry: the catalog section chip **`'תכנון חיבור'`** (renamed from "תאימות" — a
self-explanatory name for non-technical users). Safety-checklist labels carry a
plain-Hebrew gloss with the technical term in parens (e.g. "ברז ערבוב נגד כוויה (TMTV)").

| Button | Behavior | Status |
|---|---|---|
| הוסף מוצר | append a chain anchor from the dark catalog picker | ✅ |
| **השלם התקנה** | linear `buildInstallation`, or `buildTreeInstallation` when a manifold is mid-chain (trunk → branches); dark BOM sheet with quantities, ⑂ branch count + outlet warning, gaps; "החל על הקו" applies it | ✅ |
| מטראז׳ צינור (− / +) | per-pipe length in metres; header totals "X מ׳ צנרת" | ✅ |
| טמפ׳ הקו | cycles 20/60/80°C (material suitability) | ✅ |

---

## Verified by regression (`test/wiring_test.dart`)
- cart `qtyForKey` / `setQtyForKey` (sum, collapse, remove-at-0)
- store `cartPaymentProvider` / `cartDeliveryProvider` defaults from store settings
- `notifMutedSections` mapping (all-on → none; per-type off → matching section)
- chat mute notifier (`setAll`) and archive notifier (`archive`/`restore`)
- finder grouping: groups disjoint, אחר catch-all + no blank category, curated
  `kFinderSubs` cover every group category w/ products, unique labels, cats ⊆ group
- `catalogProductMatchesQuery`: category-word match, synonym expansion,
  `requireAll:false` graceful superset, colour searchable, שירותים precision
  (no connector match), `searchRelevance` ranks name-match above synonym-match

UI-only effects (theme/contrast/text-scale, grid layout, VAT display, image size)
are documented above but exercised through their underlying providers/helpers

---

## Dead code removed (step 9)

Symbols removed from `catalog_screen.dart` — never had callers, no visual impact:

| Symbol | Lines removed | Phase |
|--------|--------------|-------|
| `_MiniSearchPill` | ~22 | B ✅ |
| `_Chip` | ~37 | C ✅ |
| `_diameterSubGroups` + `_diameterCounts` + `_diameterBucket` + `scrollCtrl`/`subGroups` params + `_SectionBanner` | ~54 | D ✅ |
| `_CatalogDrillSection` cluster (P4+P5+P6+P7) | ~353 | E ✅ |

Total removed: ~466 lines. Kept: `catalogDrillCatProvider` (line 237) — used in smoke test `tabs.dart`.
rather than pixel rendering.

## Polyroll catalog spec routing (§22)
- `lib/data/polyroll_catalog.dart` `_pprSpecFor(categoryHe, nameHe, page)` returns
  the correct per-page or per-sub-type spec for each product. See
  `knowledge/CATALOG-CARD-PROTOCOL.md` §22.C/D/E/F for the full ruleset.
- p80 AQUATHERM AC blue pipes: kPprPipesAC → `spec_pprct_pipe.jpg` (was
  routing to `spec_faser_20.jpg` green by mistake; fixed in §22.F sweep).
- **§22.I — internal-card dims completeness:** `_acPipe` builder now injects
  `'מק"ט חוליות': sku` into its dims map (was missing for all 16 AC pipes,
  thinning the internal card vs. the catalog). Guard: spec_assets_test
  "§22.I every Polyroll product carries יצרן + at least one מק"ט" — sweeps
  the whole catalog, fails on any builder that skips the standard dim fields.
  mutation-verified by `scripts/mutation_verify.sh` (the protocolist's tool).
- §14 detection: `test/spec_assets_test.dart` enforces 36 routing rules
  including "every page lands on its own per-page crop or a legit shared one".
- All 74 catalog pages audited per §22.F mandatory audit checklist.

## External-card chip hierarchy (§21)
- `chip_hierarchy.dart` `parseChips(nameHe)` → breadcrumb [shape ‹ thread ‹ size];
  the title is the type noun. Angles (45°/90°) are shape, the diameter is the
  size — a digit-leading angle no longer steals the size slot.
- `lipskey_products_screen.dart` `_HierarchyChips`: display-only cleanup —
  `_chipDisplayLabel` strips wrapping parens, `_isNoiseChip` hides bare units
  (מ"מ). nameHe stays verbatim (R8); tap index maps back to the raw path level.
- §14: `spec_assets_test` · "§21 angle fittings keep the diameter as size".

## §21.A chip fixes (2026-06-01)
- Angle elbows keep diameter as size (sizeRe skips shape tokens); bare 45/90
  removed from shape set. Display: parens stripped, units (מ"מ) hidden.
- Multi-word phrase "למיקום נקודת מים" kept as one ordered chip (_l3Compounds).
- Guards: spec_assets_test "§21 angle fittings keep the diameter as size" +
  "§21 multi-word phrase stays one ordered chip".

## §21.B unit-fold — lossless recoverability (2026-06-01)
- `chip_hierarchy.dart` `_kChipUnits {מ"מ, mm}` + a parseChips branch fold the
  unit INTO the size chip (`l5 = '$l5 $t'`), so the size reads "20-63 מ"מ" and
  the full Polyroll name is recoverable from [type]+breadcrumb+material badge.
  'מ"מ' removed from kChipLevel3Feature (was being hidden as noise → dropped).
- Guard: spec_assets_test "§21.B every Polyroll name is fully recoverable from
  the chips" — behavioral, scoped to kPolyrollCatalog (no grep antipattern: מ"מ
  is a legit standalone token in lipskey_catalog, so a source grep can't tell
  the wrong placement from the right one). E2E result: 774/774 full recon.

## §21.C chip + picker level labels — primary/secondary/final clarity (2026-06-01)
- User: "אני נכנס לבורר בציפ אני לא יודע מה הוא בורר ראשי ומה משני ומה אחרון
  זה בבלגן." Chips were identical-looking pills, picker said "בחר ערך" generic.
- `chip_hierarchy.dart` `ChipPath.levelLabelOf(int) → String` maps a path index
  to one of {חיבור, צורה, תכונה, תבריג, מידה}. Two consumers:
  - `lipskey_products_screen.dart` `_HierarchyChips` — stacks each chip in a
    Column: 9pt grey level label on top + value pill below. RTL → "חיבור" reads
    first (primary), "מידה" last (final).
  - `lipskey_products_screen.dart` `_hierarchyPickerTitle` — picker header now
    reads "בחר חיבור:" / "בחר צורה:" / "בחר תכונה:" / "בחר תבריג:" / "בחר מידה:".
- Guard: spec_assets_test "§21.C every visible chip carries a semantic level
  label" — sweeps kPolyrollCatalog, asserts every non-noise chip gets one of
  the 5 allowed labels and the size chip always reads "מידה".
## Catalog lens selector (v5.44 — data layer)
- `lib/data/catalog_lens.dart` — `CatalogLens {category,variant,smartTree}`,
  `availableLensesForSet(products)` (which lenses are meaningful for a set;
  smart-tree hidden below 25% mapped — approach א), `groupByLens(products,lens)`
  (titled `LensGroup` buckets per axis), `setSupportsLens`.
- `lib/state/catalog_lens_state.dart` — `catalogLensProvider` (transient
  StateProvider, default category) + `resolveActiveLens(selected, available)`
  (falls back to first-available; never strands on an unavailable lens).
- Wiring status: data layer ONLY. The selector chips + list router (which read
  `catalogLensProvider` and render `groupByLens` output beside the existing
  grid/list + sort controls) are the NEXT step — not yet wired into
  `catalog_screen.dart`. Guard: `catalog_lens_test` (18 tests).

## Lens selector UI — step 3a (v5.46)
- `lib/screens/lens_selector_row.dart` — `LensSelectorRow(products:)` ConsumerWidget:
  a list-level chip row ("סדר לפי: 📂/🎚/🌳") that reads/writes `catalogLensProvider`
  and shows only the lenses `availableLensesForSet(products)` deems meaningful.
  Renders nothing when <2 lenses apply (category-only sets unchanged).
- Wiring status: widget BUILT + tested (`lens_selector_row_test`, 3 widget tests),
  NOT yet placed in a product-list screen. Placement into the product browse view
  (where `groupByLens` output renders) is step 3b.

## Lens selector — step 3b WIRED (v5.47)
- `LipskeyProductsList` (lib/screens/lipskey_products_screen.dart) now renders
  `LensSelectorRow` ABOVE the product list. Default lens = category → the
  original flat grid/list, unchanged. variant/smartTree → `_groupedList` renders
  `groupByLens` output: a `_LensGroupHeader` (title + count) per group, products
  as standard rows. The selector hides itself when <2 lenses apply.
- This is the user-visible activation of the lens feature (steps 1+2+3a).

## Lens selector — option א: smart-tree group = gateway (v5.48)
- Under the 🌳 smart-tree lens, each `_LensGroupHeader` in `lipskey_products_screen.dart`
  is now TAPPABLE → `openSmartProductSheet(context, smartProductForSku(first.sku))`,
  opening the rich SmartProduct card (install/compat/brands/BOM). Header shows a
  🌳 prefix + "פתח כרטיס ›" hint + Semantics(button). Category/variant headers
  stay non-tappable. Imports via `show` (openSmartProductSheet, smartProductForSku)
  to avoid circular-import symbol pollution.

## Lens selector — option א refined: per-row "כרטיס חכם" (v5.49)
- Under 🌳 smart-tree lens, each `_ProductRow` shows "כרטיס חכם" (was "פרטים")
  → `_openSheet` opens the rich SmartProduct card via openSmartProductSheet/
  smartProductForSku for THAT product's fixture (not a group-level gateway).
  Falls back to the standard Lipskey sheet when unmapped. `_LensGroupHeader`
  reverted to a plain label (🌳 prefix cue only, not tappable).

## cardReadinessScore — raised bar (v5.53)
- `related_info.dart::cardReadinessScore` expanded 5→9 dimensions so 100 reflects
  FULL smart-card readiness (spec+25 · connectivity+20 · ת"י+12 · install+13 ·
  acceptance+5 · compliance+5 · finder+5 · price+5 · variants+10). A spec'd
  connectable PPR fitting now reaches ~95 (was 90); fixture endpoints stay low.
  Guards: card_score_test (raised-bar group) + mutation_log.

## Score badge on internal card (v5.56)
- `lipskey_product_sheet.dart` header now renders the `cardReadinessScore` badge
  ("📊 ציון נתונים N · label", `scoreBandColors`) — same metric the smart card
  shows. Closes the gap: PPR/Lipskey products that open the INTERNAL card (not
  the smart card) now display their data-readiness score (PPR ~95).

## cardReadinessScore — quantity-aware (v5.57)
- `related_info.dart::cardReadinessScore` now grades by AMOUNT of knowledge, not
  binary presence (user: "לא תתסתכל על הכמות ידע שיש לו"). New/regraded terms:
  data-depth `p.dims.length` (≥8→15 · 4-7→10 · 1-3→5); connectivity (≥20→18 ·
  ≥5→12 · >0→6); install-tips / acceptance / compliance graded by item count;
  spec 25→20, finder 5→3, price 5→2. Effect: the PPR faser pipe (dims=11, richest
  but 0 mates) rises ~75→80 מצוין instead of being pinned by connectivity.
  Verified live-equivalent: PPR supply 98 · faser 80 · toilet seat 16 · trap 63.
  Guards: card_score_test (spec-weight 25→20) + mutation_log (dims `:0`→`:50`
  turns the seat "stays low" + "no single dim=100" guards red).

## cardReadinessScore — composite breadth+depth (v5.58)
- `related_info.dart::cardReadinessScore` now returns a COMPOSITE of two axes
  (user: "ציון משוכלל משני הצירים"), each ≤50, and exposes both sub-scores in
  the return record `({score, label, breadth, depth})`:
  • BREADTH — weighted presence of distinct knowledge KINDS (variety).
  • DEPTH — graded QUANTITY within the measurable kinds (dims/mates/tips/…).
  composite = breadth + depth (cap 100). Broad-but-shallow or deep-but-narrow
  products land mid-band; only broad AND deep reach מצוין. Callers
  (`lipskey_product_sheet.dart`, `catalog_screen.dart`) keep using `.score`/
  `.label` (named access — extra record fields are non-breaking).
  Verified: PPR supply 99 (b49/d50) · faser 75 (b41/d34) · seat 15 (b11/d4).
  Guards: card_score_test (spec→breadth≥10; composite==breadth+depth) +
  polyroll_score_test (pre-spec baseline ≤50) + mutation_log.

## Huliot SmartLock catalog ingestion (v5.59-60 — 2026-06-01)

### Catalog tree leaves (sml.*)
| Leaf id | Title | Category (kSml*) | Products | Pages |
|---|---|---|---|---|
| `sml.pipes` | צינור חלק | `kSmlPipes` | 7 | 11 |
| `sml.cutters` | חותך צינורות | `kSmlCutters` | 2 | 11 |
| `sml.joker` | מתאם זווית - ג'וקר | `kSmlJoker` | 3 | 11 |
| `sml.elbow_oneside` | ברכיים צד אחד חלק | `kSmlElbowOneSide` | 8 | 12 |
| `sml.elbow` | ברכיים | `kSmlElbow` | 7 | 13 |
| `sml.elbow_reducing` | ברך מצרה | `kSmlElbowReducing` | 5 | 13-14 |
| `sml.elbow_telescopic` | ברך טלסקופית | `kSmlElbowTelescopic` | 4 | 15 |
| `sml.tees` | מסעפים | `kSmlTee` | 11 | 16-17 |
| `sml.double_coupling` | מצמד כפול | `kSmlDoubleCoupling` | 4 | 18 |
| `sml.reducer` | מצרה | `kSmlReducer` | 5 | 18, 25 |
| `sml.gutters` | מאספים | `kSmlGutters` | 8 | 19-20 |
| `sml.drains` | מחסומים | `kSmlFloorDrains` | 7 | 21-23 |
| `sml.accessories` | אביזרים משלימים | `kSmlAccessories` | 46 | 24, 39-43 |
| `sml.nuts` | אום SmartLock | `kSmlNuts` | 5 | 25 |
| `sml.aquaslim` | מאסף קווי AQUA SLIM | `kSmlAquaSlim` | 10 | 27 |
| `sml.covers` | מכסים, הגבהות ורשתות | `kSmlCovers` | 20 | 28-30 |
| `sml.siphons` | סיפונים | `kSmlSiphons` | 18 | 31-38 |
| **TOTAL** | | | **170** | **11-43 (excl. 26)** |

### Guards
- `test/spec_assets_test.dart`:
  - `§22.I-Huliot every product carries יצרן + מק"ט` (170 SKUs)
  - `§22-Huliot every product asset resolves to assets/huliot_smartlock/`
  - `§22-Huliot every Huliot page asset exists on disk` (170 × N pages)
  - `§21.B-Huliot every product name renders verbatim (no empty words)`
  - `§22-Huliot every numeric token in name is grounded in dims`
  - `§22-Huliot paranoid 12-check audit — cross-product consistency`
- `test/ppr_infra_test.dart`: `kCatalogProducts.length == Lipskey + Polyroll + Huliot`
- `knowledge/mutation_log.md`: `_sl` (factory) + `_brandDir` (path mapping) verified.

### File map
- **Data:** `lib/data/huliot_smartlock_catalog.dart` (170 products, factory `_sl`).
- **Brand:** `lib/data/brands.dart` Brand(id='huliot', name='חוליות', emoji='🟢').
- **Tree:** `lib/data/catalog_tree.dart` root `sml` + 17 leaves.
- **Path mapping:** `lib/data/lipskey_catalog.dart` `_brandDir(brand)` static.
- **Unified registry:** `lib/data/polyroll_catalog.dart` `kCatalogProducts +=
  kHuliotCatalog`.
- **Sheet content:** `lib/screens/lipskey_product_sheet.dart` `_buildInfoHuliot()`
  — page 5-6 advantages + page 4 standards + page 8-9 install verbatim.
- **Brand emoji:** `lib/screens/lipskey_products_screen.dart:1187-1192` —
  '🟢 חוליות' (was '🏭 ${brand}' fallback).
- **Assets:** `assets/huliot_smartlock/pages/page_01-44.jpg` (3.5MB).

### Detail

- New file: `lib/data/huliot_smartlock_catalog.dart` — 170 products from the
  Huliot SmartLock™ HE catalog PDF (44 pages, REV 001 / 02.2026). PP drainage
  system, 32-63mm, ratchet-tooth locking, TPE elastomer pressure seal.
  Standards: ת"י 958-1, 71253-1, 71253-2, 5694, 14020.
- 17 verbatim TOC families: `kSmlPipes`/`kSmlCutters`/`kSmlJoker`/
  `kSmlElbowOneSide`/`kSmlElbow`/`kSmlElbowReducing`/`kSmlElbowTelescopic`/
  `kSmlTee`/`kSmlDoubleCoupling`/`kSmlReducer`/`kSmlGutters`/`kSmlFloorDrains`/
  `kSmlAccessories`/`kSmlNuts`/`kSmlAquaSlim`/`kSmlCovers`/`kSmlSiphons`.
- Factory `_sl` auto-injects `יצרן='חוליות'` + `מק"ט חוליות'=sku` into every
  product's dims — §22.I (internal card completeness) is satisfied by
  construction (guarded by a new spec_assets_test §22.I-Huliot test).
- Wired into `kCatalogProducts` (polyroll_catalog.dart) — now Lipskey 935 +
  Polyroll 774 + Huliot 170 = **1,879 products**.
- Brand `'חוליות'` added to `lib/data/brands.dart` (id `huliot`, green 🟢).
- Catalog tree: `lib/data/catalog_tree.dart` `'sml'` root + 17 leaf nodes
  (`sml.pipes` → `sml.siphons`), each `brandIds: ['huliot']` +
  `lipskeyCategory: <kSml*>`. Reachable from the catalog drill-down.
- `lib/data/lipskey_catalog.dart` `_brandDir(brand)` helper now resolves
  Huliot to `assets/huliot_smartlock/` (was hardcoded `polyroll|lipskey`).
- Image fallback: `_huliotImageFor` returns null → flip side lands on the
  full catalog page (`assets/huliot_smartlock/pages/page_NN.jpg`). Per-family
  crops will go here as they're cut from the PDF (protocol §17).
- 44 pages extracted via `pdftoppm` to `assets/huliot_smartlock/pages/` +
  `pubspec.yaml` asset entry added.

## cardReadinessScore — row-level chip in search results (v5.59)
- `catalog_screen.dart::_SearchResultsList` product `ListTile` now shows the
  composite `cardReadinessScore` as a band-coloured `📊 N` chip in `trailing`
  (above the "מוצר" tag), via `cardReadinessScore`/`scoreBandColors` (already
  imported). Makes the score visible at a glance in the catalog search list —
  no need to open the card overlay. Verified live: PPR אספקה → 📊 99 (🟢);
  מושב אסלה → 📊 15 (🔴). Pure display; the score engine (v5.58) is unchanged.

## Huliot SmartLock → smart-tree wiring, batch 1: drainage fixtures (v5.62)
- `smart_tree.dart`: added 17 Huliot SmartLock SKUs as `SmartBrand` options to 4
  existing drainage-fixture cards (so they become mapped via `smartProductForSku`
  and reachable under the 🌳 smart-tree lens / "כרטיס חכם" button):
  - `floorDrain` (מחסום רצפה) +7 — 70124599 · 70124590 · 70114500 · 70114590 ·
    70145960 · 70117500 · 70117560
  - `basinTrap` (סיפון לכיור רחצה) +3 — 61230060 · 63466055 · 61233360
  - `kitchenDrain` (סיפון לכיור מטבח) +4 — 61450060 · 61550060 · 61350060 · 61650060
  - `washingMachineDrain` (סיפון למכונת כביסה) +3 — 61480100 · 61230065 · 62850060
- Effect: smart-tree mapped coverage 293 → **310** SKUs. Huliot floor-drains &
  siphons now show a כרטיס-חכם instead of falling back to the plain sheet.
- Guards: `smartproduct_contract_test` — new "Huliot … wired into the smart-tree"
  test (4 cards carry a Huliot brand; spot-check sku→card; ≥17 mapped) + the
  existing "every SmartBrand.sku is a real catalog SKU" + bridge round-trip.
  Mutation-verified (a broken Huliot sku fails both). Pure data; no engine change.
- REMAINING (next batches): American-sink siphons (62230060/62450060/62550060/
  62650060/62750060 + 61233172/63350060/61100062) → visibleTrap/otherTraps;
  pipes/elbows/tees/couplings → pvcPipe/drainageElbow/drainageFittings;
  gutters/covers/aquaslim → floorCollector/drainageManifold/floorCover.

## Huliot SmartLock → smart-tree wiring, batch 2: PP piping + remaining siphons (v5.63)
- `smart_tree.dart`: +62 Huliot SmartLock SKUs as `SmartBrand` options on 4 more
  drainage cards:
  - `pvcPipe` (צינור ניקוז) +7 — צינור חלק 32/40/50/63 (3-4 מ')
  - `drainageElbow` (ברכיים) +27 — ג'וקר ×3 · צד-אחד ×8 · 45°/90° ×7 · מצרה ×5 · טלסקופית ×4
  - `drainageFittings` (מחברים/מצמדים) +20 — מסעפים ×11 · מצמד כפול ×4 · מצרה ×5
  - `visibleTrap` (מחסום גלוי) +8 — סיפוני כיור-אמריקאי ×5 · ללא-סיפון · הורקה · אמבט
- Effect: smart-tree mapped coverage 310 → **372** SKUs; Huliot **79/170** mapped.
  Together with batch 1, all of Huliot's drainage *fixtures* + *piping* now open a
  כרטיס-חכם as a brand option.
- Guards: `smartproduct_contract_test` Huliot test extended to all 8 cards + sku→card
  spot-checks + ≥79 mapped. Mutation-verified (broken sku fails it + the catalog-SKU
  contract). Pure data; no engine change.
- REMAINING (batch 3): מאספים/AQUA SLIM → floorCollector/drainageManifold; מכסים
  → floorCover; אום/חותך/אביזרים משלימים (mostly SmartAcc, not brands).
