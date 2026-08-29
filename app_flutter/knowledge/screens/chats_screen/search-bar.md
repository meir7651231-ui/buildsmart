# _SearchBar

- **screen:** `chats_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (2)

- **reads** · `watch` → `updatesChatSearchProvider.select((q) => q.isNotEmpty)`
- **writes** · `state=` → `updatesChatSearchProvider`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `ref.read(updatesChatSearchProvider.notifier).state = ''` → write → updatesChatSearchProvider

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onUpdatesChatSearch(…) callback instead of direct updatesChatSearchProvider write
- **gaps:** none (all registry-backed)
