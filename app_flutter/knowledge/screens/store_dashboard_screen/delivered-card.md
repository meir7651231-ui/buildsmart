# _DeliveredCard

- **screen:** `store_dashboard_screen`
- **role:** section

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **cfgVisible** · `store_dashboard_screen.t13` ✅
- **cfgText** "נמסר ✓" · `store_dashboard_screen.t13` ✅
- **text** "📷" · — לא-רשום

## חיבורים · connections (1)

- **action** · `showFullPhotoRefDialog` → `showFullPhotoRefDialog`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showFullPhotoRefDialog(context, fulfillment.podPhoto, label: '📦 ${order.id} …` → open → showFullPhotoRefDialog

## floor · external functions (3)

- `cfgRadius`
- `fMoney`
- `imageProviderForRef`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `order` · `fulfillment` · `onTap`
- **gaps:** 1 unregistered — "📷"
