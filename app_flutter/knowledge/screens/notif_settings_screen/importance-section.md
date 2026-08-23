# _ImportanceSection

- **screen:** `notif_settings_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `notif_settings_screen.t07` ✅
- **cfgText** "בבנייה" · `notif_settings_screen.t10` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `notifSettingsProvider`
- **writes** · `update` → `notifSettingsProvider`
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
  - onNotifSettings(…) callback instead of direct notifSettingsProvider write
- **gaps:** none (all registry-backed)
