# _AccessibilitySection

- **screen:** `worker_settings_screen`
- **role:** section

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "גודל טקסט (כל האפליקציה)" · `worker_settings_screen.text_size` ✅
- **cfgText** "ניגודיות גבוהה (כל האפליקציה)" · `worker_settings_screen.high_contrast` ✅
- **cfgText** "הנפשות מופחתות (כל האפליקציה)" · `worker_settings_screen.reduced_motion` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `catalogSettingsProvider`
- **writes** · `update` → `catalogSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onCatalogSettings(…) callback instead of direct catalogSettingsProvider write
- **gaps:** none (all registry-backed)
