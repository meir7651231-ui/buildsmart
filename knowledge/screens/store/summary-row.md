# _SummaryRow

- **screen:** `store`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (3)

- **reads** · `watch` → `cartQtysProvider`
- **reads** · `watch` → `smartCartProvider`
- **reads** · `watch` → `storeOrdersProvider.select((orders) => orders.where((x) => isOrderOpen(x.stage)).length)`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
