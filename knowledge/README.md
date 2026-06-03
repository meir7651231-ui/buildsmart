# מאגר הידע — אב-הטיפוס של BuildSmart

מאגר **חדש, מאפס**. מקור-האמת היחיד שלו הוא אב-הטיפוס:
**`/index.html`** בשורש הריפו — 1.4MB, **22,416 שורות**.

> נבנה על ענף-הכתיבה `claude/nice-volta-BSbVm` (קריאה מהקוד הקיים, כתיבה לכאן בלבד).
> **לא** קשור לפרוטוקול / ל-`app_flutter/knowledge/port/` הקיים. זה דף חלק.

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
| `18-legacy-knowledge-index.md` | אינדקס `app/knowledge` הישן (ADR · R1–R9 · 43 INSP) | app/knowledge |
| `19-feature-source-matrix.md` | מטריצת פיצ'ר × מקור (אב-טיפוס/Preact/Flutter) | חוצה-מקורות |
| `20-infra-build-tooling-protocol.md` | build/native(Capacitor)/CI/extract-catalog/protocol | תשתית |

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
> מקור: `app/src/` (53 קבצי TS/TSX · 13,657 ש׳). הסיפור-הגדול: תרגום מסכים → **dial pattern** (R1–R9).
> 🏁 **הושלם — דלתא Preact נשזרה בכל 17 הדוחות.**

| דוח | דלתא-Preact | סטטוס |
|---|---|---|
| `02` מעטפת | dial pattern: מסכים→dials · tabbar→MenuSpeedDial · appbar→FloatingHeader · routing לפי-פרסונה | ✅ |
| `01` עיצוב | tokens זהים + סקאלות; מערכת-dial/fab/float נטו-חדשה (R1/R9) | ✅ |
| `03/04/10` נתונים+מנוע | catalog/variants/tools/suppliers **auto-gen מ-index.html**, מטוייפים; brands נגזם; הסל פושט | ✅ |
| `06` הגדרות | renderSettings(sheet)→עץ-dial (R3) · LEAF_BINDINGS · PROFILE_TREE · R9 inline-edit | ✅ |
| `07/08` חיפוש/מוצר | search=FAB-dial (voice/barcode מ-AI) · category-circles · product card/sheet; עץ-מלא לא הומר | ✅ |
| `11` QA · `12` פרסונות | self-test→test/ מודולרי (R7 tabs); פרסונות→BS-dial drill, store-view מומש, השאר placeholder | ✅ |
| `05,09,13–17` hubs/scenarios | RANKS/identity/projects הומרו; ORDERS/B2B/finance/site/AI/rewards/security/service/onboarding/scenarios **לא הומרו** | ✅ |

## 📱 מקור 3 — Flutter (`app_flutter/`) — נשזר כדלתא בדוחות
> ה-Flutter (native iOS/Android/Web, ה-target לחנויות) נשזר כסקציית-דלתא (`📱 Flutter`).
> מקור: `app_flutter/lib/` (27 קבצי dart · 8,482 ש׳). **Riverpod + go_router + device-APIs אמיתיים** (mobile_scanner/speech_to_text/shared_preferences).

| דוח | דלתא-Flutter | סטטוס |
|---|---|---|
| `01` עיצוב | tokens פורט מ-Preact; **מותג כתום #FF7A18** (לא teal); native light/dark + RTL + i18n | ✅ |
| `02` מעטפת | מעטפת WhatsApp: 4 בוטם-טאבים (קטלוג/שיחות/התראות/חנות) + dial-overlays | ✅ |
| `03/04/15` data+hub | smart_tree **brands שוחזרו** · menu_trees + **kFinanceHub** | ✅ |
| `06/07` הגדרות/חיפוש | settings-dial · **device-APIs אמיתיים** (mobile_scanner/speech_to_text) | ✅ |
| `08/09/16` קטלוג/התראות/שיחות | catalog_screen · **chats+notifications = טאבים native מלאים** ⭐ | ✅ |
| `05,10–14,17` שאר | projects.dart; ORDERS/B2B/site/security/self-test/scenarios **לא הומרו** | ✅ |

🏁 **הושלם — דלתא Flutter נשזרה בכל 17 הדוחות.** המאגר מחזיק עכשיו **3 מקורות** (אב-טיפוס בסיס · Preact · Flutter) בכל דוח.

## 📚 מקור-משני — `app/knowledge/` (62 מסמכים) + `RULES.md` — סריקה-מלאה ✅
> כל המאגר-הישן נקרא **verbatim, שורה-אחר-שורה**, ונשזר/תוקן בדוחות 01–20.
> 🏁 **הושלם — 100% מקבצי ה-`.md` בריפו נקראו** (פרט ל-Xcode-LaunchImage boilerplate, ללא-ידע).
- **43/43 INSP** (`INSP-0001→0044`) — מפת-בנייה (doc 18); enrichments verbatim: hub-tile-labels (אבטחה 10 @21752 / שירות 8 @22081) · PROFILE_TREE L1–L3 · worker per-group status-filter (0042↔0041) · manager 4-sections @4213 · ניגודיות(לשמש)/אקספרס.
- **3 ADR** (no-window / dial-pattern / README) — ה-WHY; 2 חריגי-R2 + עיגון-4-פינות + bathroom-bg rationale (doc 18).
- **4 dashboards** (COURIER/STORE/WORKER/SYSTEM_MANAGER) + **UI_ARCHITECTURE** (1560 ש׳) — אישרו docs 10/12/13 (courier-6/store-8 portals · stores · HAUL).
- **`RULES.md` R1–R9** (אומת: R7=אין-המצאה · R8=RTL · R9=inline · R1 5-FAB-positions) · **inspector/** (prompt/checklist/loops) · **ROLE_DRAWER_SYSTEM** (5 subtitles + flows) · **IMPLEMENTATION_PROTOCOL** (deprecated).
- ⚠️ **divergences שנתפסו (המקור `index.html` קובע — R6):** UI_ARCH profile-mockup (סולם-דרגות + 8-badges) ≠ `RANKS`/6-`identityAchievements` · SYSTEM_MANAGER מספרים/7-manage-sections/REST-API **מומצאים** · ROLE_DRAWER worker-names (דוד/אברהם/עלי) ≠ `WORKERS` (רן/עומר) · `adr`+README קדמו-ל-R9.

## ⭐ אימות-מקור — קוד Preact + Flutter נקרא line-by-line ✅
> הדלתאות (מקור 2+3) נבנו תחילה מ-**תיאורים** (INSP/legacy-map) — עכשיו **אומתו מול קוד-המקור האמיתי** (Preact 55 קבצים/15,841 ש׳ + Flutter 27/8,482). רוב CONFIRMED; **תיקונים שנמצאו ותוקנו:**
- `LEAF_BINDINGS`=**72** (לא ~70) · service-hub=**15** (לא ~16) · `AppSettings`=**6 מפתחות** (+security) → doc 06/17.
- `fabs.tsx`=**2 FABs** (menu+search); BS/שם/עגלה ב-`FloatingHeader` — 5 ה-R1-elements מפוצלים 2+3 (doc 02 כבר מדויק).
- **Flutter ~30 מוצרים** (smart_tree, brands), לא 202; `catalog.dart`=11 קטגוריות; Flutter search-dial=**4 כלים** (בלי קטלוג) → doc 03/07.
- Preact `registry.ts`=**21 כפתורים** (מול ~350 בפרוטוטייפ) → doc 11.
- **parity-insight:** שני ה-ports = shell+dial מלאים, leaves=toast `'בבנייה'`; Flutter הוסיף תוכן-דמו עשיר ב-chats(6)/notif(9)/store(8) → doc 02.
- ✅ **CONFIRMED:** voice/barcode אמיתיים (web + native) · brands: Preact גזם / Flutter שחזר (מותג סטנדרט/כלכלי/פרימיום) · brand-color: teal `#1f6f6b` (Preact) ↔ orange `#FF7A18`+`#E85F00` (Flutter) · `shared_preferences` persist אמיתי (Flutter) · 202 מוצרים + tokens + dark-theme `#3a9e99` (Preact).
🏁 **3 המקורות אומתו ברמת-קוד.**

## ⚙️ config/infra — נקרא verbatim ✅
> כל קבצי ה-build/config נקראו: `package.json` · `vite.config.ts` · `capacitor.config.ts` · `tsconfig.json` · `smoke-settings.mjs` · `pubspec.yaml` · `analysis_options.yaml` · `manifest.json` · `service-worker.js` · `vercel.json` · `deploy.yml` + 2 web-shells.
- ⭐ **תיקון מהותי:** `deploy.yml` פורס את **שתי האפליקציות** — Preact→`/buildsmart/` **+ Flutter web→`/buildsmart/flutter/`** (flutter 3.29.3). לא רק Preact חי! → doc 20.
- ➕ Workbox-strategy (NetworkFirst/SWR/CacheFirst) → doc 17 · Capacitor `cap:*` scripts + cli/core מותקנים → doc 20 · dep-versions מדויקים → doc 20 · `security`={twoFA,sessionTimeout,privacy.analytics} (אומת מ-smoke) → doc 06 · Flutter-web מבטל SW (אין offline) → doc 17.
🏁 **הכל נקרא ואומת — `.md` + פרוטוטייפ (22,416) + קוד-מקור (24K) + config + native-manifests.** נותרו רק lockfiles · תמונות · יתר platform-scaffold = boilerplate מיוצר (ה-content-bearing נלכד: Android `applicationId=com.buildsmart.buildsmart` + iOS-perms-gap → doc 20).
