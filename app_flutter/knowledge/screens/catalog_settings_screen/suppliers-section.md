# _SuppliersSection

- **screen:** `catalog_settings_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "בקרוב" · `catalog_settings_screen.t11` ✅
- **cfgText** "בבנייה" · `catalog_settings_screen.t12` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `catalogSettingsProvider`
- **reads** · `read` → `catalogSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && _visibleChildren.isEmpty`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (kHideUnderConstruction && _visibleChildren.isEmpty)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `showToast(context, '$label — בבנייה')` → toast

## floor · external functions (1)

- `onChanged`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
