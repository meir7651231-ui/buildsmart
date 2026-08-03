# CatalogScreen

- **screen:** `catalog_screen`
- **role:** composer

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (7)

- **writes** · `state=` → `tabHeaderHiddenProvider`
- **reads** · `watch` → `catalogTreePathProvider`
- **reads** · `watch` → `catalogSectionProvider`
- **reads** · `watch` → `smartTreeCatProvider`
- **reads** · `read` → `intelBusProvider`
- **reads** · `read` → `diveResultsProvider`
- **reads** · `watch` → `keyboardDiveQueryProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onTabHeaderHidden(…) callback instead of direct tabHeaderHiddenProvider write
- **gaps:** none (all registry-backed)
