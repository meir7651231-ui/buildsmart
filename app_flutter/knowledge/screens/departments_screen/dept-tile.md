# _DeptTile

- **screen:** `departments_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "בקרוב" · `departments_screen.t02` ✅

## חיבורים · connections (5)

- **writes** · `state=` → `catalogSystemFilterProvider`
- **writes** · `state=` → `catalogTreePathProvider`
- **writes** · `state=` → `deptFlatProductsProvider`
- **writes** · `state=` → `homeDepartmentProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (6)

- **onTap** → _verb_ `showToast(context, 'בקרוב')` → toast
- **onTap** → _verb_ `ref.read(catalogSystemFilterProvider.notifier).state = null` → write → catalogSystemFilterProvider
- **onTap** → _verb_ `ref.read(catalogTreePathProvider.notifier).state = _toolDeptPath(dept.name, t…` → write → catalogTreePathProvider
- **onTap** → _verb_ `ref.read(catalogTreePathProvider.notifier).state = const []` → write → catalogTreePathProvider
- **onTap** → _verb_ `ref.read(deptFlatProductsProvider.notifier).state = false` → write → deptFlatProductsProvider
- **onTap** → _verb_ `ref.read(homeDepartmentProvider.notifier).state = dept.name` → write → homeDepartmentProvider

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `dept`
- **untangle:**
  - onCatalogSystemFilter(…) callback instead of direct catalogSystemFilterProvider write
  - onCatalogTreePath(…) callback instead of direct catalogTreePathProvider write
  - onDeptFlatProducts(…) callback instead of direct deptFlatProductsProvider write
  - onHomeDepartment(…) callback instead of direct homeDepartmentProvider write
- **gaps:** none (all registry-backed)
