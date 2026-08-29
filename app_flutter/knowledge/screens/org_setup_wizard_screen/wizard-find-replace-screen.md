# _WizardFindReplaceScreen

- **screen:** `org_setup_wizard_screen`
- **role:** section

## עצם · object (3)

> registry 0 · mapped 0/0 · **unregistered 3**

- **text** "מצא והחלף בטקסטים" · — לא-רשום
- **text** "פורסם — חי בכל האפליקציה ✓" · — לא-רשום
- **text** "פרסם לכולם (חי)" · — לא-רשום

## חיבורים · connections (3)

- **reads** · `read` → `configStoreProvider`
- **reads** · `read` → `studioOwnerEmailProvider`
- **reads** · `read` → `criticalIdsProvider`

## התנהגות · behaviour (2)

- **onPressed** → _verb_ `ref.read(configStoreProvider.notifier).publish(note: 'מצא-והחלף · אשף', byEma…` → write → configStoreProvider
- **onPressed** → _verb_ `ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('פורס…` → open → showSnackBar

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - FindReplacePane = shared component → separate atom
- **gaps:** 3 unregistered — "מצא והחלף בטקסטים" · "פורסם — חי בכל האפליקציה ✓" · "פרסם לכולם (חי)"
