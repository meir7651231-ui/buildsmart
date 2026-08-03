# _SuperFinderHero

- **screen:** `contractor-home`
- **role:** section · section `superFinder`

## עצם · object (2)

- **text** "🕸️ מאתר-על"
- **text** "גלגל-חיפוש-על — בחר מאיזה ציר להתחיל"

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
