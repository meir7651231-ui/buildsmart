# _CalendarCard

- **screen:** `worker_attendance_screen`
- **role:** section

## עצם · object (7)

> registry 6 · mapped 6/6 · **unregistered 1**

- **cfgVisible** · `worker_attendance_screen.prev` ✅
- **cfgText** "‹ הקודם" · `worker_attendance_screen.prev` ✅
- **cfgVisible** · `worker_attendance_screen.next` ✅
- **cfgText** "הבא ›" · `worker_attendance_screen.next` ✅
- **cfgText** "אין רישומי נוכחות בחודש זה" · `worker_attendance_screen.no_records` ✅
- **cfgText** "סה"כ חודשי" · `worker_attendance_screen.month_total` ✅
- **text** "📍" · — לא-רשום

## חיבורים · connections (0)

_(no edges)_

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `attendanceDateKey`
- `cfgRadius`
- `mapsQueryForDay`
- `onTapDay`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `month` · `byKey` · `total` · `dayCount` · `canGoNext` · `onPrev` · `onNext` · `onTapDay`
- **gaps:** 1 unregistered — "📍"
