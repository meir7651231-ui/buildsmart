# _DeptScopeBar

- **screen:** `departments_screen`
- **role:** section · live (gated `kProfileRawShell`)

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "כל המחלקות" · `departments_screen.t03` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `deptFlatProductsProvider`
- **writes** · `state=` → `deptFlatProductsProvider`
- **writes** · `state=` → `homeDepartmentProvider`
- **writes** · `state=` → `catalogSystemFilterProvider`
- **writes** · `state=` → `catalogTreePathProvider`

## התנהגות · behaviour (5)

- **onTap** → _verb_ `ref.read(deptFlatProductsProvider.notifier).state = !flat` → write → deptFlatProductsProvider
- **onTap** → _verb_ `ref.read(deptFlatProductsProvider.notifier).state = false` → write → deptFlatProductsProvider
- **onTap** → _verb_ `ref.read(homeDepartmentProvider.notifier).state = null` → write → homeDepartmentProvider
- **onTap** → _verb_ `ref.read(catalogSystemFilterProvider.notifier).state = null` → write → catalogSystemFilterProvider
- **onTap** → _verb_ `ref.read(catalogTreePathProvider.notifier).state = const []` → write → catalogTreePathProvider

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `name` · `system` · `showFlatToggle`
- **untangle:**
  - onCatalogSystemFilter(…) callback instead of direct catalogSystemFilterProvider write
  - onCatalogTreePath(…) callback instead of direct catalogTreePathProvider write
  - onDeptFlatProducts(…) callback instead of direct deptFlatProductsProvider write
  - onHomeDepartment(…) callback instead of direct homeDepartmentProvider write
- **gaps:** none (all registry-backed)
