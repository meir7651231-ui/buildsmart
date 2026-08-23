# _CourierIdentityCard

- **screen:** `courier_profile_screen`
- **role:** section

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **cfgVisible** · `courier_profile_screen.demo_chip` ✅
- **cfgText** "דמו" · `courier_profile_screen.demo_chip` ✅
- **text** "🛵" · — לא-רשום

## חיבורים · connections (1)

- **action** · `showCourierProfileEditSheet` → `showCourierProfileEditSheet`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showCourierProfileEditSheet(context, session: session)` → open → showCourierProfileEditSheet

## floor · external functions (3)

- `cfgRadius`
- `haulInfo`
- `imageProviderForRef`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `session` · `profile`
- **gaps:** 1 unregistered — "🛵"
