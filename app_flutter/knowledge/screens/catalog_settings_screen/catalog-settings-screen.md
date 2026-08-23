# CatalogSettingsScreen

- **screen:** `catalog_settings_screen`
- **role:** composer

## עצם · object (7)

> registry 7 · mapped 7/7 · **unregistered 0**

- **cfgText** "הגדרות" · `catalog_settings_screen.t01` ✅
- **cfgText** "איפוס הגדרות?" · `catalog_settings_screen.t02` ✅
- **cfgText** "כל ההגדרות יוחזרו לברירת המחדל." · `catalog_settings_screen.t03` ✅
- **cfgVisible** · `catalog_settings_screen.t04` ✅
- **cfgText** "ביטול" · `catalog_settings_screen.t04` ✅
- **cfgVisible** · `catalog_settings_screen.t05` ✅
- **cfgText** "אפס" · `catalog_settings_screen.t05` ✅

## חיבורים · connections (5)

- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `catalogSettingsProvider`
- **reads** · `read` → `appSettingsProvider`
- **reads** · `read` → `notifSettingsProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `kbCatalogSettingsNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `showProfileRow`
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
