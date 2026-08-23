# _FilterChipsRow

- **screen:** `chats_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (4)

- **reads** · `watch` → `_audienceChipIndexProvider`
- **writes** · `state=` → `_audienceChipIndexProvider`
- **reads** · `watch` → `_chatFilterProvider`
- **writes** · `state=` → `_chatFilterProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(_audienceChipIndexProvider.notifier).state = i` → write → _audienceChipIndexProvider

## floor · external functions (2)

- `bsOnAccent`
- `select`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `audience`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
