# DepartmentsScreen

- **screen:** `departments_screen`
- **role:** composer

## עצם · object (3)

> registry 1 · mapped 1/1 · **unregistered 2**

- **cfgText** "מחלקות" · `departments_screen.t01` ✅
- **text** "🗂️" · — לא-רשום
- **text** "אין מחלקות עדיין — יופיעו עם טעינת קטלוג החברה" · — לא-רשום

## חיבורים · connections (3)

- **reads** · `watch` → `homeDepartmentProvider`
- **reads** · `watch` → `deptFlatProductsProvider`
- **reads** · `watch` → `catalogTreePathProvider.select((p) => p.isNotEmpty)`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `companyDepartments`
- `isCatalogDept`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - CatalogScreen = shared component → separate atom
- **gaps:** 2 unregistered — "🗂️" · "אין מחלקות עדיין — יופיעו עם טעינת קטלוג החברה"
