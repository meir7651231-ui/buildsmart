# LipskeyProductGridCard

- **screen:** `lipskey_products_screen`
- **role:** section

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **text** "✓" · — לא-רשום
- **cfgText** "מחיר לפי ספק" · `lipskey_products_screen.price_by_supplier_grid` ✅
- **cfgText** "לסל" · `lipskey_products_screen.to_cart` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `smartCartProvider`
- **reads** · `watch` → `smartCartProvider.select((lines) => lines.where((l) => l.productKey == _key).fold<int>(0, (s, l) => s + l.productQty))`
- **reads** · `watch` → `catalogSettingsProvider`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **action** · `showQtyWheel` → `showQtyWheel`

## התנהגות · behaviour (3)

- **onTap** → _verb_ `showLipskeyProductSheet(context, product, products)` → open → showLipskeyProductSheet
- **onTap** → _verb_ `showQtyWheel(context, qty, (n) => cart.setQtyForKey(_line(n)))` → open → showQtyWheel
- **build** → _formula_ `label = icon == Icons.add ? … : …` → text: 'הוסף כמות' | 'הפחת כמות'

## floor · external functions (2)

- `bsOnAccent`
- `productImage`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `product` · `products`
- **gaps:** 1 unregistered — "✓"
