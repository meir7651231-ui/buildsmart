# _SmartTreeRow

- **screen:** `smart_home_screen`
- **role:** section · section `products`

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **text** "🌳 עץ חכם — אינסטלציה" · — לא-רשום
- **cfgVisible** · `smart_home_screen.add_to_cart` ✅
- **cfgText** "הוסף לסל" · `smart_home_screen.add_to_cart` ✅

## חיבורים · connections (3)

- **gated-by** · `const-flag` → `kSmartProducts.isEmpty`
- **writes** · `add` → `smartCartProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (4)

- **build** → _rule_ `if (kSmartProducts.isEmpty)` → hidden (SizedBox.shrink)
- **build** → _formula_ `priceLabel = rec.price == null ? … : …` → text: 'מחיר לפי ספק' | '₪${groupThousands(rec.price!)}'
- **onPressed** → _verb_ `ref.read(smartCartProvider.notifier).add(SmartCartLine(productKey: rec.sku ??…` → write → smartCartProvider
- **onPressed** → _verb_ `showToast(context, '${p.name} נוסף לסל')` → toast

## floor · external functions (3)

- `cfgRadius`
- `groupThousands`
- `productImage`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onSmartCart(…) callback instead of direct smartCartProvider write
- **gaps:** 1 unregistered — "🌳 עץ חכם — אינסטלציה"
