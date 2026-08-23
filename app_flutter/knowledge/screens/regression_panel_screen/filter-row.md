# _FilterRow

- **screen:** `regression_panel_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (1)

- **writes** · `state=` → `regressionFilterProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(regressionFilterProvider.notifier).state = f.id` → write → regressionFilterProvider

## floor · external functions (1)

- `bsOnAccent`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `active`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
