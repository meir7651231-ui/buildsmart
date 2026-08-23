# LipskeyProductsList

- **screen:** `lipskey_products_screen`
- **role:** composer

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **text** "📦" · — לא-רשום
- **cfgText** "אין מוצרים להצגה" · `lipskey_products_screen.empty_title` ✅
- **cfgText** "נסו לבחור קטגוריה אחרת בקטלוג" · `lipskey_products_screen.empty_hint` ✅

## חיבורים · connections (3)

- **reads** · `read` → `catalogRepositoryProvider`
- **reads** · `watch` → `catalogLensProvider`
- **reads** · `watch` → `catalogSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `availableLensesForSet`
- `groupByLens`
- `resolveActiveLens`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `products`
- **untangle:**
  - CustomScrollView = shared component → separate atom
- **gaps:** 1 unregistered — "📦"
