# _CourierRegionSection

- **screen:** `courier_settings_screen`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgVisible** · `courier_settings_screen.soon` ✅
- **cfgText** "בקרוב" · `courier_settings_screen.soon` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `appSettingsProvider`
- **writes** · `update` → `appSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `bsOnAccent`
- `onChanged`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onAppSettings(…) callback instead of direct appSettingsProvider write
- **gaps:** none (all registry-backed)
