# מאגר הידע — אב-הטיפוס של BuildSmart

מאגר **חדש, מאפס**. מקור-האמת היחיד שלו הוא אב-הטיפוס:
**`/index.html`** בשורש הריפו — 1.4MB, **22,416 שורות**.

> נבנה על ענף-הכתיבה `claude/nice-volta-BSbVm` (קריאה מהקוד הקיים, כתיבה לכאן בלבד).
> 📖 **המקור נקרא מהענף הנכון `claude/whats-happening-LyY9G`** (האפליקציה הסופית) דרך git-worktree. ⭐ **תיקון:** `app_flutter/knowledge/` הוא **מאגר-ידע קיים ומקיף שנלכד כמקור** — לא "דף חלק" כפי שכתבתי בטעות.

> ⚠️ **בתהליך-תיקון מתמשך:** דלתאות-ה-Flutter שנשזרו ב-01–17 נכתבו בתחילה מ-snapshot **מיושן** (27 קבצים, nice-volta). האפליקציה האמיתית (123 קבצים, whats-happening) **נקראה במלואה** ועכשיו נשזרת-מחדש לתוך הדוחות. **המאגר עדיין לא שלם — יש עוד מידע רב להטמיע.** תקף ולא-מושפע: הפרוטוטייפ (01–17 base) + Preact.

## השיטה (חוק-ברזל)
1. **קוראים כל שורה, כל תיבה.** לא סורקים (grep), לא מנחשים, לא מדלגים. הידע
   נלכד רק ממה שנקרא במלואו.
2. **verbatim.** מחרוזות עברית, תוויות, ו-handlers מצוטטים כפי שהם, עם
   מיקום (`index.html:NNNN`).
3. **כל ידע חדש → לקובץ מיד.** (אין זיכרון בין sessions; מה שלא נכתב — אבד.)
4. **לא נוגעים בקוד.** רק לוכדים, מארגנים ומתחזקים ידע.

## מבנה אב-הטיפוס (3 שכבות)
| שורות | שכבה | מה יש |
|---|---|---|
| 1–13 | `<head>` | meta + title |
| 14–4019 | `<style>` | מערכת-העיצוב (CSS) — ~70 סקשנים, Categories A–J |
| 4021–5419 | `<body>` | המעטפת + כל המסכים והתיבות (mockup של טלפון) |
| 5419–5439 | `<script>` #1 | בוטסטרپ קצר |
| 5440–22414 | `<script>` #2 | כל הנתונים + הלוגיקה (713 פונקציות, ~40 מבני-נתונים) |

## הקבצים במאגר
| קובץ | תחום | טווח במקור |
|---|---|---|
| `README.md` (זה) | אינדקס + שיטה + מעקב-כיסוי | — |
| `01-design-system.md` | מערכת-עיצוב מלאה (8 חלקים א׳–ח׳) | 14–4019 |
| `02-shell-and-screens.md` | המעטפת + כל המסכים והתיבות | 4021–5419 |
| `03-data-product-trees.md` | מודל-המוצר — TREES (לב הדמו) | 5441–6044 |
| `04-data-catalog-variants-tools.md` | קטלוג/וריאציות/מידות/מלאי/כלים | 6046–6320 |
| `05-data-orders-projects-ranks.md` | סדר-הרכבה/פרויקטים/דרגות/זהות | 6323–6560 |
| `06-logic-settings-projects.md` | לוגיקה: הגדרות/פרופיל/פרויקטים/תקציב/סטטוס | 6560–7700 |
| `07-logic-orders-tasks-search.md` | לוגיקה: הזמנות/משימות/מלאי/ניווט/חיפוש | 7701–9000 |
| `08-logic-product-cart-checkout.md` | ליבת מוצר/עץ/אביזרים/סורק/סל/checkout | 9000–11000 |
| `09-logic-cart-notif-onboarding.md` | סל-render/checkout/התראות/onboarding/roles | 11000–11907 |
| `10-engine-pricing-stores-sysorders.md` | מנוע-מסחר: תמחור/ספקים/VAT/SYS_ORDERS | 11908–12061 |
| `11-manager-dashboard-selftest.md` | דשבורד-מנהל + BUTTON_REGISTRY/self-test | 12062–15900 |
| `12-persona-manager-store.md` | דשבורד-מנהל (מלא) + דשבורד-חנות | 15900–17627 |
| `13-scenarios-courier-registration.md` | פריט-חסר/אזל + דשבורד-שליח + רישום | 17627–18422 |
| `14-b2b-supply-chain.md` | B2B (Cat-A): planner/RMA/השכרה/פקדונות/MSDS/RFQ | 18423–19451 |
| `15-finance-site-hubs.md` | מרכז-פיננסים (B) + ניהול-אתר (C) | 19452–20800 |
| `16-portal-ai-rewards.md` | פורטל/chat (F) + AI (G) + תגמולים (H) | 20800–21659 |
| `17-security-service-boot.md` | אבטחה/RBAC (I) + שירות/chatbot (J) + boot + PWA/deploy | 21660–22414 |
| `18-legacy-knowledge-index.md` | אינדקס `app/knowledge` הישן (ADR · כללים · 43 INSP) | app/knowledge |
| `19-feature-source-matrix.md` | מטריצת פיצ'ר × מקור (אב-טיפוס/Preact/Flutter) | חוצה-מקורות |
| `20-infra-build-tooling-protocol.md` | build/native(Capacitor)/CI/extract-catalog/protocol | תשתית |
| `21-protocols-spine-gates-enforcement.md` | ⭐ עולם-הפרוטוקולים (1): MASTER_PROTOCOL · 116 שערים · 4 שכבות-אכיפה · scripts/CI | app_flutter (whats-happening) |
| `22-protocols-agents-process-specialized.md` | ⭐ עולם-הפרוטוקולים (2): 6 סוכנים · PLAYBOOK · סולם L0–L7 · 10 פרוטוקולים-ייעודיים · 15 ADRs · stuck_log | app_flutter (whats-happening) |
| `23-flutter-architecture-state-cardflow.md` | ⭐ Flutter: ארכיטקטורה · 41 providers · SmartProduct card-flow(42) · 47 helpers · 5 engines · launch-readiness | app_flutter (whats-happening) |

(קבצים נוספים ייווצרו ככל שנקרא. מספור לפי סדר השכבות במקור, לא לפי סדר הקריאה.)

## מעקב-כיסוי (COVERAGE) — מה כבר נקרא-ונלכד
> 🏁 **הושלם — כל 22,416 השורות של אב-הטיפוס נלכדו** (head + CSS + body + JS),
> ב-17 דוחות-תחום מאורגנים ומצוטטים. כל הטווחים מסומנים נלכד — אפס פערים.
> אם אב-הטיפוס ישתנה — להשוות SHA ולעדכן את הדוח הרלוונטי.

| טווח | תחום | סטטוס | קובץ-יעד |
|---|---|---|---|
| 1–13 | head | ✅ נלכד | `01-design-system.md` |
| 14–4019 | CSS — מערכת-עיצוב מלאה (8 חלקים א׳–ח׳: יסודות→4 פרסונות) | ✅ נלכד | `01-design-system.md` |
| 4021–5419 | body — מעטפת + מסכים + תיבות | ✅ נלכד | `02-shell-and-screens.md` |
| 5419–5440 | JS — bootstrap (error-catcher, script #1) | ✅ נלכד | `17` (boot) |
| 5441–6044 | JS — TREES (מודל-מוצר: pl_/stages/rich/+148) | ✅ נלכד | `03-data-product-trees.md` |
| 6046–6320 | JS — קטלוג/וריאציות/מידות/מלאי/כלים | ✅ נלכד | `04-data-catalog-variants-tools.md` |
| 6321–6560 | JS — ORDERS/PROJECTS/RANKS/זהות | ✅ נלכד | `05-data-orders-projects-ranks.md` |
| 6561–7700 | JS — לוגיקה: הגדרות/פרופיל/פרויקטים/תקציב/סטטוס | ✅ נלכד | `06-logic-settings-projects.md` |
| 7701–9000 | JS — הזמנות/משימות/מלאי/ניווט/חיפוש | ✅ נלכד | `07-logic-orders-tasks-search.md` |
| 9001–11000 | JS — ליבת מוצר/עץ/אביזרים/סורק/סל/checkout | ✅ נלכד | `08-logic-product-cart-checkout.md` |
| 11001–11907 | JS — סל-render/checkout/התראות/onboarding/roles | ✅ נלכד | `09-logic-cart-notif-onboarding.md` |
| 11908–12061 | JS — מנוע-מסחר (תמחור/ספקים/VAT/SYS_ORDERS) | ✅ נלכד | `10-engine-pricing-stores-sysorders.md` |
| 12062–15900 | JS — דשבורד-מנהל + BUTTON_REGISTRY/self-test | ✅ נלכד | `11-manager-dashboard-selftest.md` |
| 15901–17627 | JS — דשבורד-מנהל (מלא) + דשבורד-חנות | ✅ נלכד | `12-persona-manager-store.md` |
| 17628–18422 | JS — פריט-חסר/אזל + שליח + רישום | ✅ נלכד | `13-scenarios-courier-registration.md` |
| 18423–19451 | JS — B2B Category-A (planner/RMA/השכרה/MSDS/RFQ) | ✅ נלכד | `14-b2b-supply-chain.md` |
| 19452–20800 | JS — מרכז-פיננסים (B) + ניהול-אתר (C) | ✅ נלכד | `15-finance-site-hubs.md` |
| 20801–21659 | JS — פורטל/chat (F) + AI (G) + תגמולים (H) | ✅ נלכד | `16-portal-ai-rewards.md` |
| 21660–22414 | JS — אבטחה/RBAC (I) + שירות/chatbot (J) + boot | ✅ נלכד | `17-security-service-boot.md` |

## מפת-ניווט ל-JS (5440–22414) — אינדקס-מבנה, **✅ הכל נלכד**
> אינדקס שמות+שורות של מבני-הנתונים (כולם נקראו ותועדו בדוחות 03–17). משמש lookup מהיר "איפה X במקור".

מבני-נתונים (שורת-הגדרה): `TREES`5441 · `CATALOG`6046 · `VARIANTS`6060 ·
`SIZES`6185 · `STOCK_DEMO`6202 · `TOOLS`6216 · `ORDERS`6323 · `PROJECTS`6447 ·
`RANKS`6499 · `SETTINGS_LABELS`6750 · `HELP`6766 · `DEMO_HISTORY`7013 ·
`DELIVERY_WINDOWS`7103 · `ORDER_STATUS`7632 · `WORKERS`8021 · `TASKS`8023 ·
`WORK_LOG`8156 · `ATTR_SCHEMA`8341 · `NAV_DESTINATIONS`8450 · `CONTENT_INDEX`8514 ·
`ICN`9362 · `DIAGRAMS`9375 · `ACC_PRICE_BOOK`9518 · `PLAN_TYPES`9658 · `SPECS`9894 ·
`CAT_DESC`9906 · `ACC_TYPES`9991 · `ACC_GROUPS`10025 · `HOME_PRODUCTS`10614 ·
`CATEGORY_STORE`10816 · `DELIVERY_SLOTS`10908 · `ONBOARD_SCREENS`11634 ·
`STORE_PRICING`11908 · `STORES`11930 · `VAT_RATE`11941 · `SUPPLIER_STORES`11942 ·
`HAUL_TYPES`11950 · `EXPRESS_FEE`11961 · `SYS_ORDERS_SEED`11970 · `ORDER_STAGE`12041 ·
`STORE_STOCK`12050 · `BUTTON_REGISTRY`12517 · `BUTTON_TWINS`12900 ·
`CONTRACTOR_CREDIT`16537 · `ORDER_FLOW`16943 · `SIM_CUSTOMERS`17159 · `SIM_SITES`17160 ·
`VEHICLE_RANK`17946. (713 פונקציות מפוזרות בין אלה.)

## 🔄 מקור 2 — Preact (`app/`) — נשזר כדלתא בדוחות הקיימים
> ה-Preact (האפליקציה החיה בפרודקשן) **אינו מקבל דוחות נפרדים**. הוא נשזר כסקציית-דלתא
> בתוך כל דוח-תחום רלוונטי: **➕ נוסף · ⬆️ שודרג · ➖ הוחסר** מול אב-הטיפוס.
> מקור: `app/src/` (53 קבצי TS/TSX · 13,657 ש׳). הסיפור-הגדול: תרגום מסכים → **dial pattern**.
> 🏁 **הושלם — דלתא Preact נשזרה בכל 17 הדוחות.**

| דוח | דלתא-Preact | סטטוס |
|---|---|---|
| `02` מעטפת | dial pattern: מסכים→dials · tabbar→MenuSpeedDial · appbar→FloatingHeader · routing לפי-פרסונה | ✅ |
| `01` עיצוב | tokens זהים + סקאלות; מערכת-dial/fab/float נטו-חדשה | ✅ |
| `03/04/10` נתונים+מנוע | catalog/variants/tools/suppliers **auto-gen מ-index.html**, מטוייפים; brands נגזם; הסל פושט | ✅ |
| `06` הגדרות | renderSettings(sheet)→עץ-dial · LEAF_BINDINGS · PROFILE_TREE · inline-edit | ✅ |
| `07/08` חיפוש/מוצר | search=FAB-dial (voice/barcode מ-AI) · category-circles · product card/sheet; עץ-מלא לא הומר | ✅ |
| `11` QA · `12` פרסונות | self-test→test/ מודולרי (regression tabs); פרסונות→BS-dial drill, store-view מומש, השאר placeholder | ✅ |
| `05,09,13–17` hubs/scenarios | RANKS/identity/projects הומרו; ORDERS/B2B/finance/site/AI/rewards/security/service/onboarding/scenarios **לא הומרו** | ✅ |

## 📱 מקור 3 — Flutter (`app_flutter/`) — **האפליקציה הסופית** (יעד לחנויות)
> 🚧 **שכבה זו נכתבת-מחדש** מול הקוד האמיתי על `whats-happening` (התיאור הקודם היה מ-snapshot מיושן/27-קבצים).
> מקור: `app_flutter/lib/` (**123 קבצים · 61,550 ש׳**) · `test/` (155 · 16,441) · `app_flutter/knowledge/` (~88 מסמכים — מאגר-ידע קיים). Flutter 3.29 · Riverpod · go_router · shared_preferences · mobile_scanner · speech_to_text · permission_handler.
> ⭐ **לא** port של 5-הפרסונות — **אפליקציית-אינסטלציה בוגרת** (v5.92 · ~92% roadmap · קוד מוכן-להשקה).

| תחום | המציאות (אומת-מקוד, whats-happening) |
|---|---|
| מעטפת | 4 בוטם-טאבים: **מחלקות · שיחות · התראות · חנות** + AppBar (BS-dial / מצלמה / ⋮) + 3 dial-overlays (bs/search/menu) + cart-FAB |
| קטלוג | **1,877 מוצרים** (Lipskey 935 · Polyroll 772 · Huliot 170 — אומת שורה-שורה; HW-133 = רשימה נפרדת `kHotWaterCatalog`) מ-PDFים אמיתיים; 8 sections (הכל/בית-Finder/תכנון-חיבור/קטגוריות/עץ-חכם/וריאנטים/מועדפים/חיפושים) |
| ⭐ Install Studio | מנוע-תכנון-צנרת אמיתי: **Dijkstra-pathfinding · Darcy-Weisbach pressure-drop · auto-compliance (PRV/TMTV/הרחבה/dielectric) · BOM · שמירת-פרויקטים** (`install_engine` 1391ש׳ · `pressure_drop` 501). עמוק מהפרוטוטייפ |
| כרטיס-מוצר | brands · accessories (must/why) · install-stages · compat · compliance · score → add-to-cart; SKU↔`VerifiedSpec` bridge |
| state | **50 providers ב-41 קבצי `state/`** (114 repo-wide כולל UI-local; הנמשכים `bs.*.v1` ב-shared_preferences) |
| מסחר | `smart_cart` (persisted) · checkout VAT 18% (mock) · **chats(6)/notifications(smart-collapse)/store** אמיתיים + **4 מסכי-הגדרות** (~40 כל אחד) |
| עיצוב | מותג **כתום `#FF7A18`** (ה-KB מסמן כפער מ-teal המתוכנן) · Heebo · light/dark + RTL |
| QA/launch | **1,539+ בדיקות** (אומת `b4e2198`; גדל מאז) **· 47-helper-gate · 116 שערים** · LAUNCH_PACKAGE מוכן (aab חתום 68MB) · חוסמים = קונפיג-חנות (iOS-perms · keystore · Huliot-R2-crops) |
| מאגר-קיים | `app_flutter/knowledge/`: `port/proto`(פרוטוטייפ 100%) + `port/preact` + `spec/` + architecture/status/parity/roadmap — **נלכד כמקור** |

⚠️ **doc-vs-code drift שנתפס (הקוד קובע):** ה-KB אומר **tab0=קטלוג / מותג-teal** — הקוד אומר **tab0=מחלקות / כתום `#FF7A18`**. ✅ **ספירת-מוצרים: הקוד = 1,877 ≈ "~1,879" של ה-KB → תואם.** (ה-"1,337/Lipskey-255" שנכתב בסשן קודם היה **טעות**, תוקן שורה-שורה — ר' דוח 03.)
🚧 **סטטוס:** דלתאות-Flutter ב-01–17 + מקור-3 ייכתבו-מחדש מהמציאות הזו.

## 📚 מקור-משני — `app/knowledge/` (62 מסמכים) + `RULES.md` — סריקה-מלאה ✅
> כל המאגר-הישן נקרא **verbatim, שורה-אחר-שורה**, ונשזר/תוקן בדוחות 01–20.
> 🏁 **הושלם — 100% מקבצי ה-`.md` בריפו נקראו** (פרט ל-Xcode-LaunchImage boilerplate, ללא-ידע).
- **43/43 INSP** (`INSP-0001→0044`) — מפת-בנייה (doc 18); enrichments verbatim: hub-tile-labels (אבטחה 10 @21752 / שירות 8 @22081) · PROFILE_TREE L1–L3 · worker per-group status-filter (0042↔0041) · manager 4-sections @4213 · ניגודיות(לשמש)/אקספרס.
- **3 ADR** (no-window / dial-pattern / README) — ה-WHY; 2 חריגי-overlay + עיגון-4-פינות + bathroom-bg rationale (doc 18).
- **4 dashboards** (COURIER/STORE/WORKER/SYSTEM_MANAGER) + **UI_ARCHITECTURE** (1560 ש׳) — אישרו docs 10/12/13 (courier-6/store-8 portals · stores · HAUL).
- **`RULES.md` (הכללים)** (אומת: אין-המצאה · RTL · inline · 5-FAB-positions) · **inspector/** (prompt/checklist/loops) · **ROLE_DRAWER_SYSTEM** (5 subtitles + flows) · **IMPLEMENTATION_PROTOCOL** (deprecated).
- ⚠️ **divergences שנתפסו (המקור `index.html` קובע):** UI_ARCH profile-mockup (סולם-דרגות + 8-badges) ≠ `RANKS`/6-`identityAchievements` · SYSTEM_MANAGER מספרים/7-manage-sections/REST-API **מומצאים** · ROLE_DRAWER worker-names (דוד/אברהם/עלי) ≠ `WORKERS` (רן/עומר) · `adr`+README קדמו-לכלל-ה-inline.

## ⭐ אימות-מקור — קוד Preact + Flutter נקרא line-by-line ✅
> ⚠️ **סעיף זה תיעד אימות מול ה-snapshot המיושן של Flutter (27/8,482).** ה-**Preact** (55/15,841) תקף; ה-**Flutter האמיתי** (123/61,550) נקרא-מחדש בנפרד — ראה מקור-3 + דוחות 21–23. תיקוני-ה-Preact למטה תקפים:
- `LEAF_BINDINGS`=**72** (לא ~70) · service-hub=**15** (לא ~16) · `AppSettings`=**6 מפתחות** (+security) → doc 06/17.
- `fabs.tsx`=**2 FABs** (menu+search); BS/שם/עגלה ב-`FloatingHeader` — 5 האלמנטים הקבועים מפוצלים 2+3 (doc 02 כבר מדויק).
- ~~Flutter ~30 מוצרים~~ → **בוטל (snapshot מיושן). האמת: 1,877 מוצרים / 3 מותגים** (935+772+170, אומת שורה-שורה — דוח 03/19). Flutter search-dial=4 כלים — תקף.
- Preact `registry.ts`=**21 כפתורים** (מול ~350 בפרוטוטייפ) → doc 11.
- ⚠️ **parity-insight תוקן:** Preact = shell+leaves=toast. **אבל Flutter האמיתי בוגר** (Install-Studio · checkout · 1,023-בדיקות · 116-שערים) — **לא** 'shell+toast'. ראה דוחות 02/08/19/23.
- ✅ **CONFIRMED:** voice/barcode אמיתיים (web + native) · brands: Preact גזם / Flutter שחזר (מותג סטנדרט/כלכלי/פרימיום) · brand-color: teal `#1f6f6b` (Preact) ↔ orange `#FF7A18`+`#E85F00` (Flutter) · `shared_preferences` persist אמיתי (Flutter) · 202 מוצרים + tokens + dark-theme `#3a9e99` (Preact).
🏁 **3 המקורות אומתו ברמת-קוד.**

## ⚙️ config/infra — נקרא verbatim ✅
> כל קבצי ה-build/config נקראו: `package.json` · `vite.config.ts` · `capacitor.config.ts` · `tsconfig.json` · `smoke-settings.mjs` · `pubspec.yaml` · `analysis_options.yaml` · `manifest.json` · `service-worker.js` · `vercel.json` · `deploy.yml` + 2 web-shells.
- ⭐ **תיקון מהותי:** `deploy.yml` פורס את **שתי האפליקציות** — Preact→`/buildsmart/` **+ Flutter web→`/buildsmart/flutter/`** (flutter 3.29.3). לא רק Preact חי! → doc 20.
- ➕ Workbox-strategy (NetworkFirst/SWR/CacheFirst) → doc 17 · Capacitor `cap:*` scripts + cli/core מותקנים → doc 20 · dep-versions מדויקים → doc 20 · `security`={twoFA,sessionTimeout,privacy.analytics} (אומת מ-smoke) → doc 06 · Flutter-web מבטל SW (אין offline) → doc 17.
🏁 **הכל נקרא ואומת — `.md` + פרוטוטייפ (22,416) + קוד-מקור (24K) + config + native-manifests.** נותרו רק lockfiles · תמונות · יתר platform-scaffold = boilerplate מיוצר (ה-content-bearing נלכד: Android `applicationId=com.buildsmart.buildsmart` + iOS-perms-gap → doc 20).
