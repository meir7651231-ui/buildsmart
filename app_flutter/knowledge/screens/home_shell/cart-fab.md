# CartFab

- **screen:** `home_shell`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (6)

- **reads** · `watch` → `smartCartProvider`
- **reads** · `watch` → `cartBubbleDismissedProvider`
- **writes** · `state=` → `cartBubbleDismissedProvider`
- **writes** · `state=` → `storeSectionProvider`
- **writes** · `state=` → `mainTabProvider`
- **action** · `openCartLineProductSheet` → `openCartLineProductSheet`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `openCartLineProductSheet(context, lines[i])` → open → openCartLineProductSheet

## floor · external functions (3)

- `bsOnAccent`
- `cartLineDisplay`
- `resetAllDials`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `popFirst`
- **untangle:**
  - onCartBubbleDismissed(…) callback instead of direct cartBubbleDismissedProvider write
  - onMainTab(…) callback instead of direct mainTabProvider write
  - onStoreSection(…) callback instead of direct storeSectionProvider write
- **gaps:** none (all registry-backed)
