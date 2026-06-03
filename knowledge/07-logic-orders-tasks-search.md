# לוגיקה: הזמנות · משימות · מלאי · ניווט-קטלוג · חיפוש (7701–9000)

## הזמנות — תצוגה (7701–7960)
`renderMyOrders` (→`view-orders`) · `getAllOrders` · `openShipmentStatus`/**`animateShipmentMaps`** (sheet-מעקב + מפות-SVG מונפשות) · **`orderCard`** (כרטיס מתרחב) · `toggleOrder` · `generateMockOrder` (🧪 הזמנת-בדיקה).

## מערכת-משימות (8021–8194)
- `WORKERS` (8021) = `['רן (עובד)','עומר (עובד)']`.
- `TASKS` (8023) — 5 משימות: `{id, name, detail, steps[]}` (קו-מים-חם · מיכל-הדחה-סמוי · איטום-רצפה · נקזון · ברז-כיור+ניל).
- `WORK_LOG` (8156) — יומן: `{date, items:[{worker, task, status}]}` (אתמול/שלשום; רן/עומר).
- פונקציות: `pickRole`(מנהל/עובד) · `setTaskLocation`(אתר/מחסן) · `pickWorker` · `taskStatusInfo` · `taskCard` · `renderTasks` · `openTask`/`taskActionClick` · **`taskUpload`/`taskApprove`/`taskReject`** · `openTaskLog`.

**⭐ state-machine של משימה (מ-`WORKER_DASHBOARD.md`):** 5 מצבים —
`pending`(⏳בתור/כחול) → `active`(🔨בביצוע/ירוק) → `review`(📋בבדיקה/צהוב) → `done`(✓הושלם/ירוק); ו-`rejected`(✕דחוי/אדום) → active (retry).
מעברים: **`startTask`** (pending/rejected→active) · **`completeTask`** (active→review) · `taskApprove` (review→done) · `taskReject` (review→rejected).
schema-מלא (לפי הדשבורד): `{id, worker(idx ל-WORKERS), title, desc, site, when, role, status, notes, photo, approval}`. worker-home: greeting + progress-bar (`doneCount/total`) + 3 סטטים (פעילה/בתור/הוגשו).

## מלאי (8195–8249)
`accLookup` · `pickStockTab`(warehouse/site) · `renderStock` · `moveStock` (העברה מחסן↔אתר).

## ניווט-קטלוג מדורג (8250–8446)
- `setCatalogMode`/`setCatalogCategory`/`openCatalogCategory`/`openSmartCatalog` · `catalogGroupsForMode` · `renderCatChips`.
- drill: `syncCatDrill`/`renderCatDrill`/`clearCatDrill`.
- **`ATTR_SCHEMA`** (8341) — צירי-ניווט: `productType`(סוג מוצר) · `secondary`(מאפיין) · `diameter`(קוטר/מידה) · `variantOpt`(דגם) · `brandName`(מותג).
- catNav engine (8349–8446): `catNavKeys`/`catNavAttrValues`/`catNavValues`/`catNavPicks`/`catNavFiltered`/`catNavNextAttr`/`catNavIsPlasson`/`catNavStage`/`openCatNav`/`catNavQuery` — ניווט קטגוריה→תכונה→מוצר (`view-catnav`).

## ⭐ מנוע-החיפוש (8447–9000)
- `_searchIndex` (8447, cache). **`NAV_DESTINATIONS`** (8450) — 18 יעדים (דף-הבית/קטלוג/פרויקטים/עגלה/הזמנות/פרויקט-חכם/משימות/יומן/סריקה/מלאי/פרופיל/הגדרות/עזרה + global-actions: הזמנה-חוזרת/פרויקט-חדש/הרשמה/התראות), כל יעד עם `kw[]` (מילות-מפתח). **`CONTENT_INDEX`** (8514) — אינדקס כל כותרת/אזור→`view`.
- **`buildSearchIndex`/`searchIndex`/`searchSuggestions`** (8591–8628) — אינדוקס + חיפוש-fuzzy על יעדים+תוכן. `dynamicContentEntries` (תוכן-חי). `searchReorder`/`searchOpenNotifications` (global-actions). `productKeyByName`/`goToProductByName` (קפיצה למוצר לפי שם).
- handlers per-search-bar: **home** (`onHomeSearchInput`/`renderHomeSearchSuggest`/`homeSearchGoTo`) · **catalog** (`onCatSearchInput`/`renderCatSearchSuggest`/`catSearchGoTo`) · **catnav** (`onCatNavSearchInput`). `syncSearchClear`/`clearHomeSearch`/`clearCatSearch`/`clearCatNavSearch` (✕).
- מיון: `toggleCatSort`/`catSetSort`/`renderCatSortMenu` + catNav equivalents · `catNavFilterRows`/`catNavSortRows`.
- catNav nav: `catNavPick`/`catNavBack`/`catNavBackBtn`/`catNavResetSearch`.

---
**תובנה:** החיפוש מאחד 3 מקורות — יעדי-ניווט (`NAV_DESTINATIONS`) · אינדקס-תוכן (`CONTENT_INDEX`) · מוצרי-קטלוג — ל-suggest אחד עם fuzzy + `kw`. 3 שורות-חיפוש (בית/קטלוג/catnav) חולקות את אותו מנוע.

---

## 🔄 Preact (`app/src/components/search/` + `lib/`) — דלתא (חיפוש = FAB-dial)
> `search-panel` + 6 submenus + `tools-dial` + `scope-chips` + `results-list` · `lib/search.ts`/`voice.ts`/`barcode.ts` · `store/search-store.ts` · `data/search-index.ts`.

⬆️ **שודרג:**
- **3 שורות-חיפוש → search-FAB יחיד** (R1) שפותח `SearchPanel` (input + `scope-chips` + `results-list`).
- fuzzy → `lib/search.ts`; `NAV_DESTINATIONS`/`CONTENT_INDEX` → `search-index.ts`/`search-store.ts`.

➕ **נוסף — tools-dial בחיפוש** (5 כלי-משנה): **🎤 voice** (`submenu-voice`+`lib/voice.ts`) · **📷 barcode** (`submenu-barcode`+`lib/barcode.ts`) · ⚙️ filters · ↕️ sort · ▦ catalog (`submenu-catalog`).
- ⭐ **voice+barcode הועברו ממרכז-AI (G) → חיפוש** (בפרוטוטייפ `aiVoiceTask`/`aiBarcodeScan` היו ב-AI-hub).
- **קטלוג עבר ל-search-FAB** (`submenu-catalog`) — מול tab נפרד בפרוטוטייפ.

➖ **הוחסר:** מנוע-AI המלא (G) — רק voice+barcode שרדו; predict-stock/alternatives/3way/weather/wear-detect לא הומרו.

---

## 📱 Flutter — דלתא (חיפוש + device-APIs אמיתיים) ⭐
- `search_dial_widget.dart` (`SearchDialWidget`+`_ToolsRoot`) + `data/search_index.dart` (325 ש׳) — search-dial עם tools (כמו Preact).
- ⭐ **device-APIs אמיתיים:** **barcode** → `barcode_scanner.dart`+`camera_sheet.dart` (`mobile_scanner` native); **voice** → `services/voice.dart` (`speech_to_text` native). מול **הסימולציה בפרוטוטייפ** (demo-modals). 🔧 **תיקון:** גם **Preact אמיתי** — `lib/voice.ts`/`barcode.ts` = **Web Speech API + BarcodeDetector** (לא הדמיה; מקור: `legacy-map.md`). כלומר רק הפרוטוטייפ מדומה; Preact=web-APIs, Flutter=native-APIs.
