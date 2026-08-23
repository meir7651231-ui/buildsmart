# _RoleRow

- **screen:** `role_picker_sheet`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (1)

- **writes** · `state=` → `activePersonaProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(activePersonaProvider.notifier).state = null` → write → activePersonaProvider

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `persona`
- **untangle:**
  - CourierDashboardScreen = shared component → separate atom
  - ManagerDashboardScreen = shared component → separate atom
  - StoreDashboardScreen = shared component → separate atom
  - WorkerAppScreen = shared component → separate atom
  - _pushBoard = shared component → separate atom
- **gaps:** none (all registry-backed)
