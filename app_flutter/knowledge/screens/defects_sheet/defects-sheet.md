# _DefectsSheet

- **screen:** `defects_sheet`
- **role:** composer

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "🔧 ליקויים" · `defects_sheet.header` ✅
- **cfgText** "רשימת ליקויים" · `defects_sheet.list_title` ✅
- **cfgText** "אין ליקויים" · `defects_sheet.empty` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `defectsProvider`
- **reads** · `read` → `tasksProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (2)

- `setState`
- `workerIndexForSession`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
