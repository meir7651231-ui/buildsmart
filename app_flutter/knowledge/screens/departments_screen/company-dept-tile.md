# _CompanyDeptTile

- **screen:** `departments_screen`
- **role:** section · live (gated `kProfileRawShell`)

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (1)

- **writes** · `state=` → `homeDepartmentProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(homeDepartmentProvider.notifier).state = section.title` → write → homeDepartmentProvider

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `section`
- **untangle:**
  - onHomeDepartment(…) callback instead of direct homeDepartmentProvider write
- **gaps:** none (all registry-backed)
