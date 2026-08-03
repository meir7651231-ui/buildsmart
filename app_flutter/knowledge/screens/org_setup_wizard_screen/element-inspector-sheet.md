# _ElementInspectorSheet

- **screen:** `org_setup_wizard_screen`
- **role:** section

## עצם · object (2)

> registry 0 · mapped 0/0 · **unregistered 2**

- **text** "אפס לברירת-מחדל" · — לא-רשום
- **text** "החל וסגור (חי)" · — לא-רשום

## חיבורים · connections (4)

- **reads** · `read` → `resolvedNodeProvider(_d.id)`
- **reads** · `read` → `configStoreProvider`
- **reads** · `read` → `studioOwnerEmailProvider`
- **reads** · `read` → `criticalIdsProvider`

## התנהגות · behaviour (1)

- **build** → _formula_ `previewEmoji = _hasEmoji && _emoji.text.isNotEmpty ? … : …` → text: '${_emoji.text} ' | ''

## floor · external functions (5)

- `applyCfgTextStyle`
- `applyOps`
- `publish`
- `resolvedNodeProvider`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `descriptor`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 2 unregistered — "אפס לברירת-מחדל" · "החל וסגור (חי)"
