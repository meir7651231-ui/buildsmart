# _StorePersonalAreaCard

- **screen:** `store_profile_screen`
- **role:** section

## עצם · object (9)

> registry 6 · mapped 6/6 · **unregistered 3**

- **text** "🏪" · — לא-רשום
- **cfgText** "פרופיל עסק" · `store_profile_screen.profile_row` ✅
- **cfgText** "שם, טלפון, כתובת, ח.פ. ולוגו" · `store_profile_screen.profile_row_sub` ✅
- **text** "🪪" · — לא-רשום
- **cfgText** "תעודות עסק" · `store_profile_screen.certs_row` ✅
- **cfgText** "רישיון עסק · ביטוח עסק" · `store_profile_screen.certs_row_sub` ✅
- **text** "🧾" · — לא-רשום
- **cfgText** "מסמכים" · `store_profile_screen.docs_row` ✅
- **cfgText** "יחובר עם חיבור השרת" · `store_profile_screen.docs_row_sub` ✅

## חיבורים · connections (3)

- **action** · `showStoreProfileEditSheet` → `showStoreProfileEditSheet`
- **action** · `push` → `StoreCertsScreen`
- **action** · `showStoreDocumentsSheet` → `showStoreDocumentsSheet`

## התנהגות · behaviour (3)

- **onTap** → _verb_ `showStoreProfileEditSheet(context, session: session)` → open → showStoreProfileEditSheet
- **onTap** → _verb_ `Navigator.of(context).push(StoreCertsScreen.route())` → navigate → StoreCertsScreen
- **onTap** → _verb_ `showStoreDocumentsSheet(context)` → open → showStoreDocumentsSheet

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `session`
- **gaps:** 3 unregistered — "🏪" · "🪪" · "🧾"
