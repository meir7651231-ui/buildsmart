# _BusinessSection

- **screen:** `chat_settings_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `chat_settings_screen.t14` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `chat_settings_screen.t15` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `chatSettingsProvider`
- **writes** · `update` → `chatSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty)`
- **action** · `showTimePicker` → `showTimePicker`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty))` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `showTimePicker(context: context, initialTime: time, builder: (ctx, child) => …` → open → showTimePicker

## floor · external functions (1)

- `onChanged`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onChatSettings(…) callback instead of direct chatSettingsProvider write
- **gaps:** none (all registry-backed)
