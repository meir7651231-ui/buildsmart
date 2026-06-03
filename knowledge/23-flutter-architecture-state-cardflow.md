# Flutter — ארכיטקטורה · state-model · card-flow · helpers · engines · launch

> השלמת-התמונה: תת-המערכות של האפליקציה האמיתית (`app_flutter/`, whats-happening) שלא נכנסו במלואן לדלתאות 01–17. נלכד מ-`app_flutter/knowledge/` (SCHEMA/STATE_OVERVIEW/CARD_FLOW/HELPER_INDEX/SMARTPRODUCT_ROADMAP/LAUNCH_READINESS) + הקוד. **אומת-מקוד.**

## A. ארכיטקטורה
Flutter 3.29 (deploy 3.44) · Dart 3.7 · **Riverpod** · go_router · `main.dart` → `registerPolyrollSpecs()` → `ProviderScope` → `MaterialApp` → **`OnboardingGate`** (welcome/HomeShell). שכבות: `data/` (25) · `logic/` (5 engines) · `state/` (41 providers) · `screens/` (30) · `widgets/` · `theme/` · `l10n/` · `test_harness/`. **SSOT · אין circular-deps · Preact-shared מבודד** (5 קבצי-settings = JSON-contracts).

## B. SCHEMA — 3 עמודי-נתונים (SKU = מפתח-העל)
1. **`kCatalogProducts`** (1,337 · `LipskeyCatalogProduct`) — קטלוג מאוחד (Lipskey 255 + Polyroll 779 + Huliot 170 + HW-סינתטי 133).
2. **`kVerifiedSpecs`** (808+ · `VerifiedSpec`{sku,material,ends[ConnectorEnd],pressureRating,maxTempC,systemOverride}) — **מנוע-החיבוריות**. enums EndType/WaterSystem.
3. **`kSmartProducts`** (**82** · `SmartProduct`{key,name,emoji,cat,brands[`SmartBrand`],acc[`SmartAcc`],diagramTitle,stages[`SmartStage`]}) — כרטיסים-מובחרים. **SKU על ה-`SmartBrand`** (`{name,tag,price?,rec,sku?,imageAsset?}`; חלק גנריים-ללא-SKU). getters: `recBrand`(firstWhere rec→[0]) · `mustCount`. `SmartStage` = שלבי-דיאגרמה verbatim מ-prototype DIAGRAMS (3–4/מוצר). `SmartAcc`{name,emoji,why,**must**,price?,sku?}. ✅ **אומת-עצמי שורה-שורה (smart_tree.dart 2,551ש': 4-מחלקות+82-entries+4-helpers).**
- **גשר:** forward `catalogProductForBrand(brand)` · reverse `smartProductForSku(sku)` (lazy `_smartBySku`) · `smartProductByKey` (לעלי catalog-tree) · `kSmartTreeCats`/`smartProductsForCat`. round-trip שמור (`smartproduct_contract_test`, 307/365 brands-עם-SKU).

## C. state-model — **41 Riverpod providers** (כולם `bs.*.v1` ב-shared_preferences, פרט ל-UI-transient + in-memory-logs)
- **settings (8):** app/catalog/chat/notif/store-settings · profession/project/cardDetail-mode.
- **בחירה+היסטוריה (9):** cardSelection · brandHistory · cardFilter · cardAcc · cardVersions · savedConfigs · productFavorites · comparisonSet (≤4).
- **סל+פרויקטים (5):** smartCart (`SmartCartLine`) · cardProjects · savedProjects · cartLists · draftQuote (≤30).
- **גלישה (4):** recentSearches (≤8) · recentlyViewed (≤20) · catalogLens (category/variant/smartTree) · hiddenSections.
- **UI-transient (8):** openDial · activePersona · bsDrillPath · menuTab · searchTool · mainTab · displayTemp · drill-paths.
- **flags+progress (5):** featureFlags · abExperiments · onboardingProgress · welcomeSeen · stageProgress.
- **logs in-memory (4, לא-נשמר):** analyticsLog (≤500) · crashLog (≤200) · lastAction (≤50) · shareLog.
- **גשרים:** `catalogProductForBrand` · `cartSafetyProvider` · `defaultBrandResolver` (cardSelection>brandHistory>recBrand>0).
- ⚠️ **אין `autoDispose`** (48 providers חיים-תמיד) — חוב-ארכיטקטוני P1 (memory).

## D. כרטיס-המוצר החכם — **CARD_FLOW (42 אלמנטים)** = "מוח-הידע" (`_SmartProductSheet`)
- **header:** כותרת+emoji+קטגוריה · diagram-3-שלבים · score-chip.
- **selectors:** בחר-מותג (+hot-water-filter) · בחר-סוג · בחר-מידה.
- **📦 נתוני-קטלוג (expert/simple toggle, ~30 strips):** score · ☆save · 📋quote · summary · discovery-tags · safety-note · connection-warning · "בקו שלך"+adapter · hot-water-suitability · spec-rows (material/pressure/temp/system/ends/bore/durability★/install-kit/effort/variants/manufacturer+mfr#/price) · cheaper-alt · line-cost · **🔗compat** ("מתחבר ל-N"+3-hits+frequently-paired) · inline-chain (כשהסל לא-ריק) · BOM-button · safety-kit(auto) · **project-actions** (add/dup×3/templates/full-BOM/quote) · compliance/standards/tools/tips/acceptance · brand-guide · recently-viewed.
- **footer:** אביזרי-חובה ⚡ (checkbox+qty) · אופציונלי 💡 · "הוסף לסל ₪N".

## E. HELPER_INDEX — **47 helpers** (`related_info.dart`, 1,141ש׳, regression-gated)
catalog-bridge · compat/connection (12: compatibleProductsFor/connectionJoint/jointLabelHe/connectionExplainHe/connectionNeedsHe/connectionWarningHe/lineFitFor/adapterSuggestionFor/chainArrowText...) · spec/scoring (~10: engineeringSpecFor/cardReadinessScore/durabilityRatingFor/discoveryTagsFor/israeliStandardsFor/hotWaterSuitabilityFor...) · install/kit (5: installToolsFor/installTipsFor/installEffortFor/installKitFor/acceptanceChecklistFor) · price/share (6) · compliance (2) · variants/brand. **gate 42 + `regression_gate_test`: כל helper-ציבורי חייב ≥1 test** (47-helper-gate).

## F. 5 מנועי-הלוגיקה (`lib/logic/`)
> ✅ **כל 5 המנועים (2,390ש') אומתו בקריאה-עצמית מלאה — שורה-שורה, לא דרך סוכן.** install_engine 1,391 · pressure_drop 501 · install_kit 286 · price_estimate 109 · system_division 103. כל הטענות למטה מדויקות מול-הקוד.
- **`install_engine.dart` (1,391ש׳):** Dijkstra least-cost pathfinding (`_edgeCost`=10+device-filler[50 אם לא-fitting]+material-transition[0/1/4 לפי משפחה]+pipe-bridge[2]+bore[0-10]) · `findAlternativePaths` (Yen k=3) · auto-compliance (PRV/בלון-התפשטות/TMTV/dielectric/ball-valve/clips/sealant/Y-strainer/Legionella; recirc-loop +3-שתופים/check/balance) · `buildInstallation`/`buildTreeInstallation` (manifold גזע/ענף; TMTV-per-branch לחם; balance-valve למשאבה) · `materializeChain` · סף-חם `_kHotThresholdC=60`.
- **`pressure_drop.dart` (501ש׳):** Darcy-Weisbach ΔP=(ΣK+ƒL/D)·½ρv²+ρgh · ƒ Reynolds-aware (laminar 64/Re מתחת 2300, Blasius 0.316/Re^0.25) · K לפי productType (elbow 0.9/tee 1.5/valve 0.05/strainer 5.0/PRV 10.0) · `autoFlowFix` (bottleneck-swap דרך `widerSiblingOf` / booster-pump HW-PUMP-40 אם ΔP>1bar) · `checkDrainageSlope` ≥2% (ת"י 1205).
- **`install_kit.dart` (286ש׳):** `recommendedKitForProduct` (per-מוצר) + `recommendedKitFor` (per-chain, dedup) · brand-override פולירול/PPR→מכונת-ריתוך-שקע 260°C+תבניות+חותך (לא compression-wrench) · Huliot SmartLock→מפתח-לאום bayonet לפי-DN · BSP→מפתח-שוודי+PTFE · PEX→crimper · נחושת→press · **מעבר חוצה-מתכת→רקורד-דיאלקטרי (הפרדה-גלוונית)+hemp.**
- **`price_estimate.dart` (109ש׳):** `_categoryPriceILS` (~50 קטגוריות; ברזים 280-1200₪/צינורות 28-65₪) · fallback 25₪ · `lowConfidence` כשפחות-מחצית-תואמו.
- **`system_division.dart` (103ש׳):** supply(מים-נקיים)/drainage(שפכים) · VerifiedSpec.endSystems מנצח · פולירול→supply · אחרת→drainage · **fixtures (אסלות/מקלחות-ואמבטיות/גופי-תברואה)→שני-הצדדים** · `nodeHasSystem` (ספירת-דומיננטיות) · **SSOT-חוצה-מסכים: מונע cycle `catalog`↔`finder`** (בנצי #1).

## G. Launch-readiness (`LAUNCH_READINESS.md`)
- **קוד בריא:** ~92% roadmap · 0 analyze-errors · 948-tests · SSOT.
- **Web/PWA 🟢 GO** (אחרי asset-opt 101MB→WebP). **iOS 🔴 NO-GO** (Info.plist camera/mic usage-strings + signing-team). **Android 🔴 NO-GO** (release-keystore + Play-account).
- **P0 = store-config (לא קוד).** P1: asset-opt · status-line · הסרת-deps-לא-בשימוש (go_router?) · נעילת-theme.light · exclude-test_harness-מ-release · חיווט-search/menu-dials (5-FAB או BS-only) · global-error-handler. **חסום:** pricing(`brandPrice=0`)/ratings/AI/push/telephony.
- **`LAUNCH_PACKAGE/`:** aab חתום 68MB · store-listing he/en · privacy-policy · data-safety · `SEND_TO_GOOGLE.md` runbook.

## H. ROADMAP (`SMARTPRODUCT_ROADMAP.md`, 100 צעדים · ~92% ✅)
phases: 1-unification · 2-data-enrichment · 3-compat · 4-install · 5-price · 6-AI/personalization · 7-search · 8-contractor-projects · 9-quality/a11y · 10-platform/moonshots(🟦). **coach-mode (99–100)** = הכרטיס-כמורה (text-only שמיש היום מ-helpers; voice/AR/camera=שדרוגי-ערוץ).

---
**הקשר:** דוח זה משלים את 01–17 (deltas) ו-21–22 (פרוטוקולים) — הוא תת-המערכות הפנימיות של האפליקציה האמיתית (data-schema · 41-state · 42-card-flow · 47-helpers · 5-engines · launch). יחד = **התמונה המלאה של Flutter.**
