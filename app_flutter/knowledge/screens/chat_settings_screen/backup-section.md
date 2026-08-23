# _BackupSection

- **screen:** `chat_settings_screen`
- **role:** section

## עצם · object (4)

> registry 4 · mapped 4/4 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `chat_settings_screen.t14` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `chat_settings_screen.t15` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `chat_settings_screen.t16` ✅
- **cfgText** "בבנייה" · `chat_settings_screen.t17` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `chatSettingsProvider`
- **writes** · `update` → `chatSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty)`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty))` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `showToast(context, '$label — בבנייה')` → toast

## floor · external functions (1)

- `onChanged`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onChatSettings(…) callback instead of direct chatSettingsProvider write
- **gaps:** none (all registry-backed)
