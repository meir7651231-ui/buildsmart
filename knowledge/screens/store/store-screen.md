# StoreScreen

- **screen:** `store`
- **role:** composer

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (4)

- **writes** · `state=` → `tabHeaderHiddenProvider`
- **writes** · `state=` → `storeOrderOpenProvider`
- **reads** · `read` → `storeOrdersProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onStoreOrderOpen(…) callback instead of direct storeOrderOpenProvider write
  - onTabHeaderHidden(…) callback instead of direct tabHeaderHiddenProvider write
- **gaps:** none (all registry-backed)
