# StoreSettingsScreen

- **screen:** `store_settings_screen`
- **role:** composer

## עצם · object (7)

> registry 7 · mapped 7/7 · **unregistered 0**

- **cfgText** "הגדרות חנות" · `store_settings_screen.screen_title` ✅
- **cfgText** "איפוס הגדרות?" · `store_settings_screen.reset_title` ✅
- **cfgText** "כל הגדרות החנות יוחזרו לברירת המחדל." · `store_settings_screen.reset_body` ✅
- **cfgVisible** · `store_settings_screen.cancel` ✅
- **cfgText** "ביטול" · `store_settings_screen.cancel` ✅
- **cfgVisible** · `store_settings_screen.reset_ok` ✅
- **cfgText** "אפס" · `store_settings_screen.reset_ok` ✅

## חיבורים · connections (3)

- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `storeSettingsProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `kbStoreSettingsNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
