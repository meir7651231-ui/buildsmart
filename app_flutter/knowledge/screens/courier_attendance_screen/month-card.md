# _MonthCard

- **screen:** `courier_attendance_screen`
- **role:** section

## עצם · object (6)

> registry 6 · mapped 6/6 · **unregistered 0**

- **cfgVisible** · `courier.attend.prev` ✅
- **cfgText** "‹ הקודם" · `courier.attend.prev` ✅
- **cfgVisible** · `courier.attend.next` ✅
- **cfgText** "הבא ›" · `courier.attend.next` ✅
- **cfgText** "אין רישומי נוכחות בחודש זה" · `courier.attend.empty` ✅
- **cfgText** "סה"כ חודשי" · `courier.attend.month_total` ✅

## חיבורים · connections (0)

_(no edges)_

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `cell`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `month` · `days` · `total` · `canGoNext` · `onPrev` · `onNext`
- **gaps:** none (all registry-backed)
