# _AiSection

- **screen:** `catalog_settings_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "בבנייה" · `catalog_settings_screen.t12` ✅

## חיבורים · connections (2)

- **gated-by** · `const-flag` → `kHideUnderConstruction && _visibleChildren.isEmpty`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (kHideUnderConstruction && _visibleChildren.isEmpty)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `showToast(context, '$label — בבנייה')` → toast

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
