# MASTER_PROTOCOL — פרוטוקול אב מאוחד (BuildSmart Flutter)

> מאחד בלעדי מ: README · PLAYBOOK · CATALOG-CARD-PROTOCOL · SMARTPRODUCT_ROADMAP ·
> STATUS · SCHEMA · STATE_OVERVIEW · TESTS_OVERVIEW · HELPER_INDEX · CARD_FLOW · AGENT_PATTERNS.
> גרסה: **v5.29**. עדכן בכל פעם שאחד מהמקורות משתנה.

---

# חלק א — כללי-בנייה (README)

## 6 הכללים — כל שינוי עובר דרכם

1. **מצא לפני שאתה כותב.** אין feature/string/התנהגות שאינה מגובה בקוד קיים (R8).
2. **לוגיקה = helper טהור + unit test.** math, filters, mappings, thresholds — מחוצנים לפונקציות top-level כדי שניתן לבדוק אותן. ראה: `cartVat`, `notifPasses`, `indexableWord`.
3. **Wire → WIRING.md → test.** כל setting/button שמחובר לeffect אמיתי: (א) רשום ב-`WIRING.md` עם status, (ב) מכוסה ב-`gaps_test.dart`/`wiring_test.dart`. Contract + tests = תמיד מסונכרנים.
4. **לפני כל commit:**
   ```bash
   export PATH="/home/user/flutter/bin:$PATH"
   cd app_flutter
   flutter analyze        # 0 errors
   flutter test           # all green
   flutter build web --release
   ```
5. **Mutation-test לכל helper חדש.** הזרק bug, אמת שtest נכשל, בטל. יעד: 100% domain logic caught.
6. **Commit קטן. Push = אישור מפורש בלבד.** ענף: `claude/whats-happening-LyY9G`. Bump גרסה ב-`home_shell.dart` על כל שינוי גלוי.

## אכיפה (`knowledge_protocol_test`)

Suite נכשל אוטומטית אם:
- dark surface חוזרת (`0xFF111111`, `BsTokens.bgDark`, ColoredBox עם אותו ערך)
- helper ציבורי מחווט נמחק/שונה שם (`cartVat`, `notifPasses`, `qtyForKey`...)
- `WIRING.md` סוטה מהקוד

---

# חלק ב — מצב עבודה ו-Push Policy (PLAYBOOK)

## NO STOPPING — אבל NO PUSH ללא אישור

- בנה / בדוק / commit מקומי — **בחופשיות**, ללא עצירה.
- צעד שנראה "חסום" → נסה עשרות גישות: stubs, mock data, heuristics, workarounds.
- קיר אמיתי = בלתי-עביר לחלוטין (שרת חי, חומרה, third-party בתשלום). תעד + המשך.
- **Push רק כש-"תדחוף" / "push" / "approved".** checkpoint נקי = הצע, לא בצע.

## Cadence

| פעולה | תדירות |
|---|---|
| `flutter test` מלא | כל ~5 steps |
| Local commit | כל ~20 operations (אחרי 0/0 נקי) |
| Live demo (port 8090) | כל ~10 operations |

## Push דחוי על קבצי-קטלוג

אין push אחרי כל קו קטן — **צוברים ≥100 מוצרים** ואז push יחיד עם summary commit.

---

# חלק ג — Git על ענף מהיר (PLAYBOOK §B)

## Clean push כשהענף זז תחתיך

```bash
# 1. commit קוד פיצ׳ר בלבד (ללא bump גרסה)
# 2. בדוק חפיפה:
git fetch
comm -12 <(git diff --name-only $BASE @{u}|sort) <(git diff --name-only $BASE HEAD|sort)
# 3. rebase:
git -c core.editor=true rebase origin/claude/whats-happening-LyY9G
# 4. bump גרסה — commit נפרד אחרי rebase
# 5. push → אמת: git rev-list --left-right --count HEAD...@{u} → 0 0
```

## כשהחפיפה היחידה = שורת גרסה

```bash
git diff $BASE @{u} -- home_shell.dart   # ← אמת שרק גרסה
git -c core.editor=true rebase -X theirs origin/claude/whats-happening-LyY9G
# ואז: flutter analyze + flutter test לפני push
```

`-X theirs` = "העדף commits שמשוחזרים (שלי)". **אל תשתמש עם overlap של לוגיקה.**

## `home_shell.dart` + `STATUS.md` = תמיד זהים

`knowledge_protocol_test` נכשל אם drift. bump שניהם באותו commit.

## כשה-session האחר מגרה data layer

```bash
git diff <base> origin/<branch> -- <shared-file>
```
ואז יישר לרשימה הקנונית: **`kCatalogProducts = [...kLipskeyCatalog, ...kPolyrollCatalog]`**.

---

# חלק ד — Dart / Test Pitfalls (PLAYBOOK §C)

| בעיה | תיקון |
|---|---|
| `Set == {literal}` תמיד false | `s.length == 1 && s.contains(x)` |
| `_tests.dart` (plural) = דלוג שקט | תמיד `_test.dart` singular; אמת שcount עלה |
| Mutation test גוטה על `count > 0` | invariant בלבד — vacuously true על ריק |
| `grep -c` exits 1 על 0 תוצאות | `grep -c X file \|\| true` |
| Stale assertions אחרי refactor | grep tests לסוג הישן אחרי שינוי widget |

---

# חלק ה — Engine / Domain (PLAYBOOK §D)

- **`plan.items` = BOM, לא flow.** לאdjacency: `findShortestPath(a,b)`.
- **fitting↔fitting בלי pipe = missing component.** `materializeChain` מכניס pipe בין fittings, coupling בין pipes.
- **Drainage ≠ supply.** `lineIsSupply(items)` גוט supply-compliance מקו ניקוז.
- **בדוק data distribution לפני הרחבת כלל.** `grep -c` על הcatalog לפני "בטוח שקיים".
- **ΔP לא כולל side branches.** `_kOffLineSkus` (sampling/air-vent/expansion-tank) מחוץ לhflow.
- **Synthetic specs לא דולפים לcarousel.** `HW-*/PIPE-*` ב-`kVerifiedSpecs` — `compatibleProductsFor` מסנן על `kLipskeyCatalog`.

---

# חלק ו — Refactor / Persistence / UI (PLAYBOOK §E–G)

## Build "alongside" ללא נגיעה במקור

```bash
git diff --quiet <A-file>   # אמת שA לא השתנה
```
השתמש ב-helpers ציבוריים בלבד של הקובץ המקורי.

## Persistence pattern (§F)

```dart
class MyNotifier extends StateNotifier<Set<String>> {
  MyNotifier() : super({}) { _load(); }
  Future<void> _load() async { /* SharedPreferences.getStringList */ }
  Future<void> _persist() async { /* setStringList */ }
}
// key format: 'bs.<feature>.v1'
```

**Test pattern:**
```dart
SharedPreferences.setMockInitialValues({});
final n1 = MyNotifier(); n1.toggle('x');
final n2 = MyNotifier();
await Future.delayed(Duration.zero);
expect(n2.state, contains('x'));
```

## Canvas taps (§G) — לא אמינים

Flutter web = canvas אחד. כ-2-3 ניסיונות max. אם לא עובד → `unit test על הfunction`. Buttons שפותחים `showDialog` = הכי לא אמינים. `ensureVisible(finder)` לפני tap בscrollable.

---

# חלק ז — Synthetic Catalog (PLAYBOOK §H)

```dart
// lipskey_hotwater.dart
final p = LipskeyCatalogProduct(sku: 'HW-PUMP-40', nameHe: 'משאבה 40 ליטר', ...);
kVerifiedSpecs.putIfAbsent('HW-PUMP-40', () => VerifiedSpec(...));
// לא מופיע בcarousel — מסנן על kLipskeyCatalog
```

---

# חלק ח — איך בונים כרטיס-מוצר (CATALOG-CARD-PROTOCOL)

## עיקרון-על

**אין המצאה.** כל טקסט/מספר = verbatim מהקטלוג. לא מצאת → לא כותב.

## קבצי-ליבה

| קובץ | תפקיד |
|---|---|
| `lib/data/lipskey_catalog.dart` | מודל `LipskeyCatalogProduct` + getters |
| `lib/data/polyroll_catalog.dart` | PPR + `kCatalogProducts = [...kLipskeyCatalog, ...kPolyrollCatalog]` |
| `lib/screens/lipskey_products_screen.dart` | כרטיס חיצוני — chips (`AttrKind`, siblings) |
| `lib/screens/lipskey_product_sheet.dart` | כרטיס פנימי — 9 strips, flip image |
| `lib/data/related_info.dart` | כל הפונקציות הנתוניות (~45 helpers) |
| `lib/data/chip_hierarchy.dart` | PPR chip hierarchy parser (חדש — §21) |
| `lib/data/variant_families.dart` | `productCanonicalKey`, `variantValue`, `kindOf` |

## `dims` — מפתחות וסדר תצוגה

`שם מלא` · `תיאור` · `יצרן` · `מק"ט יצרן` · `מק"ט חוליות` · `PN` · `SDR` · `חומר` · `dn נומינלי` · `de/e/di` · `משקל` · `תקנים` · `לחץ עבודה (50 שנה)` · `אורך`

## הכרטיס החיצוני

- **כותרת** = `_externalTitle(p)` — ל-Polyroll: מסיר PPR/PPRCT (נשאר בציפ בלבד)
- **Chips** מ-`nameHe` / hierarchy parser:
  - **Lipskey**: `AttrKind` — כתום=siblings, אפור=יחיד
  - **PPR (חדש §21)**: `_HierarchyChips` — 5 רמות: שיטת-חיבור · צורה · תוספת · תבריג · מידה
  - chip **חומר (PPR/PPRCT)** = בדג' על התמונה, לא ציפ שרשור (§20 #1)
- **שורה תחתונה**: `brand · #sku · PN · SDR`

## Siblings — כלל מוחלט

**כל קוד שמחפש siblings/variants/swaps חייב לרוץ על `kCatalogProducts`** — לא `kLipskeyCatalog`.
שתי מערכות ציפים נפרדות (חיצוני: `findAttrSiblings`/`findHierarchySiblings`; פנימי: `_InteractiveChips`) — לתקן **שתיהן**.

## הכרטיס הפנימי — 9 strips

מוצג רק אם הפונקציה מחזירה תוכן:

| Strip | Gate |
|---|---|
| נמצא ב | `finderGroupFor` |
| מוצרים תואמים | `compatibleProductsCount` |
| ערכת התקנה | `installKitFor` + `recommendedKitForProduct` |
| דומים | `variantSiblingsCountFor` (מ-`kCatalogProducts`) |
| תקינות | `complianceTriggersFor` |
| מפרט הנדסי | `engineeringSpecFor` |
| מחיר משוער | `priceFor` |
| מידע כללי | `_buildInfo` (brand-gated) |
| חיטוי וניקוי | `_buildHygiene` (brand-gated) |

להוסיף מותג חדש: `if (p.brand == '<מותג>')` בכל פונקציה רלוונטית.

## הטמעת קטלוג חדש — 8 שלבים

```bash
# שלב א — חילוץ
pdftotext -layout catalog.pdf /tmp/full.txt
pdftoppm -jpeg -r 110 catalog.pdf assets/<brand>/pages/page   # → page-NN.jpg
```

**⚠️ מיפוי עמודים:** מספר PDF ≠ מספר מודפס. למפות ויזואלית, לא לפי תו"ע.
**⚠️ עמודי תמונה:** `pdftotext` מפספס. לקרוא PDF ישירות (`pages:`) אם grep לא מצא.

- **שלב ב** — זיהוי מבנה מתו"ע
- **שלב ג** — תשתית קוד: `const k<Brand>Brand`, קבועי-קטגוריה, helper `_<brand>(...)`
- **שלב ד** — הטמעת מוצרים: shells + מוצר-ייחוס מלא עם כל dims
- **שלב ה** — חיווט מותג לפונקציות (`finderGroupFor`, `engineeringSpecFor`, `complianceTriggersFor`, strips)
- **שלב ו** — תוכן verbatim מהקטלוג לכל strip
- **שלב ז** — תמונות: `pdfimages -p -j` + PIL composite (rgb + smask)
- **שלב ח** — אימות: `flutter analyze` + `flutter test`

## Checklist — מוצר/משפחה הבא

- [ ] `grep "'<sku>'"` → 0 תוצאות (אין כפילות)
- [ ] `dims` מלא למוצר-ייחוס (≥5 מפתחות = 100%)
- [ ] `imageFile` + `specImageFile` חתוכים מה-PDF
- [ ] מותג מחווט בכל פונקציות הרצועה
- [ ] תוכן verbatim — לא ממציאים
- [ ] עדכון **4 מקומות מצומדים** (קטגוריה חדשה): `polyroll_catalog.dart` (const + kPprCategories) · `catalog_tree.dart` (עלה) · `finder_screen.dart` (set)
- [ ] `flutter analyze` (0) + `flutter test` ירוקים

## לקחים קריטיים (§9–§21)

| § | כלל |
|---|---|
| 9 | לפני הוספה: `grep "'<sku>'"` = 0 |
| 11 | siblings/swap → `kCatalogProducts` |
| 12 | טסט החלפה = `LipskeyProductsList` (נתיב חי), assert `#sku` ולא "ציפ נפתח" |
| 13 | Bulk = קו שלם בפעם. "טבלה אחת = קו-מוצר אחד" |
| 14 | **כל באג → בדיקה אוטומטית לפני סגירה.** grep נשכח; CI לא. |
| 15 | המנוע גנרי: `dims` מלא = כרטיס מלא אוטומטי. בנה מנוע פעם אחת. |
| 16 | Push רק כש-≥100 מוצרים נצברו. commit מקומי = תמיד מותר. |
| 17 | תמונות: `pdfimages` + PIL. לסנן smask. לפסול עמודי-סצנה. `_pprPagePhoto` switch per תת-סוג. |
| 18 | PPR ≠ PPRCT. זיהוי: קוד-יצרן (`P-CT`/`FCT`/`FRCT`) + SKU prefix (`66xx`/`67xx`/`6006xxx`) + כיתוב על הגוף |
| 19 | בורר-סוג: scope לפי `categoryHe`. `findTypeSiblings` = same-category + leading-type בלבד |
| 20 | gaps ידועים: PPRCT badge ✅ · spec_pprct_pipe ✅ · Lipskey audit ⏳ |
| 21 | chip hierarchy (§21): parser ב-`chip_hierarchy.dart`, `_HierarchyChips`, faceted picker. שלב 4 (ויזואלי) = ⏳ |

---

# חלק ט — מבנה הנתונים (SCHEMA)

## שלושה עמודות

### 1. `kCatalogProducts` — מה קיים

```dart
final List<LipskeyCatalogProduct> kCatalogProducts =
    [...kLipskeyCatalog, ...kPolyrollCatalog];
```

**source of truth יחיד.** Polyroll + Lipskey — אותה class, `brand` מבדיל.

| שדה | משמעות |
|---|---|
| `sku` | מק"ט ספק — המפתח הגלובלי |
| `nameHe` | שם תצוגה (עברית קנונית) |
| `brand` | `'ליפסקי'` / `'פולירול'` |
| `dims` | Map — כל העושר של המוצר |
| `productType` | getter מ-`nameHe` via `kLipskeyTypes` |
| `connectionSizes` | DN ends: override → name → dims → default |

**Lookup:** `catalogProductForSku(sku)` → O(1) ממemoised `_skuIndex`.

### 2. `kVerifiedSpecs` — מפרטים פיזיים

```dart
final Map<String, VerifiedSpec> kVerifiedSpecs = { '<sku>': VerifiedSpec(...) };
```

- `ends: List<ConnectorEnd>` — ports פיזיים
- `material`, `pressureRating`, `maxTempC`, `systemOverride`
- `EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }`
- `WaterSystem { supply, drainage }`

Coverage: `compat_coverage_test` → נכשל אם connector חדש ללא spec.
Synthetic (`HW-*`/`PIPE-*`) → `putIfAbsent` בruntime → לא בcarousel.

### 3. `kSmartProducts` — SmartTree

~81 מוצרים curated. `SmartProduct` = concept עם brands + acc + stages.
**SKU יושב ב-`SmartBrand`** — הlink היחיד ל-`kCatalogProducts`.

### Bridge — SKU = FK יחיד

```dart
catalogProductForSku(sku)      // O(1)
catalogProductForBrand(brand)  // via SKU
smartProductForSku(sku)        // reverse
```

Round-trip guard: `smartproduct_contract_test`.

---

# חלק י — State Files (STATE_OVERVIEW)

## 28 קבצים — מלאי

| קובץ | סוג | מפתח | Step | מטרה |
|---|---|---|---|---|
| `ab_experiments.dart` | Map | `bs.ab-experiments.v1` | 92 | A/B variants |
| `analytics_log.dart` | List | — (memory) | 91 | analytics events |
| `app_settings.dart` | AppSettings | Preact-shared | — | app settings |
| `brand_history.dart` | Map | `bs.brand-history.v1` | 51 | pick frequency |
| `card_detail_mode.dart` | enum | `bs.card-detail-mode.v1` | 95 | simple/expert |
| `card_projects.dart` | List | `bs.card-projects.v1` | 71–80 | project assignments |
| `card_selection.dart` | Map | `bs.card-brand-selection.v1` | 7 | last brand per product |
| `card_versions.dart` | List | `bs.card-versions.v1` | 76 | named snapshots |
| `cart_lists_state.dart` | Map | (own) | — | saved cart lists |
| `cart_safety.dart` | pure helpers | — | 46 | engine safety → SmartCartAcc |
| `catalog_settings.dart` | CatalogSettings | Preact-shared | — | view prefs |
| `comparison_set.dart` | Set cap 4 | `bs.comparison-set.v1` | 76-adj | comparison queue |
| `crash_log.dart` | List | — (memory) | 90 | error log (לא persisted) |
| `default_brand_resolver.dart` | — | — | 51 | smart default brand מhistory (חדש) |
| `dial_state.dart` | enum | — (memory) | R1 | which FAB open |
| `draft_quote.dart` | List | `bs.draft-quotes.v1` | 48-adj | quote drafts |
| `feature_flags.dart` | Set | `bs.feature-flags.v1` | 10 | enabled flags |
| `hidden_catalog_sections.dart` | Set | `bs.hidden-catalog-sections.v1` | — | hidden sections |
| `menu_state.dart` | drill lists | — (memory) | R1 | menu drill paths |
| `offline_cache.dart` | Map | `bs.offline-cache.v1` | 83 | TTL cache |
| `product_favorites.dart` | Set | (own) | — | heart-toggled SKUs |
| `recent_searches.dart` | List cap 8 | (own) | 62 | search queries |
| `recently_viewed.dart` | List cap 20 | `bs.recently-viewed.v1` | 66 | recently opened |
| `saved_configs.dart` | Set | `bs.saved-configs.v1` | 47 | favourite configs |
| `saved_projects.dart` | List | (own) | — | Install Studio plans |
| `smart_cart.dart` | List | (own) | — | smart cart |
| `stage_progress.dart` | Set | `bs.stage-progress.v1` | 31 | install stages done |
| `store_settings.dart` | StoreSettings | Preact-shared | — | store settings |

## ⚠️ Preact-shared — אל תיגע

`app_settings` · `catalog_settings` · `chat_settings` · `notif_settings` · `store_settings` — **contract drift עם Preact app**.

## כל persistence keys (`bs.*.v1`)

`bs.ab-experiments.v1` · `bs.brand-history.v1` · `bs.card-brand-selection.v1` · `bs.card-detail-mode.v1` · `bs.card-projects.v1` · `bs.card-versions.v1` · `bs.comparison-set.v1` · `bs.draft-quotes.v1` · `bs.feature-flags.v1` · `bs.hidden-catalog-sections.v1` · `bs.offline-cache.v1` · `bs.recently-viewed.v1` · `bs.saved-configs.v1` · `bs.stage-progress.v1`

**Migration:** כש-bump ל-`.v2` — שמור `.v1` לrelease אחד.

**Template:** mirror `card_selection.dart` / `recently_viewed.dart`.

---

# חלק יא — Test Suite (TESTS_OVERVIEW)

**102 test files, 700+ tests.** Ground truth לפני כל checkpoint.

## naming: `_test.dart` singular בלבד

`*_tests.dart` plural = דלוג שקט. **אמת שcount עלה** אחרי הוספה.

## 10 domains

| Domain | קבצים מרכזיים |
|---|---|
| SmartProduct card | `smartproduct_contract`, `smart_card_data`, `product_journey`, `card_score`, `accessibility` |
| Compat engine | `compat_50_samples`, `compat_explain`, `chain_arrow`, `adapter_suggestion`, `line_fit` |
| Install/engine/studio | `engine_harness`, `install_builder`, `build_line_bom`, `safety_kit`, `pressure_drop` |
| Card helpers | `brand_guide`, `durability`, `standards_tools`, `discovery_tags`, `compliance_why`, `line_cost` |
| Persisted state | `card_selection`, `brand_history`, `card_versions`, `card_projects`, `recently_viewed`, `feature_flags` |
| Cart/commerce | `cart_safety`, `cart_bulk_order`, `cart_stress`, `deep_link` |
| Regression gates | `regression_gate` (meta), `mutation_test`, `knowledge_protocol`, `dedup`, `catalog_regression` |
| Audits/catalog health | `audit40`, `full_compliance_audit`, `catalog_bfs`, `catalog_health`, `auto_compliance`, `zone_tmtv` |
| Cards interactions | `card_interactions`, `robustness`, `product_sheet_strips` |
| Infra helpers | `dial_test_helper`, `isolation_validator`, `infra_gap_test`, `infra_hard_test` |

## כשמוסיפים helper חדש — 5 צעדים

1. `test/<my_helper>_test.dart` (singular) — empty, happy path, boundaries
2. אם ציבורי בcard → הוסף שם ל-`_kRequiredHelpers` ב-`regression_gate_test.dart`
3. Persisted? → mock prefs + fresh notifier pattern
4. נוגע ב-rendering? → `product_journey_test` + `smart_card_data_test` מכסים
5. **אמת שcount עלה**

---

# חלק יב — Helpers Index (HELPER_INDEX)

`lib/data/related_info.dart` — 45 helpers ציבוריים. **כולם נבדקים**, כולם pure.

## גרופינג

**Catalog bridge:** `catalogProductForSku` · `catalogProductForBrand` · `catalogProductForSmart` · `finderGroupFor`

**Compat & connection:** `compatibleProductsFor` · `compatibleProductsCount` · `connectionJoint` · `jointLabelHe` · `chainEdgeLabelHe` · `connectionExplainHe` · `connectionNeedsHe` · `connectionWarningHe` · `lineFitFor` · `adapterSuggestionFor` · `chainArrowText` · `lineStructureText` · `gapAdviceHe` · `needsConnectionSpec`

**Spec, scoring, discovery:** `engineeringSpecFor` · `cardReadinessScore` · `durabilityRatingFor` · `discoveryTagsFor` · `frequentlyPairedTypesFor` · `israeliStandardsFor` · `manufacturerInfoFor` · `systemSafetyNoteHe` · `hotWaterSuitabilityFor` · `brandSuitableForHot`

**Install/kit:** `installKitFor` · `installToolsFor` · `installTipsFor` · `installEffortFor` · `acceptanceChecklistFor` · `safetyKitItems`

**Price/share:** `priceFor` · `lineCostEstimateFor` · `cheaperAlternativeBrand` · `quoteTextFor` · `deepLinkFor` · `smartCardSummaryHe`

**Compliance:** `complianceTriggersFor` · `complianceWhyHe`

**Variants/brand:** `variantSiblingsOf` · `variantSiblingsCountFor` · `brandDecisionGuide`

## Regression gate list (חייב ≥1 test reference)

`compatibleProductsFor`, `compatibleProductsCount`, `connectionExplainHe`, `connectionJoint`, `jointLabelHe`, `chainEdgeLabelHe`, `connectionNeedsHe`, `connectionWarningHe`, `lineFitFor`, `adapterSuggestionFor`, `safetyKitItems`, `chainArrowText`, `engineeringSpecFor`, `cardReadinessScore`, `durabilityRatingFor`, `discoveryTagsFor`, `frequentlyPairedTypesFor`, `manufacturerInfoFor`, `finderGroupFor`, `israeliStandardsFor`, `systemSafetyNoteHe`, `hotWaterSuitabilityFor`, `brandSuitableForHot`, `installToolsFor`, `installTipsFor`, `installEffortFor`, `installKitFor`, `acceptanceChecklistFor`, `priceFor`, `lineCostEstimateFor`, `cheaperAlternativeBrand`, `quoteTextFor`, `deepLinkFor`, `smartCardSummaryHe`, `complianceTriggersFor`, `complianceWhyHe`, `variantSiblingsOf`, `variantSiblingsCountFor`, `brandDecisionGuide`, `catalogProductForBrand`, `catalogProductForSku`, `catalogProductForSmart`

---

# חלק יג — Card Flow (CARD_FLOW)

SmartProduct card — 44 sections, top-to-bottom:

**Header:** handle · title/emoji · `_DiagramFlow` · explode chips · install progress tracker (step 31)

**Selectors:** בחר מותג (עם hot filter, step 65) · בחר סוג · בחר מידה

**📦 נתוני קטלוג:**
score badge (30) · ☆ שמור (47) · 📋 quote (48+68) · mode toggle (95) · summary (59) · discovery tags (67) · system safety note (24) · connection warning (29) · "בקו שלך" + adapter (28+27) · hot-water (26, expert)

**Spec rows** (step 11, expert): חומר · לחץ · טמפ׳ · מערכת · קצוות · קוטר · עמידות★ (15) · מאתר · ערכת · התקנה (34) · וריאנטים · יצרן (20) · מחיר

**Price:** cheaper alt (45) · line cost (42)

**Compat:** 🔗 N מוצרים (21) · paired types (56, expert) · chain inline (23) · BOM button (22) · safety kit (25) · 🛒 + safety (46)

**Projects:** ➕ project (71) · ×3 locations (72) · templates (80) · counter (74) · BOM dialog (74) · quote (75)

**Compliance (expert):** תקינות + why (19+58) · connection needs (73) · checklist (38) · standards (12) · tools (33) · tips (35) · variants (63) · 💾 versions (76) · brand guide (16) · recently viewed (66)

**Footer:** חובה ⚡ · אופציונלי 💡 · הוסף לסל

---

# חלק יד — Sub-Agent Patterns (AGENT_PATTERNS)

## TL;DR

**Disjoint NEW files** · **Absolute paths** · **Max 3 concurrent** · **No `isolation: "worktree"`**

## Pre-flight לפני כל batch

- [ ] `git ls-files` / `ls` — כל deliverable = **path חדש**
- [ ] Absolute paths בכל brief
- [ ] Verbatim: *"ADD only — never modify existing files. No git commit or push."*
- [ ] Mirror reference file לconsistency
- [ ] Cap 3 agents. על 529 → serial → supervisor-direct

## Fallback chain

1. **Concurrent (3)** — disjoint NEW files + API responsive
2. **Serial** — first response ל-529
3. **Supervisor-direct** — אם single-agent גם 529 → `Write`/`Bash` ישירות

## מלכודות

- agent כותב לcwd לא נכון → brief: *"Step 1: run `pwd && ls`. If NOT in project — STOP."*
- 529 cluster → **דלג על serial** → ישירות supervisor-direct
- תמיד אמת landing: `ls <absolute-path>` אחרי return
- **לעולם לא להעתיק doc של agent ללא אימות** — fabricated names slip in

---

# חלק טו — מצב נוכחי (STATUS + ROADMAP)

## גרסה: v5.29

## מה קיים ועובד

**Tabs:** קטלוג · שיחות · התראות · חנות · הגדרות ×4 — הכל light-mode.

**Wired (~26):** searchHistory · quickFilterBar · imageSize · compactMode · viewMode · gridColumns · botEnabled · readReceipts · per-type notifications · defaultPayment · vatInclusive · cart stepper · swipe-archive · mute-all...

**Install Studio (v3.79):** BOM zones · TMTV auto · auto-compliance · severity 🔴🟡🔵 · chain materialization · ΔP physics · progressive dock.

**Catalog card:** 9 strips · chip hierarchy (PPR §21 steps 1-3 ✅, step 4 ⏳) · profession-aware chip (step 57 ✅) · smart default brand (step 51 ✅) · 808/935 SKUs עם VerifiedSpec.

## מה חסום (⛔)

מחירים · AI recommendations · push notifications · telephony · geo/rating · media/camera · invoices/warranty.

## SmartProduct Roadmap (~46%: 32 ✅ + 14 🟦)

**Group A — buildable עכשיו:**
76 config-versioning · 25 auto safety-kit · 46 add-whole-line-to-cart · 74 full project BOM dialog · 89 regression-gate meta-test · 82 mutation tests · 85 accessibility · ~~57~~ ✅

**Group B — השלמת partials:** 2, 7, 9, 15, 20, 24, 26, 29, 30, 48, 56, 65, 68

**Group C — חסום (צריך החלטה):** 13, 17, 18, 32, 36–40, 41, 43–44, 49–50, 53–55, 60, 69–70, 79, 83–84, 86, 88, 90–94, 96–98

**Group D — מסוכן/refactor:** 1 (merge sheets — אסור), 10, 61, 64, 99/100

## Known gaps (§20) — אחרי 100/100

| # | פער | סטטוס |
|---|---|---|
| 1 | PPRCT badge על תמונה | ✅ |
| 2 | spec_pprct_pipe.jpg לצינורות PPRCT | ✅ |
| 3 | Lipskey side audit (935 מוצרים) | ⏳ |
| 4 | Orientation audit p36-p71 | ✅ |
| 5 | Sub-types מוסתרים | ✅ |
| 6 | golden test baselines | ⏳ |
| 7 | Score bar → 95 | ✅ |
| 8 | dims threshold → ≥5 = 100% | ✅ |

---

# חלק טז — פקודות-ריצה

```bash
export PATH="/home/user/flutter/bin:$PATH"
cd /home/user/buildsmart/app_flutter

flutter analyze                # 0 errors
flutter test                   # 0 failures
flutter build web --release    # נקי

# VRB — אימות מחרוזת
grep -n "הטקסט" /home/user/buildsmart/index.html

# test ספציפי
flutter test test/<domain>_test.dart -v

# web server
flutter run -d web-server --web-port 8090 --web-hostname 127.0.0.1

# git — push נקי
git fetch && git -c core.editor=true rebase origin/claude/whats-happening-LyY9G
```
