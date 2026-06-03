# לוגיקה: הזמנות · משימות · מלאי · ניווט-קטלוג · חיפוש (7701–9000)

## הזמנות — תצוגה (7701–7960)
`renderMyOrders` (→`view-orders`) · `getAllOrders` · `openShipmentStatus`/**`animateShipmentMaps`** (sheet-מעקב + מפות-SVG מונפשות) · **`orderCard`** (כרטיס מתרחב) · `toggleOrder` · `generateMockOrder` (🧪 הזמנת-בדיקה).

## מערכת-משימות (8021–8194)
- `WORKERS` (8021) = `['רן (עובד)','עומר (עובד)']`.
- `TASKS` (8023) — 5 משימות: `{id, name, detail, steps[]}` (קו-מים-חם · מיכל-הדחה-סמוי · איטום-רצפה · נקזון · ברז-כיור+ניל).
- `WORK_LOG` (8156) — יומן: `{date, items:[{worker, task, status}]}` (אתמול/שלשום; רן/עומר).
- פונקציות: `pickRole`(מנהל/עובד) · `setTaskLocation`(אתר/מחסן) · `pickWorker` · `taskStatusInfo` · `taskCard` · `renderTasks` · `openTask`/`taskActionClick` · **`taskUpload`/`taskApprove`/`taskReject`** (זרימת עובד→מנהל: ביצוע→תמונה→אישור) · `openTaskLog`.

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
