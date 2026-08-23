# NotifSettingsScreen

- **screen:** `notif_settings_screen`
- **role:** composer

## עצם · object (7)

> registry 7 · mapped 7/7 · **unregistered 0**

- **cfgText** "הגדרות התראות" · `notif_settings_screen.t01` ✅
- **cfgText** "איפוס הגדרות?" · `notif_settings_screen.t02` ✅
- **cfgText** "כל הגדרות ההתראות יוחזרו לברירת המחדל." · `notif_settings_screen.t03` ✅
- **cfgVisible** · `notif_settings_screen.t04` ✅
- **cfgText** "ביטול" · `notif_settings_screen.t04` ✅
- **cfgVisible** · `notif_settings_screen.t05` ✅
- **cfgText** "אפס" · `notif_settings_screen.t05` ✅

## חיבורים · connections (3)

- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `notifSettingsProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `kbNotifSettingsNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
