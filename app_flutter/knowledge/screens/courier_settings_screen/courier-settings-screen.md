# CourierSettingsScreen

- **screen:** `courier_settings_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "הגדרות שליח" · `courier.settings.title` ✅

## חיבורים · connections (1)

- **reads** · `watch` → `boardAuthProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `kbCourierSettingsNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
  - WelcomeScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
