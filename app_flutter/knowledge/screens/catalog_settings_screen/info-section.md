# _InfoSection

- **screen:** `catalog_settings_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "תנאי שימוש" · `catalog_settings_screen.t09` ✅
- **cfgText** "מדיניות פרטיות" · `catalog_settings_screen.t10` ✅

## חיבורים · connections (2)

- **action** · `push` → `LegalScreen`
- **gated-by** · `const-flag` → `kHideUnderConstruction && _visibleChildren.isEmpty`

## התנהגות · behaviour (3)

- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: LegalTab.terms))` → navigate → LegalScreen
- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: LegalTab.privacy))` → navigate → LegalScreen
- **build** → _rule_ `if (kHideUnderConstruction && _visibleChildren.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
