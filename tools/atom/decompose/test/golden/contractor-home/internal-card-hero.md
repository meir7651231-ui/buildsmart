# _InternalCardHero

- **screen:** `contractor-home`
- **role:** section · section `internalCard` · preview

## עצם · object (3)

> registry 0 · mapped 0/0 · **unregistered 3**

- **text** "כרטיס פנימי" · — לא-רשום
- **text** "🃏 כרטיס פנימי" · — לא-רשום
- **text** "כל המנוע במקום אחד — 13 סקציות" · — לא-רשום

## חיבורים · connections (1)

- **action** · `push` → `MaterialPageRoute<void>(builder: (_) …`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Scaffold(a…` → navigate → MaterialPageRoute<void>(builder: (_) …

## floor · external functions (2)

- `catalogProductForSku`
- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 3 unregistered — "כרטיס פנימי" · "🃏 כרטיס פנימי" · "כל המנוע במקום אחד — 13 סקציות"
