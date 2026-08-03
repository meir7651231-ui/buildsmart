# _DayDetailSheet

- **screen:** `worker_attendance_screen`
- **role:** section

## עצם · object (5)

> registry 5 · mapped 5/5 · **unregistered 0**

- **cfgText** "📍 לא נרשם מיקום ביום זה" · `worker_attendance_screen.no_loc_day` ✅
- **cfgText** "סיכום עבודה יומי" · `worker_attendance_screen.work_summary` ✅
- **cfgText** "אין פירוט-עבודה משויך ליום זה" · `worker_attendance_screen.no_work_day` ✅
- **cfgVisible** · `worker_attendance_screen.open_nav` ✅
- **cfgText** "מיקום הכניסה — פתח ניווט" · `worker_attendance_screen.open_nav` ✅

## חיבורים · connections (1)

- **action** · `openNavSheet` → `openNavSheet`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `openNavSheet(context, label: label, lat: lat, lng: lng)` → open → openNavSheet

## floor · external functions (2)

- `cfgRadius`
- `mapsQueryForDay`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `day` · `work`
- **gaps:** none (all registry-backed)
