# CourierCertsScreen

- **screen:** `courier_certs_screen`
- **role:** composer

## עצם · object (8)

> registry 7 · mapped 7/7 · **unregistered 1**

- **cfgText** "🪪 תעודות נהג" · `courier.certs.title` ✅
- **cfgText** "🪪 הוספת תעודה" · `courier.certs.sheet_title` ✅
- **cfgText** "מילוי מהיר — ממלא את שם התעודה בלבד:" · `courier_certs_screen.quick_fill_hint` ✅
- **text** "📅" · — לא-רשום
- **cfgText** "📷 צרף צילום תעודה (לא חובה)" · `courier_certs_screen.attach_photo` ✅
- **cfgText** "📷 צילום צורף ✓" · `courier_certs_screen.photo_attached` ✅
- **cfgVisible** · `courier.certs.save_button` ✅
- **cfgText** "💾 שמור תעודה" · `courier.certs.save_button` ✅

## חיבורים · connections (7)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `courierCertsProvider`
- **writes** · `remove` → `courierCertsProvider`
- **action** · `showToast` → `showToast`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **action** · `showDatePicker` → `showDatePicker`
- **writes** · `add` → `courierCertsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (5)

- `bsOnAccent`
- `confirmDestructive`
- `pickTaskPhoto`
- `setSheetState`
- `sort`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - WelcomeScreen = shared component → separate atom
- **gaps:** 1 unregistered — "📅"
