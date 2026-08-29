# _ScreenManagerScreen

- **screen:** `org_setup_wizard_screen`
- **role:** section

## עצם · object (8)

> registry 0 · mapped 0/0 · **unregistered 8**

- **text** "ניהול מסכים" · — לא-רשום
- **text** "אפס סדר/הסתרה" · — לא-רשום
- **text** "✎" · — לא-רשום
- **text** "⌨️" · — לא-רשום
- **text** "מקלדת" · — לא-רשום
- **text** "ערוך שם" · — לא-רשום
- **text** "אפס לברירת-מחדל" · — לא-רשום
- **text** "שמור" · — לא-רשום

## חיבורים · connections (4)

- **action** · `push` → `MaterialPageRoute<void>(builder: (_) …`
- **reads** · `watch` → `screenSectionsProvider`
- **reads** · `read` → `screenSectionsProvider`
- **action** · `showDialog` → `showDialog`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _ScreenKey…` → navigate → MaterialPageRoute<void>(builder: (_) …

## floor · external functions (1)

- `keyboardLayoutKey`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - ReorderableListView = shared component → separate atom
- **gaps:** 8 unregistered — "ניהול מסכים" · "אפס סדר/הסתרה" · "✎" · "⌨️" · "מקלדת" · "ערוך שם" · "אפס לברירת-מחדל" · "שמור"
