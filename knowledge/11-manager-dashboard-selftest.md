# דשבורד-מנהל + מערכת בדיקות-עצמית (12062–15900)

## דשבורד-מנהל (12062–12319)
`orderStoreIndex`/`ordersForActiveStore` (הזמנות לחנות-הפעילה) · **`mgrAnalytics`** (12081)/`mgrStats` (מדדים) · **`renderMgrDashboard`** (12133) → pane "📊 לוח בקרה" (hero-הכנסות · metric tiles · order-pipeline · chart-קטגוריות · ביצועי-חנויות + medals).

## ⭐ BUTTON_REGISTRY + self-test harness (12320–15900)
> תשתית-QA מובנית; חשופה ב-`#regTestPanel` של המנהל ("🔬 מרכז בדיקות רגרסיה", `reg-*` ב-CSS חלק ו׳).

- **`BUTTON_REGISTRY`** (12517) — **~350 כפתורים**, כל אחד `{fn, area, does}` (area=ניווט/קטלוג/סל/…). מסמך-אמת לכל כפתור באפליקציה.
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
