# _InvoicesSection

- **screen:** `store_settings_screen`
- **role:** section

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `store_settings_screen.section_wip` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `store_settings_screen.switch_wip` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `store_settings_screen.inline_wip` ✅

## חיבורים · connections (3)

- **reads** · `watch` → `storeSettingsProvider`
- **writes** · `update` → `storeSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty)`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty))` → hidden (SizedBox.shrink)

## floor · external functions (1)

- `validBusinessId`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onStoreSettings(…) callback instead of direct storeSettingsProvider write
- **gaps:** none (all registry-backed)
