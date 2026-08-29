# StockScreen

- **screen:** `stock_screen`
- **role:** composer

## עצם · object (4)

> registry 3 · mapped 3/3 · **unregistered 1**

- **cfgText** "המלאי שלי" · `stock_screen.t01` ✅
- **text** "📥" · — לא-רשום
- **cfgText** "📦 המלאי שלי" · `stock_screen.t02` ✅
- **cfgText** "💡 כשתסמן פריט כ"במחסן" או "באתר" בעץ המוצרים — הוא יופיע כאן." · `stock_screen.t03` ✅

## חיבורים · connections (6)

- **reads** · `watch` → `stockTabProvider`
- **reads** · `watch` → `stockProvider`
- **action** · `showContractorMaterialRequestsSheet` → `showContractorMaterialRequestsSheet`
- **writes** · `state=` → `stockTabProvider`
- **reads** · `read` → `stockProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (3)

- **onPressed** → _verb_ `showContractorMaterialRequestsSheet(context)` → open → showContractorMaterialRequestsSheet
- **onTap** → _verb_ `ref.read(stockTabProvider.notifier).state = 'warehouse'` → write → stockTabProvider
- **onTap** → _verb_ `ref.read(stockTabProvider.notifier).state = 'site'` → write → stockTabProvider

## floor · external functions (1)

- `kbStockNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** 1 unregistered — "📥"
