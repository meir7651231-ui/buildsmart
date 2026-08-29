# _PresentRow

- **screen:** `contractor_attendance_sheet`
- **role:** section

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgVisible** · `contractor_attendance_sheet.location` ✅
- **cfgText** "מיקום הכניסה — פתח ניווט" · `contractor_attendance_sheet.location` ✅

## חיבורים · connections (1)

- **action** · `openNavSheet` → `openNavSheet`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `openNavSheet(context, label: '${day.username} — מיקום כניסה', lat: day.inLat,…` → open → openNavSheet

## floor · external functions (1)

- `mapsQueryForDay`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `day`
- **gaps:** none (all registry-backed)
