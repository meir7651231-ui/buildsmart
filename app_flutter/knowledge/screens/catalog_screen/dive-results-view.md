# _DiveResultsView

- **screen:** `catalog_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "אין תוצאות תואמות" · `catalog_screen.t14` ✅
- **cfgText** "אין מוצרים תואמים" · `catalog_screen.t15` ✅

## חיבורים · connections (5)

- **gated-by** · `const-flag` → `kGlobalSearch`
- **reads** · `watch` → `diveResultsProvider`
- **reads** · `watch` → `keyboardDiveQueryProvider`
- **writes** · `state=` → `keyboardDiveQueryProvider`
- **action** · `push` → `LegalScreen`

## התנהגות · behaviour (3)

- **build** → _rule_ `if (kGlobalSearch)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: entry.title == 'תנאי…` → navigate → LegalScreen
- **onTap** → _verb_ `ref.read(keyboardDiveQueryProvider.notifier).state = entry.title` → write → keyboardDiveQueryProvider

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onKeyboardDiveQuery(…) callback instead of direct keyboardDiveQueryProvider write
- **gaps:** none (all registry-backed)
