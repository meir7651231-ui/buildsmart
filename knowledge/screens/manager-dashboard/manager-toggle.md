# _ManagerToggle

- **screen:** `manager-dashboard`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (2)

- **reads** · `watch` → `orgConfigProvider`
- **writes** · `state=` → `managerTabProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(managerTabProvider.notifier).state = i` → write → managerTabProvider

## floor · external functions (3)

- `bsOnAccent`
- `moduleOn`
- `seg`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `active`
- **untangle:**
  - onManagerTab(…) callback instead of direct managerTabProvider write
- **gaps:** none (all registry-backed)
