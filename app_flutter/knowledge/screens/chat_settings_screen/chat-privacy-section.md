# _ChatPrivacySection

- **screen:** `chat_settings_screen`
- **role:** section

## עצם · object (9)

> registry 9 · mapped 9/9 · **unregistered 0**

- **cfgText** "מחיקת היסטוריית שיחות" · `chat_settings_screen.t10` ✅
- **cfgText** "היסטוריית השיחות תימחק והשיחות ייפתחו ריקות." · `chat_settings_screen.t11` ✅
- **cfgVisible** · `chat_settings_screen.t12` ✅
- **cfgText** "ביטול" · `chat_settings_screen.t12` ✅
- **cfgVisible** · `chat_settings_screen.t13` ✅
- **cfgText** "מחק" · `chat_settings_screen.t13` ✅
- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `chat_settings_screen.t14` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `chat_settings_screen.t16` ✅
- **cfgText** "בבנייה" · `chat_settings_screen.t17` ✅

## חיבורים · connections (6)

- **reads** · `watch` → `chatSettingsProvider`
- **writes** · `update` → `chatSettingsProvider`
- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `chatHistoryClearedProvider`
- **action** · `showToast` → `showToast`
- **gated-by** · `const-flag` → `kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty)`

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
