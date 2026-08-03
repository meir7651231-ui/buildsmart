# _RegionSection

- **screen:** `worker_settings_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "בקרוב" · `worker_settings_screen.coming_soon` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `appSettingsProvider`
- **writes** · `update` → `appSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onAppSettings(…) callback instead of direct appSettingsProvider write
- **gaps:** none (all registry-backed)
