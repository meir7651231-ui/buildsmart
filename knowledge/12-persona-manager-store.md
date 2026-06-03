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
- הזמנות-חנות: `renderStoreOrders` · `soChip` · `storeOrderSetFilter` · **`storeAdvance`** (קדם-סטטוס: התקבלה→בהכנה→מוכן) · `shStat`.
- **תעודת-ליקוט** (picking, 17400–17627): `storeItemInfo`/`storeOrderLines`/`storeOrderDetail` · **`renderStorePick`** (17455) · `storePickLine` (✓ לוקט) / `storeMissLine` (חסר במלאי).

---
**זרימת-החנות:** הזמנה נכנסת (מ-`SYS_ORDERS`) → `renderStoreOrders` → `storeAdvance`/picking (`storePickLine`/`storeMissLine`) → `stage` מתקדם → השליח/מנהל רואים. תעודת-משלוח (`showDeliveryNote`) ניתנת להדפסה (A4).
