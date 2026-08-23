# _Body

- **screen:** `home_content_reorder`
- **role:** section

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "מסך הבית שלי" · `home_content_reorder.t03` ✅
- **cfgVisible** · `home_content_reorder.t04` ✅
- **cfgText** "איפוס" · `home_content_reorder.t04` ✅

## חיבורים · connections (3)

- **reads** · `watch` → `screenSectionsProvider`
- **reads** · `read` → `screenSectionsProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showToast(context, 'הסדר וההסתרות אופסו לברירת מחדל')` → toast

## floor · external functions (2)

- `setState`
- `smartHomeSectionFor`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - ReorderableListView = shared component → separate atom
- **gaps:** none (all registry-backed)
