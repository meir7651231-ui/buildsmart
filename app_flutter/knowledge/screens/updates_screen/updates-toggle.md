# _UpdatesToggle

- **screen:** `updates_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (1)

- **writes** · `state=` → `updatesSubTabProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(updatesSubTabProvider.notifier).state = i` → write → updatesSubTabProvider

## floor · external functions (1)

- `seg`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `active`
- **untangle:**
  - onUpdatesSubTab(…) callback instead of direct updatesSubTabProvider write
- **gaps:** none (all registry-backed)
