# _GlobalSearchOverlay

- **screen:** `home_shell`
- **role:** section · live (gated `kGlobalSearch`)

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (2)

- **reads** · `watch` → `keyboardDiveQueryProvider`
- **gated-by** · `guard` → `!active`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (!active)` → hidden (SizedBox.shrink)

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - GlobalSearchResultsView = shared component → separate atom
- **gaps:** none (all registry-backed)
