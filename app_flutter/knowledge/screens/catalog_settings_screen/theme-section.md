# _ThemeSection

- **screen:** `catalog_settings_screen`
- **role:** section

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "סידור מסך הבית" · `catalog_settings_screen.t07` ✅
- **cfgText** "גרור לשנות את סדר המקטעים בבית" · `catalog_settings_screen.t08` ✅
- **cfgText** "בקרוב" · `catalog_settings_screen.t11` ✅

## חיבורים · connections (7)

- **reads** · `watch` → `appSettingsProvider`
- **reads** · `watch` → `catalogSettingsProvider`
- **reads** · `read` → `catalogSettingsProvider`
- **writes** · `update` → `appSettingsProvider`
- **writes** · `state=` → `catalogProductSortProvider`
- **action** · `push` → `HomeContentReorder`
- **gated-by** · `const-flag` → `kHideUnderConstruction && _visibleChildren.isEmpty`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `Navigator.of(context).push(HomeContentReorder.route())` → navigate → HomeContentReorder
- **build** → _rule_ `if (kHideUnderConstruction && _visibleChildren.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (1)

- `onChanged`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onAppSettings(…) callback instead of direct appSettingsProvider write
  - onCatalogProductSort(…) callback instead of direct catalogProductSortProvider write
- **gaps:** none (all registry-backed)
