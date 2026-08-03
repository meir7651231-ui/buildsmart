# _SectionChipsRow

- **screen:** `store_screen`
- **role:** section

## עצם · object (1)

> registry 0 · mapped 0/0 · **unregistered 1**

- **text** "🔔" · — לא-רשום

## חיבורים · connections (4)

- **reads** · `watch` → `storeSectionProvider`
- **writes** · `state=` → `storeSectionProvider`
- **gated-by** · `featOn` → `orders.services`
- **action** · `showOrderNotifSheet` → `showOrderNotifSheet`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showOrderNotifSheet(context)` → open → showOrderNotifSheet

## floor · external functions (2)

- `bsOnAccent`
- `select`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 1 unregistered — "🔔"
