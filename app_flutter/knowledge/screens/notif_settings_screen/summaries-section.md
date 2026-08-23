# _SummariesSection

- **screen:** `notif_settings_screen`
- **role:** section

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `notif_settings_screen.t07` ✅
- **cfgText** "דורש חיבור שרת — לא זמין בגרסה זו" · `notif_settings_screen.t08` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `notif_settings_screen.t09` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `notifSettingsProvider`
- **writes** · `update` → `notifSettingsProvider`
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
  - onNotifSettings(…) callback instead of direct notifSettingsProvider write
- **gaps:** none (all registry-backed)
