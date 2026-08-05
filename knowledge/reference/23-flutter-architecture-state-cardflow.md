# Flutter — ארכיטקטורה · state-model · card-flow · helpers · engines · launch

> השלמת-התמונה: תת-המערכות של האפליקציה האמיתית (`app_flutter/`, whats-happening) שלא נכנסו במלואן לדלתאות 01–17. נלכד מ-`app_flutter/knowledge/` (SCHEMA/STATE_OVERVIEW/CARD_FLOW/HELPER_INDEX/SMARTPRODUCT_ROADMAP/LAUNCH_READINESS) + הקוד. **אומת-מקוד.**

## A. ארכיטקטורה
Flutter 3.29 (deploy 3.44) · Dart 3.7 · **Riverpod** · `main.dart` → `registerPolyrollSpecs()` → `ProviderScope` → `MaterialApp` → **`OnboardingGate`** (welcome/HomeShell). (`go_router` הוסר P-4.) שכבות — **snapshot ~172 קבצי-lib (גדל; הקוד=SSOT):** `data/` ~40 · `logic/` 5-engines · `state/` ~55 · `screens/` ~46 · services/widgets/theme/l10n/test_harness. **SSOT · אין circular-deps · Preact-shared מבודד** (קבצי-settings = JSON-contracts אמיתיים: `app_settings.dart` הוא port של `app-settings.ts` עם **אותו מפתח `bs.settings.v1` ואותו shape מקונן**).

## B. SCHEMA — 3 עמודי-נתונים (SKU = מפתח-העל)
1. **`kCatalogProducts`** (**1,877** · `LipskeyCatalogProduct` · אומת שורה-שורה) — קטלוג מאוחד `[...kLipskeyCatalog 935, ...kPolyrollCatalog 772, ...kHuliotCatalog 170]` (ספירת-constructors מאומתת; HW-`kHotWaterCatalog` ~133 = רשימה **נפרדת**, מוזנת ל-`kCompatCatalog` בלבד).
2. **`kVerifiedSpecs`** (808+ · `VerifiedSpec`{sku,material,ends[ConnectorEnd],pressureRating,maxTempC,systemOverride}) — **מנוע-החיבוריות**. enums EndType/WaterSystem.
3. **`kSmartProducts`** (**82** · `SmartProduct`{key,name,emoji,cat,brands[`SmartBrand`],acc[`SmartAcc`],diagramTitle,stages[`SmartStage`]}) — כרטיסים-מובחרים. **SKU על ה-`SmartBrand`** (`{name,tag,price?,rec,sku?,imageAsset?}`; חלק גנריים-ללא-SKU). getters: `recBrand`(firstWhere rec→[0]) · `mustCount`. `SmartStage` = שלבי-דיאגרמה verbatim מ-prototype DIAGRAMS (3–4/מוצר). `SmartAcc`{name,emoji,why,**must**,price?,sku?}. ✅ **אומת-עצמי שורה-שורה (smart_tree.dart 2,551ש': 4-מחלקות+82-entries+4-helpers).**
- **גשר:** forward `catalogProductForBrand(brand)` · reverse `smartProductForSku(sku)` (lazy `_smartBySku`) · `smartProductByKey` (לעלי catalog-tree) · `kSmartTreeCats`/`smartProductsForCat`. round-trip שמור (`smartproduct_contract_test`, 307/365 brands-עם-SKU).

## C. state-model — **50 providers ב-`state/`** (41 קבצים; ‎114 providers repo-wide כולל UI-local ב-screens/widgets) · הנמשכים: `bs.*.v1` ב-shared_preferences, פרט ל-UI-transient + in-memory-logs
> 🔧 **תיקון-ספירה (אומת-עצמי):** "41" בגרסה קודמת היה **ספירת-קבצים**, לא providers. בפועל: state/ = 41 קבצים שמכריזים **50 providers** (`dial_state` 7 · `menu_state` 5 · `onboarding_gate` 2 · השאר 1 כ"א); סה"כ **114 providers ברחבי lib** (היתר UI-local). פירוט-הקטגוריות למטה מונה קבצים/נושאים.
- **settings (8):** app/catalog/chat/notif/store-settings · profession/project/cardDetail-mode.
- **בחירה+היסטוריה (9):** cardSelection · brandHistory · cardFilter · cardAcc · cardVersions · savedConfigs · productFavorites · comparisonSet (≤4).
- **סל+פרויקטים (5):** smartCart (`SmartCartLine`) · cardProjects · savedProjects · cartLists · draftQuote (≤30).
- **גלישה (4):** recentSearches (≤8) · recentlyViewed (≤20) · catalogLens (category/variant/smartTree) · hiddenSections.
- **UI-transient (8):** openDial · activePersona · bsDrillPath · ~~menuTab~~ · searchTool · mainTab · displayTemp · drill-paths. *(⚠️ 07-06: ה-menu-dial הוסר — `menu_state`/`menuTab` צומצמו.)*
- **flags+progress (5):** featureFlags · abExperiments · onboardingProgress · welcomeSeen · stageProgress.
- **logs in-memory (4, לא-נשמר):** analyticsLog (≤500) · crashLog (≤200) · lastAction (≤50) · shareLog.
- **גשרים:** `catalogProductForBrand` · `cartSafetyProvider` · `defaultBrandResolver` (cardSelection>brandHistory>recBrand>0).
- ⚠️ **אין `autoDispose`** (ה-providers חיים-תמיד) — חוב-ארכיטקטוני P1 (memory).
- ✅ **אומת-עצמי שורה-שורה:** `smart_cart.dart` (174ש׳ — `SmartCartLine{productKey,name,emoji,brandName,brandPrice,productQty,acc[`SmartCartAcc`]}`+`total`; `SmartCartNotifier` persist→`bs.smart-cart.v1` בכל set-state; add/remove/setLineQty[qty≤0→remove]/qtyForKey/setQtyForKey/clear) · `app_settings.dart` (294ש׳ — 20 שדות ב-6 קבוצות display/notif/region/delivery/accessibility/security; ברירות theme=**light**/lang=he/currency=ils/session=15ד'/privMarketing=opt-in; persist→`bs.settings.v1`).

## D. כרטיס-המוצר החכם — **CARD_FLOW (42 אלמנטים)** = "מוח-הידע" (`_SmartProductSheet`)
> 🔎 **אומת-מבנית (לא שורה-שורה):** `_SmartProductSheet` = `catalog_screen.dart` שורות **4135–6128** (~2,000ש׳, הווידג'ט הגדול בקובץ בן 7,660ש׳). אומת ע"י איתור-המחלקה + ספירת קריאות-helpers בגוף (17 helpers נקראים). תוכן-הרשומות (42 אלמנטים) **לא נקרא ווידג'ט-ווידג'ט** — הוא נשען על §E.
- **header:** כותרת+emoji+קטגוריה · diagram-3-שלבים · score-chip.
- **selectors:** בחר-מותג (+hot-water-filter) · בחר-סוג · בחר-מידה.
- **📦 נתוני-קטלוג (expert/simple toggle, ~30 strips):** score · ☆save · 📋quote · summary · discovery-tags · safety-note · connection-warning · "בקו שלך"+adapter · hot-water-suitability · spec-rows (material/pressure/temp/system/ends/bore/durability★/install-kit/effort/variants/manufacturer+mfr#/price) · cheaper-alt · line-cost · **🔗compat** ("מתחבר ל-N"+3-hits+frequently-paired) · inline-chain (כשהסל לא-ריק) · BOM-button · safety-kit(auto) · **project-actions** (add/dup×3/templates/full-BOM/quote) · compliance/standards/tools/tips/acceptance · brand-guide · recently-viewed.
- **footer:** אביזרי-חובה ⚡ (checkbox+qty) · אופציונלי 💡 · "הוסף לסל ₪N".

## E. HELPER_INDEX — **43 helpers ציבוריים** (`related_info.dart`, **1,528ש׳** · אומת-עצמי: כולם בקובץ-יחיד זה)
> 🔧 **תיקון (אומת-עצמי):** הקובץ **1,528ש׳** (לא 1,141) · ספירה מדויקת = **43 פונקציות-עזר ציבוריות** (לא 47; חלקן מחזירות records `({int score,...})` ולכן נספרו-חסר בעבר). ה-`_SmartProductSheet` (catalog_screen 4135–6128) בונה את 42 אלמנטי-הכרטיס ע"י **קריאה ל-helpers האלה** — אומת: 17 קריאות בגוף-ה-sheet (§D↔§E ארכיטקטורה אמיתית).
- **catalog-bridge (5):** catalogProductForBrand/ForSku/ForSmart · finderGroupFor · deepLinkFor.
- **compat/connection (15):** compatibleProductsFor/Count · connectionJoint · jointLabelHe · connectionExplainHe/NeedsHe/WarningHe · pairConnectionWarningHe · lineFitFor · adapterSuggestionFor · chainArrowText · chainEdgeLabelHe · lineStructureText · needsConnectionSpec · gapAdviceHe.
- **spec/scoring (7):** engineeringSpecFor · cardReadinessScore · durabilityRatingFor · discoveryTagsFor · israeliStandardsFor · hotWaterSuitabilityFor · manufacturerInfoFor.
- **install/kit (6):** installToolsFor/TipsFor/EffortFor/KitFor · acceptanceChecklistFor · safetyKitItems.
- **price/share (5):** priceFor · lineCostEstimateFor · cheaperAlternativeBrand · quoteTextFor · smartCardSummaryHe.
- **compliance (2):** complianceWhyHe · systemSafetyNoteHe. **brand/variants (4):** brandIsMetallic · brandSuitableForHot · variantSiblingsOf/CountFor.
> ⚠️ טענת-ה-KB "gate 42 / regression_gate_test: כל helper ≥1 test" — מקור-KB (פרוטוקול), **לא אומת בקוד** בסשן זה.

## F. 5 מנועי-הלוגיקה (`lib/logic/`)
> ✅ **כל 5 המנועים (2,390ש') אומתו בקריאה-עצמית מלאה — שורה-שורה, לא דרך סוכן.** install_engine 1,391 · pressure_drop 501 · install_kit 286 · price_estimate 109 · system_division 103. כל הטענות למטה מדויקות מול-הקוד.
- **`install_engine.dart` (1,391ש׳):** Dijkstra least-cost pathfinding (`_edgeCost`=10+device-filler[50 אם לא-fitting]+material-transition[0/1/4 לפי משפחה]+pipe-bridge[2]+bore[0-10]) · `findAlternativePaths` (Yen k=3) · auto-compliance (PRV/בלון-התפשטות/TMTV/dielectric/ball-valve/clips/sealant/Y-strainer/Legionella; recirc-loop +3-שתופים/check/balance) · `buildInstallation`/`buildTreeInstallation` (manifold גזע/ענף; TMTV-per-branch לחם; balance-valve למשאבה) · `materializeChain` · סף-חם `_kHotThresholdC=60`.
- **`pressure_drop.dart` (501ש׳):** Darcy-Weisbach ΔP=(ΣK+ƒL/D)·½ρv²+ρgh · ƒ Reynolds-aware (laminar 64/Re מתחת 2300, Blasius 0.316/Re^0.25) · K לפי productType (elbow 0.9/tee 1.5/valve 0.05/strainer 5.0/PRV 10.0) · `autoFlowFix` (bottleneck-swap דרך `widerSiblingOf` / booster-pump HW-PUMP-40 אם ΔP>1bar) · `checkDrainageSlope` ≥2% (ת"י 1205).
- **`install_kit.dart` (286ש׳):** `recommendedKitForProduct` (per-מוצר) + `recommendedKitFor` (per-chain, dedup) · brand-override פולירול/PPR→מכונת-ריתוך-שקע 260°C+תבניות+חותך (לא compression-wrench) · Huliot SmartLock→מפתח-לאום bayonet לפי-DN · BSP→מפתח-שוודי+PTFE · PEX→crimper · נחושת→press · **מעבר חוצה-מתכת→רקורד-דיאלקטרי (הפרדה-גלוונית)+hemp.**
- **`price_estimate.dart` (109ש׳):** `_categoryPriceILS` (~50 קטגוריות; ברזים 280-1200₪/צינורות 28-65₪) · fallback 25₪ · `lowConfidence` כשפחות-מחצית-תואמו.
- **`system_division.dart` (103ש׳):** supply(מים-נקיים)/drainage(שפכים) · VerifiedSpec.endSystems מנצח · פולירול→supply · אחרת→drainage · **fixtures (אסלות/מקלחות-ואמבטיות/גופי-תברואה)→שני-הצדדים** · `nodeHasSystem` (ספירת-דומיננטיות) · **SSOT-חוצה-מסכים: מונע cycle `catalog`↔`finder`** (בנצי #1).

## G. Launch-readiness (`LAUNCH_READINESS.md`)
- **קוד בריא:** ~92%+ roadmap · 0 analyze-errors · **1,539+ בדיקות** (אומת ב-gate `b4e2198`; גדל מאז) · SSOT.
- **Web/PWA 🟢 GO** (אחרי asset-opt 101MB→WebP). **iOS 🔴 NO-GO** (Info.plist camera/mic usage-strings + signing-team). **Android 🔴 NO-GO** (release-keystore + Play-account).
- **P0 = store-config (לא קוד).** P1: asset-opt · status-line · `go_router` ✅ הוסר · נעילת-theme.light · exclude-test_harness-מ-release · חיווט-search-dial (ה-menu-dial הוסר 07-06) · global-error-handler. **חסום:** pricing(`brandPrice=0`)/ratings/AI/push/telephony.
- **`LAUNCH_PACKAGE/`:** aab חתום 68MB · store-listing he/en · privacy-policy · data-safety · `SEND_TO_GOOGLE.md` runbook.

## H. ROADMAP (`SMARTPRODUCT_ROADMAP.md`, 100 צעדים · ~92% ✅)
phases: 1-unification · 2-data-enrichment · 3-compat · 4-install · 5-price · 6-AI/personalization · 7-search · 8-contractor-projects · 9-quality/a11y · 10-platform/moonshots(🟦). **coach-mode (99–100)** = הכרטיס-כמורה (text-only שמיש היום מ-helpers; voice/AR/camera=שדרוגי-ערוץ).

---
**הקשר:** דוח זה משלים את 01–17 (deltas) ו-21–22 (פרוטוקולים) — הוא תת-המערכות הפנימיות של האפליקציה האמיתית (data-schema · 41-state · 42-card-flow · 47-helpers · 5-engines · launch). יחד = **התמונה המלאה של Flutter.**
