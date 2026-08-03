# _CourierInfoSection

- **screen:** `courier_settings_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "תנאי שימוש" · `courier.info.terms` ✅
- **cfgText** "מדיניות פרטיות" · `courier.info.privacy` ✅

## חיבורים · connections (1)

- **action** · `push` → `LegalScreen`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: LegalTab.terms))` → navigate → LegalScreen
- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: LegalTab.privacy))` → navigate → LegalScreen

## floor · external functions (1)

- `bsOnAccent`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
