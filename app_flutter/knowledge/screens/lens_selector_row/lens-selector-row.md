# LensSelectorRow

- **screen:** `lens_selector_row`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "סדר לפי:" · `lens_selector_row.sort_by` ✅

## חיבורים · connections (3)

- **gated-by** · `guard` → `available.length < 2`
- **reads** · `watch` → `catalogLensProvider`
- **writes** · `state=` → `catalogLensProvider`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (available.length < 2)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `ref.read(catalogLensProvider.notifier).state = lens` → write → catalogLensProvider

## floor · external functions (2)

- `availableLensesForSet`
- `resolveActiveLens`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `products`
- **untangle:**
  - onCatalogLens(…) callback instead of direct catalogLensProvider write
- **gaps:** none (all registry-backed)
