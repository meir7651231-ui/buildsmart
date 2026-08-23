# CourierFormsScreen

- **screen:** `courier_forms_screen`
- **role:** composer

## עצם · object (6)

> registry 5 · mapped 5/5 · **unregistered 1**

- **cfgText** "📄 טפסים" · `courier.forms.title` ✅
- **cfgText** · `courier.forms.form101_note` ✅
- **cfgText** "הבקשות שלי" · `courier.forms.my_requests` ✅
- **cfgText** "צלם את אישור המחלה — הצילום נשמר ברשימה כאן." · `courier.forms.sicknote_hint` ✅
- **cfgText** "אין אישורים שהועלו עדיין" · `courier_forms_screen.t01` ✅
- **text** "📷" · — לא-רשום

## חיבורים · connections (9)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `courierFormsProvider`
- **reads** · `watch` → `vacationRequestsProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `courierFormsProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `showDatePicker` → `showDatePicker`
- **reads** · `read` → `vacationRequestsProvider`
- **action** · `showFullPhotoRefDialog` → `showFullPhotoRefDialog`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showFullPhotoRefDialog(context, n.photo, label: 'אישור מחלה · ${_fmtDate(n.ts…` → open → showFullPhotoRefDialog

## floor · external functions (6)

- `confirmDestructive`
- `imageProviderForRef`
- `pickTaskPhoto`
- `setState`
- `sort`
- `validIsraeliMobile`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - WelcomeScreen = shared component → separate atom
- **gaps:** 1 unregistered — "📷"
