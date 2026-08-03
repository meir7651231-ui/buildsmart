# _ProductPicker

- **screen:** `install_studio_screen`
- **role:** section

## עצם · object (5)

> registry 0 · mapped 0/0 · **unregistered 5**

- **text** "מה אתה מחפש?" · — לא-רשום
- **text** "או חפש ישירות בשדה החיפוש למעלה" · — לא-רשום
- **text** "לא נמצאו מוצרים" · — לא-רשום
- **text** "✓ כבר נוסף" · — לא-רשום
- **text** "הוסף" · — לא-רשום

## חיבורים · connections (3)

- **reads** · `read` → `catalogRepositoryProvider`
- **reads** · `watch` → `chainProvider`
- **writes** · `state=` → `chainProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(chainProvider.notifier).state = [...chain, p]` → write → chainProvider

## floor · external functions (3)

- `productImage`
- `productSuitableForTemp`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `lineTemp` · `initialCat`
- **untangle:**
  - onChain(…) callback instead of direct chainProvider write
- **gaps:** 5 unregistered — "מה אתה מחפש?" · "או חפש ישירות בשדה החיפוש למעלה" · "לא נמצאו מוצרים" · "✓ כבר נוסף" · "הוסף"
