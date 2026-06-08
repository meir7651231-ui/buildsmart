# דשבורד-מנהל + מערכת בדיקות-עצמית (12062–15900)

## דשבורד-מנהל (12062–12319)
`orderStoreIndex`/`ordersForActiveStore` (הזמנות לחנות-הפעילה) · **`mgrAnalytics`** (12081)/`mgrStats` (מדדים) · **`renderMgrDashboard`** (12133) → pane "📊 לוח בקרה" (hero-הכנסות · metric tiles · order-pipeline · chart-קטגוריות · ביצועי-חנויות + medals).
5 metric-tiles verbatim (`mdMetric`, INSP-0029): 🚚 הזמנות-פתוחות · 📦 מוצרים-בקטלוג · 🧰 אביזרים-נלווים · ✅ זמינים-כעת · 🏪 חנויות-פעילות.

## ⭐ BUTTON_REGISTRY + self-test harness (12320–15900)
> תשתית-QA מובנית; חשופה ב-`#regTestPanel` של המנהל ("🔬 מרכז בדיקות רגרסיה", `reg-*` ב-CSS חלק ו׳).

- **`BUTTON_REGISTRY`** (12517) — **350 כפתורים** (אומת `{fn:` במקור; `legacy-map.md` ציין 176 — מיושן), כל אחד `{fn, area, does}`. מסמך-אמת לכל כפתור.
- **`BUTTON_TWINS`** (12900) — פונקציות-תאומות שעושות אותו דבר (`mgrAdvanceOrder`≡`storeAdvance` · `stepCatQty`≡`stepQty`) — לדדופ באודיט.
- audit: `contractOwnerOf`/`twinsOf`/**`runButtonAudit`**/`findDuplicates` · `checkProductStandard`/`regCheckProduct` (תקינות-מוצר/תקן).
- **משפחות-בדיקה** (כל אחת בודקת התנהגות-אמת, לא count):
  - `testButton_*` — courierAdvance · checkout · addTreeToCart.
  - `testTen_*` + `runTenButtonSuite` — togglePick · stepQty · removeCartItem · chooseDelivery · saveProject · storeAdvance · toggleStoreStock · taskApprove · setCatalogMode · toggleProductInCart.
  - `testContract_*` — closeTree · mgrOrderDetail · mgrDoSearch · storeOrderSetFilter (חוזי-התנהגות).
  - `testFamily_*` — openPanel · toggle · pick · save · delete · add · entry.
  - `testCrit_*` — addSingle · addScanToCart · chooseCartSite · storeLogin · storePickLine · storeMissLine · taskActionClick · taskReject · switchProject · showDeliveryNote (קריטיים).
  - `testImp_*` — setCatalogCategory · openTree · chooseSite · cycleAccStock · moveStock · setTaskLocation · clearNotifications · adjustBudget · navSafe (חשובים).
  - `profileButton_*` — courierAdvance · addTreeToCart (פרופיל-ביצועים).
- display-sync: `getDisplaySyncProbes`/`runDisplaySyncTest(Core)` — מוודא שה-DOM משקף את ה-state.
- runner: `withSilentDialogs` · **`runRegressionTests(Core)`** · `openTestChooser`/`getSelectableTests` (בחירה) · `showCustomResults` · `regCheckRow` · **`buildRegressionReport(Core)`** (דוח מלא).

---
**תובנה:** האב-טיפוס כולל **QA-harness ברמת-production** — registry של כל כפתור + עשרות בדיקות-התנהגות אמיתיות (לא smoke). זה המקור ל-`#regTestPanel`/`reg-*` ול-`▶ הרץ בדיקת רגרסיה מלאה`. (ה-Flutter תרגם זאת ל-`lib/test_harness/` — ראה knowledge הישן.)

---

## 🔄 Preact (`app/src/test/` + `components/regression/`) — דלתא (self-test)
> `test/registry.ts`(68) + `test/runner.ts`(53) + `test/tests/{buttons,dsync,products,dupes,tabs}` + `components/regression/regression-panel.tsx`(135) + `store/regression-store.ts`.

⬆️ **שודרג:** ה-self-test של הפרוטוטייפ → **מודולים מטוייפים**: `registry.ts` (רישום) + `runner.ts` + tests נפרדים. `regression-panel` (inline במנהל, `reg-*` CSS) מריץ; `regression-store` (state).
➕ **נוסף:** `tests/tabs.tsx` (regression שחייב לעבור) · `tests/dsync.ts` (display-sync).
➖ **הוחסר:** רוב משפחות-הבדיקה (`testCrit_/testImp_/testFamily_/testContract_` + ~350 `BUTTON_REGISTRY`) — Preact מכסה תת-קבוצה ממוקדת (buttons/products/dupes/dsync/tabs).

---

## 📱 Flutter — דלתא (self-test) ⭐ תיקון — נכתב-מחדש מ-whats-happening
> ⚠️ הגרסה הקודמת (snapshot nice-volta, 27 קבצים) טענה "אין test_harness". **שגוי** — באפליקציה האמיתית ה-self-test **עשיר ביותר**.
- **`lib/test_harness/`** (in-app, נפתח דרך BS-dial→מנהל→🔬 בדיקות-רגרסיה / `regression_panel_screen.dart`): `runner.dart` (**11 suites**: catalog/dsync/tabs/buttons/dupes/sections/settings/behavior/products/engine/cart/finder) + `regression_state.dart` (Riverpod) + `types.dart`. תצוגת pass/fail + filter-chips + expandable.
- **`test/` = 155+ קבצי-`.dart` · **1,539+ בדיקות** (אומת ב-gate `b4e2198`; גדל מאז עם T7/repos/install-engine) — ה-snapshot 155-קבצים/16,441ש'/953+70 היה מוקדם-יותר.** שערים: **47-helper-gate** (כל helper-ציבורי→test) · **mutation-tests** (40 מוטציות) · **`stuck_regression`** · `spec_assets` · `knowledge_protocol` · version-sync.
🔧 מול הפרוטוטייפ (`BUTTON_REGISTRY` 350 + reg-harness) ו-Preact (21-button registry): Flutter = ה-self-test **הכבד ביותר** מ-3 המקורות, נאכף ב-CI + 116-שערים (דוחות 21–22).
