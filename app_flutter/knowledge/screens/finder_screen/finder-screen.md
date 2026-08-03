# FinderScreen

- **screen:** `finder_screen`
- **role:** composer

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **cfgText** "לא נמצאו מוצרים" · `finder_screen.no_results` ✅
- **text** "💡" · — לא-רשום
- **cfgText** "צ׳יפ כתום על מוצר — הקש כדי להחליף גודל או צבע" · `finder_screen.chip_tip` ✅

## חיבורים · connections (3)

- **reads** · `watch` → `catalogSystemFilterProvider`
- **reads** · `watch` → `finderChipTipDismissedProvider`
- **writes** · `state=` → `finderChipTipDismissedProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(finderChipTipDismissedProvider.notifier).state = true` → write → finderChipTipDismissedProvider

## floor · external functions (11)

- `angleTokensIn`
- `catalogRepo`
- `chipLabelDirection`
- `filterBySystem`
- `identical`
- `letterSizeTokens`
- `narrowAxis`
- `productHasChip`
- `setState`
- `sort`
- `wallTokens`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onFinderChipTipDismissed(…) callback instead of direct finderChipTipDismissedProvider write
- **gaps:** 1 unregistered — "💡"
