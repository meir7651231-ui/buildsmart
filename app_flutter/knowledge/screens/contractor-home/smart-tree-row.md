# _SmartTreeRow

- **screen:** `contractor-home`
- **role:** section · section `products`

## עצם · object (3)

- **text** "🌳 עץ חכם — אינסטלציה"
- **cfgVisible** · `smart_home_screen.add_to_cart` ✅
- **cfgText** "הוסף לסל" · `smart_home_screen.add_to_cart` ✅

## חיבורים · connections (3)

- **gated-by** · `const-flag` → `kSmartProducts.isEmpty`
- **writes** · `add` → `smartCartProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (3)

- **build** → _rule_ `if (kSmartProducts.isEmpty)` → hidden (SizedBox.shrink)
- **onPressed** → _verb_ `ref.read(smartCartProvider.notifier).add(SmartCartLine(productKey: rec.sku ??…` → write → smartCartProvider
- **onPressed** → _verb_ `showToast(context, '${p.name} נוסף לסל')` → toast

## floor · external functions (3)

- `cfgRadius`
- `groupThousands`
- `productImage`
