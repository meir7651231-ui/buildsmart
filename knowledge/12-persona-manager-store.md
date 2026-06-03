# דשבורד-מנהל (מלא) + דשבורד-חנות (15900–17627)

## מנהל — לוח-בקרה (16374–16521)
`mgrAnimateCounters` · `mdMetric` · `mgrScrollProducts/Stores` · `mgrDoSearch`/`mgrSetCat`/`mgrShowUnavailable` · `mgrStoreDetail`/`mgrRevenueDetail` (drill) · `renderMgrProducts`/**`mgrToggleAvail`** (החלפת-זמינות-מוצר).

## מנהל — לקוחות (16533–16644)
`CONTRACTOR_CREDIT={}` (תקרת-אשראי/קבלן) · `contractorCredit` · `mgrCustomerList`/`renderMgrCustomers`/`mgrCustomerDoSearch`/**`mgrCustomerDetail`** (כרטיס-לקוח + בר-אשראי + היסטוריה).

## מנהל — ניהול קטלוג (16645–16890)
`renderMgrManage` (אקורדיון `mmSection`/`mmSettingRow` · `mgrToggleSection`):
- עצים/אביזרים: `mgrPickTree` · `mgrAddAcc`/`mgrEditAcc`/`mgrDelAcc`.
- מותגים: `mgrPickBrand` · `mgrAddBrand`/`mgrEditBrand`/`mgrDelBrand`.
- `mgrRenameCat` · `mgrEditExpress`/`mgrEditCredit` · `openMgrProduct`/`editMgrProduct`/`removeMgrProduct`.

## מנהל — חנויות (16891–16938)
`renderMgrStores` · `openMgrStore`/`editMgrStore`/`toggleMgrStore`/`removeMgrStore`.

## מנהל — הזמנות (16939–17075)
`ORDER_FLOW` (16943) = `['new','preparing','ready','pickup','transit','delivered']`. `renderMgrOrders` · `mgrOrderDoSearch`/`mgrOrderSetFilter` · **`mgrAdvanceOrder`** (קדם-שלב) · `mgrOrderDetail` (מעקב-מלא).

## ⭐ דשבורד-חנות (17076–17627)
- **`renderStoreHome`** (17080) → "🏠 בית" (פעולה-ראשית `sh-action` + סטטים + התראת-מלאי + פעולות-מהירות).
- `SIM_CUSTOMERS` (17159) = ['אלי בניין בע"מ',…] · `SIM_SITES` = ['מגדל יוקרה — רמת גן',…] · **`simulateIncomingOrder`** (17161) — מחולל הזמנה-נכנסת ריאליסטית.
- תעודת-משלוח: **`showDeliveryNote`** (17212)/`closeDeliveryNote` (מסמך מודפס, `dn-*`).
- הזמנות-חנות: `renderStoreOrders` · `soChip` · `storeOrderSetFilter` · **`storeAdvance`** · `shStat`.

**⭐ state-machine + held (מ-`STORE_DASHBOARD.md`):**
- stage: `new`(לאישור/צהוב) →"✓ אשר וקבל להכנה"→ `preparing`(בהכנה/כחול) →"📦 סמן כמוכן — העבר לשליח"→ `ready`(מוכן/ירוק) →"🛵 ממתין לאיסוף השליח"(info-only). כולם דרך `storeAdvance`.
- שדות מיוחדים: **`heldForMissing`** (פריט-חסר/כתום — כפתור מוסתר עד החלטת-קבלן) · **`missingResolved`** (✓ תיקון בוצע — re-enable) · **`splitInto`>1** ("🚚×N", pulsing `fresh`).
- home (`renderStoreHome`): toApprove(new)/inPrep/ready/**held**/todayRevenue(Σ new+preparing+ready). handlers: `data-sadvance`→storeAdvance · `data-sdetail`→storeOrderDetail (picking).
- **picking-sheet** (`renderStorePick`): **6 line-states** — picked(✓ירוק) · missing(✕אדום) · pending · cancelled("בוטל ע"י הקבלן") · replaced(🔁) · pendingDecision(⏳). split → lines מקובצים לפי `o.splitPlan[i]` (header per-shipment). `storePickLine`/`storeMissLine`.
- **stock** (`renderStoreStock`): `STORE_STOCK[key]=true/false` · **`toggleStoreStock` דורש RBAC `requirePerm('stock.edit','עריכת מלאי')`** · filter all/in/out.
- **store-portal — 8 tools verbatim:** ⭐ דירוג-ספקים · ⏱️ מעקב-SLA · 🗺️ אזורי-הפצה · 📉 הנחות-כמות · 🏷️ הפקת-ברקודים · 🚛 ניהול-צי-רכב · 💬 צ׳אט-עם-קבלן · 🔄 עדכון-מלאי-אוטומטי.
- **תעודת-ליקוט** (picking, 17400–17627): `storeItemInfo`/`storeOrderLines`/`storeOrderDetail` · **`renderStorePick`** (17455) · `storePickLine` (✓ לוקט) / `storeMissLine` (חסר במלאי).

---
**זרימת-החנות:** הזמנה נכנסת (מ-`SYS_ORDERS`) → `renderStoreOrders` → `storeAdvance`/picking (`storePickLine`/`storeMissLine`) → `stage` מתקדם → השליח/מנהל רואים. תעודת-משלוח (`showDeliveryNote`) ניתנת להדפסה (A4).

---

## 🔄 Preact (`app/src/store/bs-store.ts` + `views/`) — דלתא (פרסונות)
> 5 פרסונות (`Persona`): contractor/manager/store/courier/worker. `BsDial` (`bs-dial.tsx`, 361 ש׳) drill-in לעץ-section של כל פרסונה (`bsDrillPath`, אותו דפוס כמו profilePath).

⬆️ **שודרג:** דשבורדי-פרסונה (מסכים-מלאים) → **BS-dial drill-trees** (R2): בחירת-פרסונה ב-L1 → עץ-section ב-dial. שמות: שלמה-הקבלן · מנהל-המערכת · חנות-הסניטריה · שליח·משאית-14 · יוסי-העובד.
- **`views/store.tsx` (302 ש׳)** = הפרסונה היחידה עם **view ממשי** (`store-row`/`store-sheet` ב-CSS — הזמנות-נכנסות).

➖ **הוחסר/placeholder:** `views/` manager(16)/courier(12)/worker(12)/home(11) = מינימליים (R2). הדשבורדים המלאים מהפרוטוטייפ (`md-*`/`mm-*`/`mo-*`/`mc-*` מנהל · ליקוט-חנות מלא · שליח-מעקב · עובד-משימות) — **לא הומרו** (placeholder/חלקי).

---

## 📱 Flutter — דלתא (פרסונות)
`personas.dart` (`Persona`/`kPersonas`) + `bs_dial_widget` (BS-dial). `sections.dart`: `kStoreSections`/`kCourierSections` + order-status sections (st-pending/active/…).
- **`store_screen.dart` (990 ש׳)** = **טאב-חנות מלא native** (quick-actions + sheets מועדים/תזמון/שיחה) — פרסונת-החנות בולטת, וכאן **טאב-ראשי** (לא רק dial-drill).
➖ manager/worker/courier — סקשנים ב-`sections.dart` אך ללא view מלא.
