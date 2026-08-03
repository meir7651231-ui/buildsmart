# WorkerFormsScreen

- **screen:** `worker_forms_screen`
- **role:** composer

## עצם · object (8)

> registry 7 · mapped 7/7 · **unregistered 1**

- **cfgText** "📄 טפסים" · `worker_forms_screen.forms_title` ✅
- **cfgText** · `worker_forms_screen.form101_note` ✅
- **cfgText** "פרטי המעסיק" · `worker_forms_screen.employer_details` ✅
- **cfgText** "הבקשות שלי" · `worker_forms_screen.my_requests` ✅
- **cfgText** "צלם את אישור המחלה — הצילום נשמר ברשימה כאן." · `worker_forms_screen.sick_hint` ✅
- **cfgText** "אין אישורים שהועלו עדיין" · `worker_forms_screen.no_uploads` ✅
- **text** "📷" · — לא-רשום
- **cfgText** "חתום ✓" · `worker_forms_screen.signed` ✅

## חיבורים · connections (13)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `workerFormsProvider`
- **reads** · `watch` → `vacationRequestsProvider`
- **reads** · `watch` → `workerProfileProvider`
- **reads** · `watch` → `employerProfileProvider(session.employerId)`
- **action** · `showSignatureSheet` → `showSignatureSheet`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `employerProfileProvider(session.employerId)`
- **reads** · `read` → `workerFormsProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `showDatePicker` → `showDatePicker`
- **reads** · `read` → `vacationRequestsProvider`
- **action** · `showFullPhotoRefDialog` → `showFullPhotoRefDialog`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showFullPhotoRefDialog(context, n.photo, label: 'אישור מחלה · ${_fmtDate(n.ts…` → open → showFullPhotoRefDialog

## floor · external functions (11)

- `buildPrintableHtml`
- `confirmDestructive`
- `decodeDataUrlPhoto`
- `employerProfileProvider`
- `imageProviderForRef`
- `onChanged`
- `pickTaskPhoto`
- `printDocument`
- `setState`
- `sort`
- `validIsraeliMobile`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - WelcomeScreen = shared component → separate atom
- **gaps:** 1 unregistered — "📷"
