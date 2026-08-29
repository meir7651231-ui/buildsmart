# _StoreIdentityCard

- **screen:** `store_profile_screen`
- **role:** section

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **cfgVisible** · `store_profile_screen.demo_chip` ✅
- **cfgText** "דמו" · `store_profile_screen.demo_chip` ✅
- **text** "🏪" · — לא-רשום

## חיבורים · connections (1)

- **action** · `showStoreProfileEditSheet` → `showStoreProfileEditSheet`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showStoreProfileEditSheet(context, session: session)` → open → showStoreProfileEditSheet

## floor · external functions (2)

- `cfgRadius`
- `imageProviderForRef`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `session` · `profile`
- **gaps:** 1 unregistered — "🏪"
