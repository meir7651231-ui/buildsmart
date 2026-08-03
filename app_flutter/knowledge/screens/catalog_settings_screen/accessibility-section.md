# _AccessibilitySection

- **screen:** `catalog_settings_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "בקרוב" · `catalog_settings_screen.t11` ✅

## חיבורים · connections (3)

- **reads** · `watch` → `catalogSettingsProvider`
- **writes** · `update` → `catalogSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && _visibleChildren.isEmpty`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (kHideUnderConstruction && _visibleChildren.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (1)

- `onChanged`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onCatalogSettings(…) callback instead of direct catalogSettingsProvider write
- **gaps:** none (all registry-backed)
