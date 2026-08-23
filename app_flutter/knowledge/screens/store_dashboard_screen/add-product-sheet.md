# _AddProductSheet

- **screen:** `store_dashboard_screen`
- **role:** section

## עצם · object (4)

> registry 4 · mapped 4/4 · **unregistered 0**

- **cfgText** "➕ הוסף מוצר חדש" · `store.addProduct.title` ✅
- **cfgText** "קטגוריה" · `store.addProduct.category` ✅
- **cfgVisible** · `store.action.addProduct` ✅
- **cfgText** "➕ הוסף מוצר" · `store.action.addProduct` ✅

## חיבורים · connections (3)

- **reads** · `read` → `storeProductsProvider`
- **action** · `showToast` → `showToast`
- **writes** · `add` → `storeProductsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `cfgRadius`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
