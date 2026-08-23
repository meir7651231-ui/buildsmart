# _NotificationsSection

- **screen:** `catalog_settings_screen`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (5)

- **reads** · `watch` → `notifSettingsProvider`
- **reads** · `watch` → `catalogSettingsProvider`
- **reads** · `read` → `catalogSettingsProvider`
- **writes** · `update` → `notifSettingsProvider`
- **gated-by** · `const-flag` → `kHideUnderConstruction && _visibleChildren.isEmpty`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (kHideUnderConstruction && _visibleChildren.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onNotifSettings(…) callback instead of direct notifSettingsProvider write
- **gaps:** none (all registry-backed)
