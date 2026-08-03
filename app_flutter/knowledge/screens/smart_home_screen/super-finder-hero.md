# _SuperFinderHero

- **screen:** `smart_home_screen`
- **role:** section · section `superFinder` · preview

## עצם · object (2)

> registry 0 · mapped 0/0 · **unregistered 2**

- **text** "🕸️ מאתר-על" · — לא-רשום
- **text** "גלגל-חיפוש-על — בחר מאיזה ציר להתחיל" · — לא-רשום

## חיבורים · connections (3)

- **writes** · `state=` → `mainTabProvider`
- **writes** · `state=` → `catalogSectionProvider`
- **writes** · `state=` → `keyboardDiveQueryProvider`

## התנהגות · behaviour (3)

- **onTap** → _verb_ `ref.read(mainTabProvider.notifier).state = 0` → write → mainTabProvider
- **onTap** → _verb_ `ref.read(catalogSectionProvider.notifier).state = 'מאתר-על'` → write → catalogSectionProvider
- **onTap** → _verb_ `ref.read(keyboardDiveQueryProvider.notifier).state = ''` → write → keyboardDiveQueryProvider

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onCatalogSection(…) callback instead of direct catalogSectionProvider write
  - onKeyboardDiveQuery(…) callback instead of direct keyboardDiveQueryProvider write
  - onMainTab(…) callback instead of direct mainTabProvider write
- **gaps:** 2 unregistered — "🕸️ מאתר-על" · "גלגל-חיפוש-על — בחר מאיזה ציר להתחיל"
