# 06 — Supplier Personas, Shared Order Engine & Self-Test

Exhaustive port reference for the **4 supplier-side persona apps** (Supplier-Store,
Courier, Worker, Manager), the **shared cross-role order state machine**, the
**localStorage sync layer**, the **regression / button-audit self-test system**, and
the remaining **data tables**.

Source: `/home/user/buildsmart/index.html` (single-file Preact-less vanilla-JS prototype,
Hebrew RTL). Line refs as `[L#]`. Everything below is verbatim from source — strings,
data, control flow.

> **Architecture note.** These four personas are NOT part of the contractor app's
> `<main>`. Each is a **full-screen `admin-screen`** (`screen-manager`, `screen-store`,
> `screen-store-login`, `screen-courier`, `screen-worker`, `screen-delivery-note`)
> reached from a role drawer via `enterRole(role)` [L11806]. They share one data model
> (`SYS_ORDERS`, `TREES`, `STORE_STOCK`, `STORES`, `TASKS`) and re-render each other on
> every mutation so all roles stay coherent. The contractor's `renderMyOrders` is also
> called from supplier/courier/manager advance functions for two-way sync.

---

## 0. Entry & screen wiring

`enterRole(role)` [L11806] closes the role drawer then routes [L11816–11819]:

| role | screen shown | init call |
|---|---|---|
| `manager` | `screen-manager` | `admTab('m-products')` |
| `store` | `screen-store-login` | `renderStoreLogin()` |
| `courier` | `screen-courier` | `renderCourier()` |
| `worker` | `screen-worker` | `renderWorker()` |

`ONBOARD_SCREENS` [L11634] lists all overlay screens hidden when entering the app.

**Manager tab bar** [L4213–4216] (`admTab` keys): `m-products` `📊 לוח בקרה` · `m-orders`
`🚚 הזמנות` · `m-customers` `👥 לקוחות` · `m-manage` `🛠️ ניהול`.

**Store tab bar** [L4260–4263]: `s-home` `🏠 בית` · `s-orders` `📥 הזמנות` · `s-stock`
`📦 מלאי` · `s-portal` `🧰 פורטל`.

`admTab(tab)` [L11890] toggles `.adm-tab.on`, hides every `.adm-pane`, shows
`pane-<tab>`, then dispatches the matching render fn [L11897–11904]. **Critical quirk:**
`admTab` strips `.on` from *every* `.adm-pane` document-wide, so `renderCourier`,
`renderWorker` re-assert their own pane's `.on` class on each render
[L17967–17971, L11836–11840] — else the screen renders blank after visiting
manager/store.

---

## 1. SHARED ORDER ENGINE — the cross-role state machine

### 1.1 Stage model

`ORDER_STAGE` [L12041] — the 6 canonical stages (label + CSS class):

| key | label | cls |
|---|---|---|
| `new` | `התקבלה` | `new` |
| `preparing` | `בהכנה` | `prep` |
| `ready` | `מוכן לאיסוף` | `ready` |
| `pickup` | `נאסף` | `ready` |
| `transit` | `בדרך לאתר` | `ready` |
| `delivered` | `נמסר ✓` | `done` |

`ORDER_FLOW=['new','preparing','ready','pickup','transit','delivered']` [L16943] — the
linear order used by the manager's stepper and `mgrAdvanceOrder`.

**Who advances which transitions:**

| Actor | Function | Transitions handled |
|---|---|---|
| Supplier | `storeAdvance` [L17386] | `new→preparing`, `preparing→ready` |
| Supplier (sheet) | `storeAdvanceFromSheet` [L17817] | same, via picking sheet |
| Courier | `courierAdvance` [L18226] | `ready→pickup`, `pickup→transit`, `transit→delivered` (also `shipped→delivered`) |
| Manager | `mgrAdvanceOrder` [L17022] | any single step along `ORDER_FLOW` (god-mode) |

So the natural lifecycle is **supplier owns new→ready**, **courier owns ready→delivered**,
**manager can nudge any step**. All three call `saveSysOrders()` then `renderMyOrders()`.

### 1.2 Order object shape

Seeded by `SYS_ORDERS_SEED` [L11970]. Each order:
`{id, who, site, items, sum, stage, haul, lines:[{name,qty}]}`. Runtime-added fields:
`storeIndex`, `simulated`, `hasMissing`, `heldForMissing`, `missingResolved`
(`'replaced'|'cancelled'`), per-line `picked`/`missing`/`pendingDecision`/`cancelled`/
`replaced`, `splitInto`, `splitPlan`, `splitNoticeNew`, `shipments[]`, `deliverWhen`,
`podPhoto`, `podSigned`.

`SYS_ORDERS_SEED` — 4 demo orders verbatim:

1. **BS-1042** — `יוסי כהן` / `מגדל הרצליה` / items 7 / sum 1240 / `new` / haul `van`.
   Lines: `ברז לכיור`×2, `צינורות חיבור גמישים`×4, `ברזי ניל זוויתיים`×4, `סרט טפלון`×3,
   `אטם גומי לברז`×6, `סיליקון סניטרי`×1, `מפתח צינורות`×1.
2. **BS-1041** — `אבי מזרחי` / `דירה — רמת גן` / 3 / 680 / `preparing` / `small`.
   Lines: `אסלה תלויה`×1, `מיכל הדחה סמוי`×1, `מושב אסלה`×1.
3. **BS-1040** — `משה אברהם` / `וילה — סביון` / 12 / 3150 / `ready` / `truck`.
   Lines: `צינור PEX מים חמים/קרים`×24, `מחברי PEX`×18, `גוף סמוי לסוללת מקלחת`×2,
   `ראש מקלחת`×2, `זרוע למקלחת`×2, `סוללת מקלחת`×2.
4. **BS-1039** — `דוד לוי` / `משרדים — תל אביב` / 4 / 420 / `transit` / `van`.
   Lines: `ברז למטבח`×1, `צינורות חיבור גמישים`×2, `סרט טפלון`×1.

### 1.3 localStorage sync layer

- `BS_ORDERS_KEY='buildsmart:sharedOrders'` [L11969] — shared key with a sibling
  `buildsmart-admin.html` tab.
- `loadSysOrders()` [L12003] — reads key; `JSON.parse`; if missing/blocked falls back to
  `SYS_ORDERS_SEED.slice()`. **Migration:** any persisted order lacking `lines` is
  backfilled from the seed by id [L12010–12018] so the picking sheet always has data.
- `saveSysOrders()` [L12021] — `localStorage.setItem(...JSON.stringify(SYS_ORDERS))`;
  on failure logs `[BuildSmart] localStorage unavailable — orders not persisted.`
- `let SYS_ORDERS=loadSysOrders()` [L12025]; on first load with empty storage it
  immediately persists [L12026].
- **orderSeq collision guard** [L12031–12040]: scans existing `BS-####` ids, bumps
  `orderSeq` past the highest so a new order can never inherit a stale delivered stage.
- **Cross-tab listener** `window.addEventListener('storage', …)` [L18281]:
  - On `BS_ORDERS_KEY`: re-`loadSysOrders()`, re-render the visible admin pane
    (`pane-m-orders`→`renderMgrOrders`, `pane-s-orders`→`renderStoreOrders`), re-render
    courier if visible, toast `עודכן מטאב אחר 🔄`.
  - On `buildsmart:lastOrderUpdate`: refresh contractor `view-orders`, push notification
    with label map `{processing:'בהכנה',packing:'בהכנה',shipped:'יצאה לדרך',
    ready:'מוכנה לאיסוף',delivered:'נמסרה'}`.

> Comment [L11968]: *"localStorage works in a real browser — not in sandboxed previews."*

### 1.4 Order→store routing

`orderStoreIndex(orderId)` [L12062] — prefers the order's recorded `storeIndex`; else a
stable hash of the id `% STORES.length`. `ordersForActiveStore()` [L12075] filters
`SYS_ORDERS` so each logged-in supplier sees only its own orders.

### 1.5 Split-shipment derivation

`shipStage(o,sh)` [L12052]; `deriveOrderStageFromShipments(o)` [L12059]: all delivered→
`delivered`; any transit→`transit`; any pickup→`pickup`; else leave order stage. Used
after a per-shipment courier advance.

---

## 2. SUPPLIER-STORE persona (`screen-store`)

### 2.1 Login (no real auth)

`renderStoreLogin()` [L11775] paints `#storeLoginList` from `STORES`: each card has icon
`🏪`, name, `📍 {area} · 🕐 {eta}`, status pill `<dot> פעילה`/`<dot> מושבתת`, chevron `‹`,
`.off` class if disabled. `storeLogin(i)` [L11792] sets `activeStoreIndex`, sets title
`🏪 {name}`, `showScreen('screen-store')`, `admTab('s-home')`, toast
`ברוך הבא — {name}`. `storeLogout()` [L11801] returns to login.

### 2.2 `renderStoreHome()` [L17080] — action-first home (`#storeHome`)

Reads `ordersForActiveStore()`. Buckets: `toApprove`=new, `inPrep`=preparing,
`ready`=ready; `todayRevenue`=sum of new+preparing+ready; `outOfStock`=count of
`STORE_STOCK[k]===false`.

Strings:
- Greeting `שלום 👋`; sub `🏪 {storeName} — מה שצריך טיפול עכשיו` (fallback
  `הנה מה שצריך טיפול עכשיו`).
- **Primary action card** if `toApprove>0`: count badge, title `הזמנות ממתינות לאישור`,
  sub `הקש כדי לאשר ולהתחיל הכנה`, chevron. Else `✓ אין הזמנות שממתינות לאישור`.
- **Held card** if any `o.heldForMissing` [L17116]: `.sh-action.held`, title
  `הזמנות ממתינות לבחירת הקבלן`, sub `פריט חסר — ממתין להחלטה (החלפה / ביטול)`.
- **Quick stats** (`shStat` [L17289]): `{inPrep} בהכנה 🔧`, `{ready} מוכן לאיסוף 📦`,
  `₪{todayRevenue} מחזור פעיל 💰`.
- **Stock alert**: `⚠️ {n} מוצרים אזלו מהמלאי — הקש לעדכון` else
  `✓ כל המוצרים זמינים במלאי`.
- **Quick actions**: buttons `📥 הזמנות`, `📦 מלאי`.
- **Demo tool**: `➕ סימולציית הזמנה נכנסת (כלי הדגמה)` → `simulateIncomingOrder()`.

### 2.3 `simulateIncomingOrder()` [L17161] — demo order generator

Picks 3–6 random `TREES` keys, qty 1–5 each, price from `t.brands[0].price` (fallback 50),
sum ×1.18 (VAT, rounded). Generates a `BS-####` id that routes to `activeStoreIndex` (loop
guard 200). `SYS_ORDERS.unshift({id,who,site,items,sum,stage:'new',lines,simulated:true})`.
Saves, re-renders home + orders, toast `הזמנת הדגמה {id} נוצרה — נכנסה לתור ✓`.
Customer/site picked from `SIM_CUSTOMERS` / `SIM_SITES` (§7).

### 2.4 `renderStoreOrders()` [L17299] — work queue (`#storeOrderList`)

`storeOrderFilter='active'` (default). Only `new|preparing|ready` shown
(`mine`). Filter chips (`soChip` [L17381]): `פעילות`, `לאישור`, `בהכנה`, `מוכנות`.
Empty: `אין הזמנות בקטגוריה זו ✓`. Sorted new→preparing→ready.

Per card button logic:
- `heldForMissing` → `⏳ פריט חסר — אנא המתן להחלטת הקבלן`, pill `פריט חסר`.
- `missingResolved` → `✓ תיקון בוצע — {פריט הוסר|בדוק שינויים}` then the stage action.
- `new` → `✓ אשר וקבל להכנה`.
- `preparing` → `📦 סמן כמוכן — העבר לשליח` (amber).
- else → `🛵 ממתין לאיסוף השליח`.
- Split pill `🚚×{n}` (+`.fresh` pulse), meta ` · 🚚 הוכן ב-{n} חבילות`.

Card body: `📦 {id}`, who·site, `🕒 נדרש: {deliverWhen|בתיאום}`,
`{items} פריטים · ₪{sum} · הקש לתעודת ליקוט`. Delegated click handler [L17369]
(`data-sadvance`→`storeAdvance`, `data-sdetail`→`storeOrderDetail`).

`storeAdvance(id)` [L17386]: RBAC `requirePerm('order.fulfill','קידום הזמנה')`;
`new→preparing` / `preparing→ready`; `saveSysOrders` → `renderStoreOrders` →
`renderStoreHome` → `renderMyOrders`; toast
`ההזמנה {id} עודכנה — מסונכרן עם השליח והמנהל ✓`.

### 2.5 Picking sheet — `renderStorePick()` [L17455] (overlay `#storePickOverlay`)

`storeOrderDetail(id)` [L17440] sets `storePickId`, clears `missingResolved`/
`splitNoticeNew` badges, opens overlay. `storeItemInfo(name)` [L17408] resolves a line
name to `{img,cat,price,why}` across main products + accessories. `storeOrderLines(o)`
[L17430] guarantees a non-empty lines array (fallback single line
`הזמנה מלאה — {items} פריטים`).

Header `📦 {id}`, who·site, `סטטוס: {label}`. Progress bar `{handled}/{lines} פריטים טופלו`.
- Held alert: `⏳ פריט חסר — ממתין לבחירת הקבלן (החלפה / ביטול)`; else if missing>0:
  `⚠️ {n} פריטים חסרים — הקבלן עודכן`.
- Split banner: `🚚 ההזמנה מפוצלת ל-{n} משלוחים — הכן כל קבוצה כחבילה נפרדת.`

Each line (`renderSpLine` [L17495]) shows thumb, name (+`מוצר חלופי` chip if replaced),
cat tag, `₪{price} ליח׳`, why, `כמות לליקוט: {qty} · סה״כ ₪{total}` + status text:
`✕ בוטל ע״י הקבלן` / `🔁 הוחלף ע״י הקבלן` / `⏳ ממתין לבחירת הקבלן` / `✕ חסר` / `✓ לוקט`.
Two buttons per line: `✓` (`storePickLine`), `חסר` (`storeMissLine`). Split orders render
grouped by `splitPlan` with header `📦 משלוח {g} — {n} פריטים` + meta
`🕒 {when} · 📍 {site} · {haulIc} {haulName}`.

Footer action:
- `new` → `✓ אשר וקבל להכנה` (green, `storeAdvanceFromSheet`).
- `preparing` + all handled → `📦 כל הפריטים טופלו — סמן כמוכן`.
- `preparing` + not all → hint `סמן כל פריט כ"לוקט" או "חסר" כדי לסיים את ההכנה` +
  `סמן כמוכן בכל זאת`.
- else → `🛵 ההזמנה מוכנה — ממתינה לאיסוף השליח`.
- Always: `📄 הצג תעודת משלוח` → `showDeliveryNote(id,'screen-store')`.

`storePickLine(i)` [L17576]: toggles `picked` (clears `missing`), re-render.
`storeMissLine(i)` [L17585]: toggles `missing` (clears `picked`); **on newly-flagged
missing** sets `o.hasMissing=o.heldForMissing=true`, `line.pendingDecision=true`, saves,
`pushNotification('פריט חסר בהזמנה {id}: {name}', {icon:'⚠️', detail:{title:'פריט חסר —
נדרשת החלטה', lines:['הזמנה: {id}','פריט חסר: {name}','כמות: {qty}','התהליך נעצר. יש
לבחור: להתקדם בלי הפריט, או להחליף אותו.'], action:{label:'טיפול בפריט החסר',
fn:"openMissingDecision('{id}')"}}})` and pops `openMissingDecision`. Un-flagging clears
`pendingDecision`/`heldForMissing`.

`storeAdvanceFromSheet()` [L17817]: refuses if `stage==='ready'`; if `heldForMissing`
toasts `⚠️ ההזמנה ממתינה להחלטת הקבלן על פריט חסר — לא ניתן להמשיך` and aborts; else
delegates to `storeAdvance`.

`heldForMissing` is an **order boolean property** (the hold gate), not a function — set in
`storeMissLine` [L17597], cleared in `resolveMissingLine` [L17676]/`storeMissLine` when no
line still has `pendingDecision`, and tested in `storeAdvanceFromSheet` + the home/orders
"held" cards.

### 2.6 Missing-item decision loop (contractor side, same engine)

`openMissingDecision(orderId)` [L17636] / `closeMissingDecision` [L17668] /
`resolveMissingLine(o)` [L17673] / `notifyStoreOfDecision(o,name,outcome)` [L17680]
(`outcome` `'replaced'|'cancelled'`, sets `o.missingResolved`, pushes
`עדכון מהקבלן` notification, re-renders all store screens).
`missingProceedWithout(lineIdx)` [L17701]: marks line `cancelled`+`missing`, toast
`הקבלן ביטל את הפריט "{nm}" — המשך בליקוט`. `missingReplace(lineIdx)` [L17717]: opens
catalog to choose a replacement (`replacementContext`). **Out-of-stock gate at checkout:**
`openOutOfStockGate(cartIdx)` [L17834] (`מוצר אינו במלאי`, buttons `דלג — הסר מההזמנה`/
`החלף מוצר`) with `oosSkip` [L17854] / `oosReplace` [L17864].

### 2.7 Stock management — `renderStoreStock()` [L17875] (`#storeStockList`)

`storeStockFilter='all'`, `storeStockSearch=''`. Summary tiles: `{n} מוצרים`, `{n} זמינים`,
`{n} אזלו`. Search `חיפוש מוצר...`. Chips `הכל`/`זמינים`/`אזלו`. Each row: thumb, name,
`✅ זמין במלאי`/`❌ אזל — מוסתר מהקבלן`, and a toggle switch → `toggleStoreStock(k)`.
Empty: `לא נמצאו מוצרים תואמים.`

`toggleStoreStock(k)` [L17928]: RBAC `requirePerm('stock.edit','עריכת מלאי')`; flips
`STORE_STOCK[k]`; re-renders stock + home + **`renderCatalog`** (so a sold-out item
disappears from the contractor's catalog); toast `המוצר סומן כזמין` /
`המוצר אזל — הוסתר מקטלוג הקבלן`.

### 2.8 Supplier portal — `renderStorePortal()` [L20760] (`#storePortal`)

8 tiles (`fin-tile`) [L20763]: `⭐ דירוג ספקים / ציון וביצועים` (`portalRatings`),
`⏱️ מעקב SLA / ספירה לאחור` (`portalSLA`), `🗺️ אזורי הפצה / זמני אספקה` (`portalZones`),
`📉 הנחות כמות / מדרגות הנחה` (`portalBulk`), `🏷️ הפקת ברקודים / תוויות למוצרים`
(`portalBarcode`), `🚛 ניהול צי רכב / רכבים וזמינות` (`portalFleet`),
`💬 צ׳אט עם קבלן / הודעות פנימיות` (`openChat('contractor')`),
`🔄 עדכון מלאי / אוטומטי לפי מכירות` (`portalAutoStock`).

---

## 3. COURIER persona (`screen-courier`)

### 3.1 Vehicle gating

`courierVehicle='truck'` (default) [L17945]. `VEHICLE_RANK={small:0,van:1,truck:2}`
[L17946]. `vehicleCanCarry(vehicle,need)` [L17951] — a bigger vehicle carries everything
ranked ≤ it (`n<=v`); undefined vehicle ⇒ carries all. `pickCourierVehicle(id)` [L17956]
sets vehicle, re-renders, toast `הרכב נקבע: {ic} {name}`. `haulInfo(id)` [L17947] looks up
`HAUL_TYPES`.

### 3.2 `renderCourier()` [L17963] — orchestrator

Re-asserts the courier pane `.on` [L17967]. Installs a **one-time delegated click
handler** on `#courierList` [L17975] (`data-advance`→`courierAdvance`,
`data-detail`→`courierDetail`). Then calls `renderCourierHome()` + `renderCourierList()`
independently (each in try/catch).

### 3.3 `renderCourierHome()` [L17991] (`#courierHome`)

Filters orders to those the vehicle can carry. `active`=ready|pickup|transit;
`toPickup`=ready, `onRoad`=transit, `delivered`=delivered.
Strings: `שלום 🛵`; `המשלוחים שלך להיום`; `הרכב שלי היום`; vehicle buttons from
`HAUL_TYPES`. Primary: if `toPickup>0` → `{n}` + `משלוחים ממתינים לאיסוף` /
`אסוף מהחנות כדי להתחיל`; elif active>0 → `🚚 {n} משלוחים בדרך — אין איסופים ממתינים`;
else `✓ אין משלוחים שמתאימים ל{haulName} כרגע`. Stats (`chStat` [L17046]):
`{toPickup} לאיסוף 📦`, `{onRoad} בדרך 🚚`, `{delivered} נמסרו ✅`. Portal button
`פורטל השליח / ניווט, צי רכב, צ׳אט ומעקב SLA` → `openCourierPortal()`.

### 3.4 `renderCourierList()` [L18067] (`#courierList`)

Builds a flat list of **delivery jobs**: non-split order = 1 job; split order = N jobs
(one per active shipment). `ACTIVE=['ready','pickup','transit']`. Filters by vehicle.
Empty: `אין משלוחים שמתאימים ל{ic} {name}. נסה לבחור רכב גדול יותר.`
Sorted ready→pickup→transit. Per job: step + button:
- ready/preparing/new → step1 → `📦 אספתי מהחנות`
- pickup → step2 → `🚚 יצאתי לדרך`
- transit → step3 → `✅ נמסר ללקוח` (amber)

Card: `📦 {id}[· משלוח {n}]`, stage pill, split pill `🚚 משלוח {n}/{total}` or `×{n}`,
`👤 {who}`, `📍 {site}`, `🕒 נדרש: {when}`, `{haulIc} {haulName}`, 3-step tracker
(`איסוף`/`בדרך`/`נמסר`), meta `{itemCount} פריטים [· ₪{sum}] · הקש לפרטים`. Advance id is
`orderId` or `orderId#shipIdx`.

`courierDetail(id)` [L18155] — sheet (`#courierDetailOverlay`); parses `orderId#shipIdx`;
tracker (`איסוף מהחנות`/`בדרך לאתר`/`נמסר`); rows לקוח/כתובת מסירה/מועד נדרש/מספר פריטים
(+פיצול משלוח / סכום ההזמנה); item list `תכולת המשלוח`; action buttons mirror the list +
`📄 תעודת משלוח`.

`courierAdvance(id)` [L18226] — parses both id forms; pure `next(stage)` map
(ready/preparing/new→pickup, pickup→transit, transit/shipped→delivered, else null);
advances a single shipment (then `deriveOrderStageFromShipments`) or whole order (syncing
shipments); `saveSysOrders` → `renderCourier` → `renderMyOrders`; toast
`המשלוח {label} עודכן — מסונכרן עם החנות והמנהל ✓`.

### 3.5 Courier portal — `openCourierPortal()` [L20786] (`#courierPortalOverlay`)

Head `🧰 פורטל השליח / כל הכלים לניהול המשלוחים שלך.` 6 tiles:
`🧭 ניווט למשלוח / מסלול לאתר` (`courierNav`), `🚛 צי רכב / רכבים וזמינות`
(`portalFleet`), `⏱️ מעקב SLA / זמני אספקה` (`portalSLA`), `🗺️ אזורי הפצה / מפת אזורים`
(`portalZones`), `📸 אישור מסירה / POD + צילום` (`courierPOD`),
`💬 צ׳אט עם חנות / הודעות פנימיות` (`openChat('courier')`).

- `courierNav()` [L20812] — lists active orders → `🧭 פתח ניווט` (`startCourierNav`
  [L20830] opens Google Maps to `o.site`, toast `פותח ניווט אל: {dest} 🧭`).
- `courierPOD()` [L20842] — transit/pickup orders → `📷 צלם מסירה` (`capturePOD` [L20863]
  sets `o.podPhoto`, toast `צילום המסירה נשמר 📸 (דורש הרשאת מצלמה במכשיר)`) + `✍️ חתימה`
  (`openSignature`). Pill `נחתם ✓`/`ממתין`.

---

## 4. WORKER persona (`screen-worker`)

### 4.1 Data

`WORKERS=['רן (עובד)','עומר (עובד)']` [L8021]. `taskRole='manager'`, `activeWorker=0`,
`currentTask=null` [L8022]. `TASKS` [L8023] — 5 demo tasks, each
`{id,name,detail,worker,status,photo,note,days,steps[]}`:

| id | name | worker | status | days | steps |
|---|---|---|---|---|---|
| 1 | `התקנת קו מים חם — חדר רחצה` | 0 (רן) | `active` | 2 | 4 (סימון מסלול…→בדיקת אטימה בלחץ מים) |
| 2 | `הרכבת מיכל הדחה סמוי` | 0 | `pending` | 1 | 4 |
| 3 | `איטום רצפת מקלחת` | 1 (עומר) | `review` (photo `demo`, note `בוצע — שכבה שנייה תתייבש מחר`) | 3 | 6 |
| 4 | `התקנת נקזון רצפה` | 1 | `done` (note `הושלם ונבדק`) | 1 | 3 |
| 5 | `חיבור ברז כיור + ברזי ניל` | 0 | `pending` | 2 | 4 |

`taskStatusInfo(s)` [L8048]: `pending{ממתינה,pend,⏳}`, `active{בביצוע,act,🔨}`,
`review{ממתין לאישור,rev,📸}`, `done{אושר ✓,done,✅}`, `rejected{נדחה — לתקן,rej,↩️}`.

`WORK_LOG` [L8156] — 2 historical days: `אתמול` (3 done) + `שלשום` (2 done), each item
`{worker,task,status}`. `openTaskLog()` [L8167] prepends a synthetic `היום` day computed
from `done` TASKS.

### 4.2 `renderWorker()` [L11832] (`#workerTasksBody`)

Sets `taskRole='worker'`, re-asserts pane. Worker picker from `WORKERS`. Buckets for
`activeWorker`: `current`=active|rejected, `queue`=pending, `submitted`=review|done.
Summary `ww-summary`: `שלום, {name} 👷` (strips ` (עובד)`), sub
`יש לך משימה פעילה`/`יש משימות בתור`/`אין משימות פתוחות`, badge `{done}/{total}`, progress
bar, stats `{1|0} פעילה`/`{q} בתור`/`{s} הוגשו`. Sections: `🔨 המשימה הנוכחית שלך` (or
`🎉 אין משימה פעילה כרגע`), `⏳ הבאות בתור ({n})`, `📋 שהגשת ({n})`. `taskCard` [L8057].

### 4.3 Worker→manager approval loop

The dual-role engine in `renderTasks()`/`openTask()`/`taskActionClick()` (shared with the
contractor Tasks view):

- **Worker submits**: `taskActionClick()` [L8138] (active|rejected) — saves note, sets
  `photo='demo'` if none, `status='review'`, **auto-activates the worker's next pending
  task**, toast `נשלח לאישור המנהל ✓`.
- **Manager reviews**: `openTask` [L8106] for a `review` task shows
  `↩️ החזר לתיקון` + `✅ אשר`.
  - `taskApprove()` [L8152]: `status='done'`, toast `המשימה אושרה ✓`.
  - `taskReject()` [L8153]: `status='rejected'`, clears photo, toast
    `המשימה הוחזרה לעובד לתיקון`.
- `taskUpload()` [L8151] sets `photo='demo'`, toast `תמונה צורפה (הדגמה)`.
- Manager view `renderTasks()` [L8075] groups `📸 ממתין לאישור שלך` / `🔨 בביצוע עכשיו` /
  `⏳ ממתינות בתור` / `✅ הושלמו ואושרו`; intro
  `אתה רואה את כל משימות הצוות. אשר עבודות שהוגשו ועקוב אחרי ההתקדמות.` + log button
  `📅 יומן עבודה — מה בוצע בכל יום`.

State machine: `pending → active → review → (done | rejected→active)`.

---

## 5. MANAGER persona (`screen-manager`) — command center

### 5.1 `mgrAnalytics()` [L12081] — single derived source

Every dashboard number is computed live (no hard-coding). Returns: `orders, revenue,
items, openOrders, avgOrder, byStage, byStore, ranking, total, avail, unavail,
catalogCount, accCount, accAvail, cats, catCount, stores, activeStores`. Revenue =
Σ`o.sum`; counts by stage and by `orderStoreIndex`. Products split into
`catalogCount` vs `accCount` (accessory products), availability from `STORE_STOCK`.
`mgrStats()` [L12125] is a back-compat subset. `mgrSearch=''`, `mgrCatFilter='all'`
[L12131].

### 5.2 `renderMgrDashboard()` [L12133] (`#mgrDashboard`)

Sections, in order:
- **Hero**: `מרכז השליטה` / `BuildSmart · ניהול מערכת בזמן אמת` / `חי`.
- **Headline revenue** (click→`mgrRevenueDetail()`): `מחזור כולל במערכת`, animated
  `₪{revenue}`, sub `{n} הזמנות · ממוצע ₪{avg} להזמנה · הקש לפירוט ›`.
- **Metric tiles** (`mdMetric`): `🚚 {openOrders} הזמנות פתוחות`,
  `📦 {catalogCount} מוצרים בקטלוג`, `🧰 {accCount} אביזרים נלווים`,
  `✅ {avail} זמינים כעת`, `🏪 {active}/{stores} חנויות פעילות`.
- **Alert**: `⚠️ {unavail} מוצרים לא זמינים — הקש לבדיקה` else
  `✓ כל {total} המוצרים זמינים — הקטלוג תקין`.
- **Order pipeline** `צינור ההזמנות` + `כל ההזמנות ›`: 5 bars
  (`התקבלה`/`בהכנה`/`מוכן`/`בדרך`/`נמסר`) with hex colors `1F6F6B F2A516 1F8A4C 2B7DB8
  8B8D8F` [L12181].
- **Category mix** `תמהיל הקטלוג לפי קטגוריה` — bar chart, click→`mgrSetCat`.
- **Store performance** `ביצועי חנויות` + `＋ חנות` (`openMgrStore`): per-store cards with
  medal 🥇🥈🥉 by revenue rank, dot on/off, `{orders} הזמנות`, `₪{revenue} מחזור`.
- **Product manager** `ניהול מוצרים` + `＋ מוצר` (`openMgrProduct`); note
  `כל שינוי כאן מתעדכן מיד בקטלוג של הקבלן.`; search `חיפוש מוצר...`; category chips
  `הכל ({total})` + per-cat; container `#mgrProductList`.
- **Regression test center** `🔬 מרכז בדיקת רגרסיה` [L12253]; note
  `בודק כל מוצר קטלוג מול "חוזה תקינות" — מוודא ששום תיקון לא שבר מוצר קיים. הרץ אחרי כל
  שינוי.`; build banner `✅ גרסה תקינה — BUILD R107 · אם אתה רואה את השורה הזו, זה הקובץ
  הנכון`; buttons `▶ הרץ בדיקת רגרסיה מלאה` (`regRunBtn`) + `🎛️ בחר מה לבדוק / להשוות`
  (`regChooseBtn`→`openTestChooser`); status line `regSelfTest`. Run handler [L12273]
  swaps button to `⏳ מריץ את הבדיקות... רגע`, calls `runRegressionTests()`, restores,
  status `✓ הדוח נפתח בחלון. לחץ שוב להרצה חוזרת.`

### 5.3 `renderMgrProducts()` [L16478] (`#mgrProductList`)

Filtered by `mgrCatFilter`+`mgrSearch`. Each row: thumb, name, `{cat}[· {n} מותגים][· 🌳
{n} אביזרים]`, availability switch (`mgrToggleAvail` [L16515] — flips `STORE_STOCK`,
re-renders catalog, toast `{name} — זמין ✓`/`— סומן כלא זמין`), edit `✏️`
(`editMgrProduct`), delete `🗑️` (`removeMgrProduct`). Empty `לא נמצאו מוצרים תואמים.`

### 5.4 `renderMgrManage()` [L16645] (`#mgrManage`) — 4-section accordion

Intro `🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית.` `mgrManageOpen='trees'`.
`mmSection` builder [L16745].
1. **🌳 עץ המוצרים** / `עריכת האביזרים המשלימים של כל מוצר` — product `<select>`
   (`mgrPickTree`), per-acc rows `₪{price} · 🔴 חובה`/`🟡 אופציונלי`, `✏️`(`mgrEditAcc`)
   `🗑️`(`mgrDelAcc`), `＋ הוסף אביזר` (`mgrAddAcc`). Empty `אין אביזרים — הוסף את הראשון.`
2. **🏷️ מותגים ומחירים** / `עריכת המותגים והמחירים של כל מוצר` — `mgrPickBrand`,
   `{brand} ⭐` if `rec`, `₪{price} · {tag}`, edit/del (`mgrEditBrand`/`mgrDelBrand`),
   `＋ הוסף מותג` (`mgrAddBrand`).
3. **🗂️ קטגוריות** / `ניהול קטגוריות הקטלוג` — list with `{n} מוצרים`, `✏️ שנה שם`
   (`mgrRenameCat`), hint `שינוי שם קטגוריה מעדכן את כל המוצרים שבה.`
4. **⚙️ הגדרות אפליקציה** / `פרמטרים שהקבלן רואה` — rows `תוספת משלוח אקספרס ₪{EXPRESS_FEE}`
   (`mgrEditExpress`), `מסגרת אשראי לקבלן ₪{creditLimit}` (`mgrEditCredit`),
   `שיעור מע״מ {18}%` (static), hint
   `המע״מ קבוע לפי חוק (18%). תוספת האקספרס והאשראי נראים מיד בעגלת הקבלן.`

All editors use native `prompt`/`confirm` (so the self-test must silence dialogs, §6.7).
`mgrAddAcc` [L16770]: `שם האביזר:` / `מחיר (₪):` / `אביזר חובה? (אישור = חובה, ביטול =
אופציונלי)`. `mgrRenameCat` [L16831] rewrites all matching `t.cat`, toast `{n} מוצרים
עודכנו לקטגוריה "{newName}" ✓`. `openMgrProduct` [L16858]: prompts name/cat/icon, creates
`TREES[key]={name,img,cat,brands:[{brand:'כללי',…}],acc:[]}`, `STORE_STOCK[key]=true`,
toast `המוצר נוסף — מופיע עכשיו בקטלוג הקבלן ✓`. `removeMgrProduct` [L16882] deletes from
both TREES + STORE_STOCK.

### 5.5 `renderMgrCustomers()` [L16566] (`#mgrCustomers`)

`mgrCustomerList()` [L16546] derives contractors from `SYS_ORDERS` (group by `who`, sum
spend, unique sites). `contractorCredit(name)` [L16538] = deterministic hash → 30k–120k
ceiling. Status `low`(≥90%) / `live`(>0) / `off`. Summary `{n} קבלנים`,
`₪{used} סך רכש`, `{pct}% ניצול אשראי`. Search `חיפוש קבלן...`. Cards: `👷`, name,
`{orders} הזמנות · {sites} אתרים`, pill `אשראי גבוה`/`לא פעיל`/`פעיל`, credit bar
`ניצול אשראי: ₪{spent} / ₪{credit} ({pct}%)`. `mgrCustomerDetail` [L16609] sheet shows
tiles + rows (מסגרת/נוצל/יתרה/אתרים) + the contractor's orders.

### 5.6 `renderMgrOrders()` [L16946] (`#mgrOrderList`)

`mgrOrderFilter='all'`, `mgrOrderSearch=''`. Summary `{n} הזמנות`, `{open} פתוחות`,
`₪{revenue} מחזור`. Search `חיפוש לפי מזהה, קבלן או אתר...`. Chips `הכל ({n})` + per-stage
(label from `ORDER_STAGE`). Cards: `📦 {id}`, stage pill, who·site, mini 6-step tracker
(`mo-track`), `{items} פריטים · ₪{sum}`, `קדם שלב ›` (`mgrAdvanceOrder`) or `✓ הושלם`.
Empty `לא נמצאו הזמנות תואמות.` `mgrAdvanceOrder(idx)` [L17022] steps along `ORDER_FLOW`
(toast `ההזמנה כבר הושלמה` at end), saves, `renderMgrOrders`+`renderMyOrders`, toast
`הזמנה {id} → {label}`. `mgrOrderDetail(idx)` [L17035] sheet: full labeled tracker,
tiles (פריטים/סכום/שלב), rows, `קדם ל"{nextLabel}"` + `📄 תעודת משלוח`.

### 5.7 `renderMgrStores()` [L16892] (`#mgrStoreList`, compat — store mgmt lives in
"ניהול")

Rows `🏪 {name}` / `{area} · {eta} · {פעילה|מושבתת}`, toggle `⏼` (`toggleMgrStore`
[L16933] — flips `on`, toast `החנות הופעלה`/`החנות הושבתה`), `🗑️` (`removeMgrStore`).
`openMgrStore` [L16911] prompts name/area/eta, `STORES.unshift`, toast `החנות נוספה ✓`.
`editMgrStore` [L16920]. (`openMgrStore`/`toggleMgrStore` are also wired into the
dashboard's store-performance section.)

### 5.8 Delivery note — `showDeliveryNote(orderId, returnScreen)` [L17212]
(`screen-delivery-note`)

Shared by store/courier/manager. Renders a print-style doc: `BS` logo + `BuildSmart /
רכש חומרי בנייה`, `תעודת משלוח`, id, `תאריך: {today}`; parties (לקוח / כתובת מסירה /
סטטוס); items table headers `# / פריט / כמות / מחיר יח׳ / סה״כ`; totals `סכום ביניים`,
`מע״מ 18%`, `סה״כ לתשלום`; signature boxes `חתימת המקבל` / `חתימת השליח`; footer
`מסמך הופק על ידי מערכת BuildSmart · {today}`. `closeDeliveryNote` [L17280] returns to
`deliveryNoteReturn` (`'app'` returns to contractor orders).

---

## 6. SELF-TEST SYSTEM (regression + button audit + fingerprint + dsync + dupes)

A complete in-app QA harness, reachable from the manager dashboard. Built on the premise
that *every bug ever fixed becomes a permanent check*.

### 6.1 `BUTTON_REGISTRY` [L12517] — master action list (**exactly 350 entries**)

The single source of truth: every actionable function in the whole app. Each entry is
`{fn, area, does}` — function name, Hebrew area, Hebrew description of its contract.

**Areas** (the `area` field, used to group the audit/chooser):

| area | scope (examples) |
|---|---|
| `ניווט` | enterRole, showScreen, go, enterApp, toggleRoleDrawer, pickRole, pickWorkerScreen |
| `קטלוג` | setCatalogMode, catNav*, search*, openTree, renderCatalog, sort/clear |
| `בית` | onHomeSearchInput, openAIHub, ai* (predict/barcode/voice/plan/weather/wear/analytics) |
| `עץ מוצרים` | togglePick, toggleAccDetail, stepQty, openAccSize, addTreeToCart, openVariants, openBrands |
| `סל` | toggleProductInCart, removeCartItem, stepCartQty, chooseDelivery, checkout, addSingle, addScanToCart |
| `פרויקטים` | openProjectModal, saveProject, switchProject, chooseSite, budget/credit/category editors |
| `הזמנות` | renderMyOrders, toggleOrder, openShipmentStatus, RMA, rental, deposits, signature, OCR, gov XML, RFQ, MSDS, missing-item + OOS dialogs, ship planner |
| `מנהל` | admTab, openMgrProduct, mgr* (search/cat/brand/acc/order/customer/store), runRegressionTests |
| `חנות` | storeLogin/Logout, storeOrderDetail, storeAdvance, storePickLine, storeMissLine, toggleStoreStock, moveStock, simulateIncomingOrder, generateMockOrder |
| `ספק` | renderStorePortal, portalFleet/AutoStock/Ratings/SLA/Zones/Bulk/Barcode, openChat |
| `שליח` | openCourierPortal, courierNav, startCourierNav, courierPOD, capturePOD, courierDetail, courierAdvance, pickCourierVehicle |
| `עובד` | openTask, openTaskLog, taskActionClick, taskApprove, taskReject, taskUpload, setTaskLocation, pickWorker, day/stage pickers |
| `תקציב` | openFinanceHub, finIndex/PayTerms/Subs/Approvals/Thresholds/ROI/InvoiceSplit/Penalties/Reports/FX |
| `משימות` | openSiteHub, siteGantt/Snagging/Locations/Attendance/Diary/Safety/Deps/Photos/Inspect/Archive |
| `פרופיל` | openRewardsHub, rwChallenges/Leaderboard/Green/Coupons/Referral/VIP/Redeem, claim/redeem |
| `הגדרות` | toggleHighContrast, openSecurityHub, sec* (2FA/RBAC/Biometric/Audit/GPS/Session/…), toggleSetting, cycleSetting, resetSettings, openServiceHub |
| `שירות` | svcHelpDesk/Chatbot/ShakeReport/UnitConvert/QtyCalc/Calendar/JobBoard/Onboarding |
| `אבטחה` | unlockSession |
| `הרשמה` | openRegistration, checkRegistration, finishRegistration, enterAsDemo/Existing, loginExisting, pickProfession/Plan/Haul/Slot, prepChoice/Proceed |
| `סריקה` | startScan, resetScan |
| `כללי` | doUndo, toggleNotifications, openNotifDetail, openHelp, openProductDetail, stepCatQty, toast |

The file contains several `/* REFACTORED: … removed */` comments [L12738, 12779, 12811,
12822] documenting deletions (e.g. `cycleFontSize` merged into `cycleSetting`).

### 6.2 `BUTTON_TWINS` [L12900] — shared-contract map (`twinFn → primaryFn`)

Many buttons are functional twins. Instead of duplicating contracts, a twin points to a
primary. Families:
- **order-stage advancers** → `storeAdvance`: `mgrAdvanceOrder`, `storeAdvanceFromSheet`.
- **quantity steppers** → `stepQty`: `stepCatQty`, `stepCartQty`.
- **"open detail panel"** → `mgrOrderDetail`: `mgrCustomerDetail`, `mgrRevenueDetail`,
  `mgrStoreDetail`, `storeOrderDetail`, `courierDetail`, `openBudgetDetail`,
  `openCreditDetail`, `openPaymentDetail`, `openRankDetail`, `openNotifDetail`,
  `openShipmentStatus`, `openSiteStatus`, `openProductDetail`.
- **"close panel"** → `closeTree`: `closeOrder`, `closeAccDetail`, `closeBrands`,
  `closeVariants`, `closeHelp`, `closeDeliveryNote`, `closeSiteStatus`,
  `closeBudgetDetail`, `closeShipmentStatus`, `closeCourierDetail`,
  `closeMgrStoreDetail`, `closeNotifDetail`, `closeRankDetail`.
- **search boxes** → `mgrDoSearch`: `mgrOrderDoSearch`, `mgrCustomerDoSearch`,
  `storeStockDoSearch`.
- **list filters** → `storeOrderSetFilter`: `mgrOrderSetFilter`, `storeStockSetFilter`.

Helpers: `contractOwnerOf(fn)` [L12945] resolves a button to its contract owner;
`twinsOf(primaryFn)` [L12949] lists a primary's twins.

### 6.3 `runButtonAudit()` [L12958] — registry-vs-reality

Walks `BUTTON_REGISTRY`, `eval(b.fn)` to check `typeof===function` ⇒ `{fn,area,does,
defined}`. `NOISE` set [L12963] excludes JS built-ins (`function,indexOf,join,map,replace,
filter,forEach,split,push,slice,toLocaleString,stopPropagation,event,testCheckoutLayout`).

### 6.4 `regCheckProduct(key)` [L12320] — the product contract (13+ checks)

For every catalog product (`catalogProduct`), returns `{key,name,checks[]}`. Accessory
products (`accessoryProduct`) use a lighter standard (`isAcc`). Checks, verbatim names:
1. Required fields exist — `שדה "{fld}" קיים` (Plasson: name/cat/productType/series/
   secondary; acc drops `series`); detail `חסר או ריק`.
2. Image — `תמונה מוטמעת (Base64)` (must start `data:image`) / acc `אייקון מוצר קיים`.
3. `מערך אביזרים קיים`; `כל {n} האביזרים תקינים (שם/must/why)` (detail `פגומים: …`).
4. Size picker — `בורר מידה קיים` / acc `אביזר ללא בורר מידה (תקין)`.
5. `כל {n} המק"טים תקינים`; `כל מק"ט מתומחר בכל {n} החנויות` (detail
   `{n} חוסרי מחיר: …`).
6. `isRich() מחזיר true` (detail `isRich=false — לא יופיע ב"עץ חכם"`).
7. `משויך לקבוצת קטלוג` (detail `המוצר לא מופיע באף קבוצת קטלוג`).
8. `productPrice מחזיר מספר חיובי` / acc `…מספר תקין`.
9. `openTree פותח כרטיס מלא בלי קריסה` (looks for `cd-card`).
10. `renderAccessories רץ בלי קריסה`.
11. `מסע הזמנה מלא (פתיחה→סל) עובד` — opens tree, picks, `addTreeToCart`, asserts cart≥1.
12. `כל {n} אביזרי העץ מתומחרים (לא ₪0)`; **12b** `פונקציית התמחור (accTypePrice) — כל
    מסלול > 0` (probes 7 names incl. the unknown-name fallback).
13. `שורות האביזרים נפתחות (toggleAccDetail)`.

### 6.5 `buildRegressionReport(filter)` [L15829] → `…Core(filter)` [L15834]

Wrapped by `withSilentDialogs` (§6.7). `filter` ∈ `all|buttons|tabs|products|behavior|
dsync|dupes`. Computes: per-product checks; `runButtonAudit`; **live DOM scan** — regex
`on(?:click|change|input)="…"` extracts every wired fn [L15855], minus an extended `NOISE`
set [L15864] (adds `if/for/return/catQty/print` and the tool's *own* controls
`runRegressionTests/regReportClose/regRerunBtn/regRerunBtn2/regRunBtn`). **HOLES** =
live buttons not in the registry [L15879] (the headline finding:
`{n} כפתורים פעילים שאינם ברשימה`, detail explains they're uncovered).

**Tab-coverage matrix** `tabSpecs` [L15884] — 14 render entry-points checked for
(1) function exists, (2) runs without crashing (with full error + line), (3) produced
non-empty content (>40 chars) when a target element is named:

| role | tab | fn | target |
|---|---|---|---|
| קבלן | קטלוג | renderCatalog | catalogList |
| קבלן | סינון מדורג | renderCatDrill | catDrill (soft) |
| קבלן | הפרויקטים | renderProjects | — |
| קבלן | ההזמנות שלי | renderMyOrders | — |
| מנהל | לוח בקרה | renderMgrDashboard | mgrDashboard |
| מנהל | ניהול מוצרים | renderMgrProducts | mgrProductList |
| מנהל | הזמנות | renderMgrOrders | — |
| מנהל | לקוחות | renderMgrCustomers | — |
| מנהל | ניהול | renderMgrManage | — |
| חנות | בית | renderStoreHome | — |
| חנות | הזמנות | renderStoreOrders | — |
| חנות | מלאי | renderStoreStock | — |
| שליח | משלוחים | renderCourier | — |
| עובד | משימות | renderWorker | — |

Summary band: `✅ כל הבדיקות עברו`/`❌ נמצאו כשלים`;
`מוצרים: {p}/{t} · טאבים: {p}/{t} · כפתורים: {p}/{t}[ · ⚠️ {n} לא ברשימה]`.
Failed-tab detail block `🔎 פירוט הכשלים בכיסוי הטאבים ({n})`. Button-audit section
`🗂️ מבדק כיסוי כפתורים — כל {n} הפעולות באתר` grouped by area with `✓`/`✗` + score.

### 6.6 `runRegressionTests(filter)` [L15253] + `FILTERS` [L15276]

Builds the report then shows it in a full-screen modal `#regReportModal` (z-index 99999).
Header `🔬 דוח בדיקת רגרסיה` + `✕ סגור`. Filter bar tabs (`FILTERS`):

| key | label |
|---|---|
| `all` | `▶ הכל` |
| `buttons` | `🗂️ כפתורים` |
| `tabs` | `📑 טאבים` |
| `products` | `🔧 מוצרים` |
| `behavior` | `🎯 התנהגות` |
| `dsync` | `🖥️ סנכרון תצוגה` |
| `dupes` | `🔁 זהות` |

Each filter button re-runs `runRegressionTests(thatFilter)`.

### 6.7 `withSilentDialogs(fn)` [L14732]

Swaps `prompt→''`, `confirm→false`, `alert→noop` (on `window` AND bare globals) for the
duration of any test run, then restores — so a button calling native dialogs can't freeze
the report. *(Critical for testing the manager's prompt-based editors, §5.4.)*

### 6.8 Button fingerprinting — precise effect-signatures

`profileButton_courierAdvance()` [L14915] and `profileButton_addTreeToCart()` [L15104]
demonstrate the "200% accuracy" method: deep `snap()` of all observable state (SYS_ORDERS,
cart, treeState, STORE_STOCK, currentTree/Screen, expandedAcc, stages map), run the
button, snap again, compute a **precise diff**, then match against an `SIG` table where
each action returns true ONLY on its exact footprint.

Inside `profileButton_courierAdvance`:
- **Stage-probe matrix** [L14942]: drives the button on every stage with
  `stageExpect={ready:'pickup',pickup:'transit',transit:'delivered',delivered:'delivered'}`
  — verifies `delivered` does NOT advance.
- **Persist spy** [L14956]: wraps `saveSysOrders` to assert it was actually *called*, not
  just defined.
- `STAGE_TWINS={storeAdvance:1,mgrAdvanceOrder:1,storeAdvanceFromSheet:1}` [L15042] — these
  cause an identical stage change, so they are reported `nottouched`
  (`פעולה דומה, אך לא הופעלה ע"י הכפתור הזה`) — credit is tied to the actual invocation.
- `UNMEASURABLE` [L15045, 15212] — ~35 actions with no measurable state footprint
  (`toast,print,close*,open*Detail,mgrScrollProducts,openTask,…`) reported `unmeasured`.
- Verdicts: `self` / `touched` / `nottouched` / `unmeasured`.
  `courierAdvance` why-string: `קידם משלוח: {from} → {to}`.

`profileButton_addTreeToCart` adds cart-specific signal fields (`cartAutoCount`,
`cartManualCount`, `cartKeyed`, `cartQtySum`) so it can distinguish `addTreeToCart`
(grew with `auto:true`) from `addSingle` / `toggleProductInCart` / `removeCartItem`
/ `stepCartQty` purely by the *kind* of cart change.

### 6.9 Display-sync probes — `getDisplaySyncProbes()` [L14759]

5 probes, each runs a button that changes a number then compares the in-memory value to
the on-screen text (`synced` true only if equal):

| id | name | fn | DOM target |
|---|---|---|---|
| `stepQty` | `כמות אביזר (עץ מוצרים)` | stepQty | `qwVal0` |
| `stepCatQty` | `כמות בקטלוג` | stepCatQty | `cqVal-{k}` |
| `stepCartQty` | `כמות בסל` | stepCartQty | `cartQty0`/`cqRow0` |
| `cartTotal` | `סכום כולל בסל` | renderCart | `cartTotal`/`cartSum`/`cartTotalVal` |
| `notifCount` | `מונה התראות` | renderNotifications | `notifCount`/`notifBadge` |

`runDisplaySyncTest(probeIds)` [L14866] runs selected probes; comparison strip states
`✓ מסונכרן` / `✗ לא מסונכרן` / `לא נמדד`, with `נתון: {data} · מסך: {shown}`.

### 6.10 Duplicate detector — `findDuplicates()` [L14984]

(1) catalog products sharing a name (skips intentional main+accessory dual-listings);
detail `קטגוריה זהה/שונה, מספר אביזרים זהה/שונה`. (2) registry buttons with identical
`does` not linked as twins (unmapped twins). Surfaced under the `🔁 זהות` filter.

### 6.11 `openTestChooser()` [L15336] — hand-pick / compare

Modal `🎛️ בחר מה לבדוק`. Lists the 5 dsync probes under `🖥️ סנכרון תצוגה ({n} בדיקות —
בחר 2+ כדי להשוות ולתפוס באג תצוגה)`, then all 350 buttons grouped by area, each badged:
`⚖️ חוזה תאום ({owner})` / `🧩 חוזה משפחה — {family}` / `✓ חוזה מלא` / `בדיקת קיום בלבד`.
Toolbar: `▶ הרץ נבחרים` (`showCustomResults(ids,false)`), `⚖️ השווה נבחרים`
(needs ≥2, `…,true`), `סמן הכל`, `נקה`, `{n} נבחרו`. Alerts:
`סמן לפחות בדיקה אחת` / `להשוואה צריך לסמן לפחות 2 בדיקות`.

### 6.12 `getSelectableTests()` [L15671] — contract registry

Maps each primary button to a dedicated test fn (`CONTRACTS` [L15673]): e.g.
`storeAdvance→testTen_storeAdvance`, `toggleStoreStock→testTen_toggleStoreStock`,
`storeLogin→testCrit_storeLogin`, `storePickLine→testCrit_storePickLine`,
`storeMissLine→testCrit_storeMissLine`, `courierAdvance→testButton_courierAdvance`,
`taskApprove→testTen_taskApprove`, `taskReject→testCrit_taskReject`,
`moveStock→testImp_moveStock`, plus navigation guards via `testImp_navSafe`. Buttons
without a dedicated contract fall into **FAMILY CONTRACTS** [L15738] (each binds a generic
family test to the fn name):
- `openFamily` [L15743] → `פתיחת חלון` (`testFamily_openPanel`)
- `toggleFamily` [L15748] → `מתג הרחבה/כיווץ` (`testFamily_toggle`)
- `pickFamily` [L15752] → `בחירת אפשרות` (`testFamily_pick`)
- `saveFamily` [L15756] → `שמירת טופס` (`testFamily_save`)
- `deleteFamily` [L15758] → `מחיקת פריט` (`testFamily_delete`)
- `addFamily` [L15760] → `הוספת פריט` (`testFamily_add`)
- `entryFamily` [L15761] → `הרשמה / כניסה` (`testFamily_entry`)
- otherwise → `existenceTest(fn)` [L15724] (`הפונקציה {fn} קיימת ומוגדרת` /
  `…לא קיימת — לחיצה על הכפתור לא תעשה כלום.`)

---

## 7. REMAINING DATA TABLES (verbatim)

### Supplier / pricing
- **`STORES`** [L11930] (`let`, mutable by manager): 3 demo stores
  `{name,area,eta,on}` — `מחסני אינסטלציה תל-אביב`/`גוש דן`/`עד שעתיים`,
  `ספקי סניטריה השרון`/`השרון`/`עד שעתיים`, `חומרי בניין הרצליה`/`הרצליה והסביבה`/
  `עד שעה`; all `on:true`.
- **`SUPPLIER_STORES`** [L11942] (checkout config, keyed `s1/s2/s3`):
  `{name, icon, shipping, eta}` — s1 `🔧`/90/`עד שעתיים`, s2 `🚿`/65/`עד 3 שעות`,
  s3 `🧱`/45/`עד שעה`. `STORE_IDS=Object.keys(SUPPLIER_STORES)`.
- **`STORE_PRICING`** [L11908]: `{store0,store1,store2}` — per-store SKU→price maps,
  ~200 SKUs each (Plasson fitting catalog). store0 baseline, store1 ~−7%, store2 ~+13%.
  `activeCatalogStore='store0'`; `skuPrice(sku)` [L11918], `catalogProductPrice(key)`
  [L11923]. Used by `regCheckProduct` check #5 (every SKU priced in every store).
- **`STORE_STOCK`** [L12050]: `{}` initialized `true` for every `TREES` key [L12051].
  The availability flag toggled by store/manager; `false` ⇒ hidden from contractor
  catalog.
- **`STOCK_DEMO`** [L6202]: name→`'warehouse'|'site'` map (11 entries, e.g.
  `סרט טפלון:warehouse`, `ברזי ניל זוויתיים:site`, …). Drives the prep/"where are you?"
  flow (`buildPrep` [L11661]), NOT the supplier stock. `buildPrep(loc)` builds
  warehouse-loading vs on-site-missing lists with prompts
  `🚚 משלוח ישר לאתר`/`🛍️ אאסוף בדרך`/`🏬 לקחת מהמחסן`/`🚚 משלוח מחנות`.
- **`SUPPLIER_RATINGS`** [L20741]: 3 rows `{name,score,orders,onTime}` —
  4.7/182/96, 4.4/140/91, 4.1/97/88.
- **`DIST_ZONES`** [L20727]: 4 zones `{name,eta,fee}` —
  `תל-אביב והמרכז`/`עד שעתיים`/0, `השרון`/`עד 3 שעות`/40,
  `ירושלים והסביבה`/`יום עסקים`/90, `חיפה והצפון`/`יום עסקים`/120.
- **`BULK_TIERS`** [L20734]: `{min,discount}` — 1/0, 20/5, 50/9, 100/14.

### Haulage / fleet / vehicle
- **`HAUL_TYPES`** [L11950]: `{id,name,ic,extra}` —
  `small`/`משלוח קטן`/🛵/0, `van`/`טנדר`/🚐/40, `truck`/`משאית`/🚛/90.
  Helpers `storeHaul{}`, `haulFor(sid)` [L11956], `haulExtra(sid)` [L11957].
- **`VEHICLE_RANK`** [L17946]: `{small:0,van:1,truck:2}`.
- **`FLEET`** [L20720]: 4 vehicles `{id,name,type,cap,status,driver}` —
  V14 `משאית 14`/`עד 5 טון`/`בדרך`/`אבי`, V08 `מסחרית 08`/`עד 1.2 טון`/`פנוי`/`רונן`,
  V21 `משאית 21`/`עד 8 טון`/`בתחזוקה`/`—`, V05 `טנדר 05`/`עד 800 ק״ג`/`פנוי`/`מאי`.

### Worker
- **`WORKERS`** [L8021] = `['רן (עובד)','עומר (עובד)']`.
- **`TASKS`** [L8023] — 5 demo tasks (table in §4.1).
- **`WORK_LOG`** [L8156] — 2 historical days (§4.1).

### Manager / sim
- **`SIM_CUSTOMERS`** [L17159] =
  `['אלי בניין בע״מ','קבלן דוד שמש','י. לוי שיפוצים','מ.כ. הנדסה','אחים ברק בנייה']`.
- **`SIM_SITES`** [L17160] = `['מגדל יוקרה — רמת גן','וילה פרטית — כפר שמריהו',
  'בניין מגורים — פתח תקווה','שיפוץ דירה — תל אביב','פרויקט מסחרי — ראשל״צ']`.
- **`CONTRACTOR_CREDIT`** [L16537] = `{}` lazily filled by `contractorCredit()`
  (deterministic 30k–120k).

### Checkout config (shared)
- `VAT_RATE=0.18` [L11941] (single source of truth, Israeli VAT 18% since Jan 2025).
- `EXPRESS_FEE=80` [L11961], `expressDelivery=false`, `creditLimit=50000` [L11963] — all
  mutable by the manager.

> Note: there is **no separate `SUPPLIERS` table** — supplier data lives in `STORES`
> (login/analytics) and `SUPPLIER_STORES` (checkout fees). They are intentionally distinct
> demo sets (same 3 names, different fields).

---

## 8. Quick function index

| Function | [L#] | Persona/system |
|---|---|---|
| renderStoreLogin / storeLogin / storeLogout | 11775 / 11792 / 11801 | Store login |
| buildPrep | 11661 | Prep flow (uses STOCK_DEMO) |
| renderStoreHome | 17080 | Store |
| simulateIncomingOrder | 17161 | Store demo |
| renderStoreOrders / storeOrderSetFilter | 17299 / 17385 | Store |
| storeAdvance | 17386 | Store engine |
| renderStorePick / storePickLine / storeMissLine | 17455 / 17576 / 17585 | Store picking |
| storeAdvanceFromSheet | 17817 | Store picking |
| renderStoreStock / toggleStoreStock | 17875 / 17928 | Store stock |
| renderStorePortal | 20760 | Store portal |
| vehicleCanCarry / pickCourierVehicle | 17951 / 17956 | Courier |
| renderCourier / renderCourierHome / renderCourierList | 17963 / 17991 / 18067 | Courier |
| courierDetail / courierAdvance | 18155 / 18226 | Courier engine |
| openCourierPortal / courierNav / courierPOD | 20786 / 20812 / 20842 | Courier portal |
| renderWorker / taskActionClick / taskApprove / taskReject | 11832 / 8138 / 8152 / 8153 | Worker loop |
| openTaskLog | 8167 | Worker log |
| mgrAnalytics / renderMgrDashboard | 12081 / 12133 | Manager |
| renderMgrProducts / mgrToggleAvail | 16478 / 16515 | Manager |
| renderMgrManage (+ editors) | 16645 | Manager |
| mgrCustomerList / renderMgrCustomers / mgrCustomerDetail | 16546 / 16566 / 16609 | Manager |
| renderMgrOrders / mgrAdvanceOrder / mgrOrderDetail | 16946 / 17022 / 17035 | Manager |
| renderMgrStores / openMgrStore / toggleMgrStore | 16892 / 16911 / 16933 | Manager |
| showDeliveryNote / closeDeliveryNote | 17212 / 17280 | Shared doc |
| loadSysOrders / saveSysOrders / storage listener | 12003 / 12021 / 18281 | Engine sync |
| orderStoreIndex / ordersForActiveStore | 12062 / 12075 | Engine routing |
| regCheckProduct | 12320 | Self-test |
| runButtonAudit / contractOwnerOf / twinsOf | 12958 / 12945 / 12949 | Self-test |
| findDuplicates | 14984 | Self-test |
| withSilentDialogs | 14732 | Self-test |
| profileButton_courierAdvance / _addTreeToCart | 14915 / 15104 | Self-test fingerprint |
| getDisplaySyncProbes / runDisplaySyncTest | 14759 / 14866 | Self-test dsync |
| runRegressionTests / buildRegressionReport(Core) | 15253 / 15829 / 15834 | Self-test |
| openTestChooser / showCustomResults / getSelectableTests | 15336 / 15479 / 15671 | Self-test chooser |

---

## → Flutter port notes

**R2 is absolute: NONE of these become full-screen dashboards in Flutter.** The prototype
implements each persona as a `<main>`-filling `admin-screen`; that is exactly the
window-replacement pattern R2 forbids. In the Flutter port every persona becomes a
**multi-level dial-drill reached through the BS FAB** (`bs/bs-dial.tsx`), never a view.
The existing parity work already deferred these to placeholders — see CLAUDE.md "BS FAB —
5 personas" (👔 מנהל / 🏪 חנות / 🛵 שליח / 🦺 עובד have shallow sub-trees of *labels only*).

**Functionality is currently 0% ported.** What lives in Flutter today is only the dial
*structure* (verbatim Hebrew leaf labels + emoji), not behavior. The following are entirely
absent from `app_flutter/` and would each be substantial new work:

1. **Shared order engine** — `SYS_ORDERS` state machine (`ORDER_STAGE`/`ORDER_FLOW`), the
   localStorage cross-tab sync, and the seed/migration logic. In Flutter use a Riverpod
   `StateNotifier<List<Order>>` + persistence (Hive/`shared_preferences`); the `storage`
   event has no web-only equivalent across native — use a stream/repository the four
   persona drills all watch. Keep the exact 6-stage model and the *who-advances-what* split
   (store: new→ready, courier: ready→delivered, manager: any step).
2. **Per-persona drills** — Store (home/orders/picking-sheet/stock/portal), Courier
   (home/list/detail/portal with vehicle gating), Worker (task loop), Manager (analytics/
   products/orders/customers/manage). Each render fn maps to a *drill level*, not a screen.
   The picking sheet, missing-item hold loop, split-shipment grouping, and worker→manager
   approval loop are the high-value flows worth porting first.
3. **Self-test system** — `BUTTON_REGISTRY` (350), twins/families, `regCheckProduct`,
   the live-DOM button scan, fingerprinting, dsync probes, dupes. The DOM-scan and
   `eval()`-based existence checks **cannot** port to Flutter (no `document.outerHTML`,
   no `eval`). If a QA harness is wanted, re-express it as a Dart test suite + a static
   action registry; the *concept* (every fixed bug → permanent check; registry-vs-reality
   coverage) is portable, the *mechanism* is not.
4. **Native prompt/confirm editors** — the manager's `prompt()`/`confirm()` editors (and
   `withSilentDialogs`) must become Flutter dialogs/bottom-sheets. Per **R9**, any text
   entry should be an inline input attached to its dial leaf, not a modal.

**Verbatim-string obligation (R6/R8):** every Hebrew label, toast, pill, status text, and
section header quoted above is load-bearing and must be copied character-for-character when
the behavior is eventually ported — including punctuation (`״`, `׳`, `—`, `›`, `✓`) and
emoji. Do not invent or translate.

**Do not start building any of these as a Flutter `dashboard`/`view` without explicit
user approval** (CLAUDE.md: three R2 violations already caused three reverts).
