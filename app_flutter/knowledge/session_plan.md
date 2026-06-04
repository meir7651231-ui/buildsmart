# Session Plan — חלוקת מים/שפכים דרך ה-finder (בנצי #1, option 2)

Owner: this session
Scope: departments_screen + finder_screen + catalog_screen — מחלקה פותחת את ה-finder (בית) מסונן-מערכת, לא עץ כפוי. אסור לגעת ב-lib/data (קטלגן) או install_engine.

Style: phase → analyze (0) → test (1009) → commit מקומי. אין push ללא "תדחוף".

המשתמש בחר **option 2**: מחלקה → ה-finder הרגיל (בית/הכל/קטגוריות/חיפושים/תכנון חיבור),
אבל כל סקשני-ה-browse מסוננים ל-WaterSystem. (option 1 = tree כפוי — מוחלף.)

## אבחון (Explore — 2026-06-02)
מסונן כבר: `_TreeDrill` + `_SearchResultsList`. **לא** מסונן: בית (`FinderScreen`),
הכל (`_AllOverview`), קטגוריות (`_CatalogList`), מועדפים, עץ חכם.
מקור-דאטה של בית: `_productsForGroup(g)` → `kCatalogProducts`. helpers
(`productDivisionSystems`/`filterBySystem`/`nodeHasSystem`) ב-catalog_screen, אין test refs.
catalog_screen מייבא finder_screen → finder לא יכול לייבא חזרה (cycle).

## Phases

### Phase 1 — Foundation + Landing + Finder ⬜
- [1a] חילוץ `system_division.dart` (logic): provider + 3 helpers — בלי cycle
- [1b] departments: tap → system filter + `catalogSectionProvider='בית'` + clear tree
- [1c] finder: סינון `_productsForGroup` + הסתרת groups/subs ריקים
- [1d] שבב-scope dismissible ("מציג: שפכים ✕") — המשתמש יודע/מנקה
- [1e] עדכון טסטים (widget/journey/robustness) → ירוק 1009

### Phase 2 — שאר הסקשנים ✅ (v5.70)
- קטגוריות + הכל (קטגוריות+מועדפים) + מועדפים → `_catRowsForSystem` + `filterBySystem`
- screenshot verification ✅ (פאזה 1 + מסך מסונן); 1019 ירוק
- **Phase 2b ✅ (v5.71):** עץ חכם — `filterSmartBySystem` ממפה את ה-SKU של מותגי
  SmartProduct חזרה לקטלוג (`smartProductSystems`); לא-פתיר → נשאר בשני הצדדים (R8).
  3 בדיקות חדשות (identity · no-vanish · mapping-not-no-op). 1023 ירוק.

### Phase 3 — ניקוי ✅ (v5.71)
- בורר המערכת הכפול (`sysOpt`) הוסר מגיליון ⚙️ הפילטרים — המערכת מגיעה רק מהמחלקות
  (source-of-truth אחד; bypass של ה-scope-bar נמנע). נשאר רק פילטר התמונה.

## החלטות-ברירת-מחדל (screenshot visual verification בכל פאזה)
- תכנון חיבור (install studio) + חיפושים אחרונים = system-agnostic (כלי-תכנון / מחרוזות).

---

# Follow-on — Benzi #6: autocomplete לחיפוש ✅ (v5.78, rebased על Huliot v5.77)
Owner: this session · Scope: `catalog_screen.dart` בלבד (search panel). אסור לגעת ב-lib/data.
- `searchSuggestions` (pure, top-level ליד `catalogProductMatchesQuery`): שבבי-השלמה
  לקטגוריות תוך-כדי-הקלדה מעל `kLipskeyCatalog`, מסונני-מערכת (`filterBySystem`),
  דירוג name-hit → popularity → א-ת, cap 6, לא מהדהד קטגוריה שכבר הוקלדה במלואה.
- UI: `_SearchSuggestions` chip-row מעל התוצאות ב-`_SearchPanel` (≥2 תווים, scope מוצרי).
  טאפ משלים `searchQueryProvider` → התוצאות מתעדכנות.
- בדיקה: `search_suggestions_test` (5 — empty · real/distinct/capped · limit · no-echo · system-scope).
- analyze 0 · full suite ירוק (אחרי rebase על origin v5.77).

# Follow-on — שורות הקטגוריה חיות פר-מחלקה ✅ (v5.79)
משוב משתמש: "אני רואה עדיין בתיאורים אותו דבר" — שורות ה-קטגוריות הציגו `_kMeta`
סטטי (טקסט שיווקי + timestamp + badge קבוע), זהה בכל מחלקה.
- `_categorySummary(title, system)`: סופר מוצרי-במערכת אמיתיים מתחת לצומת-העץ +
  בונה תיאור מתת-הקטגוריות שבמערכת. `_CatalogRow` מציג ספירה+תיאור אמיתיים, ה-timestamp
  המזויף הוסר. `_kMeta` נמחק (call-sites: `_CatalogList`/`_AllOverview`/`_FilteredCatalogList`).
- אומת בצילום: אסלות שפכים 60 (מושבי אסלה · חיבורי אסלה) מול נקיים 30 (מיכלי הדחה).
- analyze 0 · 1035 ירוק.

# Follow-on — מחלקות כלי-עבודה אוספות כל קטגוריות-הכלים ✅ (v5.82→v5.83)
משוב משתמש: "מה שאין תשאיר בקרוב, אבל יש לך כלי עבודה" + "כן כל מה שכלי עבודה".
**אודיט מלא** (99 קטגוריות-עלה + חיפוש בשמות-מוצרים): הקטלוג 100% אינסטלציה (1879).
5 מקצועות (חשמל/בניין/צבע/גבס/אספקה) = 0 מוצרים אמיתיים → "בקרוב" (R8; "התאמות"
כמו לבן/ברגים/מדיח-כלים = false-positives). כל הכלים האמיתיים → 2 מחלקות חיות:
- `toolCats` (List<categoryHe>) + `_toolDeptPath` → synthetic node → `catalogTreePathProvider`.
- כלי עבודה ידני → `כלי עבודה` (2 מפתחות) + `חותך צינורות` (2 חותכים) = 4.
- כלי עבודה חשמלי → `כלי ריתוך PPR` (35 מזוודות/מכונות/מקדחים/מברגות).
- גבול שנשאר בחוץ: מכשירי לחץ/מנגנונים/סטי-הידוק = פיטינג, לא כלים.
- בדיקה: `departments_test` (toolCats ⇒ live + כל קטגוריה >0; placeholders לא-live). 1039 ירוק.

# Benzi #6 — מ-קטגוריות ל-השלמת-מילים-לפי-מוצרים ✅ (v5.85)
משוב בנצי (רשימה מקורית, פריט 6): "השלמת מילים לפי מוצרים שמופיע באפליקציה".
ה-v5.80 הציע קטגוריות → הוחלף: `searchSuggestions` משלים את המילה הנכתבת מאוצר-המילים
של שמות-המוצרים (token אחרון = fragment; מילים שהוא prefix שלהן; frequency→א-ת; cap 6;
שומר מילים שכבר הוקלדו). מסונן-מערכת. אומת בצילום (מח → מחסום·מחבר·מחזיק).
`search_suggestions_test` נכתבה מחדש (5). 1044 ירוק.

# Benzi #5 — "כל המוצרים ברצף" per-מחלקה ✅ (v5.86)
דרישה (פריט 5): "כל המוצרים ברצף ללא קשר לקטלוג, בכל ענף לבד".
- `deptFlatProductsProvider` (bool) + toggle "כל המוצרים"↔"קטלוג" ב-`_DeptScopeBar`.
- `departmentProducts(system/toolCats)`: water=`filterBySystem(kCatalogProducts)`,
  tool=מוצרי ה-toolCats. מרונדר ב-`LipskeyProductsList` שטוח (במקום ה-CatalogScreen).
- reset על פתיחת-מחלקה + "כל המחלקות". `departments_test` +3 (6 סה"כ). 1047 ירוק.
- אומת בצילום: אינסטלציה→"כל המוצרים"→רשימה שטוחה של כל מוצרי-השפכים.

# Benzi #4 — חלונית "לאן לשלוח" לא-מחייבת ✅ (v5.89)
דרישה (פריט 4) + הבהרת מיקום: "אחרי הזמן עכשיו, לפני אישור הזמנה, בשורה למעלה".
תיקון: בתחילה שמתי בעגלה (אחרי אפשרויות-המשלוח) — המשתמש הבהיר ש"הזמן" = כפתור
"הזמן עכשיו", אז הועבר לראש חלונית סיכום-ההזמנה.
- `_ShipToRow` בראש sheet הסיכום (אחרי הכותרת, לפני "אישור הזמנה").
- `_openShipToSheet`: חלונית לא-מחייבת — שדה כתובת + דלג/שמירה; אפשר לאשר בלי כתובת.
- `shipToProvider` (ריק=לא הוגדר; checkout לא דורש). אומת בצילום (sheet + popup). 1056 ירוק.

# 👔 Manager persona — 📊 dashboard: 5 leaves → real numbers (גל 1: M0+M1) (v5.93)
Owner: this session
Scope: `lib/logic/manager_dashboard.dart` (M0, חדש) + `lib/screens/bs_dial_widget.dart` +
`lib/state/dial_state.dart` (M1). אסור לגעת ב-Preact-shared, ב-`lib/data` (קטלגן), או
ב-personas/sections (העלים כבר מוגדרים ב-`sections.dart` `kManagerSections`→`m-products`).

מקור-אמת verbatim: `index.html` (repo root). `mgrAnalytics`@12081 · `renderMgrDashboard`@12133 ·
`mdMetric`@12160-12164 · `ORDER_FLOW`@16943. **לא** `SYSTEM_MANAGER.md` (מספרים מומצאים).

Style: M0 (logic+test) commit אחד → M1 (widget+state+widget-test) commit שני. אין push
ללא "תדחוף". incremental — מוות אסור שימחק הכל.

## M0 — foundation ✅
- `manager_dashboard.dart` (PURE Dart): seed (STORES/SYS_ORDERS_SEED/TREES-dist/STORE_STOCK)
  + `ManagerAnalytics` getters = 5 ה-mdMetric tiles. אומת מול הקוד החי ב-index.html
  (node-replay של לולאת `mgrAnalytics` על TREES@5441-6044): total=202 · catalog=54 ·
  acc=148 · avail=202 · cats=14 · stores=3/3 — תואם 1:1.
- `kManagerOrderFlow` (@16943) + `contractorCredit` + `mgrCustomerList` = foundation ל-M2/M3.
- `manager_dashboard_test` (12) ירוק.

## M1 — wire 5 leaves inline (R2, NO new screen) ✅
- `bsMetricLeafProvider` (state): ה-`md-*` הפתוח (toggle) · ב-`resetAllDials`.
- `bs_dial_widget.dart`: tap על leaf `md-*` → `_ManagerMetricPanel` inline מעל ה-dial
  (מספר אמיתי מ-`managerAnalytics`), במקום toast "בבנייה". 4 שאר ה-leaf-types ללא שינוי.
- `bs_dial_manager_test` (4 widget): 5 leaves נוכחים · tap→מספר אמיתי · אין "בבנייה" · toggle.

## M2 — wire 6 עלי `mo-*` (סטטוס הזמנות) inline (R2, NO new screen) ✅
- `bsOrderLeafProvider` (state): ה-`mo-*` הפתוח (toggle) · ב-`resetAllDials` · נוקה בכל pop/drill.
- `bs_dial_widget.dart`: tap על leaf `mo-*` → `_ManagerOrderPanel` inline מעל ה-dial. כל leaf =
  שלב אחד ב-`kManagerOrderFlow`; הפאנל מסנן את `kManagerOrderSeed` לאותו שלב ומציג שורה לכל
  הזמנה (`📦 id` / `who · site` / `items פריטים · ₪sum`, כמו `mo-card` הלגאסי) + ספירה בכותרת.
  שלב ריק (pickup · delivered בזרע) → טקסט ה-empty הלגאסי "לא נמצאו הזמנות תואמות." (@16986).
  panel הזמנות ומטריקה הדדית-בלעדיים. אין יותר toast "בבנייה".
- `kManagerOrderLeafStage` (leaf→stage) + `kManagerOrderLeafIds` + `_kOrderStageLabel`
  (שם-שלב עברי verbatim מ-`ORDER_STAGE`@12041-12048).
- `bs_dial_manager_orders_test` (5): 6 leaves נוכחים · כל שלב מאוכלס→שורת-ההזמנה האמיתית · 2
  השלבים הריקים→טקסט empty · metric/order mutual-exclusion · אין "בבנייה".

## M3 — wire 2 עלי `mc-*` (לקוחות) inline (R2, NO new screen) ✅ (v5.95)
- `bsCustomerLeafProvider` (state): ה-`mc-*` הפתוח (toggle) · ב-`resetAllDials` · נוקה בכל pop/drill.
- `bs_dial_widget.dart`: tap על leaf `mc-*` → `_ManagerCustomerPanel` inline מעל ה-dial. כל leaf =
  סטטוס-לקוח אחד (`kManagerCustomerLeafStatus`: `mc-live`=פעיל · `mc-low`=אשראי גבוה, תוויות
  pill verbatim @16592); הפאנל מסנן את `mgrCustomerList` לאותו סטטוס ומציג שורה לכל קבלן
  (`👷 name` / `orders הזמנות · sites אתרים` / pill / `ניצול אשראי: ₪spent / ₪credit (pct%)`,
  כמו `mc-card` הלגאסי @16593-16604; `pct`/`status`/`sites` נגזרים בדיוק @16554,16559-16562) +
  ספירה בכותרת. עם תקרות ה-credit של Dart כל 4 הקבלנים נופלים ל-`live` → **`mc-low` ריק** →
  טקסט ה-empty הלגאסי "לא נמצאו קבלנים תואמים." (@16586). panel לקוחות/הזמנות/מטריקה
  הדדית-בלעדיים. אין יותר toast "בבנייה".
- `kManagerCustomerLeafStatus` (leaf→status) + `kManagerCustomerLeafIds` + `_kCustomerStatusLabel`
  + `_grouped` (toLocaleString) + `_CustomerView`/`_customersForStatus`.
- `bs_dial_manager_customers_test` (4): 2 leaves נוכחים · mc-live→שורות-הקבלן האמיתיות ·
  mc-low ריק→טקסט empty · metric/order/customer mutual-exclusion · אין "בבנייה".

## M4 — wire כל עלי `mm-*` (🛠️ ניהול) — הגל האחרון של המנהל ✅ (v5.96)
- `bsManageLeafProvider` (state): ה-`mm-*` data-view הפתוח (toggle) · ב-`resetAllDials` · נוקה בכל pop/drill.
- `bs_dial_widget.dart`: פורט נאמן של `renderMgrManage` (@index.html:16645-16743) —
  - `mm-cats` (🗂️ קטגוריות) → `_ManagerManagePanel` inline: הקטגוריות האמיתיות + ספירת-מוצרים מ-
    `kManagerCatalogCategories` (אותה ספירת TREES-לפי-`cat` שה-SECTION 3 בונה @16716), כותרת
    `קטגוריות פעילות (14)` + הרמז verbatim "שינוי שם קטגוריה מעדכן את כל המוצרים שבה.".
  - `mm-settings` (⚙️ הגדרות אפליקציה) → אותו panel עם 3 שורות-קונפיג אמיתיות מהקבועים (SECTION 4
    @16733-16740): תוספת אקספרס=₪80 (`EXPRESS_FEE`) · אשראי=₪50,000 (`creditLimit`, toLocaleString) ·
    מע״מ=18% (`VAT_RATE`) + הרמז verbatim.
  - `mm-trees`/`mm-brands` → הלגאסי = עריכת `prompt()` מול שרת (אין backend) → toast עם תווית-הפעולה
    האמיתית verbatim (תת-כותרת ה-`mmSection` @16653/16687), **לא** "בבנייה".
  - `mm-regression` → **ללא שינוי** — עדיין route ל-`RegressionPanelScreen`.
  panel ה-data הוא R2 (dial-drill, אין מסך) והדדית-בלעדי עם metric/order/customer. אין יותר "בבנייה".
- `kManagerManageDataLeafIds` + `kManagerManageActionLeafIds` מחלקים את עלי ה-ניהול בלי חפיפה →
  אף עלה לא נופל ל-stub.
- `bs_dial_manager_manage_test` (12): 5 עלים נוכחים · mm-cats→קטגוריות+ספירות אמיתיות · mm-settings→
  3 שורות verbatim · mm-trees/mm-brands→toast-פעולה אמיתי (לא "בבנייה") · mm-regression→עדיין route ·
  mutual-exclusion דו-כיווני · partition בלי חפיפה.

## ✅ persona המנהל הושלמה — אפס "בבנייה" נגיש בכל 4 הסקשנים (md/mo/mc/mm). M0→M4 DONE.

---

# Follow-on — 🔗 SHARED ORDERS ENGINE (keystone, DATA LAYER) ✅ (v5.97)
Owner: this session · Scope: `lib/state/orders_engine.dart` (חדש) + `logic/manager_dashboard.dart`
(docs בלבד — אפס שינוי-מספר/חתימה). **DATA LAYER בלבד — אין שינוי-UI הגל הזה.**
- `SYS_ORDERS` הלגאסי (@index.html:11965-12039,:16939-17035) → `ordersEngineProvider`
  (`StateNotifier<List<Order>>`), **seeded ב-4 הזמנות-ה-seed הקיימות** (מ-`kManagerOrderSeed`
  שנשאר מקור-ה-seed) → כל מספר-מנהל קיים נשמר זהה (🚚 open=4, 4 לקוחות, מחזור).
- `Order` = `id/who/site/items/sum/stage` (+ `createdAt` אופציונלי), כמו `ManagerOrder`;
  `isOpen`=`stage!=='delivered'`. JSON round-trip; `toManagerOrder()` שומר את `manager_dashboard.dart`
  Flutter-free.
- API: `placeOrder(...)` (קבלן→stage `new`, auto-id `BS-####`, prepend+timestamp) · `advance(id)`
  (השלב הבא ב-`kManagerOrderFlow`, no-op ב-`delivered` — verbatim `mgrAdvanceOrder` @17022-17032) ·
  `setStage(id, stage)` (god-step של המנהל לכל שלב; מתעלם מ-id/stage לא-מוכרים) · `resetToSeed()`.
- persist ל-`SharedPreferences` key `bs.orders.v1` (תבנית cart/profile; payload פגום → seed).
- `managerAnalyticsProvider` + `managerCustomersProvider` גוזרים את ה-dashboard/לקוחות מההזמנות
  ה-**חיות** של ה-engine באותו fold טהור — שווים לגרסה הסטטית כל עוד ה-engine מחזיק את ה-seed.
- ה-4-tab UI + חיווט ה-dial ל-engine = גלים מאוחרים (`bs_dial_widget` ללא שינוי).
- `orders_engine_test` (21): seed-correctness · place/advance/setStage · persistence round-trip ·
  flow-ordering. כל בדיקות-המנהל (`bs_dial_manager_*` + `manager_dashboard_test`) נשארות ירוקות.
- analyze נקי (אפס error/warning חדש) · targeted-tests 47/47 ירוק.
