# _NotificationsSection

- **screen:** `store_settings_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `store_settings_screen.section_wip` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `store_settings_screen.switch_wip` ✅

## חיבורים · connections (3)

- **reads** · `watch` → `storeSettingsProvider`
- **writes** · `update` → `storeSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty)`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty))` → hidden (SizedBox.shrink)

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onStoreSettings(…) callback instead of direct storeSettingsProvider write
- **gaps:** none (all registry-backed)
