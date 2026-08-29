# _PrivacySection

- **screen:** `store_settings_screen`
- **role:** section

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות" · `store_settings_screen.section_wip` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `store_settings_screen.switch_wip` ✅
- **cfgText** "בבנייה — עדיין לא משפיע" · `store_settings_screen.number_wip` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `storeSettingsProvider`
- **writes** · `update` → `storeSettingsProvider`
- **writes** · `state=` → `storeSearchQueryProvider`
- **action** · `showToast` → `showToast`
- **gated-by** · `const-flag` → `kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty)`

## התנהגות · behaviour (3)

- **onTap** → _verb_ `showToast(context, 'החיפוש נוקה')` → toast
- **onTap** → _verb_ `ref.read(storeSearchQueryProvider.notifier).state = ''` → write → storeSearchQueryProvider
- **build** → _rule_ `if (kHideUnderConstruction && (underConstruction || _visibleChildren.isEmpty))` → hidden (SizedBox.shrink)

## floor · external functions (1)

- `confirmDestructive`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onStoreSearchQuery(…) callback instead of direct storeSearchQueryProvider write
  - onStoreSettings(…) callback instead of direct storeSettingsProvider write
- **gaps:** none (all registry-backed)
