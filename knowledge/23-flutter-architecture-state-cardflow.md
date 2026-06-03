# Flutter — ארכיטקטורה · state-model · card-flow · helpers · engines · launch

> השלמת-התמונה: תת-המערכות של האפליקציה האמיתית (`app_flutter/`, whats-happening) שלא נכנסו במלואן לדלתאות 01–17. נלכד מ-`app_flutter/knowledge/` (SCHEMA/STATE_OVERVIEW/CARD_FLOW/HELPER_INDEX/SMARTPRODUCT_ROADMAP/LAUNCH_READINESS) + הקוד. **אומת-מקוד.**

## A. ארכיטקטורה
Flutter 3.29 (deploy 3.44) · Dart 3.7 · **Riverpod** · go_router · `main.dart` → `registerPolyrollSpecs()` → `ProviderScope` → `MaterialApp` → **`OnboardingGate`** (welcome/HomeShell). שכבות: `data/` (25) · `logic/` (5 engines) · `state/` (41 providers) · `screens/` (30) · `widgets/` · `theme/` · `l10n/` · `test_harness/`. **SSOT · אין circular-deps · Preact-shared מבודד** (5 קבצי-settings = JSON-contracts).

## B. SCHEMA — 3 עמודי-נתונים (SKU = מפתח-העל)
1. **`kCatalogProducts`** (1,337 · `LipskeyCatalogProduct`) — קטלוג מאוחד (Lipskey 255 + Polyroll 779 + Huliot 170 + HW-סינתטי 133).
2. **`kVerifiedSpecs`** (808+ · `VerifiedSpec`{sku,material,ends[ConnectorEnd],pressureRating,maxTempC,systemOverride}) — **מנוע-החיבוריות**. enums EndType/WaterSystem.
3. **`kSmartProducts`** (~81 · `SmartProduct`{key,name,cat,brands[],acc[],stages[]}) — כרטיסים-מובחרים. **SKU על ה-brand.**
- **גשר:** forward `catalogProductForBrand(brand)` · reverse `smartProductForSku(sku)`. round-trip שמור (`smartproduct_contract_test`, 307/365 brands-עם-SKU).

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
- **`install_engine.dart` (1,391ש׳):** Dijkstra least-cost pathfinding (cost=parts+material-transition+bore) · auto-compliance (PRV/expansion-vessel/TMTV/dielectric/ball-valve/clips/sealant; recirc-loop +shutoffs/check/balance) · `buildInstallation`/`buildTreeInstallation` (manifold) · `materializeChain`.
- **`pressure_drop.dart` (501ש׳):** Darcy-Weisbach ΔP=(K+fL/D)½ρv²+ρgh · autofix (bottleneck-swap/booster-pump HW-PUMP-40 אם ΔP>1bar או rise≥10m) · drainage-slope ≥2% (ת"י 1205).
- **`install_kit.dart`** (tool+sealant per-joint, brand-override פולירול-260°C-welder) · **`price_estimate.dart`** (category-ILS, fallback 25₪, lowConfidence>50%-unmatched) · **`system_division.dart`** (supply/drainage taxonomy, PPR→supply, fixtures→both).

## G. Launch-readiness (`LAUNCH_READINESS.md`)
- **קוד בריא:** ~92% roadmap · 0 analyze-errors · 948-tests · SSOT.
- **Web/PWA 🟢 GO** (אחרי asset-opt 101MB→WebP). **iOS 🔴 NO-GO** (Info.plist camera/mic usage-strings + signing-team). **Android 🔴 NO-GO** (release-keystore + Play-account).
- **P0 = store-config (לא קוד).** P1: asset-opt · status-line · הסרת-deps-לא-בשימוש (go_router?) · נעילת-theme.light · exclude-test_harness-מ-release · חיווט-search/menu-dials (5-FAB או BS-only) · global-error-handler. **חסום:** pricing(`brandPrice=0`)/ratings/AI/push/telephony.
- **`LAUNCH_PACKAGE/`:** aab חתום 68MB · store-listing he/en · privacy-policy · data-safety · `SEND_TO_GOOGLE.md` runbook.

## H. ROADMAP (`SMARTPRODUCT_ROADMAP.md`, 100 צעדים · ~92% ✅)
phases: 1-unification · 2-data-enrichment · 3-compat · 4-install · 5-price · 6-AI/personalization · 7-search · 8-contractor-projects · 9-quality/a11y · 10-platform/moonshots(🟦). **coach-mode (99–100)** = הכרטיס-כמורה (text-only שמיש היום מ-helpers; voice/AR/camera=שדרוגי-ערוץ).

---
**הקשר:** דוח זה משלים את 01–17 (deltas) ו-21–22 (פרוטוקולים) — הוא תת-המערכות הפנימיות של האפליקציה האמיתית (data-schema · 41-state · 42-card-flow · 47-helpers · 5-engines · launch). יחד = **התמונה המלאה של Flutter.**
