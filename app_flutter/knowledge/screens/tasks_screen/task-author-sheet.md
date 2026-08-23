# _TaskAuthorSheet

- **screen:** `tasks_screen`
- **role:** section

## עצם · object (6)

> registry 0 · mapped 0/0 · **unregistered 6**

- **text** "שם המשימה" · — לא-רשום
- **text** "תיאור" · — לא-רשום
- **text** "שלבי ביצוע — שלב בכל שורה" · — לא-רשום
- **text** "משך משוער (ימים)" · — לא-רשום
- **text** "📅 תאריך התחלה (לגאנט)" · — לא-רשום
- **text** "שיוך לעובד" · — לא-רשום

## חיבורים · connections (3)

- **action** · `showToast` → `showToast`
- **reads** · `read` → `tasksProvider`
- **action** · `showDatePicker` → `showDatePicker`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (3)

- `bsOnAccent`
- `onSelect`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `edit` · `initialWorker`
- **gaps:** 6 unregistered — "שם המשימה" · "תיאור" · "שלבי ביצוע — שלב בכל שורה" · "משך משוער (ימים)" · "📅 תאריך התחלה (לגאנט)" · "שיוך לעובד"
