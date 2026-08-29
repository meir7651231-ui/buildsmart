# WorkerTaskDetailSheet

- **screen:** `worker_task_detail_sheet`
- **role:** composer

## עצם · object (10)

> registry 4 · mapped 4/4 · **unregistered 6**

- **text** "מה להביא" · — לא-רשום
- **cfgText** "אין המלצת ערכת התקנה למוצרי המשימה" · `worker_task_detail_sheet.t09` ✅
- **cfgText** "המשימה לא נמצאה" · `worker_task_detail_sheet.t06` ✅
- **cfgText** "משימה בתור — תעבור לביצוע אוטומטית כשתוגש המשימה הנוכחית." · `worker_task_detail_sheet.t07` ✅
- **text** "תיאור והוראות" · — לא-רשום
- **text** "שלבי ביצוע" · — לא-רשום
- **cfgText** "לא הוגדרו שלבים למשימה זו" · `worker_task_detail_sheet.t08` ✅
- **text** "תמונת ביצוע" · — לא-רשום
- **text** "הערת העובד" · — לא-רשום
- **text** "דווח על הביצוע" · — לא-רשום

## חיבורים · connections (5)

- **reads** · `read` → `tasksProvider`
- **writes** · `state=` → `keyboardJobSkusProvider`
- **action** · `showToast` → `showToast`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **reads** · `watch` → `tasksProvider`

## התנהגות · behaviour (6)

- **onPressed** → _verb_ `showLipskeyProductSheet(context, p, catalogSiblingsFor(p))` → open → showLipskeyProductSheet
- **onTap** → _verb_ `ref.read(tasksProvider.notifier).startWork(t.id)` → write → tasksProvider
- **onTap** → _verb_ `showToast(context, '⏱️ שעון העבודה הופעל')` → toast
- **onPressed** → _verb_ `showToast(context, 'לא צולמה תמונה')` → toast
- **onPressed** → _verb_ `ref.read(tasksProvider.notifier).attachPhoto(t.id, dataUrl)` → write → tasksProvider
- **onPressed** → _verb_ `showToast(context, '📷 תמונת ההוכחה צורפה')` → toast

## floor · external functions (6)

- `catalogSiblingsFor`
- `pickTaskPhoto`
- `productsForTask`
- `recommendedKitForProduct`
- `setState`
- `taskClockLabel`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `taskId`
- **untangle:**
  - onKeyboardJobSkus(…) callback instead of direct keyboardJobSkusProvider write
- **gaps:** 6 unregistered — "מה להביא" · "תיאור והוראות" · "שלבי ביצוע" · "תמונת ביצוע" · "הערת העובד" · "דווח על הביצוע"
