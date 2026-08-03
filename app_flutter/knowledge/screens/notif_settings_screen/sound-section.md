# _SoundSection

- **screen:** `notif_settings_screen`
- **role:** section

## עצם · object (4)

> registry 4 · mapped 4/4 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `notif_settings_screen.t07` ✅
- **cfgText** "דורש חיבור שרת — לא זמין בגרסה זו" · `notif_settings_screen.t08` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `notif_settings_screen.t09` ✅
- **cfgText** "בבנייה" · `notif_settings_screen.t10` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `notifSettingsProvider`
- **writes** · `update` → `notifSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty)`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty))` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `showToast(context, '$label — בבנייה')` → toast

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onNotifSettings(…) callback instead of direct notifSettingsProvider write
- **gaps:** none (all registry-backed)
