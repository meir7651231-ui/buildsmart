# _OrdersTab

- **screen:** `manager-dashboard`
- **role:** section

## עצם · object (9)

> registry 5 · mapped 5/5 · **unregistered 4**

- **cfgText** "לא נמצאו הזמנות תואמות." · `manager.orders.empty` ✅
- **cfgText** "✓ הושלם" · `manager_dashboard_screen.order_completed_badge` ✅
- **text** "📦" · — לא-רשום
- **cfgText** "✓ ההזמנה הושלמה ונמסרה" · `manager_dashboard_screen.order_completed_delivered` ✅
- **text** "🧾 הפק חשבונית" · — לא-רשום
- **text** "💵 הפק קבלה" · — לא-רשום
- **text** "📦 תעודת משלוח" · — לא-רשום
- **cfgVisible** · `manager.orders.advance` ✅
- **cfgText** "קדם שלב ›" · `manager.orders.advance` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `ordersEngineProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `ordersEngineProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **gated-by** · `guard` → `order == null`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (order == null)` → hidden (SizedBox.shrink)
- **onPressed** → _verb_ `showToast(context, 'הדפסה זמינה בדפדפן')` → toast

## floor · external functions (15)

- `bsOnAccent`
- `buildDeliveryNoteRows`
- `buildInvoiceRows`
- `buildPrintableHtml`
- `cfgRadius`
- `chip`
- `deliveryNoteTitle`
- `featEnabled`
- `invoiceTitle`
- `onSelect`
- `printDocument`
- `row`
- `setState`
- `stat`
- `tile`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 4 unregistered — "📦" · "🧾 הפק חשבונית" · "💵 הפק קבלה" · "📦 תעודת משלוח"
