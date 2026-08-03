# _CourierNotifSection

- **screen:** `courier_settings_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (2)

- **reads** · `watch` → `notifSettingsProvider`
- **writes** · `update` → `notifSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `bsOnAccent`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onNotifSettings(…) callback instead of direct notifSettingsProvider write
- **gaps:** none (all registry-backed)
