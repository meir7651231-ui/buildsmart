# _EquipmentChecklistSheet

- **screen:** `worker_equipment_checklist_sheet`
- **role:** composer

## עצם · object (7)

> registry 5 · mapped 5/5 · **unregistered 2**

- **cfgText** "🧰 ציוד נדרש להיום" · `worker_equipment_checklist_sheet.t01` ✅
- **cfgText** "רשימת הציוד נגזרת ממיפוי דמו של מוצרים למשימה — תחובר עם השרת" · `worker_equipment_checklist_sheet.t02` ✅
- **text** "צ׳קליסט ציוד" · — לא-רשום
- **cfgText** "אין רשימת ציוד למשימות הנוכחיות" · `worker_equipment_checklist_sheet.t03` ✅
- **text** "משימות ללא רשימת ציוד" · — לא-רשום
- **cfgVisible** · `worker_equipment_checklist_sheet.t04` ✅
- **cfgText** "סגור" · `worker_equipment_checklist_sheet.t04` ✅

## חיבורים · connections (4)

- **action** · `showToast` → `showToast`
- **reads** · `read` → `chatEngineProvider`
- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `employerStockProvider(employerId)`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `availabilityFor`
- `employerStockProvider`
- `productsForTask`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `tasks`
- **gaps:** 2 unregistered — "צ׳קליסט ציוד" · "משימות ללא רשימת ציוד"
