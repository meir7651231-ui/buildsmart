# _DeliveredCard

- **screen:** `courier_reports_tab`
- **role:** section

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **text** "📷" · — לא-רשום
- **cfgVisible** · `courier_reports_tab.t06` ✅
- **cfgText** "נמסר ✓" · `courier_reports_tab.t06` ✅

## חיבורים · connections (1)

- **action** · `showFullPhotoRefDialog` → `showFullPhotoRefDialog`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showFullPhotoRefDialog(context, widget.podPhoto, label: '📦 ${order.id} — איש…` → open → showFullPhotoRefDialog

## floor · external functions (3)

- `fMoney`
- `identical`
- `imageProviderForRef`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `order` · `podCaptured` · `podPhoto` · `deliveredAt`
- **gaps:** 1 unregistered — "📷"
