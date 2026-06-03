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

## נשאר (גלים הבאים)
- M2 — 6 עלי `mo-*` (סטטוס הזמנות) דרך `kManagerOrderFlow` (כל שלב מסנן הזמנות).
- M3 — 👥 לקוחות דרך `mgrCustomerList` + `contractorCredit`.
- M4 — שאר ה-sections של המנהל (הזמנות/ניהול).
