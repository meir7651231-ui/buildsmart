# _StoreOrderCard

- **screen:** `store_dashboard_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "🕒 נדרש: בתיאום" · `store_dashboard_screen.t11` ✅
- **cfgText** "✓ תיקון בוצע — בדוק שינויים" · `store_dashboard_screen.t12` ✅

## חיבורים · connections (0)

_(no edges)_

## התנהגות · behaviour (1)

- **build** → _formula_ `splitTag = fulfillment.splitInto > 1 ? … : …` → text: ' · 🚚 הוכן ב-${fulfillment.splitInto} חבילות' | ''

## floor · external functions (4)

- `cfgRadius`
- `confirmDestructive`
- `fMoney`
- `onAdvance`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `order` · `fulfillment` · `onAdvance` · `onOpenPick`
- **gaps:** none (all registry-backed)
