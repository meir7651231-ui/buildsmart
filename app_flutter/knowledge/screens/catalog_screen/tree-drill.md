# _TreeDrill

- **screen:** `catalog_screen`
- **role:** section

## עצם · object (5)

> registry 5 · mapped 5/5 · **unregistered 0**

- **cfgVisible** · `catalog_screen.t21` ✅
- **cfgText** "בקרוב" · `catalog_screen.t21` ✅
- **cfgText** "הקטגוריה הזו בבנייה — תת-קטגוריות ומוצרים יתווספו בקרוב." · `catalog_screen.t22` ✅
- **cfgText** "מוצרים" · `catalog_screen.t19` ✅
- **cfgText** "מיון לפי" · `catalog_screen.t20` ✅

## חיבורים · connections (14)

- **reads** · `watch` → `catalogTreeQueryProvider.select((q) => q.trim())`
- **reads** · `watch` → `catalogFacetProvider`
- **reads** · `watch` → `catalogSystemFilterProvider`
- **reads** · `watch` → `catalogRepositoryProvider`
- **writes** · `state=` → `catalogTreeQueryProvider`
- **writes** · `state=` → `catalogFacetProvider`
- **writes** · `state=` → `catalogTreePathProvider`
- **action** · `openSmartProductSheet` → `openSmartProductSheet`
- **action** · `openNode` → `openNode`
- **reads** · `watch` → `catalogProductSortProvider`
- **reads** · `watch` → `catalogSettingsProvider.select((s) => s.quickFilterBar)`
- **writes** · `state=` → `catalogProductSortProvider`
- **reads** · `read` → `catalogTreeQueryProvider`
- **reads** · `watch` → `catalogTreeQueryProvider.select((q) => q.isNotEmpty)`

## התנהגות · behaviour (3)

- **onTap** → _verb_ `ref.read(catalogFacetProvider.notifier).state = [...facetSel, o.label]` → write → catalogFacetProvider
- **onTap** → _verb_ `openNode(n)` → open → openNode
- **onPressed** → _verb_ `ref.read(catalogTreeQueryProvider.notifier).state = ''` → write → catalogTreeQueryProvider

## floor · external functions (8)

- `bsOnAccent`
- `catalogProductSortLabel`
- `filterBySystem`
- `jumpToFacet`
- `jumpToTree`
- `nodeHasSystem`
- `resetFacets`
- `resetQuery`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `path`
- **untangle:**
  - CustomScrollView = shared component → separate atom
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
