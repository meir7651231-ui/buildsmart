# _SnoozeBanner

- **screen:** `notif_settings_screen`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "🔇 השתק התראות" · `notif_settings_screen.t06` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `notifSettingsProvider`
- **reads** · `read` → `notifSettingsProvider`
- **action** · `showToast` → `showToast`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `ref.read(notifSettingsProvider.notifier).cancelSnooze()` → write → notifSettingsProvider
- **onTap** → _verb_ `showToast(context, 'השתקה בוטלה')` → toast

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
