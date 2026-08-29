# _Favorites

- **screen:** `contractor-home`
- **role:** section · section `favorites`

## עצם · object (2)

> registry 0 · mapped 0/0 · **unregistered 2**

- **text** "מועדפים" · — לא-רשום
- **text** "עדיין אין מועדפים — סמן ☆ על מוצר והוא יופיע כאן." · — לא-רשום

## חיבורים · connections (4)

- **reads** · `watch` → `productFavoritesProvider`
- **reads** · `watch` → `catalogRepositoryProvider`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **reads** · `read` → `catalogRepositoryProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showLipskeyProductSheet(context, p, ref.read(catalogRepositoryProvider).allPr…` → open → showLipskeyProductSheet

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 2 unregistered — "מועדפים" · "עדיין אין מועדפים — סמן ☆ על מוצר והוא יופיע כאן."
