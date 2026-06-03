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
| `17-security-service-boot.md` | אבטחה/RBAC (I) + שירות/chatbot (J) + boot | 21660–22414 |

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

## מפת-ניווט ל-JS (5440–22414) — roadmap לקריאה, **טרם נלכד**
> רשימת שמות+שורות בלבד, להכוונת הקריאה הרציפה. **התוכן ייחשב נלכד רק אחרי
> קריאה מלאה** של הטווח והעברתו לקובץ-תחום. לא תחליף לקריאה.

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

| דוח | דלתא-Preact | סטטוס |
|---|---|---|
| `02` מעטפת | dial pattern: מסכים→dials · tabbar→MenuSpeedDial · appbar→FloatingHeader · routing לפי-פרסונה | ✅ |
| `01` עיצוב | tokens זהים + סקאלות; מערכת-dial/fab/float נטו-חדשה (R1/R9) | ✅ |
| `03/04/10` נתונים+מנוע | catalog/variants/tools/suppliers **auto-gen מ-index.html**, מטוייפים; brands נגזם; הסל פושט | ✅ |
| `06` הגדרות | renderSettings(sheet)→עץ-dial (R3) · LEAF_BINDINGS · PROFILE_TREE · R9 inline-edit | ✅ |
| `07/08` חיפוש/מוצר | search=FAB-dial (voice/barcode מ-AI) · category-circles · product card/sheet; עץ-מלא לא הומר | ✅ |
| `09,11–17` סל/QA/פרסונות/hubs | — | ⬜ בעבודה |
