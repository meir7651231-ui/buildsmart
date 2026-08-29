# _QuickActionsRow

- **screen:** `store_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (6)

- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **reads** · `watch` → `storeFavoritesProvider`
- **action** · `showToast` → `showToast`
- **gated-by** · `modOn` → `finance`
- **action** · `openFinanceHub` → `openFinanceHub`
- **writes** · `state=` → `storeSectionProvider`

## התנהגות · behaviour (6)

- **onTap** → _verb_ `showToast(context, 'אין פריטים מועדפים')` → toast
- **onTap** → _verb_ `openFinanceHub(context)` → open → openFinanceHub
- **onTap** → _verb_ `ref.read(storeSectionProvider.notifier).state = StoreSection.cart` → write → storeSectionProvider
- **onTap** → _verb_ `ref.read(storeSectionProvider.notifier).state = StoreSection.orders` → write → storeSectionProvider
- **onTap** → _verb_ `showToast(context, 'שיחה עם ${c.name} — בבנייה')` → toast
- **onTap** → _verb_ `showToast(context, '$label — בבנייה')` → toast

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onStoreSection(…) callback instead of direct storeSectionProvider write
- **gaps:** none (all registry-backed)
