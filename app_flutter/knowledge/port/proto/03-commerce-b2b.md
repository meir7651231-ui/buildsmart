# 03 — Commerce + B2B Supply-Chain Flows

Exhaustive port reference for the BuildSmart prototype (`/home/user/buildsmart/index.html`, ~22,416 lines, Hebrew RTL). Domain: the **cart, checkout pricing math, orders, shipping planner, and the whole B2B supply-chain toolkit** (RFQ, RMA, rental, deposits, MSDS, price-compare, bulk/FX calculators, credit, government XML export, digital signature, delivery notes). Every Hebrew string is verbatim, every data value is reproduced, every formula and format is spelled out. `[L#]` = source line number.

> Scope note on two same-named symbols: the brief mentions `CONTRACTS`. In this codebase `CONTRACTS` `[L15673]` is the **test-harness button-contract registry**, NOT a commerce structure — documented as such at the end. Likewise `ORDERS` `[L6323]` is the **construction-phase tree** data (building → infra → sealing → tiling → finish), and `openOrder(key)` `[L9623]` opens that phase overlay — it is NOT a commerce order. The commerce order array is `localOrders` (contractor side) and `SYS_ORDERS` (system/seed side). All three are covered below so the distinction is unambiguous.

---

## 1. Global commerce state & checkout config

Single source of truth `[L11936-11963]`:

```js
const VAT_RATE = 0.18;            // Israeli VAT 18% (raised from 17% Jan 2025) [L11941]
let   EXPRESS_FEE = 80;           // express surcharge, editable [L11961]
let   expressDelivery = false;    // express slot chosen? [L11962]
let   creditLimit = 50000;        // contractor cart credit ceiling, editable [L11963]
let   storeHaul = {};             // store id -> haul type id [L11955]
let   cart = [], deliverySlot = 0; // [L6382]
let   cartShipments = null;       // null = single shipment; array = split [L18452]
let   orderSeq = 1001;            // demo running id, server assigns in prod [L11203]
let   localOrders = [];           // in-memory contractor orders [L11205]
```

### `SUPPLIER_STORES` `[L11942-11946]` — three demo suppliers, each with own delivery fee

| id | name | icon | shipping (₪) | eta |
|----|------|------|-----------|-----|
| `s1` | מחסני אינסטלציה תל-אביב | 🔧 | 90 | עד שעתיים |
| `s2` | ספקי סניטריה השרון | 🚿 | 65 | עד 3 שעות |
| `s3` | חומרי בניין הרצליה | 🧱 | 45 | עד שעה |

`STORE_IDS = Object.keys(SUPPLIER_STORES)` `[L11947]` → `['s1','s2','s3']`.
Comment: "Fees are placeholders for the prototype, not real logistics tariffs."

### `HAUL_TYPES` `[L11950-11954]` — vehicle class, adds to shipping, selectable per supplier

| id | name | ic | extra (₪) |
|----|------|----|---------|
| `small` | משלוח קטן | 🛵 | 0 |
| `van` | טנדר | 🚐 | 40 |
| `truck` | משאית | 🚛 | 90 |

Helpers: `haulFor(sid)` → `storeHaul[sid] || 'small'` `[L11956]`; `haulExtra(sid)` returns the chosen type's `extra` `[L11957-11960]`; `pickHaul(sid,hid)` sets `storeHaul[sid]=hid` then `renderCart()` `[L10793-10796]`.

### Item → store assignment

`assignStore(item)` `[L10801-10813]`: (1) if `item.store` already a valid SUPPLIER_STORES key, keep it; (2) if `item.productKey` set, try `storeForProduct(key)` (category mapping); (3) else deterministic hash of the name `h=(h*31+charCode)>>>0` → `STORE_IDS[h % 3]` and cache on `item.store`. Stable across re-renders.

`CATEGORY_STORE` `[L10816-10828]` — maps catalog category → store (s1 = plumbing/installation, s2 = sanitary, s3 = building materials):

| Category | → store |
|----------|---------|
| ברזים וכיורים | s1 |
| ניקוז וצנרת | s1 |
| חימום מים | s1 |
| אביזרי קצה וחיבורים | s1 |
| אביזרים נלווים | s1 |
| אסלות | s2 |
| מקלחות ואמבטיות | s2 |
| גופי תברואה | s2 |
| מטבח | s2 |
| בנייה ומחיצות | s3 |
| גמר | s3 |

`storeForProduct(key)` `[L10829-10834]`: looks up `TREES[key].cat`, maps via `CATEGORY_STORE`, returns the sid if valid.

### `DELIVERY_SLOTS` `[L10908-10914]` — schedule picker (5 slots, index 0 is express)

| idx | day | window |
|-----|-----|--------|
| 0 | היום | אקספרס · עד שעתיים |
| 1 | היום | 14:00–16:00 |
| 2 | מחר | 07:00–09:00 |
| 3 | מחר | 12:00–14:00 |
| 4 | מחר | 16:00–18:00 |

`pickSlot(i)` `[L10787-10792]`: sets `deliverySlot=i`, then `expressDelivery = slot.window.indexOf('אקספרס')>=0` (only index 0 is express), `renderCart()`.

### `DELIVERY_WINDOWS` `[L7103]` — app-bar delivery-time picker (separate, simpler)

`['עד שעה','עד שעתיים','היום אחה"צ','מחר בבוקר','חלון מתוזמן']`. `openDeliveryPicker` `[L7104]` renders buttons `🕐 <w>`; `chooseDelivery(w)` `[L7117]` updates `#appbarDelivery` (re-styling "עד X" with bold) and toasts `זמן האספקה עודכן: <w>`.

---

## 2. `computeCheckout()` — the FULL pricing math `[L10838-10905]`

Pure function (no DOM, unit-testable). Returns an object consumed by `renderCart`, `openPaymentDetail`, `openCreditDetail`, `checkout`, `testCheckoutLayout`.

**Step 1 — group cart by supplier store** `[L10839-10852]`:
```
groups[sid] = { id, items[], subtotal }   // subtotal += it.price * (it.qty||1)
storeGroups = each group enriched with:
   baseShipping = SUPPLIER_STORES[sid].shipping
   haulExtra    = haulExtra(sid)                // 0 / 40 / 90
   shipping     = baseShipping + haulExtra      // base + chosen haul
```

**Step 2 — items subtotal** `[L10853]`: `itemsSubtotal = Σ group.subtotal`.

**Step 3 — shipping, two modes:**

*Single-wave (default)* `[L10887-10889]`: `shippingTotal = Σ storeGroups.shipping`.

*Multi-wave split* — when `cartHasSplit()` is true `[L10858-10886]`. Billing changes because each wave is a separate vehicle dispatch. For every shipment in `cartShipments`:
- Read `s.lines` (new shape; legacy `s.itemIdx` migrated on the fly to `{idx,qty:cart[i].qty||1}`).
- Collect the set of **unique stores touched** by the wave's lines (`assignStore(cart[l.idx])`).
- `baseSum = Σ over unique stores of SUPPLIER_STORES[sid].shipping` (base only, once per supplier per wave).
- `haulInfo = HAUL_TYPES.find(id===s.haul) || HAUL_TYPES[0]`; `haulFee = haulInfo.extra`.
- `subtotal = baseSum + haulFee`; push `{idx:idx+1, stores:#unique, baseSum, haulFee, haulName, subtotal}`.
- `shipmentShipping = { total: Σ subtotal, breakdown:[…] }`; `shippingTotal = shipmentShipping.total`.

> Key billing rule: per-wave shipping = (sum of BASE shipping of every unique supplier in that wave) + (haul extra of that wave's single chosen vehicle). The haul extra is charged **once per wave**, not per supplier.

**Step 4 — express, VAT, total** `[L10890-10893]`:
```
expressFee = expressDelivery ? EXPRESS_FEE : 0           // 80 or 0
taxable    = itemsSubtotal + shippingTotal + expressFee  // VAT applies to shipping & express too
vat        = taxable * VAT_RATE                            // * 0.18
grandTotal = taxable + vat
```

**Return** `[L10894-10904]`: `{ storeGroups, itemsSubtotal, shippingTotal, shipmentShipping, expressFee, vatRate, vat, grandTotal, itemCount: cart.length }`.

### `testCheckoutLayout()` — self-check `[L10980/L11445-11470]` (button "🧪 בדוק את החישוב")

Recomputes independently (single-wave only): `expectedItems=Σ price*qty`, `expectedShip=Σ group.shipping`, `expectedVat=(items+ship)*VAT_RATE`, `expectedGrand=items+ship+vat`, with `approx(a,b)=|a-b|<0.01`. Checks keyed `'סכום ביניים'`, `'דמי משלוח'`, `'מע"מ'`, `'סה"כ לתשלום'`. Toast success: `✅ כל החישובים תקינים — סה"כ ₪<grand>`; failure: `❌ נמצאה שגיאת חישוב: <names>`. Empty: `הסל ריק — אין מה לבדוק`.

---

## 3. `renderCart()` — the cart screen `[L11044-11199]`

Money format throughout: `'₪'+Math.round(n).toLocaleString()`.

**Empty state** `[L11052-11060]`: hides items/summary, shows `#cartEmpty`, resets `cartShipments=null`, re-renders ship-plan strip.

**Site strip** `[L11047-11051]`: `#cartSiteName` ← `activeProject().name || '—'`.

**Stale-split pruning** `[L11063-11074]`: drops any `cartShipments` line whose `idx >= cart.length` (line removed after split planned); migrates legacy `itemIdx`→`lines`. Then `renderCartShipPlan()`.

**Items grouped per store** `[L11079-11139]` — for each `storeGroup`:
- Header: `<span class="sg-name">${st.icon} ${st.name}</span><span class="sg-eta">${st.eta}</span>`.
- Each line: thumb `it.img`; name (clickable → `goToProductByName`); price line `₪<price> ליח'` plus, if `it.auto`, ` · <span class="auto-badge">⚡ עץ מוצרים</span>`; qty-wheel (`−` `stepCartQty(ci,-1)`, value opens `openCartQtyInput(ci)`, `+` `stepCartQty(ci,1)`); delete `🗑️` `removeCartItem(ci)` title `הסר`; line total `₪<price*qty>`.
- **Single-wave** only `[L11111-11130]`: per-store haul picker — title `סוג הובלה`, three buttons `<ic> <name>[ +₪<extra>]` (active class `on`); footer `סכום ביניים · <store>` / `₪<subtotal>`; ship footer `🚚 משלוח · <store> [(כולל הובלה)]` / `₪<shipping>`.
- **Split mode** `[L11131-11138]`: only the subtotal footer (planner owns shipping/timing).

**Delivery slot picker** `[L11142-11164]` — hidden when split (`cartHasSplit()`). Title row with clock SVG + `בחר חלון משלוח לאתר`. Each slot tile: top `<window>`, sub `<day>[ · +₪<EXPRESS_FEE>]` if express; active class `on`.

**Checkout summary box** `[L11165-11198]` (`onclick=openPaymentDetail()`):
- Title `💳 פירוט תשלום` + `<span class="co-more">פרטים מלאים ›</span>`.
- Row `סכום ביניים · <itemCount> פריטים` → `₪<itemsSubtotal>`.
- Shipping row(s): split → `דמי משלוח · <N> גלים נפרדים` → `₪<shippingTotal>` plus a sub-row per wave `· משלוח <idx> (<haulName>)` → `₪<subtotal>`. Single → `דמי משלוח · <N> חנות|חנויות` → `₪<shippingTotal>` (singular `חנות` when N==1, else `חנויות`).
- If `expressFee>0`: `⚡ תוספת אקספרס` → `₪<expressFee>`.
- `מע"מ (<vatPct>%)` → `₪<vat>` (vatPct = `Math.round(vatRate*100)` = 18).
- Auto note row (teal): `⚡ אביזרים שעץ המוצרים מנע שתשכח` → `<autoCount> פריטים` (count of `cart.filter(i=>i.auto)`).
- Grand: `סה"כ לתשלום` → `₪<grandTotal>`.
- Pay note: `💳 זמין לקבלנים מאושרי חיתום: תשלום בשוטף +60`.
- Test button: `🧪 בדוק את החישוב` (`testCheckoutLayout`).

**Credit box** `[L11183-11193]` (`onclick=openCreditDetail()`):
- Label `מסגרת אשראי — קבלן`; pill `שוטף +60 · פרטים ›`.
- Bar width `min(100, round(grandTotal/creditLimit*100))%`.
- Row `נוצל: ₪<grandTotal>` / `פנוי: ₪<creditLimit-grandTotal> מתוך ₪<creditLimit>`.

**Confirm button** `[L11195-11198]`: checkmark SVG + `אשר הזמנה · משלוח ל<activeProject().name || האתר>` → `checkout()`.

### Cart item edits
- `stepCartQty(ci,d)` `[L10917]`: `qty=max(1, qty+d)`, sync, re-render, `updateCartCount`.
- `openCartQtyInput(ci)` `[L10924]`: `prompt('כמות עבור "<name>":', qty)`; invalid → toast `יש להזין מספר תקין`.
- `removeCartItem(ci)` `[L10935]`: splice, sync, re-render catalog/home, toast `<name> הוסר מהסל`.
- `syncCartToProject()` `[L10947]`: `activeProject().cart = cart.slice()`.
- `updateCartCount()` `[L10780]`: `#cartCount`←length; tab dot shown when length>0.
- `openCartSitePicker`/`chooseCartSite(id)` `[L10955-10973]`: re-assigns order to a PROJECT; toast `ההזמנה שויכה ל<name>`.

### `openPaymentDetail()` — full per-store breakdown overlay `[L10976-10999]`
For each storeGroup: header `<icon> <name>`; rows `פריטים (<count>)`→`₪<subtotal>`, `משלוח בסיס`→`₪<baseShipping>`, `הובלה · <ic> <name>`→`<₪haulExtra | ללא תוספת>`. Totals block: `סכום ביניים`, `דמי משלוח (כל החנויות)`, optional `⚡ תוספת אקספרס`, `מע"מ (<pct>%)`, grand `סה"כ לתשלום`. fmt = `₪+Math.round(n).toLocaleString()`.

### `openCreditDetail()` / `saveCreditLimit()` — editable cart credit ceiling `[L11005-11042]`
- `used = grandTotal`, `free = creditLimit - used`, `pct = round(used/creditLimit*100)`.
- Headline `<pct>%` + `מהמסגרת בשימוש`; bar width `min(100,pct)%`.
- Number tiles: `מסגרת כוללת` ₪creditLimit, `בהזמנה זו` ₪used, `פנוי` ₪free (color danger if free<0 else ok).
- Terms: `תנאי תשלום`→`שוטף +60`; `סטטוס חיתום`→`✓ מאושר`.
- Input `עדכון מסגרת אשראי (₪)` id `creditLimitInput`; button `שמור מסגרת`.
- Note: `* מסגרת האשראי להמחשה — בגרסה המלאה תיקבע מול חיתום הלקוח.`
- `saveCreditLimit()` `[L11035]`: parse int; invalid/<0 → toast `יש להזין סכום תקין`; else set `creditLimit`, close, re-render, toast `מסגרת האשראי עודכנה`.

> Note: cart credit uses the global `creditLimit` (50,000). The manager-side per-contractor ceiling is a SEPARATE system — `CONTRACTOR_CREDIT`/`contractorCredit(name)` (§9).

---

## 4. `checkout()` — place order `[L11312-11442]`

1. **Out-of-stock gate** `[L11315-11324]`: if any cart item with a real `productKey` has `STORE_STOCK[key]===false`, call `openOutOfStockGate(idx)` and return (one item at a time).
2. `co=computeCheckout()`; `slot=DELIVERY_SLOTS[deliverySlot||0]`; `orderId='BS-'+(orderSeq++)`.
3. **Structured order** `[L11334-11367]`:
```js
{ id, createdAt:ISO, status:'pending',
  project:{ site: activeProject().name (fallback 'מגדל הרצליה'), stage: currentStage().name },
  delivery:{ day: slot.day, window: slot.window },
  items:[{ name, qty, price, auto, store, supplier:SUPPLIER_STORES[store].name }],
  suppliers:[{ store:name, storeId, subtotal, shipping }],   // from co.storeGroups
  totals:{ itemsSubtotal, shippingTotal, vatRate, vat:round2, grandTotal:round2 } }
```
(`round2 = Math.round(x*100)/100`.)
4. **Multi-wave embed** `[L11369-11412]` — when `cartShipments.length>1`: expand flat `items[]` so each per-wave claim becomes its own line (e.g. "Cement ×6" in wave 1 + "Cement ×4" in wave 2 → two rows). Build `shipmentMeta[]`: `{ idx, lineIdx[], when: slot.day+' '+slot.window (else 'בתיאום'), site: PROJECT.name, siteAddr, haul }`. Set `order.items=expandedItems`, `order.shipments=shipmentMeta`.
5. **Save** `[L11414-11441]`: if `apiService.saveOrder` exists, save then verify; else push to `localOrders`. `onOrderSaved` `[L11415]`: clears `cart`, resets `cartShipments=null`, sync, `syncOrderToSystem(saved)` (BRIDGE), `go('orders')`, toast `ההזמנה <id> אושרה ונשמרה ✓`, `notifyOrderStatus(id,'התקבלה ונכנסה להכנה')`.

### `syncOrderToSystem(order)` — the BRIDGE `[L11212-11310]`
Maps a contractor order into the `SYS_ORDERS` shape so supplier/courier/manager all see it. Skips if no id / no SYS_ORDERS / id already present. Derives:
- `who`: `userProfile.name || userProfile.business || 'קבלן'`.
- `itemCount=Σ qty`; `sum = round(totals.grandTotal)` or `Σ price*qty`.
- `storeIndex`: best = `suppliers[0].storeId`→`STORE_IDS.indexOf`; next = match supplier name in `STORES`; last = `items[0].store`; default 0.
- `haul`: heaviest of `storeHaul` across items (rank small<van<truck).
- `deliverWhen`: `order.delivery.day+' '+window` trimmed, else `בתיאום`.
- `sysOrder = { id, who, site, items:itemCount, sum, stage:'new', storeIndex, haul, deliverWhen, lines:[{name,qty}], fromContractor:true }`.
- If `order.shipments.length>1`: also `shipments`, `splitInto`, `splitPlan` (line→wave number array), `splitNoticeNew:true`.
- `SYS_ORDERS.unshift(sysOrder)`; `saveSysOrders()`.

### `generateMockOrder()` — test order `[L7958-8018]`
Sample pool (all s1): `ברז אמבטיה לכיור` ₪189, `צינורות חיבור גמישים` ₪35 (auto), `אטם גומי לברז` ₪12 (auto), `סיפון לכיור` ₪46, `דוד שמש 150 ליטר` ₪1450. Picks 2–4, qty 1–3. `shipping=65`, `vat=(items+ship)*0.18`. id `BS-MOCK-<seq>-<100..999>`, site `מגדל הרצליה`, delivery `{day:'מחר',window:'07:00–09:00'}`. Toast `הזמנת בדיקה <id> נוצרה — נשלחה לחנות`.

---

## 5. Orders screen — `renderMyOrders`, `orderCard`, `toggleOrder` `[L7701-7953]`

### Status maps
`ORDER_STATUS` `[L7632-7637]` (contractor 4-state display):

| key | label | cls |
|-----|-------|-----|
| pending | ממתינה | st-pending |
| processing | בהכנה | st-processing |
| shipped | בדרך | st-shipped |
| delivered | נמסרה | st-delivered |

`resolveStatus(o)` `[L7641-7650]` normalizes `o.status||o.stage`: `{pending,new→pending; processing,preparing,ready→processing; shipped,transit,pickup→shipped; delivered,done→delivered}`, default pending.

`ORDER_STAGE` `[L12041-12048]` (system 6-stage, supplier/courier/manager side):

| key | label | cls |
|-----|-------|-----|
| new | התקבלה | new |
| preparing | בהכנה | prep |
| ready | מוכן לאיסוף | ready |
| pickup | נאסף | ready |
| transit | בדרך לאתר | ready |
| delivered | נמסר ✓ | done |

`ORDER_FLOW` `[L16943]` = `['new','preparing','ready','pickup','transit','delivered']` — the linear advance order used by supplier/courier "advance" buttons (`o.stage=ORDER_FLOW[cur+1]`, toast `הזמנה <id> → <label>`; if already last → `ההזמנה כבר הושלמה`).

### Helpers
- `fmtOrderDate(iso)` `[L7653]` → `DD/MM · HH:MM` (zero-padded), `—` if invalid.
- `orderTotal(o)` `[L7664]`: `totals.grandTotal` || flat `total` || `Σ price*qty`.
- `orderItemCount(o)` `[L7672]`: array length || number || 0.
- `syncStatusFromSystem(orders)` `[L7682-7699]`: mirrors live `SYS_ORDERS[id].stage` back into each local order's `stage`/`status`; flags `_stageChanged`.

### `renderMyOrders()` `[L7701-7736]`
`show(orders)`: `syncStatusFromSystem`, sort newest-first by `createdAt`. Empty: `🗂️ אין עדיין הזמנות.<br>אשר הזמנה מהעגלה, או צור הזמנת בדיקה.`. With apiService: shows `טוען הזמנות…`, merges `localOrders + apiService.getOrders()` deduped by id. Renders `orderCard` for each.

### `orderCard(o)` `[L7867-7948]`
Collapsed: head `<id>` + badge `<st.label>` (class `st.cls`); meta `📅 <date>` / `📍 <site>`; foot `<count> פריטים` / `₪<total>`. `onclick=toggleOrder(id)`.

**Expanded breakdown** `[L7876-7929]` (only when `expandedOrder===id`):
- Each item: name (clickable, ⚡ if auto) / `×<qty>` / `₪<price*qty>`.
- If delivery window: `🚚 חלון משלוח: <day> <window>`.
- If totals: `מע"מ` → `₪<vat>`, grand `סה"כ` → `₪<total>`.
- Button `📄 הצג / הדפס תעודת משלוח` → `showDeliveryNote(id,'app')`.
- If `shipments.length>1`: ship-plan summary `🚚 תכנון אספקה · <N> גלים` then per wave `משלוח <i> · <#lineIdx> פריטים · <when|בתיאום> · <site|—>`.

**The 5 action buttons** `[L7916-7928]` (in two `.oc-ca-actions` rows):
1. `🚚 ערוך תכנון אספקה` (if already split) / `🚚 פצל לכמה משלוחים` (if not) → `openOrderShipPlanner(id)` — only shown when `canEditPlan` (stKey is `pending` or `processing`; can't re-plan after the truck left).
2. `↩️ החזרה / זיכוי` → `openRMA(id)`.
3. `✍️ חתימת מסירה` → `openSignature(id)`.
4. `📷 צילום תעודה` → `openDocScan(id)`.
5. `🗂️ ייצוא XML` → `openGovExport(id)`.

`toggleOrder(id)` `[L7950]`: `expandedOrder = (expandedOrder===id)?null:id`; `renderMyOrders()`.

### `renderReorderHistory()` `[L7017-7038]` + `DEMO_HISTORY` `[L7013-7016]`
`DEMO_HISTORY` (shown only when `entryMode==='demo'`):

| name | price | icon | cat | ago |
|------|-------|------|-----|-----|
| מקדחה רוטטת בוש GBH | 640 | 🔩 | כלי עבודה | הוזמן לפני 9 ימים |
| שק מלט אפור 25 ק"ג | 31 | 🪨 | בנייה | הוזמן לפני 6 ימים |

Empty: `עדיין אין הזמנות קודמות — לאחר ההזמנה הראשונה היא תופיע כאן.`. Each row: thumb, name, `<cat> · <ago>`, `₪<price>`, `+` mini-add. Both row and mini-button call `addSingle(name,price,icon)`.

### Shipment status tracker — `openShipmentStatus` `[L7752-7823]`
App-bar mini-tracker (separate from the orders list). Filters `resolveStatus(o)!=='delivered'`. 4-step labels `{pending:'התקבלה',processing:'בהכנה',shipped:'יצאה',delivered:'נמסרה'}`. Each card: `📦 <id>` + badge, `🏗️ <site>`, dotted track, and (only when shipped) an animated SVG mini-map (store 🏪 → site 🏗️, truck 🚚) with caption `🚚 השליח בדרך — הגעה בעוד <12> דק׳`, plus `🕐 חלון הגעה: <eta|בתיאום>`. Empty: `🚚 אין משלוחים פעילים כרגע.<br>הזמנות שתבצע יופיעו כאן עד למסירה.`. `animateShipmentMaps` `[L7826]` drives trucks along the path; ETA counts down `round(12*(1-prog))`.

### SYS_ORDERS seed `[L11969-12040]`
`BS_ORDERS_KEY='buildsmart:sharedOrders'` (localStorage, cross-tab sync with admin). `SYS_ORDERS_SEED` (5 orders), each `{id,who,site,items,sum,stage,haul,lines:[{name,qty}]}`:

| id | who | site | items | sum | stage | haul |
|----|-----|------|-------|-----|-------|------|
| BS-1042 | יוסי כהן | מגדל הרצליה | 7 | 1240 | new | van |
| BS-1041 | אבי מזרחי | דירה — רמת גן | 3 | 680 | preparing | small |
| BS-1040 | משה אברהם | וילה — סביון | 12 | 3150 | ready | truck |
| BS-1039 | דוד לוי | משרדים — תל אביב | 4 | 420 | transit | van |

(BS-1042 lines: ברז לכיור ×2, צינורות חיבור גמישים ×4, ברזי ניל זוויתיים ×4, סרט טפלון ×3, אטם גומי לברז ×6, סיליקון סניטרי ×1, מפתח צינורות ×1. BS-1041: אסלה תלויה ×1, מיכל הדחה סמוי ×1, מושב אסלה ×1. BS-1040: צינור PEX מים חמים/קרים ×24, מחברי PEX ×18, גוף סמוי לסוללת מקלחת ×2, ראש מקלחת ×2, זרוע למקלחת ×2, סוללת מקלחת ×2. BS-1039: ברז למטבח ×1, צינורות חיבור גמישים ×2, סרט טפלון ×1.)

`loadSysOrders` `[L12003]`: localStorage or seed; backfills missing `lines` from seed by id. `saveSysOrders` `[L12021]`: persists to localStorage. On load `orderSeq` is bumped past the highest existing `BS-####` `[L12031-12039]`.

---

## 6. Shipping planner `[L18450-18974]`

Shared engine for two contexts via `plannerCtx`. State `[L18452-18456]`: `cartShipments` (cart context), `plannerCtx` (`'cart'` | `{orderId}`), `shipPickerCtx`, `shipItemFilter`, `shipCatFilter`.

### The split model — `lines = [{idx, qty}]`
Internal shape: each shipment holds `sh.lines = [{idx: lineIdx-into-plannerItems, qty: numberToTake}]` `[L18490-18491]`. A single cart/order line can be split across waves (e.g. 6 here, 4 there). Legacy `sh.itemIdx` (just indices) is migrated on read by `shipLines(sh)` `[L18492-18503]` into `{idx, qty:items[i].qty||1}`.

Context accessors:
- `plannerItems()` `[L18459]`: cart context → `cart`; order context → `SYS_ORDERS[orderId].lines`.
- `plannerShipments()`/`setPlannerShipments(arr)` `[L18467-18486]`: cart → `cartShipments`; order → `o.shipments`.
- `cartHasSplit()` `[L18488]`: `Array.isArray(cartShipments) && length>1`.

Quantity math:
- `plannerLineQty(idx)` `[L18504]`: `items[idx].qty||1`.
- `qtyTakenAcross(idx)` `[L18508]`: Σ over all shipments of that idx's qty.
- `qtyInShip(sh,idx)` `[L18514]`: qty of idx in one shipment.
- `setShipLineQty(sh,idx,qty)` `[L18518-18527]`: qty<=0 removes the line; else update or push `{idx,qty}`.

### The `claimable` invariant
`claimable = cartQty - takenElsewhere`, where `takenElsewhere = qtyTakenAcross(idx) - qtyInShip(thisShip,idx)` `[L18847]`. This is the max qty a shipment may grab for a line. Enforced everywhere: checkbox `toggleShipItem` claims `claimable` `[L18889]`; `bumpShipQty` clamps to `min(cartQty-takenElsewhere, max(0,cur+delta))` `[L18900]`; `setShipQty` clamps `v>claimable→claimable`, `v<0→0` `[L18909-18911]`; bulk select grabs all remaining `[L18926]`. A line with `claimable===0` renders `locked` with a disabled checkbox `[L18853-18854]`. **Every unit must live in exactly one shipment** — the planner can't be saved while any qty is unassigned.

`unassignedInPlanner()` `[L18553-18562]`: `[{idx, remaining: cartQty - qtyTakenAcross(idx)}]` for any line where taken < cartQty.

`ensurePlannerShipments()` `[L18528-18550]`: if none, create shipment #1 = `{id:1, slot:deliverySlot||0, siteId:activeProject().id, haul:dominantHaul, lines: all items at full qty}`. `dominantHaul` = heaviest of `storeHaul` (rank small<van<truck).

### Entry points
- `openCartShipPlanner()` `[L18565]`: empty cart → toast `הסל ריק`; else `plannerCtx='cart'`, ensure, render, show `#shipPlanOverlay`.
- `openOrderShipPlanner(orderId)` `[L18572]`: find SYS_ORDERS order (not found → `הזמנה לא נמצאה`; no lines → `אין פריטים בהזמנה`); `plannerCtx={orderId}`, ensure, render, show.

### `renderShipPlanner()` `[L18583-18608]`
Head `🚚 תכנון אספקה · <בסל | הזמנה <id>>`; sub `קבע מתי, לאן ובאיזה רכב יגיע כל גל. כל פריט חייב להיות בדיוק במשלוח אחד.`. If unassigned: warn `⚠️ <N> פריטים · <totalRemain> יח׳ עדיין לא משויכים` + button `צרף למשלוח 1` (`assignRemainingTo(ships[0].id)`). One `renderShipCard` per shipment. Button `+ הוסף משלוח נוסף` (`addShipment`). If >1 shipment: `בטל פיצול — חזור לאספקה אחת` (`resetToSingleShipment`). Primary: enabled `שמור תכנון` when all assigned, else disabled `אי אפשר לשמור — <N> פריטים לא משויכים` (`finalizeShipPlanner`).

### `renderShipCard(s,idx)` `[L18609-18659]`
Header `📦 משלוח <idx+1>` + (if >1) `הסר משלוח` (`removeShipment(s.id)`). Sections:
- `מועד אספקה` — 5 `DELIVERY_SLOTS` buttons (`<day>`/`<window>`), active `on`, `setShipSlot(id,si)`.
- `יעד` — `<select>` over PROJECTS: `<p.name>[ · <p.addr>]`, `setShipSite(id,value)`.
- `סוג רכב` — 3 `HAUL_TYPES` buttons `<ic> <name>[ +₪<extra>]`, active `on`, `setShipHaul(id,'<id>')`.
- Items row: `<#lines> סוגי פריט · <qtySum> יח׳ סה״כ` + `בחר פריטים ›` (`openShipItems(s.id)`).
- Preview (first 5 lines): chip `<name truncated 17ch + …> ×<qty>[ / <cartQty>]` (partial shown when `l.qty<cartQty`); `+<extra>` chip if >5. Empty: `אין פריטים — הקש "בחר פריטים"`.

### `setShip*` mutations `[L18662-18706]`
- `setShipSlot(id,si)` `[L18662]`: `s.slot=si`, re-render.
- `setShipSite(id,siteId)` `[L18666]`: `s.siteId=siteId` (no re-render — it's a `<select>`).
- `setShipHaul(id,h)` `[L18670]`: `s.haul=h`, re-render.
- `addShipment()` `[L18674]`: new id = max+1, `{id,slot:0,siteId,haul:'small',lines:[]}`.
- `removeShipment(id)` `[L18681]`: refuses below 1 (`חייב להישאר משלוח אחד`); re-homes orphan lines onto shipment #1 (merging qty when the line already exists there — no silent loss).
- `assignRemainingTo(shipId)` `[L18698]`: for each unassigned, `setShipLineQty(s, idx, cur+remaining)`.
- `setShipFilter(v)` `[L18878]` / `setShipCat(c)` `[L18879]`: update filter, re-render picker.
- `setShipLineQty` / `bumpShipQty` / `setShipQty` — see claimable above.

### `resetToSingleShipment()` `[L18707-18720]`
Cart → `cartShipments=null`. Order → clear `o.shipments/splitInto/splitPlan`, save. Close overlay, re-render all views. Toast `תכנון הפיצול בוטל — אספקה אחת לכל ההזמנה`.

### `finalizeShipPlanner()` `[L18721-18785]`
Blocks if unassigned (toast `<N> פריטים עדיין לא משויכים`). **Cart context**: if `ships<=1` set `cartShipments=null`; close, re-render cart; toast `תכנון נשמר · ההזמנה תגיע ב-<N> גלים` or `תכנון נשמר · אספקה אחת`. **Order context** `[L18735-18784]`: expand `o.lines` into per-claim lines so `splitPlan` keeps one-value-per-line; rewrite `sh.lines` idx + mirror `sh.lineIdx`; set `o.splitInto`, `o.splitNoticeNew=true`; save; push notification `הזמנה <id> פוצלה ל-<N> משלוחים` (detail title `תכנון אספקה עודכן`); toast `תכנון אספקה עודכן · הספק והשליח עודכנו ✓`; re-render manager/store/courier.

### Item picker — `renderShipItems()` `[L18803-18876]`
Head `📦 בחר פריטים למשלוח <idx+1>`; sub `חיפוש, סינון לפי ספק, ובחירה קבוצתית — מתאים גם להזמנות גדולות.`. Search input `🔎 חיפוש שם פריט…`. Category chips: `הכל (<all>)` + one per `shipCategoryOf` (= supplier name, else `אחר`) `(<count>)`. Bulk row: `✓ בחר את כל המוצגים` (`shipBulkSelectVisible`) / `נקה מהמשלוח` (`shipBulkClearHere`). List rows: checkbox (disabled if claimable 0); name + badge `×<takenElsewhere> במשלוחים אחרים`; meta `בסל ×<cartQty>[ · ₪<price*cartQty>] · ניתן לקחת כאן עד ×<claimable>`; if checked & cartQty>1, qty stepper (`−` / number `min 0 max claimable` / `+`) + `יח׳ במשלוח זה`. Empty: `אין פריטים תואמים לחיפוש / סינון`. Done: `סיים` (close + `renderShipPlanner`).

### Cart strip — `renderCartShipPlan()` `[L18937-18974]`
Single: `🚚 אספקה אחת · <day> <window>[ · <projectName>]` + `חלק לגלים ›`. Split: `🚚 ההזמנה תגיע ב-<N> גלים`[ + ` · <u> פריטים לא משויכים` in red] + `ערוך ›`. Both call `openCartShipPlanner`.

---

## 7. RFQ · RMA · Rental · Deposits · MSDS

Shared helpers `[L18442-18445]`: `caMoney(n)=fMoney(n)='₪'+Math.round(n||0).toLocaleString()`; `caToday()=new Date().toLocaleDateString('he-IL')`; `caEsc(s)` escapes quotes; `closeOverlayById(id)`. Lists `[L18427]`: `let rmaList=[], toolRentals=[], depositLedger=[]`. `rfqList=[]` `[L19228]`. Hub render `renderSupplyHub()` `[L19220]` = RMA + rental + deposit + RFQ lists.

### RMA — returns / credit `[L18976-19037]`
`openRMA(orderId)` `[L18978]`: `rmaDraft={orderId,items:[],reason:'עודף שלא נוצל'}`. Head `↩️ בקשת החזרה / זיכוי`; sub `[הזמנה <id> — ]סמן פריטים להחזרה וקבל זיכוי.`. Per line: checkbox + `<name> · עד <qty> יח׳` (`toggleRMAItem(i,name,maxQty)`). No lines → `לא נמצאו פריטים — ניתן לפתוח בקשת החזרה כללית.`. Reason `<select id=rmaReason>` options: `עודף שלא נוצל`, `פריט פגום`, `נשלח בטעות`, `שינוי בתכנון`. Button `שלח בקשת החזרה`.
`toggleRMAItem` `[L19002]`: toggle `{idx,name,qty:maxQty}` in draft.
`submitRMA()` `[L19008]`: empty → `יש לסמן לפחות פריט אחד להחזרה`; id `RMA-<1000+len+1>`; unshift `{id,orderId,items,reason,status:'ממתינה לאישור',createdAt:caToday()}`; push notif; toast `בקשת החזרה <id> נשלחה ✓`.
`renderRMAList()` `[L19024]`: empty `אין בקשות החזרה פעילות`; card `<id>` + pill `<status>`, sub `[הזמנה <id> · ]<#items> פריטים · <reason>`, `📅 <date>`.

### Tool rental `[L19039-19098]` + `RENTAL_TOOLS` `[L18428-18435]`

| id | name | ic | perDay (₪) |
|----|------|----|----------|
| mixer | מערבל בטון | 🛢️ | 120 |
| hammer | פטיש חשמלי | 🔨 | 75 |
| scaffold | פיגום נייד | 🪜 | 90 |
| laser | מאזנת לייזר | 📏 | 55 |
| genset | גנרטור 5kW | ⚡ | 140 |
| cutter | מסור דיסק לבטון | ⚙️ | 85 |

`openToolRental()` `[L19040]`: head `🔧 השכרת כלי עבודה`; sub `בחר כלי, קבע מספר ימים — חיוב יומי ומעקב החזרה.`; grid of tools `<ic><name> <₪perDay> / יום`.
`startRental(toolId)` `[L19054]`: `prompt('כמה ימי השכרה עבור "<name>"?','3')`; `days=max(1,int)`; due = now + days·86400000 ms; unshift `{id:'RNT-<100+len+1>',toolId,name,ic,days,perDay,total:days*perDay,startStr,dueStr (he-IL),dueTs,status:'מושכר'}`; notif; toast `<name> הושכר ל-<days> ימים ✓`.
`returnRental(rentalId)` `[L19074]`: `status='הוחזר'`; toast `<name> סומן כהוחזר ✓`.
`renderRentalList()` `[L19081]`: empty `אין השכרות פעילות`; overdue = `status==='מושכר' && now>dueTs` (card `.overdue`, pill `באיחור` danger); card `<ic> <name>` + pill, `<days> ימים · <₪total> · להחזרה עד <dueStr>`, button `סמן כהוחזר` or `✓ הוחזר`.

### Deposits `[L19100-19156]` + `DEPOSIT_ITEMS` `[L18436-18441]`

| id | name | ic | deposit (₪) |
|----|------|----|-----------|
| pallet | משטח עץ | 🟫 | 45 |
| cylinder | בלון גז | 🛢️ | 220 |
| frame | תבנית יציקה | 🔲 | 380 |
| crate | ארגז ציוד מושאל | 📦 | 160 |

`openDeposits()` `[L19101]`: head `💰 פקדונות על ציוד`; sub `פקדון נגבה על משטחים, בלונים וציוד יקר — ומוחזר עם החזרת הפריט.`; grid `<ic><name> פקדון <₪deposit>`.
`addDeposit(itemId)` `[L19115]`: `prompt('כמה יחידות של "<name>"?','1')`; `qty=max(1,int)`; unshift `{id:'DEP-<100+len+1>',itemId,name,ic,qty,unit:deposit,total:qty*deposit,status:'מוחזק',createdAt}`; toast `פקדון <₪total> נרשם עבור <name>`.
`refundDeposit(depId)` `[L19127]`: `status='הוחזר'`; notif `החזר פקדון`; toast `פקדון <₪total> הוחזר ✓`.
`renderDepositList()` `[L19139]`: empty `אין פקדונות פעילים`; header `סך פקדונות מוחזקים: <₪held>` (held = Σ total of `status==='מוחזק'`); card `<ic> <name>` + pill `<status>`, `<qty> יח׳ · פקדון <₪total> · 📅 <date>`, button `החזר ציוד וזכה פקדון` or `✓ הפקדון הוחזר`.

### MSDS safety sheets `[L19419-19450]` + `MSDS_SHEETS` `[L19230-19246]`

| id | name | ic | hazard | risk | handling | firstAid |
|----|------|----|--------|------|----------|----------|
| cement | מלט פורטלנד | 🏗️ | מגרה — אבק | גבוה | מסכה ומשקפי מגן. להימנע ממגע עם עור לח. | שטיפה במים זורמים 15 דק׳. פנייה לרופא במגע עם עין. |
| solvent | ממס אקרילי | 🧪 | דליק · רעיל בשאיפה | גבוה מאוד | אוורור מלא. הרחקה ממקור אש. כפפות ניטריל. | הוצאה לאוויר צח. לא לעורר הקאה אם נבלע — פנייה מיידית. |
| epoxy | דבק אפוקסי דו-רכיבי | 🪣 | מגרה · אלרגן | בינוני | כפפות וביגוד מגן. ערבוב באזור מאוורר. | הסרת ביגוד מזוהם. שטיפה ביסודיות. פנייה לרופא בתגובה עורית. |
| silica | אבקת סיליקה | ⚠️ | מסוכן לנשימה ממושכת | גבוה | מסכת P3 חובה. עבודה רטובה להפחתת אבק. | הרחקה מהאזור. במצוקה נשימתית — חמצן ופינוי רפואי. |
| lime | סיד בנייה | 🪨 | צורב — בסיסי חזק | בינוני | משקפי מגן וכפפות. למנוע מגע עם עור ועיניים. | שטיפה ממושכת במים. פנייה לרופא בכוויה כימית. |

`openMSDS()` `[L19420]`: head `🧪 גיליונות בטיחות (MSDS)`; sub `מידע בטיחות לחומרים מסוכנים — טיפול, סיכונים ועזרה ראשונה.`; list of buttons `<ic> <name>` + risk badge (class `risk-x` if "מאוד", `risk-h` if "גבוה", else `risk-m`) showing `<risk>` (`showMSDSDetail(id)`).
`showMSDSDetail(id)` `[L19436]`: head `<ic> <name>`; sub `גיליון בטיחות — דרגת סיכון: <risk>`; three blocks: `⚠️ סיווג סיכון`→hazard, `🧤 הנחיות טיפול`→handling, `🚑 עזרה ראשונה`→firstAid; back button `‹ חזרה לרשימה` (`openMSDS`).

### Supplier RFQ `[L19355-19417]`
`openRFQ()` `[L19357]`: `rfqDraft={product:'',qty:1,suppliers:['מחסני אינסטלציה תל-אביב','ספקי סניטריה השרון','חומרי בניין הרצליה']}`. Head `📨 מכרז ספקים מהיר (RFQ)`; sub `שלח בקשת הצעת מחיר לכל הספקים בו-זמנית וקבל הצעות תוך דקות.`. Field `מה דרוש?` input `לדוגמה: 200 שק מלט`. `ספקים שיקבלו את הבקשה` → `✓ <supplier>` rows. Button `שלח בקשת הצעות`.
`submitRFQ()` `[L19375]`: empty product → `יש לפרט מה דרוש`; id `RFQ-<500+len+1>`; demo `base=400+rand(600)`; quotes per supplier `{supplier, price:round(base*(0.9+i*0.08)), eta:'<i+1> ימי עבודה'}` sorted ascending; unshift `{id,product,status:'התקבלו הצעות',quotes,createdAt}`; notif lists cheapest; toast `מכרז <id> נשלח — התקבלו <N> הצעות ✓`.
`renderRFQList()` `[L19399]`: empty `אין מכרזים פעילים`; card `<id>` + pill `<status>`, `<product> · 📅 <date>`, quote rows `[🏆 ]<supplier> <₪price> <eta>` (first = `best`).

---

## 8. Pricing tools

### Dekel price compare — `openPriceCompare(productName)` `[L19328-19353]`
Head `📊 השוואת מחירים`; sub `<productName|מוצר> — מחירון דקל מול הצעות הספקים.`; server note `⚙️ נתוני מחירון דקל מסונכרנים מהשרת — כאן הדגמה`. `base=900+rand(400)`. Demo rows sorted by price:
- `מחירון דקל` → base (note `מחיר רשמי`)
- `מחסני אינסטלציה תל-אביב` → round(base·0.94) (note `-6%`)
- `ספקי סניטריה השרון` → round(base·1.03) (note `+3%`)
- `חומרי בניין הרצליה` → round(base·0.97) (note `-3%`)

Cheapest row gets `🏆 ` + `best`. Footer `חיסכון מול דקל: <₪(max-min)>`.

### Bulk discount calculator `[L21005-21034]` + `BULK_TIERS` `[L20734-20739]`

| tier (min qty) | discount |
|----------------|----------|
| 1 | 0% (full price) |
| 20 | 5% |
| 50 | 9% |
| 100 | 14% |

`portalBulk()` `[L21006]`: head `📉 הנחות כמות`; sub `מדרגות הנחה אוטומטיות — ככל שמזמינים יותר, המחיר ליחידה יורד.`. Rows: range `<min>–<next.min-1> יח׳` (last = `<min>+ יח׳`) → `[-<discount>% | מחיר מלא]`. Calc input `בדוק הנחה לכמות` (default 50).
`updateBulkCalc()` `[L21026]`: pick highest tier where `qty>=min`; output `<qty> יח׳ → הנחה של <discount>%`.

### FX calculator `[L19774-19806]` + `FX_RATES` `[L19482]`
`FX_RATES = { USD:3.72, EUR:4.05, GBP:4.71 }` (₪ per unit, demo).
`finFX()` `[L19774]`: head `💱 רכש במט״ח`; sub `שערי חליפין לרכש מספקים בחו״ל.`; server note `⚙️ שערי המט״ח מתעדכנים מהשרת — כאן מוצגים שערי דמו`. Rows `1 <cur>` → `₪<rate.toFixed(2)>`. Calc: amount input (default 1000) + select (`דולר אמריקאי (USD)`, `אירו (EUR)`, `לירה שטרלינג (GBP)`); result id `fxResult`.
`updateFXCalc()` `[L19797]`: `amt*rate` → `<amt> <cur> = ₪<round(amt*rate)>`.

### `STORE_PRICING` `[L11908-11912]` — per-store SKU price book
Three stores `store0` / `store1` / `store2`, each a `{ SKU: price }` map of ~200 Plasson/PEX SKUs. Same SKU costs differently per store (store1 cheapest, store2 dearest). Examples: `"870606075"` → store0:15, store1:14, store2:17; `"0712060500A"` → 70/64/78; `"0794L60500A"` → 64/59/72. `activeCatalogStore='store0'` `[L11916]` selects which store the catalog shows. `skuPrice(sku)` `[L11918]` → `STORE_PRICING[activeCatalogStore][sku] ?? 0`. `catalogProductPrice(key)` `[L11923]` → price of the chosen size's SKU. (Full SKU map is reproduced in source; port should load it verbatim as an asset/JSON.)

`STORES` `[L11930-11934]` — legacy display list (1:1 with s1/s2/s3): `מחסני אינסטלציה תל-אביב` (גוש דן, עד שעתיים), `ספקי סניטריה השרון` (השרון, עד שעתיים), `חומרי בניין הרצליה` (הרצליה והסביבה, עד שעה).

---

## 9. Credit & payment terms

### Cart credit (contractor side)
Global `creditLimit=50000` `[L11963]`, displayed/edited via `openCreditDetail`/`saveCreditLimit` (§3). Tied to `computeCheckout().grandTotal`.

### Per-contractor credit registry (manager side) `[L16537-16545]`
`CONTRACTOR_CREDIT={}` (demo). `contractorCredit(name)` `[L16538]`: lazily assigns a deterministic ceiling `30000 + (hash(name)%10)*10000` → **30k–120k** range, stable across renders.
`mgrCustomerList()` `[L16546-16564]`: derives each contractor live from `SYS_ORDERS` — `{name, orders, spent, credit:contractorCredit(name), pct:round(spent/credit*100), sites, status: pct>=90?'low':pct>0?'live':'off'}`, sorted by spend desc.
`renderMgrCustomers()` `[L16566-16607]`: summary `<N> קבלנים` / `₪<totalUsed> סך רכש` / `<pct>% ניצול אשראי`; search `חיפוש קבלן...`; status pills `אשראי גבוה`(low) / `לא פעיל`(off) / `פעיל`(live); credit bar (`hot` when pct>=90) `ניצול אשראי: ₪<spent> / ₪<credit> (<pct>%)`.
`mgrCustomerDetail(name)` `[L16609-16643]`: tag `⚠️ ניצול אשראי גבוה`/`לא פעיל`/`🟢 קבלן פעיל`; tiles `<orders> הזמנות`/`₪<spent> סך רכש`/`<pct>% אשראי`; rows `מסגרת אשראי`/`נוצל`/`יתרה זמינה`/`אתרי בנייה`; lists that contractor's orders with ORDER_STAGE badges.

### `PAYMENT_TERMS` `[L19461-19466]`

| id | name | days |
|----|------|------|
| now | מזומן / מיידי | 0 |
| net30 | שוטף + 30 | 30 |
| net60 | שוטף + 60 | 60 |
| milestone | לפי אבני דרך | null |

`activePaymentTerm='net30'` `[L19467]`. `finPayTerms()` `[L19545]`: head `🗓️ תנאי תשלום`; sub `בחר את תנאי התשלום של הפרויקט — משפיע על מועדי החיוב.`; per term, due string = `משולם בכל אבן דרך` (null) / `תשלום מיידי` (0) / `התשלום מתבצע <days> יום מקבלת החשבונית`. `setPaymentTerm(id)` `[L19561]`: toast `תנאי התשלום עודכנו: <name>`. (Note: the cart's credit box hard-codes "שוטף +60" regardless of `activePaymentTerm`.)

> Adjacent finance-hub data the port may need: `subcontractors` `[L19469]` (3, allocated/spent), `approvalQueue` `[L19475]` (AP-201/202), `BUILD_INDEX` `[L19459]` `{base:121.3,current:128.7,label:'מדד תשומות הבנייה'}`, `SUPPLIER_RATINGS` `[L20741]` (s1 4.7/182/96%, s2 4.4/140/91%, s3 4.1/97/88%). Manager express edit: `mgrEditExpress()` `[L16845]` `prompt('תוספת משלוח אקספרס (₪):',EXPRESS_FEE)` → sets `EXPRESS_FEE`, toast `תוספת האקספרס עודכנה — ₪<n>`.

---

## 10. Government XML export `[L19285-19325]`

`openGovExport(orderId)` `[L19286]`: order = `SYS_ORDERS.find(id)` or `SYS_ORDERS[0]`. Head `🗂️ ייצוא XML — מבנה אחיד`; sub `הפקת קובץ במבנה האחיד (מבנה 1.31) לדיווח לרשויות.`; server note `⚙️ השידור לשער הממשלתי מתבצע בשרת — כאן מופק הקובץ להורדה`. Preview = escaped XML. Button `⬇️ הורד קובץ XML` (`downloadGovXML`).

### `buildGovXML(o)` — EXACT format `[L19298-19311]`
```
id  = o.id || '—'
sum = o.sum || 0
vat = Math.round(sum * 0.18)         // hard-coded 18% on the order's pre-VAT sum
```
Output (literal, `\n`-separated):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Movein>
  <DocumentNumber>{id}</DocumentNumber>
  <DocumentType>305</DocumentType>
  <DocumentDate>{caToday()}</DocumentDate>
  <TotalBeforeVAT>{sum}</TotalBeforeVAT>
  <VATAmount>{vat}</VATAmount>
  <TotalWithVAT>{sum + vat}</TotalWithVAT>
</Movein>
```
Notes: root element `<Movein>`; `DocumentType` fixed `305`; `DocumentDate` is `he-IL` locale date string (e.g. `28.5.2026`); this is the Israeli Tax Authority "מבנה אחיד" (uniform structure) v1.31 shape. `o.sum` is already VAT-inclusive in seed orders, but `buildGovXML` treats it as pre-VAT — a prototype simplification to carry through.

### `downloadGovXML(orderId)` `[L19312-19325]`
Builds XML, creates a `Blob` (`application/xml`), object-URL, programmatic `<a download="<o.id>.xml">.click()`, revokes URL. Success toast `קובץ XML הופק ✓`; unsupported env → `הורדת הקובץ אינה נתמכת בסביבה זו`.

---

## 11. Digital signature & delivery note

### Signature pad `[L19158-19217]`
`sigPad = {canvas,ctx,drawing,dirty,targetOrderId}` `[L19159]`.
`openSignature(orderId)` `[L19160]`: set target, show `#signatureOverlay`, `setTimeout(initSignaturePad,30)`.
`initSignaturePad()` `[L19166]`: canvas `#sigCanvas`, width `max(280, rect.width||300)`, height 160; ctx `lineWidth=2.5, lineCap/lineJoin='round', strokeStyle='#10243a'`. Pointer math `pos(ev)` scales client coords to canvas coords for both mouse and touch. Binds mousedown/move/up/leave + touchstart/move/end (once via `_sigBound`). Drawing sets `dirty=true`.
`clearSignature()` `[L19194]`: `clearRect`, `dirty=false`.
`saveSignature()` `[L19200]`: not dirty → toast `נא לחתום על המסך לפני אישור`; else `dataUrl=canvas.toDataURL('image/png')`; if target order, set `o.signature=dataUrl`, `o.signedAt=caToday()`, `o.podSigned=true`, save; notif `תעודת משלוח נחתמה[· <id>]` (detail `חתימה דיגיטלית`, lines `המסירה אושרה בחתימה דיגיטלית.`/`תאריך: <today>`); toast `החתימה נשמרה — המסירה אושרה ✓`; re-render orders.

> The brief's `SIG` refers to no commerce constant — the signature is stored as `o.signature`/`o.podSigned`. (`SIG` at `[L15004]`/`[L15179]` are unrelated test-harness button-contract maps.) The supplier order card shows pill `o.podSigned ? 'נחתם ✓' : 'ממתין'` `[L20853]`.

### Delivery note (תעודת משלוח) `[L17208-17288]`
`showDeliveryNote(orderId, returnScreen='screen-store')` `[L17212]`: order from SYS_ORDERS; lines = `o.lines` or `[{name:'<items> פריטים',qty:1}]`; `today=he-IL date`. Builds a print-style A4 document:
- Header: brand block `BS` / `BuildSmart` / `רכש חומרי בנייה`; meta `תעודת משלוח` / `<o.id>` / `תאריך: <today>`.
- Parties: `לקוח` → `<o.who|—>`; `כתובת מסירה` → `<o.site|—>`; `סטטוס` → `<ORDER_STAGE[stage].label>`.
- Table headers: `# | פריט | כמות | מחיר יח׳ | סה״כ`. Per line: index, name, qty, unit (`storeItemInfo(name).price` else `—`), line sum (`₪<unit*qty>` else `—`). `total = Σ line sums`.
- Totals: `סכום ביניים` → `₪<total>`; `מע״מ 18%` → `₪<round(total*0.18)>`; grand `סה"כ לתשלום` → `₪<total+vat>`.
- Signatures: two boxes `חתימת המקבל` / `חתימת השליח`.
- Footer: `מסמך הופק על ידי מערכת BuildSmart · <today>`.
- `showScreen('screen-delivery-note')`.

`#screen-delivery-note` markup `[L4311-4318]`: bar with `‹ סגור` (`closeDeliveryNote`), title `תעודת משלוח`, `🖨️ הדפסה` (`window.print()`), scroll body `#deliveryNoteBody`.
`closeDeliveryNote()` `[L17280]`: if return is `app`, `enterApp()` + `go('orders')`; else `showScreen(deliveryNoteReturn)`.
Print CSS `[L3923-3940]`: `@page{size:A4;margin:14mm}`; hides everything except `#screen-delivery-note`; hides `.dn-bar`; avoids page-breaks inside table rows / signature.

### Delivery-note photo + OCR — `openDocScan(orderId)` `[L19248-19283]`
Head `📷 צילום תעודת משלוח`; sub `צלם את תעודת המשלוח הפיזית — המערכת תקלוט את הפרטים אוטומטית.`; note `⚙️ קליטת הטקסט (OCR) מתבצעת בשרת — כאן מוצגת הדגמה`; scan frame `📄 מסגרת הצילום`; button `📷 צלם וקלוט תעודה` (`runDocOCR`). `runDocOCR(orderId)` `[L19260]` simulates extraction `{docNo:o.id|BS-<1000+rand>, date:caToday(), supplier, items}`, stores `o.docScanned=true`/`o.docScanData`, shows result rows `מספר תעודה`/`תאריך`/`ספק`/`פריטים`, button `שמור וסגור`, toast `תעודת המשלוח נקלטה ✓`.

---

## → Flutter port notes

**What the Flutter port has today (very little of this domain):**
- `lib/state/smart_cart.dart` — `SmartCartNotifier` (`smartCartProvider`): a per-product accessory cart. `SmartCartLine{productKey, productName, productEmoji, brandName, brandPrice, productQty, accessories:[SmartCartAcc{name,emoji,price,qty}]}`; `total = brandPrice*productQty + Σ acc.price*acc.qty`. Persisted to SharedPreferences (`bs.smart-cart.v1`). add/remove/setLineQty/qtyForKey/setQtyForKey/clear.
- `lib/state/cart_lists_state.dart` — `cartListsProvider`: named saved shopping lists (`CartList{id,name,items:[(emoji,name,qty,price)],createdAt}`), persisted. Pure list management, no pricing.
- `lib/screens/suppliers_screen.dart` — a 113-line stub: one supplier tile (`ליפסקי ברקן`) linking to a brand screen. No SUPPLIER_STORES model, no shipping fees.
- `lib/data/sections.dart` `[L86-88]` — haul types appear only as **dial menu labels** (`haul-small` 🛵 משלוח קטן, `haul-van` 🚐 טנדר, `haul-truck` 🚛 משאית); no `extra` fees, no checkout wiring.

**What is entirely ABSENT in Flutter (must be built for parity):**
- **No checkout pricing at all** — no `computeCheckout` equivalent, no `VAT_RATE` (18%), no `EXPRESS_FEE`, no per-supplier shipping, no haul extras, no split-billing per wave, no `expressDelivery`, no taxable/grand-total math. The two carts only sum item totals.
- **No supplier model** — no `SUPPLIER_STORES` (s1/s2/s3 with shipping & eta), no `CATEGORY_STORE` routing, no `assignStore` hashing, no `STORE_PRICING` SKU price book.
- **No orders subsystem** — no `localOrders`/`SYS_ORDERS`, no `ORDER_STATUS`/`ORDER_STAGE`/`ORDER_FLOW`, no `renderMyOrders`/`orderCard`/`toggleOrder`, no `DEMO_HISTORY`/reorder, no `checkout()` placement, no `syncOrderToSystem` bridge, no shipment status tracker, no two-way stage sync.
- **No shipping planner** — none of `cartShipments`, the `lines=[{idx,qty}]` split model, the `claimable` invariant, the item picker, slot/site/haul pickers, or the cart ship-plan strip exist.
- **No B2B supply-chain tools** — no RFQ, RMA, tool rental, deposits, MSDS, Dekel price-compare, bulk-discount calc, or FX calc (data tables `RENTAL_TOOLS`, `DEPOSIT_ITEMS`, `MSDS_SHEETS`, `BULK_TIERS`, `FX_RATES`, `PAYMENT_TERMS` all unported).
- **No credit/payment** — no cart `creditLimit`, no `CONTRACTOR_CREDIT`/`contractorCredit`, no `PAYMENT_TERMS`.
- **No documents** — no government XML export (`buildGovXML`/`Movein`/DocumentType 305/מבנה 1.31), no digital signature pad, no delivery note (תעודת משלוח) print document, no OCR doc-scan.

**Port guidance:**
- Lift `computeCheckout` verbatim into a pure Dart function (already DOM-free, unit-testable) and reuse its `testCheckoutLayout` checks as Dart tests. Keep `VAT_RATE`, `EXPRESS_FEE`, `creditLimit`, `SUPPLIER_STORES`, `HAUL_TYPES`, `DELIVERY_SLOTS` as a single config source.
- The shipping planner's `lines=[{idx,qty}]` + `claimable` invariant is the trickiest logic — model shipments as `{id, slot, siteId, haul, lines:[(idx,qty)]}` and enforce `claimable = cartQty - takenElsewhere` on every mutation, exactly as `setShipLineQty`/`bumpShipQty`/`setShipQty`/`toggleShipItem` do.
- Per R2 (no full-screen views), the prototype's overlays (planner, RFQ, RMA, rental, deposits, MSDS, price-compare, gov XML, signature) should each map to a **dial / sheet**, not a screen — except the delivery note, which is intentionally a full print document (`screen-delivery-note`) and the one legitimate full-screen surface here.
- Money format is universally `'₪' + Math.round(n).toLocaleString()` (Hebrew thousands separators); replicate with an intl `NumberFormat` for `he_IL`.
- All Hebrew strings above are verbatim from the prototype and must be copied exactly (R6).
