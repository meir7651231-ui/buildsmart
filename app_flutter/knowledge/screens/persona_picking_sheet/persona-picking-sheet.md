# PersonaPickingSheet

- **screen:** `persona_picking_sheet`
- **role:** composer

## עצם · object (7)

> registry 7 · mapped 7/7 · **unregistered 0**

- **cfgText** "אין הזמנות בקטגוריה זו ✓" · `persona_picking_sheet.t01` ✅
- **cfgVisible** · `persona_picking_sheet.t02` ✅
- **cfgText** "📄 הצג תעודת משלוח" · `persona_picking_sheet.t02` ✅
- **cfgVisible** · `persona_picking_sheet.t03` ✅
- **cfgText** "🛵 ההזמנה מוכנה — ממתינה לאיסוף השליח" · `persona_picking_sheet.t03` ✅
- **cfgText** "סמן כל פריט כ"לוקט" או "חסר" כדי לסיים את ההכנה" · `persona_picking_sheet.t04` ✅
- **cfgText** "תעודת משלוח" · `persona_picking_sheet.t05` ✅

## חיבורים · connections (6)

- **reads** · `watch` → `sysOrdersProvider`
- **reads** · `watch` → `fulfillmentProvider`
- **reads** · `read` → `fulfillmentProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `sysOrdersProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `fMoney`
- `haulInfo`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `orderId`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
