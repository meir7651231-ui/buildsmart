# _CatalogBody

- **screen:** `catalog_screen`
- **role:** section

## עצם · object (8)

> registry 5 · mapped 5/5 · **unregistered 3**

- **text** "⭐" · — לא-רשום
- **cfgVisible** · `catalog.search.clearAll` ✅
- **cfgText** "נקה הכל" · `catalog.search.clearAll` ✅
- **text** "—" · — לא-רשום
- **cfgText** "אין משפחות וריאנטים" · `catalog_screen.t40` ✅
- **cfgText** "אין פריטים להצגה.
פתחו את ניהול הרשימות והקישו ✏️ כדי לבחור פריטים." · `catalog_screen.t18` ✅
- **cfgText** "מיון לפי:" · `catalog_screen.t41` ✅
- **text** "|" · — לא-רשום

## חיבורים · connections (43)

- **reads** · `watch` → `catalogSectionProvider`
- **gated-by** · `modOn` → `search`
- **gated-by** · `modOn` → `dive`
- **reads** · `watch` → `featureFlagsProvider`
- **reads** · `watch` → `catalogListItemsProvider`
- **reads** · `watch` → `smartTreeCatProvider`
- **reads** · `watch` → `catalogSystemFilterProvider`
- **reads** · `watch` → `productFavoritesProvider`
- **reads** · `watch` → `catalogRepositoryProvider`
- **reads** · `watch` → `recentSearchesProvider`
- **writes** · `clear` → `recentSearchesProvider`
- **writes** · `remove` → `recentSearchesProvider`
- **reads** · `watch` → `variantsActiveFamilyProvider`
- **reads** · `watch` → `variantsKindFilterProvider`
- **reads** · `watch` → `variantsValueFilterProvider`
- **reads** · `watch` → `variantsSizePatternProvider`
- **reads** · `watch` → `variantsSizeDiameterProvider`
- **reads** · `watch` → `variantsSizeSystemProvider`
- **reads** · `watch` → `variantsSizeGenderProvider`
- **reads** · `watch` → `variantsValuesExpandedProvider`
- **writes** · `state=` → `smartTreeCatProvider`
- **reads** · `watch` → `categorySummaryProvider`
- **writes** · `state=` → `catalogTreePathProvider`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **reads** · `read` → `catalogRepositoryProvider`
- **writes** · `state=` → `variantsActiveFamilyProvider`
- **writes** · `state=` → `variantsKindFilterProvider`
- **writes** · `state=` → `variantsValueFilterProvider`
- **writes** · `state=` → `variantsSizePatternProvider`
- **writes** · `state=` → `variantsSizeDiameterProvider`
- **writes** · `state=` → `variantsSizeSystemProvider`
- **writes** · `state=` → `variantsSizeGenderProvider`
- **writes** · `state=` → `variantsValuesExpandedProvider`
- **reads** · `read` → `variantsKindFilterProvider`
- **reads** · `read` → `variantsValuesExpandedProvider`
- **reads** · `watch` → `variantsSizeSortAxisProvider`
- **writes** · `state=` → `variantsSizeSortAxisProvider`
- **writes** · `state=` → `variantsActiveSubGroupProvider`
- **reads** · `read` → `variantsValueFilterProvider`
- **reads** · `watch` → `variantsActiveSubGroupProvider`
- **reads** · `watch` → `provider`
- **writes** · `state=` → `provider`
- **gated-by** · `guard` → `group.isEmpty`

## התנהגות · behaviour (20)

- **onPressed** → _verb_ `ref.read(recentSearchesProvider.notifier).clear()` → write → recentSearchesProvider
- **onPressed** → _verb_ `ref.read(recentSearchesProvider.notifier).remove(q)` → write → recentSearchesProvider
- **onTap** → _verb_ `LipskeyProductsScreen.openWordSearch(context, q)` → open → openWordSearch
- **onTap** → _verb_ `ref.read(smartTreeCatProvider.notifier).state = cat` → write → smartTreeCatProvider
- **onTap** → _verb_ `ref.read(catalogTreePathProvider.notifier).state = [node]` → write → catalogTreePathProvider
- **onTap** → _verb_ `showLipskeyProductSheet(context, product, ref.read(catalogRepositoryProvider)…` → open → showLipskeyProductSheet
- **onTap** → _verb_ `ref.read(variantsActiveFamilyProvider.notifier).state = null` → write → variantsActiveFamilyProvider
- **onTap** → _verb_ `ref.read(variantsKindFilterProvider.notifier).state = kind` → write → variantsKindFilterProvider
- **onTap** → _verb_ `ref.read(variantsValueFilterProvider.notifier).state = <String>{}` → write → variantsValueFilterProvider
- **onTap** → _verb_ `ref.read(variantsSizePatternProvider.notifier).state = <String>{}` → write → variantsSizePatternProvider
- **onTap** → _verb_ `ref.read(variantsSizeDiameterProvider.notifier).state = <String>{}` → write → variantsSizeDiameterProvider
- **onTap** → _verb_ `ref.read(variantsSizeSystemProvider.notifier).state = <String>{}` → write → variantsSizeSystemProvider
- **onTap** → _verb_ `ref.read(variantsSizeGenderProvider.notifier).state = <String>{}` → write → variantsSizeGenderProvider
- **onTap** → _verb_ `ref.read(variantsValuesExpandedProvider.notifier).state = false` → write → variantsValuesExpandedProvider
- **onTap** → _verb_ `ref.read(variantsSizeSortAxisProvider.notifier).state = axis` → write → variantsSizeSortAxisProvider
- **onTap** → _verb_ `ref.read(variantsActiveSubGroupProvider.notifier).state = null` → write → variantsActiveSubGroupProvider
- **onTap** → _verb_ `ref.read(variantsActiveFamilyProvider.notifier).state = family` → write → variantsActiveFamilyProvider
- **build** → _rule_ `if (group.isEmpty)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `ref.read(variantsActiveSubGroupProvider.notifier).state = isActive ? null : l…` → write → variantsActiveSubGroupProvider
- **onTap** → _verb_ `ref.read(variantsActiveSubGroupProvider.notifier).state = active == m.key ? n…` → write → variantsActiveSubGroupProvider

## floor · external functions (17)

- `bsOnAccent`
- `confirmDestructive`
- `familiesByKind`
- `filterBySystem`
- `filterSmartBySystem`
- `genderPattern`
- `productImage`
- `productMaterial`
- `sizeDiameterAtoms`
- `sizeStructurePattern`
- `sort`
- `subGroupLabel`
- `toggle`
- `toggleAtom`
- `toggleValue`
- `valueSubGroupsForKind`
- `variantValue`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `scrollCtrl`
- **untangle:**
  - AtomHomeScreen = shared component → separate atom
  - CardKeyboardScreen = shared component → separate atom
  - CatalogWheelScreen = shared component → separate atom
  - FinderScreen = shared component → separate atom
  - InstallStudioScreen = shared component → separate atom
  - PlainDiveScreen = shared component → separate atom
  - RingDiveScreen = shared component → separate atom
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 3 unregistered — "⭐" · "—" · "|"
