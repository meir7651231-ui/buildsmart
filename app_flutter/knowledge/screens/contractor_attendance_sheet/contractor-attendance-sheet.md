# _ContractorAttendanceSheet

- **screen:** `contractor_attendance_sheet`
- **role:** composer

## עצם · object (5)

> registry 5 · mapped 5/5 · **unregistered 0**

- **cfgText** "🕒 נוכחות עובדים" · `contractor_attendance_sheet.header` ✅
- **cfgText** "מי מהעובדים שלך מחותם כרגע ומי נכח היום (לצפייה בלבד)" · `contractor_attendance_sheet.subtitle` ✅
- **cfgText** "אין עובדים מחותמים כרגע" · `contractor_attendance_sheet.empty_present` ✅
- **cfgText** "היום" · `contractor_attendance_sheet.today` ✅
- **cfgText** "אין נוכחות רשומה היום" · `contractor_attendance_sheet.empty_today` ✅

## חיבורים · connections (1)

- **reads** · `watch` → `attendanceForEmployer(kDemoContractorId)`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (3)

- `attendanceDateKey`
- `attendanceForEmployer`
- `clockedInNow`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
