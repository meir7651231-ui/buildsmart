# _SearchSection

- **screen:** `catalog_settings_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "בבנייה" · `catalog_settings_screen.t12` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `catalogSettingsProvider`
- **writes** · `update` → `catalogSettingsProvider`
- **writes** · `clear` → `recentSearchesProvider`
- **action** · `showToast` → `showToast`
- **gated-by** · `const-flag` → `kHideUnderConstruction && _visibleChildren.isEmpty`

## התנהגות · behaviour (4)

- **onTap** → _verb_ `ref.read(recentSearchesProvider.notifier).clear()` → write → recentSearchesProvider
- **onTap** → _verb_ `showToast(context, 'ההיסטוריה נוקתה')` → toast
- **build** → _rule_ `if (kHideUnderConstruction && _visibleChildren.isEmpty)` → hidden (SizedBox.shrink)
- **onTap** → _verb_ `showToast(context, '$label — בבנייה')` → toast

## floor · external functions (1)

- `confirmDestructive`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onCatalogSettings(…) callback instead of direct catalogSettingsProvider write
  - onRecentSearches(…) callback instead of direct recentSearchesProvider write
- **gaps:** none (all registry-backed)
