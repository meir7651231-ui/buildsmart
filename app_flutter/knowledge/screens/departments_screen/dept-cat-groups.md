# _DeptCatGroups

- **screen:** `departments_screen`
- **role:** section

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **text** "🗂️" · — לא-רשום
- **cfgText** "אין קטגוריות במחלקה זו" · `departments_screen.t04` ✅
- **cfgText** "הקטגוריות יופיעו כאן כשיתווסף קטלוג למחלקה" · `departments_screen.t05` ✅

## חיבורים · connections (1)

- **writes** · `state=` → `catalogTreePathProvider`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `ref.read(catalogTreePathProvider.notifier).state = [node]` → write → catalogTreePathProvider

## floor · external functions (4)

- `bsOnAccent`
- `catNodeProductCount`
- `cfgRadius`
- `resolveCatTitle`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `deptName`
- **untangle:**
  - onCatalogTreePath(…) callback instead of direct catalogTreePathProvider write
- **gaps:** 1 unregistered — "🗂️"
