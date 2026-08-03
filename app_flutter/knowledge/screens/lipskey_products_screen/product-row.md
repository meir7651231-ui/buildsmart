# _ProductRow

- **screen:** `lipskey_products_screen`
- **role:** section

## עצם · object (6)

> registry 3 · mapped 3/3 · **unregistered 3**

- **text** "✓" · — לא-רשום
- **cfgText** "מחיר לפי ספק" · `lipskey_products_screen.price_by_supplier_row` ✅
- **cfgText** "מק"ט הועתק" · `lipskey_products_screen.sku_copied` ✅
- **text** "+" · — לא-רשום
- **text** "‹" · — לא-רשום
- **cfgText** "מידה" · `lipskey_products_screen.size_label` ✅

## חיבורים · connections (10)

- **reads** · `read` → `catalogRepositoryProvider`
- **reads** · `read` → `smartCartProvider`
- **action** · `openSmartProductSheet` → `openSmartProductSheet`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **action** · `showDialog` → `showDialog`
- **reads** · `watch` → `catalogSettingsProvider.select((s) => s.compactMode)`
- **reads** · `watch` → `smartCartProvider.select((lines) => lines.where((l) => l.productKey == 'lip:${p.sku}').fold<int>(0, (s, l) => s + l.productQty))`
- **reads** · `watch` → `catalogSettingsProvider.select((s) => s.imageSize)`
- **action** · `showQtyWheel` → `showQtyWheel`
- **gated-by** · `guard` → `shown.isEmpty`

## התנהגות · behaviour (5)

- **onTap** → _verb_ `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: CfgText('lipskey…` → open → showSnackBar
- **build** → _formula_ `label = s == '+' ? … : …` → text: 'הוסף כמות' | 'הפחת כמות'
- **onTap** → _verb_ `showQtyWheel(context, _qty, _setQty)` → open → showQtyWheel
- **build** → _rule_ `if (shown.isEmpty)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `LipskeyProductsScreen.openWordSearch(context, w)` → open → openWordSearch

## floor · external functions (18)

- `bsOnAccent`
- `btn`
- `cb`
- `chipLabelDirection`
- `confirmDestructive`
- `displaySizeLabel`
- `findHierarchySiblings`
- `isSelected`
- `label`
- `max`
- `onTap`
- `opt`
- `parseChips`
- `parseSizeTokens`
- `productImage`
- `setState`
- `sort`
- `tokensFromDims`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `product` · `categoryProducts` · `familySiblings` · `onCycle` · `smartLens`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 3 unregistered — "✓" · "+" · "‹"
