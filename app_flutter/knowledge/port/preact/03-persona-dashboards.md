# 03 — Supplier-Side Persona Dashboards (Store · Courier · Worker · Manager)

> **Scope.** Faithful capture of the four **deep-dive dashboard specs** in the live
> Preact knowledge base — `app/knowledge/{STORE,COURIER,WORKER,SYSTEM_MANAGER}_DASHBOARD.md`
> — into the Flutter port knowledge. These are reverse-engineering specs of the four
> supplier-side persona apps, derived from the `/index.html` prototype.
> **Read-only capture; no source was edited.**
>
> **Cross-reference.** The prototype source of truth for all four personas + the shared
> order engine is `../proto/06-personas-engine-selftest.md` (line-anchored `[L#]` to
> `/index.html`). **This doc is the UI-layer companion**: where proto 06 gives the
> verbatim strings, functions, and state machine, the four dashboard docs add **screen
> geometry, per-stage card anatomy, portal tile grids, the manager 7-section management
> hub, the customer credit model, and the delivery-note document layout**. Sections below
> flag "**adds beyond proto 06:**" wherever the dashboard doc carries detail not in 06.
>
> **R2 reminder.** In the prototype each persona is a full-screen `admin-screen`. Per R2
> these become **BS-dial drills** in Flutter, never windows. See "→ Flutter port notes".
>
> **Maps to** `PARITY.md` **domain G** ("4 אפליקציות-התפקיד — כ-dial, לא dashboards!").

---

## 0. Shared frame (all four personas)

- **Entry:** role drawer (`screen-welcome`) → `enterRole(role)` sets RBAC role, shows the
  persona screen, calls its init render. Routing: `manager`→`screen-manager`+`admTab('m-products')`,
  `store`→`screen-store-login`+`renderStoreLogin()`, `courier`→`screen-courier`+`renderCourier()`,
  `worker`→`screen-worker`+`renderWorker()`.
- **Tab quirk** (proto 06 §0): `admTab` strips `.on` from *every* `.adm-pane` document-wide,
  so courier/worker re-assert their own pane `.on` on each render or render blank after a
  manager/store visit. Manager + Store are tabbed (4 tabs each); Courier + Worker are
  single-pane.
- **Shared data model:** `SYS_ORDERS`, `TREES`, `STORE_STOCK`, `STORES`, `TASKS`. Every
  mutation re-renders the other roles (incl. the contractor's `renderMyOrders`) for two-way
  sync.
- **Shared order stages (6):** `new` התקבלה · `preparing` בהכנה · `ready` מוכן לאיסוף ·
  `pickup` נאסף · `transit` בדרך לאתר · `delivered` נמסר ✓. `ORDER_FLOW` is that linear order.
  Who advances: **store** owns `new→preparing→ready`; **courier** owns
  `ready→pickup→transit→delivered`; **manager** can nudge any single step.

---

## 1. 🏪 חנות ספק — Supplier Store (`screen-store`)

**Role:** supplier store manager / warehouse operator. **RBAC:** `order.fulfill` + `stock.edit`.
**Tabs (4):** `s-home` 🏠 בית · `s-orders` 📥 הזמנות · `s-stock` 📦 מלאי · `s-portal` 🧰 פורטל.

### 1.1 Login (`screen-store-login`, `renderStoreLogin`)
List of 3 stores from `STORES` (`{name, area, eta, on}`). Each card: 🏪 icon, name,
`📍 {area} · 🕐 {eta}`, status pill 🟢 `פעילה` / 🔴 `מושבתת`, chevron `‹`. `storeLogin(i)`
sets `activeStoreIndex`, appbar title `🏪 {name}`, opens `screen-store`, selects `s-home`,
toast `ברוך הבא — {name}`. `storeLogout()` returns to login. Stores (verbatim):
`מחסני אינסטלציה תל-אביב`/גוש דן/עד שעתיים · `ספקי סניטריה השרון`/השרון/עד שעתיים ·
`חומרי בניין הרצליה`/הרצליה והסביבה/עד שעה (all `on:true`).

### 1.2 Home tab (`renderStoreHome`, `#storeHome`)
Buckets from `ordersForActiveStore()`: `toApprove`=new, `inPrep`=preparing, `ready`=ready,
`held`=heldForMissing, `todayRevenue`=Σ sum of new+preparing+ready, `outOfStock`=count of
`STORE_STOCK[k]===false`. Layout order:
1. Greeting `שלום 👋`; sub `🏪 {store} — מה שצריך טיפול עכשיו`.
2. **Primary action card** if `toApprove>0`: count badge · `הזמנות ממתינות לאישור` ·
   `הקש כדי לאשר ולהתחיל הכנה` · chevron → `admTab('s-orders')`. Else `✓ אין הזמנות שממתינות לאישור`.
3. **Held card** if any held: `הזמנות ממתינות לבחירת הקבלן` · `פריט חסר — ממתין להחלטה (החלפה / ביטול)`.
4. **Quick stats (3):** `{inPrep} בהכנה 🔧` · `{ready} מוכן לאיסוף 📦` · `₪{todayRevenue} מחזור פעיל 💰` (each → orders).
5. **Stock alert:** `⚠️ {n} מוצרים אזלו מהמלאי — הקש לעדכון` else `✓ כל המוצרים זמינים במלאי` (→ stock).
6. **Big action buttons (2):** `📥 הזמנות` · `📦 מלאי`.
7. **Demo tool:** `➕ סימולציית הזמנה נכנסת (כלי הדגמה)` → `simulateIncomingOrder()` (picks 3–6 random
   `TREES`, qty 1–5, sum ×1.18; `unshift` a `BS-####` `new` order routed to active store; toast
   `הזמנת הדגמה {id} נוצרה — נכנסה לתור ✓`; customer/site from `SIM_CUSTOMERS`/`SIM_SITES`).

### 1.3 Orders tab (`renderStoreOrders`, `#storeOrderList`)
`storeOrderFilter='active'`; only `new|preparing|ready` shown. Chips: `פעילות` · `לאישור` ·
`בהכנה` · `מוכנות`. Empty `אין הזמנות בקטגוריה זו ✓`. Card body: `📦 {id}`, who·site,
`🕒 נדרש: {deliverWhen|בתיאום}`, meta `{items} פריטים · ₪{sum} · הקש לתעודת ליקוט`. Per-stage button:

| stage / flag | status pill | action button |
|---|---|---|
| `new` | לאישור (yellow) | `✓ אשר וקבל להכנה` → `storeAdvance` (→preparing) |
| `preparing` | בהכנה (blue) | `📦 סמן כמוכן — העבר לשליח` (amber) → `storeAdvance` (→ready) |
| `ready` | מוכן (green) | `🛵 ממתין לאיסוף השליח` (info-only) |
| `heldForMissing` | פריט חסר (orange) | `⏳ פריט חסר — אנא המתן להחלטת הקבלן` (button hidden) |
| `missingResolved` | original | `✓ תיקון בוצע — {פריט הוסר|בדוק שינויים}` then the stage action |

Split pill `🚚×{n}` (pulses `.fresh` first view), meta ` · 🚚 הוכן ב-{n} חבילות`.
`storeAdvance(id)`: RBAC `requirePerm('order.fulfill','קידום הזמנה')`; `saveSysOrders` then
re-render orders+home+`renderMyOrders`; toast `ההזמנה {id} עודכנה — מסונכרן עם השליח והמנהל ✓`.
Delegated handlers: `data-sadvance`→`storeAdvance`, `data-sdetail`→`storeOrderDetail`.

### 1.4 Picking sheet (`renderStorePick`, overlay `#storePickOverlay`)
*Adds beyond proto 06:* the dashboard doc enumerates the full per-line state set + the
progress-bar/grouping geometry. Header `📦 {id}`, who·site, `סטטוס: {label}`; progress bar
`{handled}/{lines} פריטים טופלו`. Alerts: held `⏳ פריט חסר — ממתין לבחירת הקבלן (החלפה / ביטול)`;
else missing>0 `⚠️ {n} פריטים חסרים — הקבלן עודכן`; split banner
`🚚 ההזמנה מפוצלת ל-{n} משלוחים — הכן כל קבוצה כחבילה נפרדת.`. `storeItemInfo(name)` resolves a
line → `{img,cat,price,why}`. Per line: thumb, name (+`מוצר חלופי` chip if replaced), cat tag,
`₪{price} ליח׳`, why, `כמות לליקוט: {qty} · סה״כ ₪{total}`, status text + two buttons `✓`/`חסר`.

**Line states:** `✓ לוקט` (picked) · `✕ חסר` (missing) · pending (both off) ·
`✕ בוטל ע״י הקבלן` (cancelled) · `🔁 הוחלף ע״י הקבלן` (replaced) · `⏳ ממתין לבחירת הקבלן` (pendingDecision).
**Split grouping:** lines grouped by `splitPlan[i]`; group header `📦 משלוח {g} — {n} פריטים` +
meta `🕒 {when} · 📍 {site} · {haulIc} {haulName}`. Footer action: `new`→`✓ אשר וקבל להכנה`;
`preparing`+all handled→`📦 כל הפריטים טופלו — סמן כמוכן`; `preparing`+not all→hint
`סמן כל פריט כ"לוקט" או "חסר" כדי לסיים את ההכנה` + `סמן כמוכן בכל זאת`; else
`🛵 ההזמנה מוכנה — ממתינה לאיסוף השליח`; always `📄 הצג תעודת משלוח`.

`storePickLine(i)` toggles `picked` (clears missing). `storeMissLine(i)` toggles `missing`; on
newly-flagged missing sets `o.hasMissing=o.heldForMissing=true`, `line.pendingDecision=true`,
pushes a `פריט חסר — נדרשת החלטה` notification, opens `openMissingDecision`. `heldForMissing`
is an **order boolean** (hold gate), cleared in `resolveMissingLine` when no line still has
`pendingDecision`. `storeAdvanceFromSheet`: aborts on held with `⚠️ ההזמנה ממתינה להחלטת הקבלן
על פריט חסר — לא ניתן להמשיך`, else delegates to `storeAdvance`. Missing-item loop (contractor
side): `missingProceedWithout` (cancel line) / `missingReplace` (open catalog) + checkout
out-of-stock gate `openOutOfStockGate` (`מוצר אינו במלאי`, `דלג — הסר מההזמנה`/`החלף מוצר`).

### 1.5 Stock tab (`renderStoreStock`, `#storeStockList`)
`storeStockFilter='all'`, `storeStockSearch=''`. Summary tiles `{n} מוצרים`/`{n} זמינים`/`{n} אזלו`.
Search `חיפוש מוצר...`. Chips `הכל`/`זמינים`/`אזלו`. Row: thumb, name, `✅ זמין במלאי` /
`❌ אזל — מוסתר מהקבלן`, toggle switch → `toggleStoreStock(k)`. Empty `לא נמצאו מוצרים תואמים.`
`toggleStoreStock(k)`: RBAC `requirePerm('stock.edit','עריכת מלאי')`; flips `STORE_STOCK[k]`
(`{}` init `true` per `TREES` key); re-renders stock+home+**`renderCatalog`** (sold-out item
disappears from contractor catalog); toast `המוצר סומן כזמין` / `המוצר אזל — הוסתר מקטלוג הקבלן`.

### 1.6 Portal tab (`renderStorePortal`, `#storePortal`) — 8 tiles
*Adds beyond proto 06:* the dashboard doc gives each tile a title+subtitle+target fn. Tiles
(`fin-tile`): `⭐ דירוג ספקים / ציון וביצועים` (`portalRatings`) · `⏱️ מעקב SLA / ספירה לאחור`
(`portalSLA`) · `🗺️ אזורי הפצה / זמני אספקה` (`portalZones`) · `📉 הנחות כמות / מדרגות הנחה`
(`portalBulk`) · `🏷️ הפקת ברקודים / תוויות למוצרים` (`portalBarcode`) · `🚛 ניהול צי רכב / רכבים
וזמינות` (`portalFleet`, data `FLEET`) · `💬 צ׳אט עם קבלן / הודעות פנימיות` (`openChat('contractor')`)
· `🔄 עדכון מלאי / אוטומטי לפי מכירות` (`portalAutoStock`). Each opens `#portalFeatureOverlay`.

### 1.7 Store state variables
`activeStoreIndex` · `storeOrderFilter` · `storeStockSearch` · `storeStockFilter` ·
`storePickId` · `deliveryNoteReturn`.

---

## 2. 🛵 שליח — Courier (`screen-courier`)

**Role:** delivery driver. **RBAC:** `order.fulfill`. **Single pane** (no tabs); two regions
(`#courierHome` + `#courierList`) rendered independently by `renderCourier()`. State:
`courierVehicle='truck'`, `activeChatPeer`.

### 2.1 Vehicle gating
`HAUL_TYPES`: `small` משלוח קטן 🛵 (extra 0) · `van` טנדר 🚐 (40) · `truck` משאית 🚛 (90).
`VEHICLE_RANK={small:0,van:1,truck:2}`. `vehicleCanCarry(vehicle,need)` → `need.rank <= vehicle.rank`
(bigger carries smaller; undefined vehicle carries all). `pickCourierVehicle(id)` sets vehicle,
re-renders both regions, toast `הרכב נקבע: {ic} {name}`.

### 2.2 Home region (`renderCourierHome`)
Orders filtered by vehicle capacity. `toPickup`=ready, `onRoad`=transit, `delivered`=delivered.
Greeting `שלום 🛵` · `המשלוחים שלך להיום` · vehicle picker `הרכב שלי היום` (3 buttons, selected
gets `.on`). Primary: `toPickup>0`→count + `משלוחים ממתינים לאיסוף` / `אסוף מהחנות כדי להתחיל`;
elif active>0→`🚚 {n} משלוחים בדרך — אין איסופים ממתינים`; else `✓ אין משלוחים שמתאימים ל{haulName} כרגע`.
Stats (3): `{toPickup} לאיסוף 📦` · `{onRoad} בדרך 🚚` · `{delivered} נמסרו ✅`. Portal button
`פורטל השליח / ניווט, צי רכב, צ׳אט ומעקב SLA` → `openCourierPortal()`.

### 2.3 Delivery list region (`renderCourierList`)
**Job model** (key concept, *adds beyond proto 06 with the full grouping algorithm*): a "job"
≠ an order. Non-split order = 1 job; split order = N jobs (one per active shipment).
`ACTIVE=['ready','pickup','transit']`; filtered by vehicle; `delivered` excluded; sorted
ready→pickup→transit. Empty `אין משלוחים שמתאימים ל{ic} {name}. נסה לבחור רכב גדול יותר.`
Card: `📦 {id}[· משלוח {n}]`, stage pill (`ready`→לאיסוף yellow, `pickup`→לקיחה blue, `transit`→בדרך
green), split pill `🚚 משלוח {n}/{total}` (pulses fresh), `👤 {who}`, `📍 {site}`, `🕒 נדרש: {when}`,
`{haulIc} {haulName}`, **3-step tracker** (`איסוף`──`בדרך`──`נמסר`), meta `{itemCount} פריטים
[· ₪{sum}] · הקש לפרטים` (split jobs omit price). Advance id = `orderId` or `orderId#shipIdx`.

Per-stage button: ready/preparing/new → step1 → `📦 אספתי מהחנות`; pickup → step2 →
`🚚 יצאתי לדרך`; transit → step3 → `✅ נמסר ללקוח` (amber). Delegated: `data-advance`→`courierAdvance`,
`data-detail`→`courierDetail`.

### 2.4 Detail sheet (`courierDetail`, `#courierDetailOverlay`)
Parses `orderId#shipIdx`. Expanded tracker (`איסוף מהחנות`/`בדרך לאתר`/`נמסר`); labelled rows
לקוח / כתובת מסירה / מועד נדרש / מספר פריטים (+פיצול משלוח / סכום ההזמנה); item list `תכולת המשלוח`
(filtered to shipment's `lineIdx` if per-shipment); action buttons mirror the list +
`📄 תעודת משלוח`. Close → `closeCourierDetail()`.

### 2.5 Advance engine (`courierAdvance`)
Pure `next(stage)` map: ready/preparing/new→pickup, pickup→transit, transit/shipped→delivered,
else null. For a shipment job: advance `sh.stage` then `o.stage = deriveOrderStageFromShipments(o)`
(all delivered→delivered; any transit→transit; any pickup→pickup; any ready→ready; else preparing).
For a whole-order job: advance `o.stage`, syncing all shipments. `saveSysOrders`→`renderCourier`→
`renderMyOrders`; toast `המשלוח {label} עודכן — מסונכרן עם החנות והמנהל ✓`.

### 2.6 Portal (`openCourierPortal`, `#courierPortalOverlay`) — 6 tiles
Head `🧰 פורטל השליח / כל הכלים לניהול המשלוחים שלך.` Tiles: `🧭 ניווט למשלוח / מסלול לאתר`
(`courierNav` → lists active orders → `🧭 פתח ניווט` → `startCourierNav` opens Google Maps to
`o.site`, toast `פותח ניווט אל: {dest} 🧭`) · `🚛 צי רכב / רכבים וזמינות` (`portalFleet`) ·
`⏱️ מעקב SLA / זמני אספקה` (`portalSLA`) · `🗺️ אזורי הפצה / מפת אזורים` (`portalZones`) ·
`📸 אישור מסירה / POD + צילום` (`courierPOD` → transit/pickup orders → `📷 צלם מסירה`
[`capturePOD` sets `o.podPhoto`, toast `צילום המסירה נשמר 📸 (דורש הרשאת מצלמה במכשיר)`] +
`✍️ חתימה` [`openSignature`]; pill `נחתם ✓`/`ממתין`) · `💬 צ׳אט עם חנות / הודעות פנימיות`
(`openChat('courier')`).

---

## 3. 🦺 עובד — Field Worker (`screen-worker`)

**Role:** on-site crew member. **Single pane**, task-centric. Shares the `TASKS` model with the
manager task view via the shared `taskCard()` + `openTask()` engine. State: `activeWorker=0`,
`taskRole='worker'` (set on render so `openTask` shows worker controls), `currentTask`.
`WORKERS=['רן (עובד)','עומר (עובד)']`.

### 3.1 Render (`renderWorker`, `#workerTasksBody`)
Worker picker buttons from `WORKERS` (selected `.on`) → `pickWorkerScreen(i)`. Buckets for
`activeWorker`: `current`=active|rejected, `queue`=pending, `submitted`=review|done; `doneCount`,
`pct = round(done/total*100)`. Summary (`ww-summary`): `שלום, {name} 👷` (strips ` (עובד)`), sub
`יש לך משימה פעילה` / `יש משימות בתור` / `אין משימות פתוחות`, badge `{done}/{total}`, progress bar,
stats `{1|0} פעילה` 🔨 / `{q} בתור` ⏳ / `{s} הוגשו` 📋. Sections: `🔨 המשימה הנוכחית שלך`
(or `🎉 אין משימה פעילה כרגע`) · `⏳ הבאות בתור ({n})` · `📋 שהגשת ({n})`.

### 3.2 Task model (`TASKS`, 5 demo tasks)
Shape: `{id, name, detail, worker, status, photo, note, days, steps[]}`.

| id | name | worker | status | days | steps |
|---|---|---|---|---|---|
| 1 | התקנת קו מים חם — חדר רחצה | 0 רן | `active` | 2 | 4 |
| 2 | הרכבת מיכל הדחה סמוי | 0 | `pending` | 1 | 4 |
| 3 | איטום רצפת מקלחת | 1 עומר | `review` (photo `demo`, note `בוצע — שכבה שנייה תתייבש מחר`) | 3 | 6 |
| 4 | התקנת נקזון רצפה | 1 | `done` (note `הושלם ונבדק`) | 1 | 3 |
| 5 | חיבור ברז כיור + ברזי ניל | 0 | `pending` | 2 | 4 |

`taskStatusInfo(s)`: `pending` ⏳ ממתינה (cls pend) · `active` 🔨 בביצוע (act) · `review` 📸 ממתין
לאישור (rev) · `done` ✅ אושר ✓ (done) · `rejected` ↩️ נדחה — לתקן (rej).
*Note — string drift between docs:* WORKER_DASHBOARD.md renders the badges as `⏳ בתור` / `🔨 בביצוע`
/ `✕ דחוי` / `📋 בבדיקה` / `✓ הושלם`; proto 06 / `taskStatusInfo` (the prototype source) uses the
verbatim strings in this table. **For the port, treat `taskStatusInfo` (proto 06) as authoritative.**

`WORK_LOG`: 2 historical days `אתמול` (3 done) + `שלשום` (2 done), items `{worker,task,status}`;
`openTaskLog()` prepends a synthetic `היום` day computed from `done` tasks.

### 3.3 Worker→Manager approval loop (state machine)
`pending → active → review → (done | rejected → active)`.
- **Worker** (`taskRole='worker'`): pending→`startTask` (→active); active→`completeTask`/
  `taskActionClick` saves note, sets `photo='demo'` if none, status→`review`, **auto-activates the
  worker's next pending task**, toast `נשלח לאישור המנהל ✓` (WORKER_DASHBOARD also notes the toast
  `המשימה הוגשה לבדיקה`); rejected→`startTask` retry; review/done→view-only.
- **Manager** (`taskRole='manager'`): a `review` task shows `↩️ החזר לתיקון` + `✅ אשר`.
  `taskApprove` → done, toast `המשימה אושרה ✓`. `taskReject` → rejected, clears photo, toast
  `המשימה הוחזרה לעובד לתיקון`. `taskUpload` sets `photo='demo'`, toast `תמונה צורפה (הדגמה)`.
- Manager view `renderTasks()` groups `📸 ממתין לאישור שלך` / `🔨 בביצוע עכשיו` / `⏳ ממתינות בתור`
  / `✅ הושלמו ואושרו`; intro `אתה רואה את כל משימות הצוות. אשר עבודות שהוגשו ועקוב אחרי ההתקדמות.`
  + log button `📅 יומן עבודה — מה בוצע בכל יום`.
- `refreshTasks()` re-renders whichever view (`screen-worker` visible → `renderWorker`, else `renderTasks`).

*Adds beyond proto 06:* the dashboard doc spells out the per-status worker action matrix and the
team-coordination walkthrough; the `taskCard` geometry (header 🏗️ title, status badge, site,
description, details grid 📍/🕒/👔, status bar, context buttons). WORKER_DASHBOARD also lists a
*Notes for Future Implementation* block (photo uploads, supervisor override, signature, scheduling,
push notifications, offline mode) — these are speculative, not in the prototype; do **not** port as
features unless `proto 06`/`/index.html` backs them.

---

## 4. 👔 מנהל המערכת — System Manager (`screen-manager`)

**Role:** administrator, unrestricted read + write (products/prices, order status, customer credit,
system settings, audit). Exit `‹ יציאה` → `screen-welcome`. Title `👔 מנהל המערכת`.
**Tabs (4):** `m-products` 📊 לוח בקרה · `m-orders` 🚚 הזמנות · `m-customers` 👥 לקוחות · `m-manage` 🛠️ ניהול.
Render fns: `renderMgrDashboard` / `renderMgrOrders` / `renderMgrCustomers` / `renderMgrManage`.
Every number is **derived live** by `mgrAnalytics()` (no hard-coding): `orders, revenue, items,
openOrders, avgOrder, byStage, byStore, ranking, total, avail, unavail, catalogCount, accCount,
cats, stores, activeStores`.

> *Doc divergence to note:* SYSTEM_MANAGER_DASHBOARD.md illustrates several sections with
> **placeholder/aspirational figures** (e.g. "Products: 1,247", "Revenue ₪847,500", a 7-item
> management menu, REST endpoints, an audit log) that are **not in the prototype** — `mgrAnalytics`
> computes everything from `SYS_ORDERS`/`TREES`/`STORE_STOCK`, and the real management tab is a
> **4-section accordion** (below). Treat **proto 06 §5 as authoritative** for what actually exists;
> the dashboard doc's extra sections are a product wish-list, not parity scope (R8 — no invention).

### 4.1 Tab 1 — לוח בקרה (`renderMgrDashboard`, `#mgrDashboard`)
Sections in order (all strings verbatim from proto 06 §5.2):
- **Hero:** `מרכז השליטה` / `BuildSmart · ניהול מערכת בזמן אמת` / `חי`.
- **Headline revenue** (→`mgrRevenueDetail`): `מחזור כולל במערכת`, animated `₪{revenue}`, sub
  `{n} הזמנות · ממוצע ₪{avg} להזמנה · הקש לפירוט ›`.
- **Metric tiles:** `🚚 {openOrders} הזמנות פתוחות` · `📦 {catalogCount} מוצרים בקטלוג` ·
  `🧰 {accCount} אביזרים נלווים` · `✅ {avail} זמינים כעת` · `🏪 {active}/{stores} חנויות פעילות`.
- **Alert:** `⚠️ {unavail} מוצרים לא זמינים — הקש לבדיקה` else `✓ כל {total} המוצרים זמינים — הקטלוג תקין`.
- **Order pipeline** `צינור ההזמנות` + `כל ההזמנות ›`: 5 bars (התקבלה/בהכנה/מוכן/בדרך/נמסר), hex
  `1F6F6B F2A516 1F8A4C 2B7DB8 8B8D8F`.
- **Category mix** `תמהיל הקטלוג לפי קטגוריה` (→`mgrSetCat`).
- **Store performance** `ביצועי חנויות` + `＋ חנות`: per-store cards, medal 🥇🥈🥉 by revenue rank,
  dot on/off, `{orders} הזמנות`, `₪{revenue} מחזור`.
- **Product manager** `ניהול מוצרים` + `＋ מוצר`; note `כל שינוי כאן מתעדכן מיד בקטלוג של הקבלן.`;
  search `חיפוש מוצר...`; chips `הכל ({total})` + per-cat; list `#mgrProductList`.
- **Regression test center** `🔬 מרכז בדיקת רגרסיה`; build banner `✅ גרסה תקינה — BUILD R107 …`;
  buttons `▶ הרץ בדיקת רגרסיה מלאה` + `🎛️ בחר מה לבדוק / להשוות` (→`openTestChooser`).

`renderMgrProducts` (`#mgrProductList`): row = thumb, name, `{cat}[· {n} מותגים][· 🌳 {n} אביזרים]`,
availability switch (`mgrToggleAvail` flips `STORE_STOCK`, re-renders catalog, toast `{name} — זמין ✓`
/`— סומן כלא זמין`), `✏️` (`editMgrProduct`), `🗑️` (`removeMgrProduct`). Empty `לא נמצאו מוצרים תואמים.`

### 4.2 Tab 2 — הזמנות (`renderMgrOrders`, `#mgrOrderList`)
`mgrOrderFilter='all'`, `mgrOrderSearch=''`. Summary `{n} הזמנות`/`{open} פתוחות`/`₪{revenue} מחזור`.
Search `חיפוש לפי מזהה, קבלן או אתר...`. Chips `הכל ({n})` + per-stage. Card: `📦 {id}`, stage pill,
who·site, mini **6-step tracker** (`mo-track`), `{items} פריטים · ₪{sum}`, `קדם שלב ›`
(`mgrAdvanceOrder` — steps along `ORDER_FLOW`, toast `הזמנה {id} → {label}`; at end `ההזמנה כבר הושלמה`)
or `✓ הושלם`. Empty `לא נמצאו הזמנות תואמות.` `mgrOrderDetail(idx)` sheet (`mgrStoreDetailOverlay`):
full labelled tracker, tiles פריטים/סכום/שלב, rows, `קדם ל"{nextLabel}"` + `📄 תעודת משלוח`.

### 4.3 Tab 3 — לקוחות (`renderMgrCustomers`, `#mgrCustomers`)
*Adds beyond proto 06 with the full credit field list.* `mgrCustomerList()` derives contractors
from `SYS_ORDERS` (group by `who`, sum spend, unique sites). `contractorCredit(name)` = deterministic
hash → 30k–120k ceiling (`CONTRACTOR_CREDIT` lazily filled). Status `low`(≥90% usage) / `live`(>0) /
`off`. Summary `{n} קבלנים` / `₪{used} סך רכש` / `{pct}% ניצול אשראי`. Search `חיפוש קבלן...`. Card:
👷, name, `{orders} הזמנות · {sites} אתרים`, pill `אשראי גבוה` / `לא פעיל` / `פעיל`, credit bar
`ניצול אשראי: ₪{spent} / ₪{credit} ({pct}%)`. `mgrCustomerDetail` sheet: tiles + rows
(מסגרת / נוצל / יתרה / אתרים) + the contractor's orders. (The dashboard doc's extra per-customer
fields — email, business name, payment status, suspend/activate, export, audit log — are
aspirational; not in the prototype.)

### 4.4 Tab 4 — ניהול (`renderMgrManage`, `#mgrManage`) — 4-section accordion
*This is the real "ניהול" tab* (proto 06 §5.4), **not** the 7-item menu in SYSTEM_MANAGER_DASHBOARD.md.
Intro `🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית.` `mgrManageOpen='trees'`.
1. **🌳 עץ המוצרים** / `עריכת האביזרים המשלימים של כל מוצר` — product `<select>` (`mgrPickTree`),
   per-acc rows `₪{price} · 🔴 חובה`/`🟡 אופציונלי`, `✏️`(`mgrEditAcc`)/`🗑️`(`mgrDelAcc`),
   `＋ הוסף אביזר` (`mgrAddAcc`: prompts `שם האביזר:` / `מחיר (₪):` / `אביזר חובה? (אישור = חובה,
   ביטול = אופציונלי)`). Empty `אין אביזרים — הוסף את הראשון.`
2. **🏷️ מותגים ומחירים** / `עריכת המותגים והמחירים של כל מוצר` — `mgrPickBrand`, `{brand} ⭐` if rec,
   `₪{price} · {tag}`, `mgrEditBrand`/`mgrDelBrand`, `＋ הוסף מותג` (`mgrAddBrand`).
3. **🗂️ קטגוריות** / `ניהול קטגוריות הקטלוג` — list with `{n} מוצרים`, `✏️ שנה שם` (`mgrRenameCat`
   rewrites all matching `t.cat`, toast `{n} מוצרים עודכנו לקטגוריה "{newName}" ✓`), hint
   `שינוי שם קטגוריה מעדכן את כל המוצרים שבה.`
4. **⚙️ הגדרות אפליקציה** / `פרמטרים שהקבלן רואה` — `תוספת משלוח אקספרס ₪{EXPRESS_FEE}` (`mgrEditExpress`),
   `מסגרת אשראי לקבלן ₪{creditLimit}` (`mgrEditCredit`), `שיעור מע״מ {18}%` (static), hint
   `המע״מ קבוע לפי חוק (18%). תוספת האקספרס והאשראי נראים מיד בעגלת הקבלן.`

All editors use native `prompt`/`confirm` (the self-test silences them via `withSilentDialogs`).
`openMgrProduct` creates `TREES[key]={name,img,cat,brands:[{brand:'כללי',…}],acc:[]}`,
`STORE_STOCK[key]=true`, toast `המוצר נוסף — מופיע עכשיו בקטלוג הקבלן ✓`. Store mgmt also lives here:
`renderMgrStores` rows `🏪 {name}` / `{area} · {eta} · {פעילה|מושבתת}`, toggle `⏼` (`toggleMgrStore`,
toast `החנות הופעלה`/`החנות הושבתה`), `🗑️` (`removeMgrStore`); `openMgrStore` prompts name/area/eta,
`STORES.unshift`, toast `החנות נוספה ✓`.

---

## 5. Shared delivery note (`showDeliveryNote(orderId, returnScreen)`, `screen-delivery-note`)

Used by store, courier, and manager (all four flows reach it). Print-style document:
- **Header:** BS logo + `BuildSmart` / `רכש חומרי בנייה` · `תעודת משלוח` · id · `תאריך: {today}`.
- **Parties:** `לקוח: {who}` · `כתובת מסירה: {site}` · `סטטוס: {stage label}`.
- **Items table** headers: `# / פריט / כמות / מחיר יח׳ / סה״כ` (unit price via `storeItemInfo`,
  `lineSum = unit × qty`).
- **Totals:** `סכום ביניים` · `מע״מ 18%` (`round(total*0.18)`) · `סה״כ לתשלום` (total + vat).
- **Signatures:** `חתימת המקבל` / `חתימת השליח`; footer `מסמך הופק על ידי מערכת BuildSmart · {today}`.

`closeDeliveryNote` returns to `deliveryNoteReturn` (`'app'` → contractor orders). VAT 18%
(`VAT_RATE=0.18`, Israeli VAT since Jan 2025). Triggered from store orders/picking-sheet
(`screen-store`), courier detail (`screen-courier`), manager order detail (`m-orders`).

---

## 6. Cross-role engine + supporting data (condensed; full detail in proto 06 §1, §7)

- **`SYS_ORDERS`** (seed `SYS_ORDERS_SEED`, 4 demo orders BS-1042/1041/1040/1039). Order shape
  `{id, who, site, items, sum, stage, haul, lines:[{name,qty}]}` + runtime fields `storeIndex`,
  `simulated`, `hasMissing`, `heldForMissing`, `missingResolved('replaced'|'cancelled')`, per-line
  `picked`/`missing`/`pendingDecision`/`cancelled`/`replaced`, `splitInto`, `splitPlan`, `shipments[]`,
  `deliverWhen`, `podPhoto`, `podSigned`.
- **Sync:** `BS_ORDERS_KEY='buildsmart:sharedOrders'`; `loadSysOrders`/`saveSysOrders`; cross-tab
  `storage` listener re-renders the visible admin pane + pushes contractor notifications. Migration
  backfills `lines` from seed; `orderSeq` collision guard.
- **Routing:** `orderStoreIndex(orderId)` (recorded `storeIndex` else stable hash % `STORES.length`);
  `ordersForActiveStore()` filters per logged-in store.
- **Supporting tables (verbatim, proto 06 §7):** `STORES` (3) · `SUPPLIER_STORES` (s1/s2/s3, checkout
  fees) · `STORE_PRICING` (per-store SKU maps) · `STORE_STOCK` · `SUPPLIER_RATINGS` (3) ·
  `DIST_ZONES` (4) · `BULK_TIERS` (4) · `HAUL_TYPES` (3) · `VEHICLE_RANK` · `FLEET` (4 vehicles:
  V14 משאית/V08 מסחרית/V21 בתחזוקה/V05 טנדר) · `WORKERS` (2) · `TASKS` (5) · `WORK_LOG` (2 days) ·
  `SIM_CUSTOMERS` (5) · `SIM_SITES` (5) · `CONTRACTOR_CREDIT` · `EXPRESS_FEE=80`/`creditLimit=50000`/
  `VAT_RATE=0.18`.
- **RBAC:** store `order.fulfill`+`stock.edit`; courier `order.fulfill`; manager full read/write;
  worker none (gated by the shared task engine). `requirePerm(perm, label)` guards each mutating call.

---

## → Flutter port notes

Maps to **`PARITY.md` domain G** ("4 אפליקציות-התפקיד — כ-dial, לא dashboards!"). Current Flutter
status (per PARITY G): 🏪/🛵/🦺 = names→toast placeholders, 👔 = regression harness only, shared
order engine = ❌ absent. The dial *structure* (verbatim leaf labels + emoji) exists in
`bs/bs-dial.tsx`'s 5-persona tree; **functionality is ~0% ported**.

1. **R2 — these are dial-drills, not windows.** Every prototype `admin-screen` (store login,
   store, courier, worker, manager) becomes a **multi-level BS-dial drill** reached through the BS
   FAB. Each `render*` fn maps to a *drill level / leaf*, never a `<main>`-filling view or a
   `dashboard`/persona `view`. Three prior R2 violations caused three reverts — **do not build any of
   these as a Flutter dashboard/view without explicit user approval** (CLAUDE.md).

2. **Shared SYS_ORDERS engine first** (PARITY G last row, ❌). Port the 6-stage model
   (`ORDER_STAGE`/`ORDER_FLOW`) and the **who-advances-what** split (store `new→ready`, courier
   `ready→delivered`, manager any step) as a Riverpod `StateNotifier<List<Order>>` + persistence
   (Hive/`shared_preferences`). The web-only cross-tab `storage` event has no native equivalent —
   model it as a repository/stream all four persona drills watch. Keep seed + migration + `orderSeq`
   guard. High-value flows to port first: the **picking sheet**, the **missing-item hold loop**
   (`heldForMissing` gate + replace/cancel), **split-shipment grouping**, and the
   **worker→manager approval loop**.

3. **Verbatim strings (R6/R8).** Every Hebrew label, toast, pill, status text, section header, and
   emoji quoted above is load-bearing — copy character-for-character (incl. `״ ׳ — › ✓ ⏳ 🚚` etc.).
   **Where the dashboard docs and proto 06 disagree, proto 06 / `/index.html` wins** (it is the
   prototype source): notably the worker status badges (`taskStatusInfo`), and the manager dashboard
   numbers (everything is `mgrAnalytics`-derived, *not* the placeholder figures in
   SYSTEM_MANAGER_DASHBOARD.md). The dashboard docs' aspirational extras (manager 7-item menu, REST
   endpoints, audit log, customer email/export, worker photo/offline "future" list) are **not parity
   scope** — do not invent them (R8).

4. **R9 — text entry is inline.** The manager's native `prompt()`/`confirm()` editors (add accessory,
   edit brand/price, rename category, credit/express, add store/product) must become **inline inputs
   attached to their dial leaf**, not modals/sheets/prompts.

5. **Self-test harness does not port as-is.** `BUTTON_REGISTRY` (350), the live-DOM `onclick` scan,
   and `eval()`-based existence checks rely on `document.outerHTML`/`eval` (web only). Flutter already
   has an in-app harness (PARITY I, ✅); extend that. The *concept* (every fixed bug → permanent check,
   registry-vs-reality coverage) ports; the *mechanism* does not.

**Source docs captured:** `app/knowledge/{STORE,COURIER,WORKER,SYSTEM_MANAGER}_DASHBOARD.md`.
**Prototype cross-reference:** `../proto/06-personas-engine-selftest.md` (line-anchored to `/index.html`).
