# חנות ספק Dashboard — Deep Dive
**Supplier Store Portal — Order Fulfillment & Inventory Hub**

---

## Overview — Role Context

**Role:** Supplier Store Manager (חנות ספק) / Warehouse Operator  
**Entry Point:** Role Drawer → "חנות" button  
**First Screen:** Store selection (screen-store-login) → Choose from 3 supplier stores  
**Active Screen:** screen-store (admin-screen class)  
**Tab Navigation:** `admTab()` function with prefixes `s-home`, `s-orders`, `s-stock`, `s-portal`  
**RBAC:** `order.fulfill` + `stock.edit` permissions

---

## Screen Architecture — Store Dashboard

### 1. Store Login Screen (screen-store-login)
**Entry transition:** `enterRole('store')` → `showScreen('screen-store-login')` → `renderStoreLogin()`

#### Structure:
```
┌─────────────────────────────────────┐
│ [Appbar: BuildSmart · Icons]        │
├─────────────────────────────────────┤
│ Store Selection List (3 items)      │
│ ┌───────────────────────────────────┤
│ │ 🏪 מחסני אינסטלציה תל-אביב     │
│ │ 📍 גוש דן · 🕐 עד שעתיים      │
│ │ Status: 🟢 פעילה  · [›]         │
│ ├───────────────────────────────────┤
│ │ 🏪 ספקי סניטריה השרון           │
│ │ 📍 השרון · 🕐 עד שעתיים        │
│ │ Status: 🟢 פעילה  · [›]         │
│ ├───────────────────────────────────┤
│ │ 🏪 חומרי בניין הרצליה            │
│ │ 📍 הרצליה והסביבה · 🕐 עד שעה  │
│ │ Status: 🟢 פעילה  · [›]         │
│ └───────────────────────────────────┘
│ [FAB 1: BS] [FAB 2: Search] ...     │
└─────────────────────────────────────┘
```

#### Store List Item (sl-store):
- **Icon:** 🏪 (fixed store emoji)
- **Name:** Store name (e.g., "מחסני אינסטלציה תל-אביב")
- **Metadata:** Location (📍) + ETA (🕐)
- **Status Indicator:** 
  - 🟢 Dot + "פעילה" (active)
  - 🔴 Dot + "מושבתת" (disabled)
- **Navigation Chevron:** › 
- **Click Handler:** `onclick="storeLogin(i)"` where i = store index

#### Data Source:
```javascript
let STORES = [
  {name: 'מחסני אינסטלציה תל-אביב', area: 'גוש דן', eta: 'עד שעתיים', on: true},
  {name: 'ספקי סניטריה השרון', area: 'השרון', eta: 'עד שעתיים', on: true},
  {name: 'חומרי בניין הרצליה', area: 'הרצליה והסביבה', eta: 'עד שעה', on: true},
];
```

#### Interaction:
- User clicks store row → `storeLogin(i)` 
  - Sets `activeStoreIndex = i`
  - Updates appbar title: "🏪 [Store Name]"
  - Transitions to `screen-store`
  - Auto-selects first tab: `admTab('s-home')`
  - Toast: "ברוך הבא — [Store Name]"

---

### 2. Store Dashboard Screen (screen-store)

**Container:** `<div class="fullscreen admin-screen" id="screen-store">`  
**Layout:** Tab navigation (top) + Pane switching (single active pane at a time)

#### Appbar:
```
[BS Logo] BuildSmart — [Store Name] | [Bell Icon] [More Menu]
```

#### Tab Navigation:
4 clickable tabs at the top using `.adm-tab` elements:
- `data-at="s-home"` → Dashboard/home (📊)
- `data-at="s-orders"` → Orders (📥)
- `data-at="s-stock"` → Stock (📦)
- `data-at="s-portal"` → Portal tools (🛠️)

**Logic:** `admTab(tab)` function:
1. Removes `.on` class from all `.adm-tab` buttons
2. Adds `.on` to the clicked tab
3. Hides all `.adm-pane` divs
4. Shows `#pane-{tab}` pane
5. Calls appropriate render function (renderStoreHome, renderStoreOrders, etc.)

---

## Tab 1: Home Dashboard (s-home)

**Pane ID:** `pane-s-home`  
**Render Function:** `renderStoreHome()`  
**Data Source:** `ordersForActiveStore()` filters `SYS_ORDERS` by active store

### Home Layout:

```
┌─────────────────────────────────────────────────┐
│ Greeting + Subtitle                             │
│ "שלום 👋"                                       │
│ "🏪 [Store] — מה שצריך טיפול עכשיו"          │
├─────────────────────────────────────────────────┤
│ PRIMARY ACTION CARD (if toApprove.length > 0)  │
│ [Count] | הזמנות ממתינות לאישור                │
│         | הקש כדי לאשר ולהתחיל הכנה           │
│         | [›]                                    │
│                                                  │
│ Onclick: admTab('s-orders')                    │
├─────────────────────────────────────────────────┤
│ HELD ALERT (if held.length > 0)                │
│ [Count] | הזמנות ממתינות לבחירת הקבלן         │
│         | פריט חסר — ממתין להחלטה             │
│         | [›]                                    │
├─────────────────────────────────────────────────┤
│ QUICK STATS (3-column grid)                    │
│ ┌──────────┬──────────┬──────────┐            │
│ │ 🔧       │ 📦       │ 💰       │            │
│ │ [N]      │ [N]      │ ₪[sum]   │            │
│ │ בהכנה    │ מוכן     │ מחזור    │            │
│ │          │ לאיסוף   │ פעיל     │            │
│ └──────────┴──────────┴──────────┘            │
│ (Each stat clickable → admTab('s-orders'))    │
├─────────────────────────────────────────────────┤
│ STOCK ALERT (1-line banner)                    │
│ ✓ כל המוצרים זמינים במלאי                    │
│ OR                                              │
│ ⚠️ [N] מוצרים אזלו מהמלאי — הקש לעדכון     │
│ (Clickable → admTab('s-stock'))               │
├─────────────────────────────────────────────────┤
│ BIG ACTION BUTTONS (2-column)                  │
│ ┌──────────────────┬──────────────────┐       │
│ │ 📥               │ 📦               │       │
│ │ הזמנות           │ מלאי             │       │
│ └──────────────────┴──────────────────┘       │
│ (Each → admTab('s-orders'/'s-stock'))        │
├─────────────────────────────────────────────────┤
│ DEMO TOOL (lower, smaller)                     │
│ ➕ סימולציית הזמנה נכנסת (כלי הדגמה)         │
│ Onclick: simulateIncomingOrder()              │
└─────────────────────────────────────────────────┘
```

### Data Calculation:

**Count Filters:**
```javascript
const all = ordersForActiveStore();        // All orders for this store
const toApprove = all.filter(o => o.stage === 'new');
const inPrep = all.filter(o => o.stage === 'preparing');
const ready = all.filter(o => o.stage === 'ready');
const held = all.filter(o => o.heldForMissing);
const todayRevenue = all.filter(o => 
  ['new','preparing','ready'].includes(o.stage)
).reduce((s, o) => s + (o.sum || 0), 0);
```

### Key Order Statuses (Order Stages):
- **'new'** — Just arrived, awaiting approval
- **'preparing'** — In picking/packing
- **'ready'** — Packed, waiting for courier pickup
- **'pickup'** — Courier on the way to store
- **'transit'** — In transit to delivery site
- **'delivered'** — Successfully delivered
- **'held'** — On hold for missing-item decision

---

## Tab 2: Orders (s-orders)

**Pane ID:** `pane-s-orders`  
**Render Function:** `renderStoreOrders()`  
**Data Source:** Orders in active store, filtered by status + search

### Orders Layout:

```
┌─────────────────────────────────────────────────┐
│ FILTER CHIPS (horizontal scrollable)            │
│ [פעילות (N)] [לאישור (N)] [בהכנה (N)] [מוכנות]│
├─────────────────────────────────────────────────┤
│ ORDER CARD (repeats for each order)             │
│ ┌──────────────────────────────────────────┐   │
│ │ Top Row:                                 │   │
│ │ 📦 BS-001 | [Status Pill] [Split Pill]  │   │
│ │                                          │   │
│ │ Customer: [who] · [site]                │   │
│ │ 🕒 Needed: [deliverWhen]                │   │
│ │                                          │   │
│ │ Meta: [items] פריטים · ₪[sum] · Meta   │   │
│ │                                          │   │
│ │ [Action Button based on stage]           │   │
│ │  ✓ אשר וקבל להכנה                       │   │
│ │  (OR) 📦 סמן כמוכן — העבר לשליח         │   │
│ │  (OR) 🛵 ממתין לאיסוף השליח             │   │
│ │  (OR) ⏳ פריט חסר — אנא המתן             │   │
│ └──────────────────────────────────────────┘   │
│ [... repeats for other orders ...]             │
├─────────────────────────────────────────────────┤
│ EMPTY STATE (if no orders match filters)      │
│ אין הזמנות בקטגוריה זו ✓                     │
└─────────────────────────────────────────────────┘
```

### Filter States:
- **'active'** — All non-delivered orders (new, preparing, ready)
- **'new'** — Awaiting approval
- **'preparing'** — In picking
- **'ready'** — Ready for courier

**Filter Control:** `storeOrderFilter` variable  
**Setter:** `storeOrderSetFilter(k)` → updates filter → `renderStoreOrders()`

### Order Card States:

**Stage: 'new' (Awaiting Approval)**
- **Status Pill:** Yellow "לאישור" 
- **Action Button:** "✓ אשר וקבל להכנה"
- **OnClick:** `storeAdvance(orderId)` → Sets `o.stage = 'preparing'`

**Stage: 'preparing' (In Picking)**
- **Status Pill:** Blue "בהכנה"
- **Action Button:** "📦 סמן כמוכן — העבר לשליח"
- **OnClick:** `storeAdvance(orderId)` → Sets `o.stage = 'ready'`

**Stage: 'ready' (Ready for Pickup)**
- **Status Pill:** Green "מוכן"
- **Action Button:** "🛵 ממתין לאיסוף השליח" (disabled/info-only)

**Special Case: heldForMissing**
- **Status Pill:** Orange "פריט חסר"
- **Alert Box:** "⏳ פריט חסר — אנא המתן להחלטת הקבלן"
- **Action Button:** Hidden until contractor resolves

**Special Case: missingResolved**
- **Status Pill:** Original stage color
- **Alert Box:** "✓ תיקון בוצע — [בדוק שינויים / פריט הוסר]"
- **Action Button:** Re-enables (advance to next stage)

**Split Indicator Pill:**
- Shows when `o.splitInto > 1`
- Format: "🚚×[N]"
- Pulses (class 'fresh') first time supplier sees it
- Clears when supplier opens the order detail

### Click Handlers (Delegated):

**data-sadvance:** Button click → `storeAdvance(orderId)`
- Advances order through workflow stages
- Syncs with courier and manager views

**data-sdetail:** Card click → `storeOrderDetail(orderId)`
- Opens picking sheet (detailed order view)
- Shows item-by-item status
- Allows mark-picked, mark-missing operations

---

## Tab 2 Details: Picking Sheet (storePickOverlay)

**Element:** `<div id="storePickOverlay" class="sheet-modal">`  
**Render Function:** `renderStorePick()`  
**Data Source:** Single order + its line items

### Picking Sheet Layout:

```
┌──────────────────────────────────────────┐
│ Header:                                  │
│ 📦 BS-001                                │
│ Customer · Site                          │
│ Status: [Stage label]                    │
├──────────────────────────────────────────┤
│ Progress Bar:                            │
│ ████████░░ (8/10 items handled)         │
├──────────────────────────────────────────┤
│ ALERTS (if present):                     │
│ [⏳ Missing item waiting for contractor]│
│ [🚚 Split into N shipments — group each]│
├──────────────────────────────────────────┤
│ LINE ITEMS (repeated for each line):     │
│ ┌────────────────────────────────────────┤
│ │ 📦 [Item emoji]                       │
│ │ [Item name] [Optional: Replacement]   │
│ │ [Category tag] [Price tag]            │
│ │ [Reason: Accessory / Main product]    │
│ │ Qty: [N] · Total: ₪[sum]              │
│ │ [Status] [✓ Mark picked] [×Missing]  │
│ └────────────────────────────────────────┤
│ [... repeats for each line ...]          │
├──────────────────────────────────────────┤
│ [Close button] [Delivery Note button]    │
└──────────────────────────────────────────┘
```

### Line Item States:

**picked (✓)** — Green highlight, checkbox on
**missing (✕)** — Red highlight, X on
**pending** — Default, both buttons off
**cancelled** — Greyed, "✕ בוטל ע״י הקבלן"
**replaced (🔁)** — Highlighted, "Replacement product"
**pendingDecision (⏳)** — "Awaiting contractor decision"

### Line Item Handlers:
- **storePickLine(lineIndex)** — Toggle picked state
- **storeMissLine(lineIndex)** — Toggle missing state (alerts contractor)

### Split Order Grouping:

When order split into N shipments:
- Lines grouped by `o.splitPlan[i]` (which shipment index)
- Each group has header showing:
  - 📦 Shipment N
  - 🕒 Delivery time
  - 📍 Site/address
  - 🚛 Haulage type
- Picker handles each group as separate package

---

## Tab 3: Stock Management (s-stock)

**Pane ID:** `pane-s-stock`  
**Render Function:** `renderStoreStock()`  
**Data Source:** `TREES` (product catalog) + `STORE_STOCK` (availability)

### Stock Layout:

```
┌─────────────────────────────────────────────────┐
│ SUMMARY (3-column stats)                        │
│ [N] מוצרים | [N] זמינים | [N] אזלו           │
├─────────────────────────────────────────────────┤
│ SEARCH BAR                                      │
│ 🔍 [input: "חיפוש מוצר..."]                    │
├─────────────────────────────────────────────────┤
│ FILTER CHIPS                                    │
│ [הכל (N)] [זמינים (N)] [אזלו (N)]            │
├─────────────────────────────────────────────────┤
│ PRODUCT LIST (filtered)                         │
│ ┌──────────────────────────────────────────┐   │
│ │ [Product emoji] | Product Name           │   │
│ │ ✅ זמין במלאי OR ❌ אזל — מוסתר      │   │
│ │                    [Toggle Switch] →    │   │
│ └──────────────────────────────────────────┘   │
│ [... repeats for each product ...]             │
│                                                 │
│ EMPTY STATE (if no products match)             │
│ לא נמצאו מוצרים תואמים.                        │
└─────────────────────────────────────────────────┘
```

### Stock Data Structure:

```javascript
// STORE_STOCK[productKey] = true/false
// true (default) = available in catalog
// false = out of stock, hidden from contractors

STORE_STOCK = {
  '870606075': true,    // Available
  '870606090': false,   // Out of stock
  // ...
};
```

### Interaction:
- **toggleStoreStock(productKey)**
  - Requires RBAC: `requirePerm('stock.edit', 'עריכת מלאי')`
  - Flips `STORE_STOCK[k]` between true/false
  - Updates UI immediately
  - Notifies contractor via catalog refresh
  - Toast confirms action

### Search/Filter Logic:

```javascript
let storeStockSearch = '';    // Current search string
let storeStockFilter = 'all'; // 'all' | 'in' | 'out'

// Filter applied to product list:
const list = Object.keys(TREES).filter(k => {
  const avail = STORE_STOCK[k] !== false;
  if (storeStockFilter === 'in' && !avail) return false;
  if (storeStockFilter === 'out' && avail) return false;
  if (q && TREES[k].name.indexOf(q) < 0) return false;
  return true;
});
```

---

## Tab 4: Portal Tools (s-portal)

**Pane ID:** `pane-s-portal`  
**Render Function:** `renderStorePortal()`  
**Layout:** Grid of 8 tool tiles

### Portal Layout:

```
┌─────────────────────────────────────────────────┐
│ PORTAL TOOL GRID (2 columns × 4 rows)           │
│ ┌──────────────────┬──────────────────┐        │
│ │ ⭐               │ ⏱️               │        │
│ │ דירוג ספקים      │ מעקב SLA         │        │
│ │ ציון וביצועים    │ ספירה לאחור      │        │
│ ├──────────────────┼──────────────────┤        │
│ │ 🗺️               │ 📉               │        │
│ │ אזורי הפצה       │ הנחות כמות       │        │
│ │ זמני אספקה       │ מדרגות הנחה     │        │
│ ├──────────────────┼──────────────────┤        │
│ │ 🏷️               │ 🚛               │        │
│ │ הפקת ברקודים     │ ניהול צי רכב     │        │
│ │ תוויות למוצרים   │ רכבים וזמינות    │        │
│ ├──────────────────┼──────────────────┤        │
│ │ 💬               │ 🔄               │        │
│ │ צ׳אט עם קבלן     │ עדכון מלאי       │        │
│ │ הודעות פנימיות   │ אוטומטי          │        │
│ └──────────────────┴──────────────────┘        │
└─────────────────────────────────────────────────┘
```

### Portal Tiles (8 tools):

1. **⭐ דירוג ספקים** → `portalRatings()`
   - Supplier performance scores
   - Star ratings (1-5)
   - Order count, SLA metrics

2. **⏱️ מעקב SLA** → `portalSLA()`
   - Service level agreement tracking
   - Countdown timers to delivery windows
   - Alert if approaching deadline

3. **🗺️ אזורי הפצה** → `portalZones()`
   - Delivery zones map
   - ETA by zone
   - Coverage heatmap

4. **📉 הנחות כמות** → `portalBulk()`
   - Volume discount tiers
   - Quantity brackets
   - Pricing matrix

5. **🏷️ הפקת ברקודים** → `portalBarcode()`
   - Barcode label generation
   - Print-to-warehouse integration
   - Batch processing

6. **🚛 ניהול צי רכב** → `portalFleet()`
   - Fleet status dashboard (data: `FLEET` array)
   - Vehicle availability
   - Driver assignments
   - Maintenance alerts

7. **💬 צ׳אט עם קבלן** → `openChat('contractor')`
   - Internal messaging with contractors
   - Thread-based history
   - Auto-reply simulation

8. **🔄 עדכון מלאי** → `portalAutoStock()`
   - Real-time inventory sync
   - Auto-decrement on sale
   - Demo showing before/after counts

### Each Tile Opens Overlay:
- **Element:** `#portalFeatureOverlay` (sheet modal)
- **Body:** `#portalFeatureBody`
- **Close:** User swipes down or taps backdrop

---

## Delivery Note (תעודת משלוח)

**Triggered from:**
- Orders tab (meta text: "הקש לתעודת משלוח")
- Picking sheet (button: "📄 הצג תעודת משלוח")

**Element:** `#deliveryNoteBody`  
**Render Function:** `showDeliveryNote(orderId, returnScreen)`

### Document Layout:

```
┌──────────────────────────────────────────────────┐
│ HEADER:                                          │
│ [BS Logo] BuildSmart                             │
│           רכש חומרי בנייה                        │
│                          תעודת משלוח             │
│                          BS-0001                 │
│                          תאריך: [date]          │
├──────────────────────────────────────────────────┤
│ PARTIES:                                         │
│ לקוח: [customer name]                           │
│ כתובת מסירה: [site address]                    │
│ סטטוס: [order stage]                            │
├──────────────────────────────────────────────────┤
│ ITEMS TABLE:                                     │
│ # | פריט | כמות | מחיר יח׳ | סה״כ              │
│ 1 | [item] | [qty] | ₪[price] | ₪[sum]        │
│ 2 | [item] | [qty] | ₪[price] | ₪[sum]        │
│ ...                                             │
├──────────────────────────────────────────────────┤
│ TOTALS:                                          │
│ סכום ביניים: ₪[subtotal]                       │
│ מע״מ 18%: ₪[vat]                               │
│ סה״כ לתשלום: ₪[grand]                          │
├──────────────────────────────────────────────────┤
│ SIGNATURES:                                      │
│ ________              ________                   │
│ חתימת המקבל          חתימת השליח                │
│                                                  │
│ מסמך הופק על ידי BuildSmart · [date]          │
└──────────────────────────────────────────────────┘
```

### Calculation:
```javascript
// Gather lines from order
const lines = o.lines || [{name: '...' + o.items + ' פריטים', qty: 1}];

// Calculate per line
lines.forEach(l => {
  const inf = storeItemInfo(l.name);  // Get catalog entry
  const unit = inf.price;             // Unit price
  const lineSum = unit * l.qty;       // Line total
  total += lineSum;                   // Running sum
});

const vat = Math.round(total * 0.18);  // VAT (18%)
const grand = total + vat;              // Final total
```

---

## Order Advancement Workflow

**Function:** `storeAdvance(orderId)`

### Validation:
- RBAC: `requirePerm('order.fulfill', 'קידום הזמנה')`
- Order exists in `SYS_ORDERS`

### Stage Transitions:

```
new (awaiting approval)
    ↓ [✓ אשר וקבל להכנה]
preparing (in picking)
    ↓ [📦 סמן כמוכן — העבר לשליח]
ready (waiting for courier)
    ↓ [Courier picks up]
pickup (courier at store)
    ↓ [Courier in transit]
transit (on the road)
    ↓ [Delivery complete]
delivered
```

### Side Effects on Advance:
1. Updates `o.stage`
2. Calls `saveSysOrders()` (persistence)
3. Triggers 'storage' event in other tabs
4. Refreshes multiple views:
   - `renderStoreOrders()`
   - `renderStoreHome()`
   - `renderMyOrders()` (contractor view)
5. Toast confirmation: "ההזמנה [id] עודכנה — מסונכרן"

---

## Store Screen Navigation

**Entry Flows:**
1. **From Role Drawer:** `enterRole('store')` → Store login → Store selection → Home
2. **From Another Tab:** Store data persists in `activeStoreIndex`

**Exit Flow:**
- **storeLogout()** → Transition back to store-login → `renderStoreLogin()`

**Tab Switching:**
- User clicks tab → `admTab('s-home'|'s-orders'|'s-stock'|'s-portal')`
- Clears all `.adm-tab.on` classes
- Shows relevant pane
- Renders fresh data

---

## Key Data Structures

### Order Object (SYS_ORDERS element):
```javascript
{
  id: 'BS-001',
  who: 'לקוח בניין בע״מ',
  site: 'אתר בנייה — תל אביב',
  items: 12,
  sum: 5420,                       // Incl. VAT
  stage: 'new',                    // 'new'|'preparing'|'ready'|...
  lines: [
    {name: 'שם מוצר', qty: 2, picked: true, missing: false},
    {name: '...', qty: 1}
  ],
  haul: 'truck',                   // 'small'|'van'|'truck'
  deliverWhen: 'עד שעתיים',
  heldForMissing: false,
  missingResolved: null,
  splitInto: 1,                    // 1 = not split
  splitPlan: [1, 1, 2],            // Which shipment each line belongs to
  shipments: [
    {when: 'עד שעה', site: 'אתר A', haul: 'small', stage: 'ready'},
    {when: '...' }
  ],
  suppliers: [{store: '...', storeId: 's1'}],
  simulated: false
}
```

### Store Array (STORES):
```javascript
[
  {name: 'מחסני אינסטלציה תל-אביב', area: 'גוש דן', eta: 'עד שעתיים', on: true},
  // ...
]
```

### Stock Map (STORE_STOCK):
```javascript
{
  '870606075': true,    // Available
  '870606090': false,   // Out of stock
}
```

---

## RBAC Rules — Store Role

| Permission | Context | Function |
|-----------|---------|----------|
| `order.fulfill` | Progress order through stages | `storeAdvance()` |
| `stock.edit` | Mark products available/unavailable | `toggleStoreStock()` |

---

## State Variables — Store Screen

| Variable | Type | Purpose |
|----------|------|---------|
| `activeStoreIndex` | number | Current store (0-2) |
| `storeOrderFilter` | string | Active filter ('active'\|'new'\|'preparing'\|'ready') |
| `storeStockSearch` | string | Current search term |
| `storeStockFilter` | string | Stock filter ('all'\|'in'\|'out') |
| `storePickId` | string | Currently open picking sheet order ID |
| `deliveryNoteReturn` | string | Screen to return to after viewing note |

---

## Screen Registration

**HTML Structure:** Lines 4241–4288 in index.html

```html
<div class="fullscreen" id="screen-store-login" style="display:none">
  <!-- Store selection list -->
  <div id="storeLoginList"></div>
</div>

<div class="fullscreen admin-screen" id="screen-store" style="display:none">
  <!-- Tab buttons -->
  <div class="adm-tab" data-at="s-home">...</div>
  <div class="adm-tab" data-at="s-orders">...</div>
  <div class="adm-tab" data-at="s-stock">...</div>
  <div class="adm-tab" data-at="s-portal">...</div>
  
  <!-- Panes -->
  <div class="adm-pane" id="pane-s-home"><div id="storeHome"></div></div>
  <div class="adm-pane" id="pane-s-orders"><div id="storeOrderList"></div></div>
  <div class="adm-pane" id="pane-s-stock"><div id="storeStockList"></div></div>
  <div class="adm-pane" id="pane-s-portal"><div id="storePortal"></div></div>
</div>
```

---

## Modals & Overlays

| ID | Title | Function | Content |
|----|-------|----------|---------|
| `storePickOverlay` | Picking Sheet | `renderStorePick()` | Order lines with pick/miss toggles |
| `deliveryNoteBody` | Delivery Note | `showDeliveryNote()` | Print-style document |
| `portalFeatureOverlay` | Portal Feature | Dynamic | Tool-specific content |

---

## Interaction Flow Summary

```
Store Login
  ↓ Select store (storeLogin)
  ↓ activeStoreIndex set
Store Dashboard (Home Tab)
  ├─ View: Summary, alerts, quick actions
  ├─ Action: Click stat → admTab('s-orders')
  └─ Action: Click stock alert → admTab('s-stock')

Orders Tab
  ├─ View: Filtered order list with pills
  ├─ Filter: Click chip → storeOrderSetFilter
  └─ Detail: Click order card → storeOrderDetail (Picking Sheet)
     ├─ Mark each line: picked / missing
     ├─ View delivery note
     └─ Close → back to Orders

Stock Tab
  ├─ Search: Type in input → storeStockDoSearch
  ├─ Filter: Click chip → storeStockSetFilter
  └─ Toggle: Click switch → toggleStoreStock (✓ available ↔ ✗ out)

Portal Tab
  ├─ View: Grid of 8 tools
  └─ Tap: Open overlay with tool content

Advance Order
  ├─ admTab('s-orders')
  ├─ Click "✓ אשר..." button
  ├─ storeAdvance(id)
  ├─ Stage transitions: new → preparing → ready
  └─ Two-way sync with manager & courier views
```

---

## Logout

**Function:** `storeLogout()`
- Transitions to `screen-store-login`
- Calls `renderStoreLogin()`
- Allows selecting a different store or exiting to role drawer

