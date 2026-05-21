# שליח Courier Dashboard — Deep Dive
**Delivery Hub — Real-Time Shipment Tracking & Fulfillment**

---

## Overview — Role Context

**Role:** Courier / Delivery Driver (שליח)  
**Entry Point:** Role Drawer → "שליח" button  
**First Screen:** Courier delivery hub (screen-courier)  
**Active Screen:** screen-courier (admin-screen class)  
**Layout:** Single pane (no tabs — two main regions: home summary + delivery list)  
**Render Function:** `renderCourier()` (orchestrates both regions)  
**RBAC:** `order.fulfill` permission for stage advancement

---

## Screen Architecture — Courier Dashboard

### Entry Point

**Transition:** `enterRole('courier')` → `showScreen('screen-courier')` → `renderCourier()`

**Appbar:**
```
[BS Logo] BuildSmart | [Notification Bell] [Menu Icon]
```

**Screen:** Single .adm-pane (full height, not tabbed)

---

## Layout Structure

```
┌────────────────────────────────┐
│ Appbar (top)                   │
├────────────────────────────────┤
│                                │
│ HOME SUMMARY REGION            │
│ ┌──────────────────────────────┤
│ │ שלום 🛵                      │
│ │ המשלוחים שלך להיום          │
│ │ [Vehicle Picker]             │
│ │ [Primary Action Card]        │
│ │ [Stats Row]                  │
│ └──────────────────────────────┤
│                                │
├────────────────────────────────┤
│                                │
│ DELIVERY LIST REGION           │
│ ┌──────────────────────────────┤
│ │ משלוחים פעילים (N)         │
│ │ [Delivery Card 1]            │
│ │ [Delivery Card 2]            │
│ │ [... repeats ...]            │
│ └──────────────────────────────┤
│                                │
├────────────────────────────────┤
│ FABs (5 standard buttons)       │
└────────────────────────────────┘
```

---

## Region 1: Courier Home Summary (courierHome)

**Element ID:** `#courierHome`  
**Render Function:** `renderCourierHome()`

### Home Summary Content:

```
┌──────────────────────────────────┐
│ שלום 🛵                         │
│ המשלוחים שלך להיום              │
├──────────────────────────────────┤
│ VEHICLE PICKER                   │
│ הרכב שלי היום                    │
│ ┌────────────┬────────────────┐ │
│ │ 🛵        │ 🚐      │ 🚛   │ │
│ │ משלוח קטן │ טנדר   │משאית│ │
│ └────────────┴────────────────┘ │
│ (One selected with .on class)   │
├──────────────────────────────────┤
│ PRIMARY ACTION CARD              │
│ (if toPickup > 0)               │
│ ┌────────────────────────────────┤
│ │ [N]  משלוחים ממתינים          │
│ │      לאיסוף                   │
│ │      אסוף מהחנות כדי להתחיל   │
│ └────────────────────────────────┤
│ OR                               │
│ ┌────────────────────────────────┤
│ │ ✓ אין משלוחים ממתינים        │
│ └────────────────────────────────┤
├──────────────────────────────────┤
│ QUICK STATS (3-column)           │
│ ┌──────┬──────┬──────────┐     │
│ │ [N]  │ [N]  │ [Time]   │     │
│ │לאיסוף│בדרך │ בתור     │     │
│ └──────┴──────┴──────────┘     │
│ (Each stat clickable → scrolls) │
│                                 │
└──────────────────────────────────┘
```

### Vehicle Picker

**Function:** `pickCourierVehicle(id)`  
**Variable:** `courierVehicle` (current selection)  
**Options:** 'small', 'van', 'truck' (defined in `HAUL_TYPES`)

```javascript
const HAUL_TYPES = [
  {id: 'small', name: 'משלוח קטן', ic: '🛵', extra: 0},
  {id: 'van', name: 'טנדר', ic: '🚐', extra: 40},
  {id: 'truck', name: 'משאית', ic: '🚛', extra: 90},
];
```

**Default:** 'truck' (can carry any delivery)  
**Capacity Hierarchy:** small < van < truck

**Filter Logic:**
```javascript
function vehicleCanCarry(vehicle, need) {
  const VEHICLE_RANK = {small: 0, van: 1, truck: 2};
  const v = VEHICLE_RANK[vehicle];
  const n = VEHICLE_RANK[need];
  return n <= v;  // Bigger vehicle carries smaller hauls
}
```

**Interaction:**
- Click vehicle button → `pickCourierVehicle(id)`
  - Sets `courierVehicle = id`
  - Calls `renderCourier()` (re-renders both regions with new filter)
  - Toast: "הרכב נקבע: [icon] [name]"
  - List automatically re-filters to compatible deliveries

### Primary Action Card

**Condition:** Only shows if `toPickup > 0` (orders in 'ready' stage)

```javascript
const all = allOrders.filter(o => vehicleCanCarry(courierVehicle, o.haul || 'small'));
const toPickup = all.filter(o => o.stage === 'ready').length;
const onRoad = all.filter(o => o.stage === 'transit').length;
const delivered = all.filter(o => o.stage === 'delivered').length;
```

**Card Styling:**
- Large count badge: `[N]`
- Title: "משלוחים ממתינים לאיסוף"
- Subtitle: "אסוף מהחנות כדי להתחיל"
- Encourages next action

### Quick Stats Row

3 columns (equal width):
- **Left:** 🔧 [N] לאיסוף (pickups pending)
- **Center:** 🚚 [N] בדרך (in transit)
- **Right:** ✅ [N] נמסר (delivered)

Each stat updates live as deliveries progress.

---

## Region 2: Delivery List (courierList)

**Element ID:** `#courierList`  
**Render Function:** `renderCourierList()`

### List Structure:

```
┌────────────────────────────────────────┐
│ משלוחים פעילים (N)                  │
├────────────────────────────────────────┤
│ DELIVERY CARD (repeats per job)        │
│ ┌──────────────────────────────────────┤
│ │ Top Row:                             │
│ │ 📦 BS-001 | [Status Pill] [Split] │
│ │                                     │
│ │ Customer Info:                      │
│ │ 👤 [Customer Name]                 │
│ │ 📍 [Delivery Address]              │
│ │ 🕒 Required: [When]                │
│ │ 🚛 [Vehicle type] [Name]           │
│ │                                     │
│ │ DELIVERY TRACKER (3-step progress) │
│ │ ① Pickup ──── ② In Transit ────③ Delivered │
│ │   [on]        [off]            [off]      │
│ │                                     │
│ │ Meta: [Item count] · ₪[sum] · Meta  │
│ │                                     │
│ │ [ACTION BUTTON: based on stage]    │
│ │ 📦 אספתי מהחנות                    │
│ └──────────────────────────────────────┘
│                                        │
│ [... repeats for each active job ...]  │
│                                        │
│ EMPTY STATE (if no compatible jobs)   │
│ אין משלוחים שמתאימים ל[vehicle].     │
│ נסה לבחור רכב גדול יותר.              │
└────────────────────────────────────────┘
```

### Job Model

**Key Concept:** A "job" is not necessarily an order; split orders create N jobs (one per shipment).

```javascript
const jobs = [];
allOrders.forEach(o => {
  if (Array.isArray(o.shipments) && o.shipments.length > 1) {
    // Per-shipment jobs (split order)
    o.shipments.forEach((sh, si) => {
      const st = shipStage(o, sh);
      if (!ACTIVE.includes(st) && o.stage !== 'ready') return;
      if (!vehicleCanCarry(courierVehicle, sh.haul || o.haul || 'small')) return;
      if (st === 'delivered') return;
      jobs.push({
        order: o,
        ship: sh,
        shipIdx: si + 1,
        stage: st || 'ready'
      });
    });
  } else {
    // Whole-order job (not split)
    const st = o.stage;
    if (!ACTIVE.includes(st)) return;
    if (!vehicleCanCarry(courierVehicle, o.haul || 'small')) return;
    jobs.push({
      order: o,
      ship: null,
      shipIdx: null,
      stage: st
    });
  }
});
```

### Delivery Card States

**Stage: 'ready' (Awaiting Pickup)**
- **Tracker:** ✓ Pickup (on) · — · Transit (off) · — · Delivered (off)
- **Button:** "📦 אספתי מהחנות"
- **OnClick:** `courierAdvance(id)` → `o.stage = 'pickup'`

**Stage: 'pickup' (Picked Up, Ready to Go)**
- **Tracker:** ✓ Pickup (on) · — · Transit (off) · — · Delivered (off)
- **Button:** "🚚 יצאתי לדרך"
- **OnClick:** `courierAdvance(id)` → `o.stage = 'transit'`

**Stage: 'transit' (In Transit to Delivery)**
- **Tracker:** ✓ Pickup (on) · ✓ Transit (on) · — · Delivered (off)
- **Button:** "✅ נמסר ללקוח"
- **OnClick:** `courierAdvance(id)` → `o.stage = 'delivered'`

**Stage: 'delivered' (Complete)**
- Card removed from active list (ACTIVE includes only ['ready','pickup','transit'])

### Card Header

**Top row:**
- **Order ID:** "📦 BS-001" (or "📦 BS-001 · משלוח 1" for split jobs)
- **Status Pill:** Colored badge with stage label
  - 'ready' → Yellow "לאיסוף"
  - 'pickup' → Blue "לקיחה"
  - 'transit' → Green "בדרך"
- **Split Pill (if applicable):** "🚚 משלוח 1/3" (pulsing 'fresh' class first time seen)

### Card Details

**Customer:** "👤 [customer name from o.who]"  
**Address:** "📍 [site address from o.site or shipment-specific]"  
**When:** "🕒 Required: [o.deliverWhen or sh.when]"  
**Haul:** "🚛 [vehicle icon] [vehicle name]"

### Delivery Tracker (3-Step Visual)

```
① Pickup ──── ② In Transit ──── ③ Delivered
```

- **Step 1** (Pickup): On after 'pickup' stage or later
- **Connector Line 1**: On when progressing to/past 'transit'
- **Step 2** (Transit): On at 'transit' stage or later
- **Connector Line 2**: On when progressing to 'delivered'
- **Step 3** (Delivered): On when 'delivered'

### Meta Row

**Content:** "[Item Count] פריטים" + (if whole order) "· ₪[sum]" + "· הקש לפרטים"

**Note:** Split jobs don't show price (price belongs to whole order, not individual shipment).

### Click Handlers (Delegated)

**Courier List Container** (.addEventListener on #courierList):

**data-advance (Button):** `courierAdvance(advId)`
- Parses "orderId" or "orderId#shipIdx"
- Advances stage in workflow
- Refreshes list

**data-detail (Card body):** `courierDetail(id)`
- Opens detail sheet overlay
- Shows full order + items + actions

---

## Detail Sheet (courierDetailOverlay)

**Element:** `<div id="courierDetailOverlay" class="sheet-modal">`  
**Render Function:** `courierDetail(id)`

### Detail Sheet Layout:

```
┌────────────────────────────────────┐
│ Header:                            │
│ 🛵 [Order ID · Shipment N if split]│
│ [Status Pill]                      │
├────────────────────────────────────┤
│ DELIVERY TRACKER (expanded)        │
│ ① Pickup ── ② Transit ── ③ Done   │
│ (Shows current progress)           │
├────────────────────────────────────┤
│ DETAILS ROW (repeats)              │
│ Label: Value (bold)                │
│ • לקוח: [customer]                 │
│ • כתובת מסירה: [site]             │
│ • מועד נדרש: [when]               │
│ • מספר פריטים: [count]            │
│ • [if split] פיצול משלוח: [info]   │
│ • [if whole order] סכום: ₪[sum]    │
├────────────────────────────────────┤
│ ITEMS LIST (if o.lines exists)     │
│ Header: תכולת המשלוח              │
│ ┌──────────────────────────────────┤
│ │ [emoji] Item Name × Qty         │
│ │ [emoji] Item Name × Qty         │
│ │ [...]                           │
│ └──────────────────────────────────┤
├────────────────────────────────────┤
│ ACTION BUTTONS                     │
│ [Stage-specific button] (green)    │
│ [📄 Delivery Note button] (outline)│
│                                    │
└────────────────────────────────────┘
```

### Item List (if o.lines)

**Data:** Filtered by shipment if per-shipment job

```javascript
const lineIndices = sh 
  ? (sh.lineIdx || [])  // Indices for this shipment
  : o.lines.map((_, i) => i);  // All lines for whole order

lineIndices.forEach(li => {
  const l = o.lines[li];
  const inf = storeItemInfo(l.name);
  // Render: [emoji] Name ×Qty
});
```

### Action Buttons (Bottom)

Two buttons, contextual by stage:

**Button 1 (Green):** Stage-dependent
- ready → "📦 אספתי מהחנות"
- pickup → "🚚 יצאתי לדרך"
- transit → "✅ נמסר ללקוח"
- Onclick: `closeCourierDetail(); courierAdvance(id);`

**Button 2 (Outline):** Delivery Note
- "📄 תעודת משלוח"
- Onclick: `closeCourierDetail(); showDeliveryNote(orderId, 'screen-courier');`

### Detail Interaction

**Close:** `closeCourierDetail()` removes '.show' class from overlay  
**Effect:** Brings user back to list view

---

## Order Advancement Workflow (courierAdvance)

**Function:** `courierAdvance(id)`

### Input Parsing

```javascript
const raw = String(id || '').trim();
let orderId = raw, shipIdx = null;
const hash = raw.indexOf('#');
if (hash > 0) {
  orderId = raw.substring(0, hash);
  shipIdx = parseInt(raw.substring(hash + 1), 10);
}
```

**Formats:**
- `"BS-001"` → Whole order
- `"BS-001#2"` → Shipment 2 of BS-001

### Stage Transition Logic

```javascript
function next(stage) {
  const s = String(stage || '').trim().toLowerCase();
  if (['ready', 'preparing', 'new'].includes(s)) return 'pickup';
  if (s === 'pickup') return 'transit';
  if (['transit', 'shipped'].includes(s)) return 'delivered';
  return null;
}
```

### Advancement

**For Shipment Jobs (shipIdx != null):**
```javascript
const sh = o.shipments[shipIdx - 1];
const nx = next(shipStage(o, sh));
if (!nx) return;
sh.stage = nx;
o.stage = deriveOrderStageFromShipments(o);  // Re-compute order level stage
label = 'משלוח ' + shipIdx + ' של ' + o.id;
```

**For Whole-Order Jobs (shipIdx == null):**
```javascript
const nx = next(o.stage);
if (!nx) return;
o.stage = nx;
// Keep shipments in sync if split
if (Array.isArray(o.shipments) && o.shipments.length > 1) {
  o.shipments.forEach(sh => {
    const cur = shipStage(o, sh);
    const nxt = next(cur);
    if (nxt) sh.stage = nxt;
  });
}
```

### Side Effects
1. Updates `o.stage` and/or `sh.stage`
2. Calls `saveSysOrders()` (persistence)
3. Refreshes views:
   - `renderCourierList()` (local)
   - `renderCourierHome()` (local)
   - Manager/Store views notified via storage event
4. Toast confirmation

---

## Portal Overlay (courierPortal)

**Triggered by:** Portal button (future, not yet wired)  
**Element:** `#courierPortalOverlay`  
**Function:** `openCourierPortal()`

### Portal Tile Grid (6 tools)

```
┌──────────────────────────────────────────┐
│ 🧰 פורטל השליח                         │
│ כל הכלים לניהול המשלוחים שלך.            │
├──────────────────────────────────────────┤
│ Grid (2 cols × 3 rows):                  │
│ ┌───────────────┬───────────────┐       │
│ │ 🧭           │ 🚛           │       │
│ │ ניווט         │ צי רכב        │       │
│ │ למשלוח        │               │       │
│ ├───────────────┼───────────────┤       │
│ │ ⏱️            │ 🗺️            │       │
│ │ מעקב SLA      │ אזורי הפצה    │       │
│ │               │               │       │
│ ├───────────────┼───────────────┤       │
│ │ 📸            │ 💬            │       │
│ │ אישור מסירה   │ צ׳אט עם חנות  │       │
│ │ POD + צילום   │               │       │
│ └───────────────┴───────────────┘       │
└──────────────────────────────────────────┘
```

### Courier Portal Tools

1. **🧭 ניווט למשלוח** → `courierNav()`
   - Pick active delivery
   - Open Google Maps with site address
   - Integration with native maps app

2. **🚛 צי רכב** → `portalFleet()`
   - Fleet status from `FLEET` array
   - Vehicle availability + driver info
   - Maintenance alerts

3. **⏱️ מעקב SLA** → `portalSLA()`
   - Service level agreement tracking
   - Countdown timers
   - Performance metrics

4. **🗺️ אזורי הפצה** → `portalZones()`
   - Delivery zones map
   - ETA by zone
   - Coverage heatmap

5. **📸 אישור מסירה (POD)** → `courierPOD()`
   - Proof of delivery
   - Photo capture
   - Digital signature
   - Marks `o.podSigned = true` and `o.podPhoto = true`

6. **💬 צ׳אט עם חנות** → `openChat('contractor')`
   - Internal messaging with supplier
   - Thread-based history
   - Auto-reply simulation

Each tool opens in `#courierPortalOverlay` sheet modal.

---

## Delivery Note (תעודת משלוח)

**Same as Store view** (see STORE_DASHBOARD.md)

**Triggered from:**
- Delivery detail sheet: "📄 תעודת משלוח" button
- Returns to `screen-courier` after viewing

---

## Key Data Structures

### Delivery Job (rendered in list):
```javascript
{
  order: { id: 'BS-001', who: '...', site: '...', ... },
  ship: null or { when: '...', site: '...', haul: 'van', stage: 'transit', ... },
  shipIdx: null or 1,2,3...,
  stage: 'ready' | 'pickup' | 'transit'
}
```

### Order Object (relevant fields):
```javascript
{
  id: 'BS-001',
  who: 'Customer Name',
  site: 'Delivery Address',
  items: 12,
  sum: 5420,
  stage: 'ready' | 'pickup' | 'transit' | 'delivered',
  haul: 'small' | 'van' | 'truck',
  deliverWhen: 'עד שעתיים',
  shipments: [
    { when: '...', site: '...', haul: '...', stage: '...', lineIdx: [0,1,2] },
    // ...
  ],
  lines: [
    { name: '...', qty: 2, picked: true },
    // ...
  ],
  podSigned: false,
  podPhoto: false
}
```

### Vehicle Rank:
```javascript
const VEHICLE_RANK = {
  small: 0,
  van: 1,
  truck: 2
};
```

---

## RBAC Rules — Courier Role

| Permission | Context | Function |
|-----------|---------|----------|
| `order.fulfill` | Progress delivery through stages | `courierAdvance()` |

---

## State Variables — Courier Screen

| Variable | Type | Purpose |
|----------|------|---------|
| `courierVehicle` | string | Vehicle selection (default: 'truck') |
| `activeChatPeer` | string | Chat recipient ('contractor') |

---

## Screen Registration

**HTML Structure:** Lines 4291–4328 in index.html

```html
<div class="fullscreen admin-screen" id="screen-courier" style="display:none">
  <!-- Single pane (no tabs) -->
  <div class="adm-pane on">
    <div id="courierHome"></div>
    <div id="courierList"></div>
  </div>
</div>
```

**Overlay:**
```html
<div class="sheet-modal" id="courierDetailOverlay" style="display:none">
  <div class="sheet-body" id="courierDetailBody"></div>
</div>

<div class="sheet-modal" id="courierPortalOverlay" style="display:none">
  <div class="sheet-head">...</div>
  <div class="sheet-body" id="courierPortalBody"></div>
</div>
```

---

## Interaction Flow Summary

```
Courier Screen Entry
  ↓ renderCourier() (called by enterRole)
  ↓ [Two regions render independently]

Home Region
  ├─ Vehicle Picker
  │  └─ Click vehicle → pickCourierVehicle(id)
  │     → Re-filters list + toast
  ├─ Primary Action Card
  │  └─ Click → Scrolls to list
  └─ Quick Stats
     └─ Tap → Scrolls to list

Delivery List Region
  ├─ Filtered by:
  │  ├─ Vehicle capacity (courierVehicle)
  │  └─ Active stages (ready, pickup, transit)
  ├─ Click Card Body → courierDetail(id)
  │  ├─ Opens overlay
  │  ├─ Shows full details + items
  │  └─ Action button in overlay
  │     └─ Click → closeCourierDetail() + courierAdvance(id)
  │        → Advances stage → Re-renders
  └─ Click Action Button (list) → courierAdvance(id)
     → Same workflow

Delivery Note
  └─ Click "📄" button
     → showDeliveryNote(orderId, 'screen-courier')
     → Opens print-style document
     → Close → Back to detail or list

Portal
  └─ Click Portal button (future)
     → openCourierPortal()
     → Shows 6 tool tiles
     → Each tile opens feature overlay

Stage Progression
  ready → [📦 Pick up]
  pickup → [🚚 Go in transit]
  transit → [✅ Deliver]
  delivered → [Removed from active list]
```

---

## Key Algorithms

### Ship Stage Calculation

```javascript
function shipStage(order, shipment) {
  // Derive the stage of a specific shipment in a split order
  return shipment.stage;  // Stored directly on shipment object
}
```

### Derive Order Stage from Shipments

```javascript
function deriveOrderStageFromShipments(order) {
  if (!Array.isArray(order.shipments) || order.shipments.length === 0) {
    return order.stage || 'new';
  }
  const stages = order.shipments.map(sh => sh.stage);
  if (stages.every(s => s === 'delivered')) return 'delivered';
  if (stages.some(s => s === 'transit')) return 'transit';
  if (stages.some(s => s === 'pickup')) return 'pickup';
  if (stages.some(s => s === 'ready')) return 'ready';
  return 'preparing';
}
```

### Active Delivery Filtering

```javascript
const ACTIVE = ['ready', 'pickup', 'transit'];
const jobs = [];

allOrders.forEach(o => {
  if (Array.isArray(o.shipments) && o.shipments.length > 1) {
    o.shipments.forEach((sh, si) => {
      const st = shipStage(o, sh);
      if (!ACTIVE.includes(st) && o.stage !== 'ready') return;
      if (!vehicleCanCarry(courierVehicle, sh.haul || o.haul)) return;
      if (st === 'delivered') return;
      jobs.push({order: o, ship: sh, shipIdx: si + 1, stage: st});
    });
  } else {
    const st = o.stage;
    if (!ACTIVE.includes(st)) return;
    if (!vehicleCanCarry(courierVehicle, o.haul)) return;
    jobs.push({order: o, ship: null, shipIdx: null, stage: st});
  }
});
```

---

## Mobile-First Design Notes

- **Single Pane Layout:** Optimized for vertical scrolling on mobile
- **Large Touch Targets:** Buttons and cards sized for thumb interaction
- **Vehicle Picker:** Horizontal scroll for vehicle selection
- **Tracker Visual:** 3-step progress bar is touch-optimized
- **Detail Sheet:** Swipe-down to close (sheet-modal pattern)
- **Portal Tiles:** 2-column grid scales to mobile naturally

---

## Performance Considerations

1. **Delegated Event Listeners:** One listener on #courierList survives all re-renders
2. **Independent Regions:** renderCourierHome() and renderCourierList() fail gracefully
3. **Vehicle Filter:** Re-renders both regions when vehicle changes
4. **Lazy Loading:** Portal features load on-demand (not on entry)

