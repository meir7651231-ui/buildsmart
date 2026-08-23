# _CourierPersonalAreaCard

- **screen:** `courier_profile_screen`
- **role:** section

## עצם · object (12)

> registry 8 · mapped 8/8 · **unregistered 4**

- **text** "🕐" · — לא-רשום
- **cfgText** "נוכחות" · `courier.personal.attendance_title` ✅
- **cfgText** "כניסה/יציאה ודוח חודשי" · `courier_profile_screen.attendance_subtitle` ✅
- **text** "📄" · — לא-רשום
- **cfgText** "טפסים" · `courier.personal.forms_title` ✅
- **cfgText** "טופס 101 · בקשת חופשה · אישור מחלה" · `courier_profile_screen.forms_subtitle` ✅
- **text** "🪪" · — לא-רשום
- **cfgText** "תעודות נהג" · `courier.personal.certs_title` ✅
- **cfgText** "רישיון נהיגה · ביטוח רכב · רישיון רכב" · `courier_profile_screen.certs_subtitle` ✅
- **text** "💰" · — לא-רשום
- **cfgText** "תלושי שכר" · `courier.personal.payslips_title` ✅
- **cfgText** "יחובר עם חיבור השרת" · `courier_profile_screen.payslips_subtitle` ✅

## חיבורים · connections (4)

- **action** · `push` → `CourierAttendanceScreen`
- **action** · `push` → `CourierFormsScreen`
- **action** · `push` → `CourierCertsScreen`
- **action** · `showWorkerPayslipsSheet` → `showWorkerPayslipsSheet`

## התנהגות · behaviour (4)

- **onTap** → _verb_ `Navigator.of(context).push(CourierAttendanceScreen.route())` → navigate → CourierAttendanceScreen
- **onTap** → _verb_ `Navigator.of(context).push(CourierFormsScreen.route())` → navigate → CourierFormsScreen
- **onTap** → _verb_ `Navigator.of(context).push(CourierCertsScreen.route())` → navigate → CourierCertsScreen
- **onTap** → _verb_ `showWorkerPayslipsSheet(context)` → open → showWorkerPayslipsSheet

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 4 unregistered — "🕐" · "📄" · "🪪" · "💰"
