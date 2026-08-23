# _TaskSheet

- **screen:** `tasks_screen`
- **role:** section

## עצם · object (8)

> registry 3 · mapped 3/3 · **unregistered 5**

- **text** "תיאור המשימה" · — לא-רשום
- **text** "שלבי ביצוע" · — לא-רשום
- **text** "תמונת ביצוע" · — לא-רשום
- **text** "הערת העובד" · — לא-רשום
- **text** "דווח על הביצוע" · — לא-רשום
- **cfgText** "העובד הגיש את המשימה. אשר אם בוצעה כראוי, או החזר לתיקון." · `tasks_screen.decide_intro` ✅
- **cfgVisible** · `tasks_screen.sheet_reject` ✅
- **cfgText** "↩️ החזר לתיקון" · `tasks_screen.sheet_reject` ✅

## חיבורים · connections (3)

- **reads** · `watch` → `tasksProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `tasksProvider`

## התנהגות · behaviour (9)

- **onPressed** → _verb_ `showToast(context, 'לא צולמה תמונה')` → toast
- **onPressed** → _verb_ `ref.read(tasksProvider.notifier).attachPhoto(t.id, dataUrl)` → write → tasksProvider
- **onPressed** → _verb_ `showToast(context, '📷 תמונת ההוכחה צורפה')` → toast
- **onTap** → _verb_ `ref.read(tasksProvider.notifier).submitForReview(t.id, note: _note.text)` → write → tasksProvider
- **onTap** → _verb_ `showToast(context, 'נשלח לאישור המנהל ✓')` → toast
- **onPressed** → _verb_ `ref.read(tasksProvider.notifier).reject(t.id, reason: why)` → write → tasksProvider
- **onPressed** → _verb_ `showToast(context, 'המשימה הוחזרה לעובד לתיקון')` → toast
- **onTap** → _verb_ `ref.read(tasksProvider.notifier).approve(t.id)` → write → tasksProvider
- **onTap** → _verb_ `showToast(context, 'המשימה אושרה ✓')` → toast

## floor · external functions (5)

- `bsOnAccent`
- `confirmDestructive`
- `pickTaskPhoto`
- `promptRejectReason`
- `taskPhotoWidget`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `task` · `role`
- **gaps:** 5 unregistered — "תיאור המשימה" · "שלבי ביצוע" · "תמונת ביצוע" · "הערת העובד" · "דווח על הביצוע"
