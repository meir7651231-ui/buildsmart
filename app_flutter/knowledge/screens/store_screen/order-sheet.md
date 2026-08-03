# _OrderSheet

- **screen:** `store_screen`
- **role:** section

## עצם · object (10)

> registry 7 · mapped 7/7 · **unregistered 3**

- **text** "📍" · — לא-רשום
- **text** "📝" · — לא-רשום
- **cfgText** "פרטי הפריטים אינם זמינים" · `store_screen.order_no_items` ✅
- **cfgText** "סכום ביניים" · `store_screen.order_subtotal` ✅
- **cfgText** "מע"מ + משלוח" · `store_screen.order_vat_delivery` ✅
- **cfgText** "סה"כ" · `store_screen.order_total` ✅
- **cfgText** "🚛 מעקב הזמנה" · `shop.tracking.title` ✅
- **cfgVisible** · `store_screen.order_scan_delivery` ✅
- **text** "📄" · — לא-רשום
- **cfgText** "סרוק תעודת-משלוח" · `store_screen.order_scan_delivery` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `ordersEngineProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showToast(context, 'סריקת תעודת-משלוח (OCR) — בקרוב')` → toast

## floor · external functions (1)

- `bsOnAccent`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `order`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 3 unregistered — "📍" · "📝" · "📄"
