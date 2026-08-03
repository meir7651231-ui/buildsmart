# StoreProfileBody

- **screen:** `store_profile_screen`
- **role:** composer

## עצם · object (4)

> registry 2 · mapped 2/2 · **unregistered 2**

- **text** "⚙️" · — לא-רשום
- **cfgText** "הגדרות ספק" · `store_profile_screen.settings_row` ✅
- **text** "🚪" · — לא-רשום
- **cfgText** "יציאה מהחשבון" · `store_profile_screen.logout_row` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `boardAuthProvider`
- **gated-by** · `guard` → `session == null || session.role != BoardRole.store`
- **reads** · `watch` → `storeProfileProvider.select((m) => m[session.username] ?? const StoreProfile())`
- **action** · `push` → `SupplierSettingsScreen`
- **reads** · `read` → `boardAuthProvider`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (session == null || session.role != BoardRole.store)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `Navigator.of(context).push(SupplierSettingsScreen.route())` → navigate → SupplierSettingsScreen

## floor · external functions (2)

- `cfgRadius`
- `confirmDestructive`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `standalone`
- **gaps:** 2 unregistered — "⚙️" · "🚪"
