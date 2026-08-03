# _ConsentDialog

- **screen:** `consent_modal`
- **role:** composer

## עצם · object (8)

> registry 8 · mapped 8/8 · **unregistered 0**

- **cfgText** "שיפור השירות — נתוני שימוש" · `consent_modal.t01` ✅
- **cfgText** · `consent_modal.t02` ✅
- **cfgVisible** · `consent_modal.t03` ✅
- **cfgText** "קראו את מדיניות הפרטיות המלאה" · `consent_modal.t03` ✅
- **cfgVisible** · `consent_modal.t04` ✅
- **cfgText** "לא עכשיו" · `consent_modal.t04` ✅
- **cfgVisible** · `consent_modal.t05` ✅
- **cfgText** "אני מסכים" · `consent_modal.t05` ✅

## חיבורים · connections (1)

- **action** · `push` → `LegalScreen`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `Navigator.of(context).push(LegalScreen.route(initialTab: LegalTab.privacy))` → navigate → LegalScreen

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `onAgree` · `onDismiss`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
