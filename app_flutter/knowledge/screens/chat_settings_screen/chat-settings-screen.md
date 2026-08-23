# ChatSettingsScreen

- **screen:** `chat_settings_screen`
- **role:** composer

## עצם · object (7)

> registry 7 · mapped 7/7 · **unregistered 0**

- **cfgText** "הגדרות שיחות" · `chat_settings_screen.t01` ✅
- **cfgText** "איפוס הגדרות?" · `chat_settings_screen.t02` ✅
- **cfgText** "כל הגדרות השיחות יוחזרו לברירת המחדל." · `chat_settings_screen.t03` ✅
- **cfgVisible** · `chat_settings_screen.t04` ✅
- **cfgText** "ביטול" · `chat_settings_screen.t04` ✅
- **cfgVisible** · `chat_settings_screen.t05` ✅
- **cfgText** "אפס" · `chat_settings_screen.t05` ✅

## חיבורים · connections (3)

- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `chatSettingsProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
